"""Check versioned/candidate files without printing matched secret values.

Use alongside Gitleaks and human review. This is a publication guard, not a
comprehensive security audit. Ignored private files are never read.
"""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
PRIVATE_PREFIXES = ("references/", "evidence/", "firmware/local/", "firmware/build/",
                    "tools/runtime/", "tools/arduino-", "tools/.sensor-venv/",
                    "release/", ".publication-private/")
PRIVATE_FILES = {"firmware/aventura_esp32/config.h", "COMO-RETOMAR-PROJETO.md"}
PATTERNS = {
    "private key": rb"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----",
    "GitHub token": rb"(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})",
    "OpenAI token": rb"sk-(?:proj-|svcacct-)[A-Za-z0-9_-]{30,}",
    "AWS access key": rb"(?:AKIA|ASIA)[A-Z0-9]{16}",
    "personal absolute path": rb"/(?:Users|home)/[A-Za-z0-9_.-]+/",
}

def main():
    output = subprocess.check_output(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=ROOT)
    files = sorted(set(p for p in output.decode().split("\0") if p))
    failures = []
    total = 0
    for name in files:
        p = ROOT / name
        if name in PRIVATE_FILES or name.startswith(PRIVATE_PREFIXES) or (p.name.startswith(".env") and p.name != ".env.example"):
            failures.append((name, "private path"))
            continue
        if p.is_symlink():
            failures.append((name, "symlink requires explicit review"))
            continue
        if not p.is_file():
            continue
        data = p.read_bytes()
        total += len(data)
        if len(data) > 50 * 1024 * 1024:
            failures.append((name, "file exceeds 50 MiB"))
        for label, pattern in PATTERNS.items():
            if re.search(pattern, data):
                failures.append((name, label))
    for name, label in failures:
        print("BLOCKED:", name, "—", label)
    print(f"Publication check: {len(files)} files, {total / 1024 / 1024:.1f} MiB, {len(failures)} findings.")
    return 1 if failures else 0

if __name__ == "__main__":
    sys.exit(main())
