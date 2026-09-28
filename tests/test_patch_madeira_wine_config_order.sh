#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
source="$tmp/Madeira/wine/dlls/ntdll/unix/sync.c"
mkdir -p "$(dirname "$source")"
printf '%s\n' '#include "../../../../build/madeira_cfg.h"   /* ml1122: before the Wine headers, which ban strncpy by macro */' '#include "config.h"' > "$source"

bash "$repo_root/scripts/patch-madeira-wine-config-order.sh" "$tmp/Madeira"
first="$(sed -n '1p' "$source")"
[[ "$first" == '#include "config.h"' ]]
bash "$repo_root/scripts/patch-madeira-wine-config-order.sh" "$tmp/Madeira" | grep -Fq 'Already patched'
echo 'Madeira Wine config-order patch test passed.'
