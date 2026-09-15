#!/usr/bin/env python3
"""ESP32 raw IMU -> detector -> existing Godot local protocol. No cloud service."""
import argparse
import hmac
import json
import math
import select
import socket
import sys
import time
from pathlib import Path
from imu_detector import JumpDetector
from sensor_bridge import Bridge, ADDRESS

class SampleGate:
    def __init__(self, token):
        self.token = token
        self.reset()

    def reset(self):
        self.identity = None
        self.sequence = -1
        self.device_ms = None
        self.last_arrival = None
        self.clock_offset = None

    def accept(self, payload, source, now):
        if len(payload) > 512:
            return None
        try:
            p = json.loads(payload)
            if not isinstance(p, dict) or p.get('v') != 1:
                return None
            token = p.get('token', '')
            if not isinstance(token, str) or not hmac.compare_digest(token, self.token):
                return None
            if not all(isinstance(p.get(k), str) and 1 <= len(p[k]) <= 32 for k in ('device', 'boot')):
                return None
            if any(type(p.get(k)) is not int or not 0 <= p[k] <= 0xffffffff for k in ('seq', 'ms')):
                return None
            for key, limit in [('a', 5), ('g', 600)]:
                if not isinstance(p.get(key), list) or len(p[key]) != 3:
                    return None
                if any(type(x) not in (float, int) or not math.isfinite(x) or abs(x)>limit for x in p[key]):
                    return None
        except (ValueError, TypeError, UnicodeError):
            return None
        identity = (source, p['device'], p['boot'])
        if self.identity is not None and identity != self.identity:
            return None
        if p['seq'] <= self.sequence:
            return None
        if self.device_ms is not None and p['ms'] <= self.device_ms:
            return None  # A reboot/wrap needs a new calibrated session.
        offset = now-p['ms']/1000.0
        if self.clock_offset is None:
            self.clock_offset = offset
        else:
            self.clock_offset = min(self.clock_offset, offset)
        if offset-self.clock_offset > .15:
            return None
        self.identity = identity
        self.sequence, self.device_ms = p['seq'], p['ms']
        self.last_arrival = now
        return p

