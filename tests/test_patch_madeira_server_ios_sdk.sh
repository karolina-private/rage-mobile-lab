#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
source="$tmp/Madeira/build/ntdll-unix/server_ios.c"
mkdir -p "$(dirname "$source")"
printf '%s\n' 'XP_MS( ru.ri_runnable_time - pru.ri_runnable_time ), XP_MS( ru.ri_page_wait_time_mach - pru.ri_page_wait_time_mach ),' > "$source"

bash "$repo_root/scripts/patch-madeira-server-ios-sdk.sh" "$tmp/Madeira"
grep -Fq 'XP_MS( ru.ri_runnable_time - pru.ri_runnable_time ), 0.0,' "$source"
bash "$repo_root/scripts/patch-madeira-server-ios-sdk.sh" "$tmp/Madeira" | grep -Fq 'Already patched'
echo 'Madeira server iOS SDK patch test passed.'
