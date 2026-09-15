#!/usr/bin/env python3
"""Create local firmware settings. Does not install, compile or flash anything."""
import argparse
import getpass
import ipaddress
import json
import os
from pathlib import Path
import secrets

root=Path(__file__).resolve().parent.parent
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--sda',type=int,required=True,help='Confirmed SDA GPIO from your board/wiring')
parser.add_argument('--scl',type=int,required=True,help='Confirmed SCL GPIO from your board/wiring')
parser.add_argument('--wifi',action='store_true')
parser.add_argument('--mac-ip',default='192.168.1.100')
args=parser.parse_args()
if args.sda==args.scl or not 0<=args.sda<=48 or not 0<=args.scl<=48:
    parser.error('Informe dois GPIOs diferentes confirmados para sua placa; a ferramenta não valida a pinagem elétrica.')
ipaddress.IPv4Address(args.mac_ip)
folder=root/'firmware/local';folder.mkdir(exist_ok=True,mode=0o700)
token_file=folder/'pairing-token.txt'
if token_file.exists():token=token_file.read_text().strip()
else:
    token=secrets.token_hex(16)
    token_file.write_text(token+'\n');os.chmod(token_file,0o600)
ssid=input('Nome da rede Wi-Fi: ') if args.wifi else ''
password=getpass.getpass('Senha do Wi-Fi (fica somente no arquivo local): ') if args.wifi else ''
values={'IMU_SDA_PIN':args.sda,'IMU_SCL_PIN':args.scl,'USE_WIFI':args.wifi,'WIFI_SSID':ssid,'WIFI_PASSWORD':password,'MAC_IP':args.mac_ip,'PAIR_TOKEN':token}
config=root/'firmware/aventura_esp32/config.h'
config.write_text('#pragma once\n// Private local settings: do not share this file.\n'+''.join('#define '+key+' '+json.dumps(value,ensure_ascii=True)+'\n' for key,value in values.items()))
os.chmod(config,0o600)
print('Configuração local criada. O ESP32 ainda precisa ser compilado e gravado com o modelo correto de placa.')
