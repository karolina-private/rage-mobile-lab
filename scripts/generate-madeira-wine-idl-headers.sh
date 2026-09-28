#!/usr/bin/env bash
# Generate every Wine IDL-derived header needed by ARM64EC consumers.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Madeira" >&2
  exit 64
fi

root="$(cd "$1" && pwd)"
source_makefile="$root/wine/include/Makefile.in"
build_dir="$root/wine/build-arm64ec"

[[ -f "$source_makefile" ]] || { echo "Wine include manifest not found: $source_makefile" >&2; exit 66; }
[[ -f "$build_dir/Makefile" ]] || { echo "Wine ARM64EC build tree is not configured: $build_dir/Makefile" >&2; exit 66; }

headers=()
while IFS= read -r idl; do
  headers+=("include/${idl%.idl}.h")
done < <(awk '
  /^SOURCES =/ { in_sources=1; next }
  in_sources && /^[A-Z][A-Z0-9_]* =/ { exit }
  in_sources {
    gsub(/\\/, "")
    for (i = 1; i <= NF; i++) if ($i ~ /\.idl$/) print $i
  }
' "$source_makefile")

(( ${#headers[@]} > 0 )) || { echo "No IDL header targets found." >&2; exit 65; }
echo "Generating ${#headers[@]} Wine IDL headers for ARM64EC..."
make -C "$build_dir" -j4 "${headers[@]}"
echo "Wine ARM64EC IDL headers generated."
