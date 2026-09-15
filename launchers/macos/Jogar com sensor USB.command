#!/bin/sh
sensor_root="$(cd -- "$(dirname -- "$0")/../.." && pwd)"
"$sensor_root/tools/.sensor-venv/bin/python" "$sensor_root/tools/play_sensor_usb.py"
if [ "$?" -ne 0 ]; then
  printf '\nPressione Enter para fechar.\n'
  read -r sensor_wait
fi
