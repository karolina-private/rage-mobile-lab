#!/usr/bin/env bash
# Make Madeira's optional macOS telemetry compile against current iPhone SDKs.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Madeira" >&2
  exit 64
fi

source_file="$1/build/ntdll-unix/server_ios.c"
[[ -f "$source_file" ]] || { echo "Madeira server source not found: $source_file" >&2; exit 66; }

python3 - "$source_file" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
old = 'XP_MS( ru.ri_runnable_time - pru.ri_runnable_time ), XP_MS( ru.ri_page_wait_time_mach - pru.ri_page_wait_time_mach ),'
new = 'XP_MS( ru.ri_runnable_time - pru.ri_runnable_time ), 0.0,'
if new in text:
    print(f"Already patched: {path}")
elif old in text:
    path.write_text(text.replace(old, new, 1))
    print(f"Patched: {path}")
else:
    raise SystemExit("Expected telemetry expression was not found; refusing to edit an unknown upstream revision.")
PY
