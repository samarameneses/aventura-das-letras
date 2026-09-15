#!/usr/bin/env python3
"""Local protocol bridge. Simulation is a bench test, never a gesture detector.

--simulate: J + Enter sends a simulated jump after three-second calibration.
--stdin: reads adapter JSON lines with event, sent_at_ms and stable (for ready).
The hardware adapter is responsible for real stillness/gesture recognition.
"""
import argparse
import json
import select
import socket
import sys
import time
import uuid

ADDRESS = ('127.0.0.1', 9250)

class Bridge:
    def __init__(self, device='bench-simulator'):
        self.device = device
        self.challenge = None
        self.session = uuid.uuid4().hex
        self.sequence = 0
        self.event_id = 0

    def set_challenge(self, challenge):
        if not isinstance(challenge, str) or len(challenge) != 24:
            return False
        if challenge == self.challenge:
            return False
        self.challenge = challenge
        self.session = uuid.uuid4().hex
        self.sequence = self.event_id = 0
        return True

    def packet(self, event, **extra):
        self.sequence += 1
        result = dict(protocol_version=1, challenge=self.challenge,
                      session_id=self.session, device_id=self.device,
                      sequence=self.sequence, sent_at_ms=time.time()*1000,
                      event=event)
        if event == 'jump':
            self.event_id += 1
            result['event_id'] = self.event_id
        result.update(extra)
        return result

def valid_adapter_event(value, now_ms):
    if not isinstance(value, dict):
        return False
    stamp = value.get('sent_at_ms')
    if not isinstance(stamp, (float, int)) or not 0 <= now_ms-stamp <= 150:
        return False
    return value.get('event') in ('calibration_start', 'ready', 'jump', 'heartbeat')

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument('--simulate', action='store_true')
    modes.add_argument('--stdin', action='store_true')
    parser.add_argument('--device', default='external-adapter')
    args = parser.parse_args()
    bridge = Bridge('bench-simulator' if args.simulate else args.device)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('127.0.0.1', 0))
    sock.setblocking(False)
    started = None
    ready = False
    hello_at = heartbeat_at = 0.0
    adapter_last_seen = 0.0
    def send(event, **extra):
        sock.sendto(json.dumps(bridge.packet(event, **extra)).encode(), ADDRESS)
    print('Abra Com sensor no jogo. Ctrl+C encerra.', file=sys.stderr)
    if args.simulate:
        print('SIMULAÇÃO: não usa nem valida o sensor físico. J + Enter = salto.', file=sys.stderr)
    try:
        while True:
            now = time.monotonic()
            if now-hello_at > 0.5:
                sock.sendto(b'{"event":"hello"}', ADDRESS)
                hello_at = now
            readable, _, _ = select.select([sock, sys.stdin], [], [], 0.02)
            if sock in readable:
                payload, address = sock.recvfrom(1024)
                if address != ADDRESS:
                    continue
                try:
                    response = json.loads(payload)
                except (ValueError, UnicodeError):
                    continue
                if response.get('event') == 'challenge' and bridge.set_challenge(response.get('challenge')):
                    ready = False
                    started = now if args.simulate else None
                    adapter_last_seen = 0
                    if args.simulate:
                        send('calibration_start')
                    else:
                        print('Nova conexão: adaptador deve reiniciar a calibração.', file=sys.stderr)
            if sys.stdin in readable:
                line = sys.stdin.readline()
                if not line:
                    break  # EOF must never leave heartbeats running.
                if args.simulate:
                    if line.strip().lower() == 'j' and ready:
                        send('jump')
                else:
                    try:
                        value = json.loads(line)
                    except ValueError:
                        continue
                    if not bridge.challenge or not valid_adapter_event(value, time.time()*1000):
                        continue
                    event = value['event']
                    adapter_last_seen = now
                    if event == 'calibration_start':
                        started = now; ready = False; send(event)
                    elif event == 'ready' and started and now-started >= 3 and value.get('stable') is True:
                        ready = True; send(event, stable=True)
                    elif event == 'jump' and ready:
                        send(event, sent_at_ms=value['sent_at_ms'])
            if args.simulate and started and now-started >= 3.1 and not ready:
                send('ready', stable=True);ready = True
                print('Simulador pronto.', file=sys.stderr)
            alive = args.simulate or now-adapter_last_seen < 0.3
            if bridge.challenge and started and alive and now-heartbeat_at > 0.1:
                send('heartbeat');heartbeat_at = now
    except KeyboardInterrupt:
        pass
    finally:
        sock.close()

if __name__ == '__main__':
    main()
