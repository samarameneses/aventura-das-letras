"""Run the bounded physical Wi-Fi experiment without changing family progress."""
import json
import subprocess
import sys
from configure_sensor_wifi import ROOT, LOCAL, mac_ip, stop_game_connection

def main():
    engine=ROOT/'tools/runtime/Godot.app/Contents/MacOS/Godot'
    address=mac_ip()
    settings=json.loads((LOCAL/'wifi-settings.json').read_text())
    if not settings.get('verified') or settings.get('mac_ip')!=address:
        raise SystemExit('A configuração Wi-Fi precisa ser conferida.')
    stop_game_connection()
    children=[]
    try:
        children.append(subprocess.Popen([sys.executable,str(ROOT/'tools/esp32_receiver.py'),
            '--wifi','--bind',address,'--token-file',str(LOCAL/'pairing-token.txt'),
            '--trace-file',str(LOCAL/'latency-motion.jsonl'),'--trace-seconds','900']))
        children.append(subprocess.Popen([str(engine),
            '--path',str(ROOT/'game'),'res://tests/sensor_latency_lab.tscn','--',
            '--sensor-usb','--sensor-diagnostics','--sensor-latency-lab']+
            (['--lab-preview'] if '--preview' in sys.argv else [])))
        return children[-1].wait()
    finally:
        for child in reversed(children):
            if child.poll() is None:
                child.terminate()
                try:child.wait(timeout=4)
                except subprocess.TimeoutExpired:child.kill();child.wait()

if __name__=='__main__':
    try:raise SystemExit(main())
    except KeyboardInterrupt:pass
