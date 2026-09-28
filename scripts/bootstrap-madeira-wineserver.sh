#!/usr/bin/env bash
# Build an initial iOS wineserver archive for Madeira's patching script.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Madeira" >&2
  exit 64
fi

root="$(cd "$1" && pwd)"
wine="$root/wine"
build_dir="$root/build/wineserver"
obj_dir="$build_dir/obj"
base_dir="$obj_dir/base"
app_lib="$root/app/Madeira/libwineserver.a"
shims_dir="$root/build/ntdll-unix/shims"
sdk="$(xcrun --sdk iphoneos --show-sdk-path)"

[[ -f "$wine/build-macos/include/config.h" ]] || {
  echo "Wine host configuration is missing: $wine/build-macos/include/config.h" >&2
  echo "Configure Wine for macOS before bootstrapping wineserver." >&2
  exit 1
}

if [[ -f "$obj_dir/libwineserver.a" || -f "$app_lib" ]]; then
  echo "wineserver base: cached"
  exit 0
fi

mkdir -p "$base_dir"
flags=(
  -arch arm64 -isysroot "$sdk" -miphoneos-version-min=17.0 -O2
  -I"$wine/include" -I"$wine/include/wine"
  -I"$wine/build-macos/include" -I"$wine/build-macos/server"
  -I"$build_dir" -I"$wine/server" -I"$shims_dir"
  -include "$build_dir/config_ios.h" -include stdarg.h
  -include "$build_dir/unicode_fix.h" -include "$build_dir/wineserver_ios_kill.h"
  '-DBINDIR="/usr/local/bin"' '-DDATADIR="/usr/local/share"'
  -D__WINESRC__ -DWINE_IOS=1 -Dmain=wineserver_main
  -Wno-implicit-function-declaration
)

is_replaced() {
  case "$1" in
    async.c|class.c|fd.c|mach.c|main.c|mapping.c|object.c|process.c|queue.c|region.c|request.c|sock.c|thread.c|unicode.c|user.c|window.c|winstation.c)
      return 0 ;;
    *) return 1 ;;
  esac
}

objects=()
while IFS= read -r filename; do
  [[ -n "$filename" ]] || continue
  is_replaced "$filename" && continue
  source="$wine/server/$filename"
  object="$base_dir/${filename%.c}.o"
  echo "  bootstrap ${filename%.c}"
  xcrun -sdk iphoneos clang "${flags[@]}" -c "$source" -o "$object"
  objects+=("$object")
done < <(awk '
  /^SOURCES =/ { in_sources=1; next }
  in_sources && /^UNIX_CFLAGS/ { exit }
  in_sources {
    gsub(/\\/, "")
    for (i=1; i<=NF; i++) if ($i ~ /\.c$/) print $i
  }
' "$wine/server/Makefile.in")

(( ${#objects[@]} > 0 )) || { echo "No wineserver sources compiled." >&2; exit 1; }
ar rcs "$obj_dir/libwineserver.a" "${objects[@]}"
cp "$obj_dir/libwineserver.a" "$app_lib"
echo "wineserver base: $(wc -c < "$app_lib" | tr -d ' ') bytes"
