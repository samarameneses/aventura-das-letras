#!/bin/sh
sensor_root="$(cd -- "$(dirname -- "$0")/../.." && pwd)"
if [ ! -f "$sensor_root/firmware/local/pairing-token.txt" ]; then
  echo 'Primeiro configure e grave o ESP32. Consulte docs/SENSOR.md.'
  read -r sensor_wait
  exit 1
fi
python3 "$sensor_root/tools/esp32_receiver.py" --wifi --token-file "$sensor_root/firmware/local/pairing-token.txt"
printf '\nPressione Enter para fechar.\n'
read -r sensor_wait
