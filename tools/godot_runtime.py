"""Find an installed Godot editor without requiring a bundled executable."""
import os
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parent.parent

def find_godot():
    override = os.environ.get("GODOT_BIN")
    candidates = [override] if override else [
        shutil.which("godot"), shutil.which("godot4"),
        "/Applications/Godot.app/Contents/MacOS/Godot",
        str(ROOT / "tools/runtime/Godot.app/Contents/MacOS/Godot"),
    ]
    for candidate in candidates:
        if candidate:
            path = Path(candidate).expanduser()
            if path.is_file() and os.access(path, os.X_OK):
                return str(path.resolve())
    raise FileNotFoundError("Instale Godot 4.7.2 e defina GODOT_BIN com o caminho do executável.")
