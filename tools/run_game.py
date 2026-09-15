"""Run the current Godot source project."""
import subprocess
import sys
from godot_runtime import ROOT, find_godot

if __name__ == "__main__":
    try:
        godot = find_godot()
        subprocess.run([godot, "--headless", "--path", str(ROOT / "game"), "--editor", "--import"], check=True)
        raise SystemExit(subprocess.call([godot, "--path", str(ROOT / "game"), *sys.argv[1:]]))
    except (FileNotFoundError, subprocess.CalledProcessError) as error:
        print(str(error), file=sys.stderr)
        raise SystemExit(1)
