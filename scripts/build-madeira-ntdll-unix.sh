#!/usr/bin/env bash
# Build Madeira ntdll and generate only Wine IDL headers its compiler requests.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Madeira" >&2
  exit 64
fi

root="$(cd "$1" && pwd)"
build_dir="$root/wine/build-arm64ec"
error_file="$root/build/ntdll-unix/obj/dwrite_unixlib.err"
archive="$root/app/Madeira/libntdll_unix.a"
log_file="$(cd "$root/../.." && pwd)/madeira-ntdll-unix-build.log"

[[ -f "$build_dir/Makefile" ]] || { echo "Wine ARM64EC build tree is not configured." >&2; exit 66; }

for attempt in $(seq 1 32); do
  echo "=== ntdll build attempt $attempt/32 ==="
  set +e
  bash "$root/build/ntdll-unix/build.sh" 2>&1 | tee "$log_file"
  set -e

  if [[ -f "$archive" ]]; then
    echo "Verified ntdll archive: $archive"
    exit 0
  fi

  [[ -f "$error_file" ]] || { echo "ntdll build failed without dwrite error log: $error_file" >&2; exit 1; }
  missing="$(grep -Eo "fatal error: '[^']+\.h' file not found" "$error_file" | sed -E "s/^fatal error: '([^']+)' file not found$/\1/" | tail -n 1 || true)"
  [[ -n "$missing" ]] || { echo "dwrite failed for a non-IDL reason; inspect: $error_file" >&2; exit 1; }

  idl="$root/wine/include/${missing%.h}.idl"
  [[ -f "$idl" ]] || { echo "Missing header is not a Wine IDL output: $missing" >&2; exit 1; }
  echo "Generating requested Wine header: include/$missing"
  make -C "$build_dir" -j4 "include/$missing"
done

echo "Exceeded 32 Wine IDL-header resolution attempts." >&2
exit 1
