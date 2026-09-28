#!/usr/bin/env bash
# Put Wine config.h before Madeira's auxiliary configuration header.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Madeira" >&2
  exit 64
fi

source_file="$1/wine/dlls/ntdll/unix/sync.c"
[[ -f "$source_file" ]] || { echo "Wine sync source not found: $source_file" >&2; exit 66; }

python3 - "$source_file" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = '''#include "../../../../build/madeira_cfg.h"   /* ml1122: before the Wine headers, which ban strncpy by macro */
#include "config.h"
'''
new = '''#include "config.h"
#include "../../../../build/madeira_cfg.h"   /* ml1122: before the Wine headers, which ban strncpy by macro */
'''
if new in text:
    print(f"Already patched: {path}")
elif old in text:
    path.write_text(text.replace(old, new, 1))
    print(f"Patched: {path}")
else:
    raise SystemExit("Expected include order was not found; refusing to edit an unknown Wine revision.")
PY
