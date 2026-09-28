#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
script="$repo_root/scripts/preflight-macos.sh"

set +e
output=$(PATH=/usr/bin:/bin "$script" 2>&1)
status=$?
set -e

if [ "$status" -ne 2 ]; then
  printf 'expected exit 2 on non-macOS, got %s\n%s\n' "$status" "$output" >&2
  exit 1
fi

printf '%s\n' "$output" | grep -F 'must run on macOS'
printf 'non-macOS preflight behavior verified\n'
