#!/usr/bin/env python3
"""Local Wi-Fi setup. Credentials are entered in Terminal and never printed."""
import getpass
import hashlib
import ipaddress
import json
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import sys
import time
from serial.tools import list_ports
from esp32_receiver import SampleGate

ROOT=Path(__file__).resolve().parent.parent
LOCAL=ROOT/'firmware/local'
SKETCH=LOCAL/'wifi_setup/aventura_esp32'
BUILD=ROOT/'firmware/build/aventura_wifi'
CORE=ROOT/'tools/arduino-data/packages/esp32/hardware/esp32/2.0.17'

def mac_ip():
    value=subprocess.check_output(['/usr/sbin/ipconfig','getifaddr','en0'],text=True).strip()
    address=ipaddress.IPv4Address(value)
    if address.is_loopback or address.is_unspecified:raise ValueError('Mac sem endereço de rede.')
    return str(address)

def prepare_sketch(ssid,password,address):
    if not 1<=len(ssid.encode('utf-8'))<=32:raise ValueError('O nome da rede deve ter de 1 a 32 bytes.')
    if not (8<=len(password.encode('utf-8'))<=63 or (len(password)==64 and all(c in '0123456789abcdefABCDEF' for c in password))):
        raise ValueError('Use a senha WPA/WPA2 da rede (normalmente de 8 a 63 caracteres).')
    ipaddress.IPv4Address(address)
    token=(LOCAL/'pairing-token.txt').read_text().strip()
    if len(token)<32 or any(c not in '0123456789abcdef' for c in token):raise ValueError('Pareamento local inválido.')
    SKETCH.mkdir(parents=True,exist_ok=True)
    shutil.copy2(ROOT/'firmware/aventura_esp32/aventura_esp32.ino',SKETCH/'aventura_esp32.ino')
    settings={'IMU_SDA_PIN':21,'IMU_SCL_PIN':22,'USE_WIFI':True,'WIFI_SSID':ssid,
              'WIFI_PASSWORD':password,'MAC_IP':address,'PAIR_TOKEN':token}
    config=SKETCH/'config.h'
    config.write_text('#pragma once\n'+''.join('#define '+k+' '+json.dumps(v)+'\n' for k,v in settings.items()))
    config.chmod(0o600)
    return token

def compile_wifi(log):
    subprocess.run([str(ROOT/'tools/arduino-cli/arduino-cli'),'--config-file',str(ROOT/'tools/arduino-cli/arduino-cli.yaml'),
        'compile','--fqbn','esp32:esp32:esp32','--build-path',str(BUILD),
        '--build-property','runtime.tools.esptool_py.path='+str(ROOT/'tools/.sensor-venv/bin'),str(SKETCH)],
        stdout=log,stderr=log,check=True)

def segments(folder):
    return [(0x1000,folder/'aventura_esp32.ino.bootloader.bin'),(0x8000,folder/'aventura_esp32.ino.partitions.bin'),
            (0xe000,CORE/'tools/partitions/boot_app0.bin'),(0x10000,folder/'aventura_esp32.ino.bin')]

def flash(port,folder,log):
    command=[sys.executable,'-m','esptool','--chip','esp32','--port',port,'--baud','230400','write-flash']
    for offset,file in segments(folder):command.extend([hex(offset),str(file)])
    subprocess.run(command,stdout=log,stderr=log,check=True)

def stop_game_connection():
    # Stop only this project's sensor games; their launchers close their receiver.
    processes=subprocess.check_output(['ps','-axo','pid=,command='],text=True)
    for line in processes.splitlines():
        parts=line.strip().split(None,1)
        if len(parts)!=2:continue
        command=parts[1]
        if command.startswith(str(ROOT/'tools/runtime/Godot.app/Contents/MacOS/Godot')) and '--sensor-usb' in command:
            os.kill(int(parts[0]),signal.SIGTERM)
    time.sleep(1)

