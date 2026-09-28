#!/usr/bin/env bash
# Retrieve the exact missing ARM64EC loader helper from Wine PR #2.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Madeira" >&2
  exit 64
fi

source_root="$1/wine/dlls/ntdll"
loader="$source_root/loader.c"
target="$source_root/arm64ec_x64_export_iat.c"
url="https://github.com/willfaust/wine/raw/c9c186e9998270015d12ebd6a11de264421df98c/dlls/ntdll/arm64ec_x64_export_iat.c"
expected_sha256="06710c6d80624bbb7dd570553c9639f71418c18dc2983365f0136230d987331d"

[[ -f "$loader" ]] || { echo "Wine loader source not found: $loader" >&2; exit 66; }
grep -Fq '#include "arm64ec_x64_export_iat.c"' "$loader" || {
  echo "The expected include is absent; refusing to apply a mismatched helper." >&2
  exit 65
}
[[ ! -e "$target" ]] || { echo "Target already exists; refusing to overwrite: $target" >&2; exit 73; }

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fL --retry 3 "$url" -o "$tmp"
actual_sha256="$(shasum -a 256 "$tmp" | awk '{print $1}')"
[[ "$actual_sha256" == "$expected_sha256" ]] || {
  echo "SHA-256 mismatch: $actual_sha256" >&2
  exit 65
}
grep -Fq 'static BOOL arm64ec_iat_slot_is_x64_export' "$tmp" || {
  echo "Downloaded file lacks the expected ARM64EC helper." >&2
  exit 65
}
mv "$tmp" "$target"
trap - EXIT
echo "Installed verified ARM64EC helper: $target"
