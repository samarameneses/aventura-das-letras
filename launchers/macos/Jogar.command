#!/bin/sh
set -eu
game_dir="$(cd -- "$(dirname -- "$0")/../.." && pwd)"
exec python3 "$game_dir/tools/run_game.py" "$@"
