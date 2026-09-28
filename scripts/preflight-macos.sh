#!/usr/bin/env sh
# Validate prerequisites before building Madeira on a developer-owned Mac.
set -eu

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 2
}

info() {
  printf 'OK: %s\n' "$*"
}

[ "$(uname -s)" = 'Darwin' ] || fail 'must run on macOS'

command -v xcode-select >/dev/null 2>&1 || fail 'xcode-select is unavailable; install Xcode'
command -v xcodebuild >/dev/null 2>&1 || fail 'xcodebuild is unavailable; install Xcode'
command -v xcrun >/dev/null 2>&1 || fail 'xcrun is unavailable; install Xcode command-line tools'

xcode_path=$(xcode-select -p 2>/dev/null) || fail 'select an Xcode installation with xcode-select -s'
iphone_sdk=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null) || fail 'iPhoneOS SDK is unavailable in the selected Xcode'

[ -d "$iphone_sdk" ] || fail "iPhoneOS SDK path does not exist: $iphone_sdk"
info "Xcode selected at $xcode_path"
info "iPhoneOS SDK at $iphone_sdk"
xcodebuild -version | sed -n '1,2p'

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
madeira_dir=${MADEIRA_DIR:-"$repo_root/upstream/Madeira"}
[ -d "$madeira_dir/.git" ] || fail "Madeira checkout not found at $madeira_dir; clone it recursively first"

(
  cd "$madeira_dir"
  git submodule status --recursive | grep -q '^-'
) && fail 'Madeira has uninitialized submodules; run git submodule update --init --recursive' || true

for required in FEX wine research/dxmt app/Madeira.xcodeproj build/fex-ios/build.sh build/dxmt-ios/build.sh; do
  [ -e "$madeira_dir/$required" ] || fail "Madeira checkout is incomplete: missing $required"
done

team=$(grep -E '^[[:space:]]*DEVELOPMENT_TEAM = ' "$madeira_dir/app/Madeira.xcodeproj/project.pbxproj" | sed -n '1p' || true)
[ -n "$team" ] && printf 'NOTICE: upstream Xcode project contains %s; change signing to your Apple Development team before building.\n' "$team"

printf '%s\n' 'NEXT: Download the Metal Toolchain component in Xcode and provide the documented non-repository inputs before attempting the full build.'
printf '%s\n' 'Preflight passed.'
