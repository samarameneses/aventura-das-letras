"""Actual UDP raw-sample receiver -> Godot. Synthetic data; no hardware is exercised."""
from godot_runtime import find_godot
import json
import pathlib
import socket
import subprocess
import sys
import tempfile
import time
from test_esp32_receiver import sample, TOKEN

root=pathlib.Path(__file__).resolve().parent.parent
processes=[]
# Do not take over an occupied game receiver.
probe=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
probe.bind(('127.0.0.1',9250));probe.close()
with tempfile.TemporaryDirectory() as tmp, (root/'evidence/esp32-integration.log').open('w') as log:
    token=pathlib.Path(tmp)/'token';token.write_text(TOKEN)
    try:
        godot=subprocess.Popen([find_godot(),'--headless','--path',str(root/'game'),'--script','res://tests/sensor_probe.gd','--','--test'],stdout=log,stderr=log)
        processes.append(godot);time.sleep(.5)
        adapter=subprocess.Popen([sys.executable,str(root/'tools/esp32_receiver.py'),'--wifi','--bind','127.0.0.1','--port','19251','--token-file',str(token)],stdout=log,stderr=log)
        processes.append(adapter);time.sleep(.6)
        sock=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
        wave=[1.0]*380+[1.65]*6+[.5]*10+[1.9]*6+[1.0]*80
        started=time.monotonic()
        for n,a in enumerate(wave):
            target=started+n*.01
            time.sleep(max(0,target-time.monotonic()))
            sock.sendto(sample(n+1,n*10,acc=a),('127.0.0.1',19251))
        sock.close()
        # Leave adapter running: absence of IMU samples, not adapter shutdown, must disconnect.
        status=godot.wait(timeout=6)
        result=json.loads((root/'evidence/sensor-integration.json').read_text())
        result['transport']='synthetic raw IMU -> UDP -> ESP32 receiver/detector -> UDP -> actual Godot receiver'
        result['firmware_compiled']=False
        (root/'evidence/esp32-integration.json').write_text(json.dumps(result,indent=2)+'\n')
        print(json.dumps(result,indent=2))
    finally:
        for process in processes:
            if process.poll() is None:process.terminate();process.wait(timeout=4)
raise SystemExit(status)
