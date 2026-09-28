#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
root="$tmp/repo/upstream/Madeira"
mkdir -p "$root/wine/build-arm64ec" "$root/wine/include" "$root/build/ntdll-unix/obj" "$root/app/Madeira" "$tmp/bin"
: > "$root/wine/build-arm64ec/Makefile"
: > "$root/wine/include/propidl.idl"
cat > "$root/build/ntdll-unix/build.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
state="$(dirname "$0")/state"
if [[ ! -f "$state" ]]; then
  : > "$state"
  printf "fatal error: 'propidl.h' file not found\n" > "$(dirname "$0")/obj/dwrite_unixlib.err"
  exit 1
fi
touch "$(cd "$(dirname "$0")/../.." && pwd)/app/Madeira/libntdll_unix.a"
EOF
chmod +x "$root/build/ntdll-unix/build.sh"
cat > "$tmp/bin/make" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$MAKE_ARGS_FILE"
EOF
chmod +x "$tmp/bin/make"
MAKE_ARGS_FILE="$tmp/make.args" PATH="$tmp/bin:$PATH" \
  "$repo_root/scripts/build-madeira-ntdll-unix.sh" "$root" > "$tmp/output"
grep -qx 'include/propidl.h' "$tmp/make.args"
grep -q 'Verified ntdll archive:' "$tmp/output"
echo 'Madeira ntdll IDL resolver test passed.'
