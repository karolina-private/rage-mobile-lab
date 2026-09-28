#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/scripts/fetch-madeira-arm64ec-export-iat.sh"

bash -n "$script"
if "$script" >/dev/null 2>&1; then
  echo 'Fetch script unexpectedly accepted no path.' >&2
  exit 1
else
  status=$?
  [[ $status -eq 64 ]]
fi
grep -Fq 'c9c186e9998270015d12ebd6a11de264421df98c' "$script"
grep -Fq '06710c6d80624bbb7dd570553c9639f71418c18dc2983365f0136230d987331d' "$script"
echo 'ARM64EC helper fetch script test passed.'