def verify_wifi(listener,token):
    gate=SampleGate(token);deadline=time.monotonic()+45;count=0;peer_ip=None
    listener.settimeout(.5)
    while time.monotonic()<deadline:
        try:body,peer=listener.recvfrom(1024)
        except socket.timeout:continue
        if gate.accept(body,peer[0],time.monotonic()) is not None:
            count+=1;peer_ip=peer[0]
            if count>=100:return peer_ip,count
    return None,count

def main():
    os.umask(0o077)
    print('\nCONFIGURAR O SENSOR SEM FIO\n')
    print('Mantenha a ESP32 ligada ao Mac por USB durante toda a configuração.')
    print('Escolha a rede doméstica com 2,4 GHz, na mesma rede local do Mac.\n')
    ports=[p.device for p in list_ports.comports() if p.vid==0x10C4 and p.pid==0xEA60]
    if len(ports)!=1:raise ValueError('Conecte somente a ESP32 do jogo por USB e tente novamente.')
    address=mac_ip()
    ssid=input('Nome do Wi-Fi: ')
    password=getpass.getpass('Senha do Wi-Fi (não aparece enquanto você digita): ')
    token=prepare_sketch(ssid,password,address)
    usb=ROOT/'firmware/build/aventura_esp32'
    expected=json.loads((ROOT/'evidence/esp32-usb-firmware.json').read_text())['binary_sha256']
    if hashlib.sha256((usb/'aventura_esp32.ino.bin').read_bytes()).hexdigest()!=expected:
        raise ValueError('A cópia USB de recuperação precisa ser conferida antes de continuar. Avise o assistente.')
    for _,path in segments(usb):
        if not path.exists():raise ValueError('Arquivo de recuperação USB ausente. Avise o assistente.')
    log_path=LOCAL/'wifi-setup.log'
    with log_path.open('w') as log:
        print('\nPreparando o programa. Aguarde e mantenha o cabo conectado.',flush=True)
        compile_wifi(log)
        print('Programa pronto. Vou fechar o jogo e gravar a ESP32.',flush=True)
        stop_game_connection()
        with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as listener:
            listener.bind((address,9251))
            try:
                flash(ports[0],BUILD,log)
                print('Gravação concluída. Testando o envio pelo Wi-Fi…',flush=True)
                peer,count=verify_wifi(listener,token)
                if peer is None:raise RuntimeError('Nenhuma sequência suficiente de dados válidos chegou pelo Wi-Fi.')
            except (subprocess.CalledProcessError,RuntimeError):
                print('O teste Wi-Fi não concluiu. Vou restaurar o funcionamento por USB.',flush=True)
                flash(ports[0],usb,log)
                (LOCAL/'wifi-settings.json').write_text(json.dumps({'verified':False,'reason':'USB restored'})+'\n')
                print('USB restaurado. Confira nome, senha e rede de 2,4 GHz antes de tentar novamente.')
                return 1
    metadata={'verified':True,'mac_ip':address,'esp_ip':peer,'samples':count,'verified_at':time.time()}
    (LOCAL/'wifi-settings.json').write_text(json.dumps(metadata,indent=2)+'\n')
    (ROOT/'evidence/esp32-wifi-setup.json').write_text(json.dumps({'verified':True,'samples':count,'physical_sensor':True,'usb_power_still_connected':True},indent=2)+'\n')
    print('\nWI-FI FUNCIONANDO! Os movimentos chegaram ao Mac sem usar os dados do cabo.')
    print('O jogo vai abrir. Deixe o sensor parado e clique em Jogar com sensor.')
    print('Para tirar o cabo do Mac depois, use o power bank na entrada USB da ESP32.')
    return subprocess.call([sys.executable,str(ROOT/'tools/play_sensor_usb.py'),'--wifi'])

if __name__=='__main__':
    try:raise SystemExit(main())
    except (KeyboardInterrupt,EOFError):
        print('\nConfiguração interrompida. Se a gravação estava em andamento, mantenha a USB conectada e avise o assistente.')
        raise SystemExit(1)
    except (ValueError,OSError,subprocess.CalledProcessError):
        print('\nNão foi possível concluir. Mantenha a ESP32 conectada e avise o assistente para conferir o registro local.')
        raise SystemExit(1)
