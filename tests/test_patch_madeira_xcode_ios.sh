#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
project="$tmp/Madeira/app/Madeira.xcodeproj/project.pbxproj"
mkdir -p "$(dirname "$project")"
cat >"$project" <<'PBX'
A1000017 /* libJemallocLibs.a in Frameworks */ = {isa = PBXBuildFile; fileRef = A2000017 /* libJemallocLibs.a */; };
A2000017 /* libJemallocLibs.a */ = {isa = PBXFileReference; path = "../../FEX/build-ios/FEXCore/Source/libJemallocLibs.a"; };
				A1000017 /* libJemallocLibs.a in Frameworks */,
				A2000017 /* libJemallocLibs.a */,
PBX

bash "$repo_root/scripts/patch-madeira-xcode-ios.sh" "$tmp/Madeira"
if grep -Fq 'JemallocLibs' "$project"; then
  echo 'Stale jemalloc reference survived' >&2
  exit 1
fi
bash "$repo_root/scripts/patch-madeira-xcode-ios.sh" "$tmp/Madeira" | grep -Fq 'Already patched'
echo 'Madeira Xcode iOS patch test passed.'
