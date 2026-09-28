#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/Madeira/wine/include" "$tmp/Madeira/wine/build-arm64ec"
: > "$tmp/Madeira/wine/build-arm64ec/Makefile"
cat > "$tmp/Madeira/wine/include/Makefile.in" <<'EOF'
SOURCES = \
  alpha.idl \
  static.h \
  beta.idl
EXTRA_TARGETS =
EOF
mkdir -p "$tmp/bin"
cat > "$tmp/bin/make" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$MAKE_ARGS_FILE"
EOF
chmod +x "$tmp/bin/make"
MAKE_ARGS_FILE="$tmp/make.args" PATH="$tmp/bin:$PATH" \
  "$repo_root/scripts/generate-madeira-wine-idl-headers.sh" "$tmp/Madeira" > "$tmp/output"
grep -qx 'include/alpha.h' "$tmp/make.args"
grep -qx 'include/beta.h' "$tmp/make.args"
! grep -q 'static.h' "$tmp/make.args"
grep -qx 'Wine ARM64EC IDL headers generated.' "$tmp/output"
echo 'Wine IDL header generator test passed.'
