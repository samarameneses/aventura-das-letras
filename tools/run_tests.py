"""Run synthetic tests without touching a player's saved progress or hardware."""
import subprocess
import sys
from godot_runtime import ROOT, find_godot

# Deterministic 60 Hz simulation runs without real-time pacing.
# Hardware and screenshot labs run separately.
GODOT_TESTS = ["curriculum", "speedrun", "gentle_flow",
               "powers_continuity", "adventure_terrain", "player_fast_fall",
               "sensor_game_jump", "sensor_repeat_jumps", "sensor_wifi_timeout", "answer_feedback", "acceptance"]

def run(command, timeout=360):
    subprocess.run(command, cwd=ROOT, check=True, timeout=timeout)

def main():
    godot = find_godot()
    (ROOT / "evidence").mkdir(exist_ok=True)
    for suite in ["test_sensor_bridge.py", "test_esp32_receiver.py"]:
        run([sys.executable, "-m", "unittest", "discover", "-s", "tools", "-p", suite, "-v"])
    run([godot, "--headless", "--path", str(ROOT / "game"), "--editor", "--import", "--log-file", str(ROOT / "evidence/import.log")])
    for test in GODOT_TESTS:
        print("Running Godot test:", test, flush=True)
        run([godot, "--headless", "--fixed-fps", "60", "--path", str(ROOT / "game"),
             "--log-file", str(ROOT / ("evidence/" + test + ".log")),
             "--script", "res://tests/" + test + ".gd", "--", "--test"])
    print("All selected tests passed.")

if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.SubprocessError) as error:
        print(str(error), file=sys.stderr)
        raise SystemExit(1)