class Receiver:
    def __init__(self, token, send, trace=None):
        self.gate = SampleGate(token)
        self.detector = JumpDetector()
        self.bridge = Bridge('esp32')
        self.send = send
        self.trace = trace
        self.started = False
        self.last_heartbeat = 0.0
        self.last_ready = float('-inf')

    def reset_detector(self):
        self.detector.reset()
        self.started = False
        self.last_ready = float('-inf')

    def challenge(self, value):
        if self.bridge.set_challenge(value):
            self.reset_detector()

    def emit(self, event, **extra):
        self.send(self.bridge.packet(event, **extra))

    def sample(self, payload, source, now):
        p = self.gate.accept(payload, source, now)
        if p is None or not self.bridge.challenge:
            return None
        # A fresh reading is the sole source of liveness, never a timer alone.
        if not self.started:
            self.bridge.device = p['device']
            self.emit('calibration_start')
            self.started = True
        was_ready = self.detector.ready
        # Measure gesture duration on the sensor clock. Wi-Fi can deliver fresh
        # samples in bursts; arrival time remains the gate/liveness clock only.
        event = self.detector.feed(p['a'], p['g'], p['ms']/1000.0)
        if self.trace is not None:
            self.trace({'kind':'sample','wall_ms':time.time()*1000,'device_ms':p['ms'],
                'a':p['a'],'g':p['g'],'ready':self.detector.ready,
                'baseline':self.detector.baseline,'event':event,
                'impulse_at':self.detector.impulse_at,'low_at':self.detector.low_at,
                'arrival_excess_ms':max(0,(now-p['ms']/1000.0-self.gate.clock_offset)*1000)})
        if was_ready and not self.detector.ready:
            self.emit('calibration_start')
        if event == 'ready':
            print('Sensor calibrado. Entre no jogo.', flush=True)
        elif event == 'jump':
            self.emit('jump')
            print('Salto detectado.', flush=True)
        # Godot may receive the first ready just before its own 3 s minimum,
        # or lose a UDP packet. Retry only while fresh IMU data remains calibrated.
        if self.detector.ready and (event == 'ready' or now-self.last_ready >= .5):
            self.emit('ready', stable=True)
            self.last_ready = now
        if now-self.last_heartbeat >= .1:
            self.emit('heartbeat')
            self.last_heartbeat = now
        return event

    def tick(self, now):
        seen = self.gate.last_arrival
        if seen is not None and now-seen > JumpDetector.CONNECTION_GAP_SECONDS:
            self.reset_detector()
            # Keep identity/sequence for 2 s to reject stale packets during a brief drop.
            if now-seen > 2:
                self.gate.reset()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--wifi', action='store_true')
    mode.add_argument('--usb', metavar='PORT')
    parser.add_argument('--token-file', required=True)
    parser.add_argument('--bind', default='0.0.0.0')
    parser.add_argument('--port', type=int, default=9251)
    parser.add_argument('--trace-file', help='Optional local motion-only JSONL capture (no pairing key)')
    parser.add_argument('--trace-seconds',type=int,default=180,choices=range(1,901),metavar='1..900',help='Bounded capture duration, starting at the first recorded event')
    args = parser.parse_args()
    token = Path(args.token_file).read_text().strip()
    if len(token)<32 or not all(c in '0123456789abcdef' for c in token):
        parser.error('Use uma chave hexadecimal aleatória com pelo menos 32 caracteres.')
    local = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    local.bind(('127.0.0.1',0));local.setblocking(False)
    trace_file = None
    trace_until = None
    if args.trace_file:
        trace_path=Path(args.trace_file);trace_path.parent.mkdir(parents=True,exist_ok=True)
        trace_file=trace_path.open('w');trace_path.chmod(0o600)
    def trace(row):
        nonlocal trace_until
        if trace_file is not None and trace_until is None:trace_until=time.monotonic()+args.trace_seconds
        if trace_file is not None and time.monotonic()<trace_until:
            trace_file.write(json.dumps(row)+'\n')
            if row.get('event') or row.get('kind')=='sent':trace_file.flush()
    def send(packet):
        local.sendto(json.dumps(packet).encode(),ADDRESS)
        if packet['event'] in ('jump','calibration_start','ready'):
            trace({'kind':'sent','wall_ms':time.time()*1000,'event':packet['event'],'event_id':packet.get('event_id')})
    receiver = Receiver(token, send, trace if trace_file is not None else None)
    source = None
    try:
        if args.wifi:
            source = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
            source.bind((args.bind,args.port));source.setblocking(False)
        else:
            try:
                import serial
            except ImportError:
                parser.error('USB requer pyserial. Consulte docs/SENSOR.md.')
            source = serial.Serial(args.usb,230400,timeout=0)
            source.reset_input_buffer()
        print('Abra Com sensor no jogo e mantenha o dispositivo parado por três segundos.',flush=True)
        hello = 0.0
        buffer = b''
        while True:
            now = time.monotonic();receiver.tick(now)
            if now-hello >= .5:
                local.sendto(b'{"event":"hello"}',ADDRESS);hello=now
            readable,_,_ = select.select([local,source],[],[],.02)
            if local in readable:
                body,peer = local.recvfrom(1024)
                if peer == ADDRESS:
                    try:
                        p=json.loads(body)
                        if isinstance(p,dict) and p.get('event')=='challenge':receiver.challenge(p.get('challenge'))
                    except (ValueError,UnicodeError):pass
            if source in readable:
                if args.wifi:
                    # Bound per-cycle work prevents a burst from starving game liveness.
                    for _ in range(64):
                        try:body,peer=source.recvfrom(1024)
                        except BlockingIOError:break
                        receiver.sample(body,peer[0],time.monotonic())
                else:
                    buffer+=source.read(max(1,min(source.in_waiting,8192)))
                    if len(buffer)>16384:buffer=b'';receiver.reset_detector()
                    while b'\n' in buffer:
                        line,buffer=buffer.split(b'\n',1)
                        receiver.sample(line,'usb',time.monotonic())
    except KeyboardInterrupt:
        print('\nReceptor encerrado. O jogo oferece continuar pelos botões.')
    finally:
        if source is not None:source.close()
        local.close()
        if trace_file is not None:trace_file.close()

if __name__=='__main__':main()
