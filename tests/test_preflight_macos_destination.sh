#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
script="$repo_root/scripts/preflight-macos.sh"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/sdk" "$fixture/madeira/app/Madeira.xcodeproj" "$fixture/madeira/FEX" "$fixture/madeira/wine" "$fixture/madeira/research/dxmt" "$fixture/madeira/build/fex-ios" "$fixture/madeira/build/dxmt-ios" "$fixture/madeira/.git"
: > "$fixture/madeira/build/fex-ios/build.sh"
: > "$fixture/madeira/build/dxmt-ios/build.sh"
printf '  DEVELOPMENT_TEAM = EXAMPLETEAM;\n' > "$fixture/madeira/app/Madeira.xcodeproj/project.pbxproj"

cat > "$fixture/bin/uname" <<'EOF'
#!/usr/bin/env sh
echo Darwin
EOF
cat > "$fixture/bin/xcode-select" <<'EOF'
#!/usr/bin/env sh
echo /Applications/Xcode.app/Contents/Developer
EOF
cat > "$fixture/bin/xcrun" <<EOF
#!/usr/bin/env sh
echo "$fixture/sdk"
EOF
cat > "$fixture/bin/xcodebuild" <<'EOF'
#!/usr/bin/env sh
if [ "${1:-}" = '-version' ]; then
  printf 'Xcode 26.6\nBuild version 17F113\n'
  exit 0
fi
printf '%s\n' 'Ineligible destinations for the "Madeira" scheme:'
printf '%s\n' 'error:iOS 26.5 is not installed. Please download and install the platform from Xcode > Settings > Components.'
EOF
chmod +x "$fixture/bin"/*

set +e
output=$(PATH="$fixture/bin:/usr/bin:/bin" MADEIRA_DIR="$fixture/madeira" "$script" 2>&1)
status=$?
set -e

if [ "$status" -ne 2 ]; then
  printf 'expected exit 2 for a missing iOS platform, got %s\n%s\n' "$status" "$output" >&2
  exit 1
fi
printf '%s\n' "$output" | grep -F 'iOS platform is unavailable in Xcode'
printf 'missing iOS platform behavior verified\n'
