#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/scripts/bootstrap-madeira-wineserver.sh"

bash -n "$script"
if "$script" >/dev/null 2>&1; then
  echo 'Bootstrap script unexpectedly accepted no path.' >&2
  exit 1
else
  status=$?
  [[ $status -eq 64 ]]
fi
grep -Fq 'is_replaced' "$script"
grep -Fq 'ar rcs' "$script"
echo 'Madeira wineserver bootstrap script test passed.'
