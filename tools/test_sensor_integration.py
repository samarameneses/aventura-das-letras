"""Exercise the actual Python bridge and Godot receiver over local UDP."""
from godot_runtime import find_godot
import pathlib, subprocess, sys, time, json
root=pathlib.Path(__file__).resolve().parent.parent
with (root/'evidence/sensor-integration.log').open('w') as log:
    godot=subprocess.Popen([find_godot(),'--headless','--path',str(root/'game'),'--script','res://tests/sensor_probe.gd','--','--test'],stdout=log,stderr=log)
    bridge=None
    try:
        time.sleep(0.8)
        bridge=subprocess.Popen([sys.executable,str(root/'tools/sensor_bridge.py'),'--simulate'],stdin=subprocess.PIPE,stdout=log,stderr=log,text=True)
        time.sleep(4.5)
        bridge.stdin.write('j\n');bridge.stdin.flush()
        time.sleep(0.7)
        bridge.terminate();bridge.wait(timeout=3)
        status=godot.wait(timeout=10)
    finally:
        for proc in (bridge,godot):
            if proc and proc.poll() is None:proc.terminate();proc.wait(timeout=3)
print((root/'evidence/sensor-integration.json').read_text())
sys.exit(status)
