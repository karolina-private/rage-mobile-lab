#!/usr/bin/env bash
# Remove a stale jemalloc archive reference when FEX is built for iOS.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Madeira" >&2
  exit 64
fi

project="$1/app/Madeira.xcodeproj/project.pbxproj"
if [[ ! -f "$project" ]]; then
  echo "Madeira Xcode project not found: $project" >&2
  exit 66
fi

python3 - "$project" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
markers = (
    'A1000017 /* libJemallocLibs.a in Frameworks */',
    'A2000017 /* libJemallocLibs.a */',
)
if not any(marker in text for marker in markers):
    print(f"Already patched: {path}")
    raise SystemExit(0)

lines = text.splitlines(keepends=True)
filtered = [line for line in lines if not any(marker in line for marker in markers)]
path.write_text(''.join(filtered))
print(f"Patched: {path}")
PY
