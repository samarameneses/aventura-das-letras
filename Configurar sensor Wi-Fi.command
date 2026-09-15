#!/bin/sh
sensor_root="$(cd -- "$(dirname -- "$0")" && pwd)"
"$sensor_root/tools/.sensor-venv/bin/python" "$sensor_root/tools/configure_sensor_wifi.py"
printf '\nPressione Enter para fechar.\n'
read -r sensor_wait
