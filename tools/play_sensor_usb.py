#!/usr/bin/env python3
"""Open the local game and keep its USB motion receiver alive until the game closes."""
from godot_runtime import find_godot
from pathlib import Path
import socket
import subprocess
import sys
import json
from serial.tools import list_ports

root = Path(__file__).resolve().parent.parent

def main():
    token = root / 'firmware/local/pairing-token.txt'
    if not token.exists():
        print('A placa ainda precisa ser configurada e gravada.')
        return 1
    wifi = '--wifi' in sys.argv[1:]
    ports = [] if wifi else [p.device for p in list_ports.comports() if p.vid == 0x10C4 and p.pid == 0xEA60]
    if not wifi and len(ports) != 1:
        print('Conecte somente a ESP32 do jogo por USB e abra este atalho novamente.')
        return 1
    if wifi:
        from configure_sensor_wifi import mac_ip
        settings_path=root/'firmware/local/wifi-settings.json'
        settings=json.loads(settings_path.read_text()) if settings_path.exists() else {}
        if not settings.get('verified'):
            print('Abra primeiro Configurar sensor Wi-Fi.command com a ESP32 ligada por USB.')
            return 1
        try: address=mac_ip()
        except (OSError,ValueError,subprocess.CalledProcessError):
            print('Conecte este Mac ao Wi-Fi antes de abrir o jogo.');return 1
        if address!=settings.get('mac_ip'):
            print('O endereço do Mac mudou. Abra Configurar sensor Wi-Fi.command para atualizar a ESP32.')
            return 1
    probe = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        probe.bind(('127.0.0.1', 9250))
    except OSError:
        print('Já existe uma conexão de sensor aberta. Feche esse jogo antes de abrir outro.')
        return 1
    finally:
        probe.close()
    receiver = game = None
    diagnostic = '--diagnose' in sys.argv[1:]
    try:
        receiver_args=[sys.executable, str(root/'tools/esp32_receiver.py'),
            '--token-file', str(token)]+(['--wifi','--bind',address] if wifi else ['--usb',ports[0]])
        if diagnostic:receiver_args+=['--trace-file',str(root/'firmware/local/motion-trace.jsonl')]
        receiver = subprocess.Popen(receiver_args)
        game = subprocess.Popen([find_godot(),
            '--path', str(root/'game'), '--', '--sensor-usb', '--speed-run']+
            (['--sensor-diagnostics'] if diagnostic else []))
        print('Deixe o sensor parado. Quando estiver pronto, clique em Jogar com sensor.', flush=True)
        while True:
            try:
                return game.wait(timeout=.5)
            except subprocess.TimeoutExpired:
                if receiver.poll() is not None:
                    print('A conexão do sensor terminou. No jogo, você pode continuar pelos botões.', flush=True)
                    return game.wait()
    except KeyboardInterrupt:
        return 0
    finally:
        for process in (game, receiver):
            if process is not None and process.poll() is None:
                process.terminate()
                try: process.wait(timeout=4)
                except subprocess.TimeoutExpired: process.kill(); process.wait()

if __name__ == '__main__':
    raise SystemExit(main())
