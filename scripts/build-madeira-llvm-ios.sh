#!/usr/bin/env bash
# Build the LLVM 15 static archives consumed by Madeira's iOS DXMT archive.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/Madeira" >&2
  exit 64
fi

root="$(cd "$1" && pwd)"
toolchains="$root/toolchains"
source_dir="$toolchains/llvm-project"
host_build="$toolchains/llvm-host-build"
ios_build="$toolchains/llvm-ios-build"
pin="8dfdcc7b7bf66834a761bd8de445840ef68e4d1a"

command -v cmake >/dev/null || { echo "cmake is required." >&2; exit 69; }
command -v ninja >/dev/null || { echo "ninja is required." >&2; exit 69; }
command -v xcrun >/dev/null || { echo "Xcode command-line tools are required." >&2; exit 69; }

mkdir -p "$toolchains"
if [[ ! -d "$source_dir/.git" ]]; then
  git clone https://github.com/llvm/llvm-project.git "$source_dir"
fi
git -C "$source_dir" fetch --depth=1 origin "$pin"
git -C "$source_dir" checkout --detach "$pin"

add_llvm="$source_dir/llvm/cmake/modules/AddLLVM.cmake"
python3 - "$add_llvm" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
old = 'if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")\n        # ld64\'s implementation of -dead_strip'
new = 'if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin|iOS")\n        # ld64\'s implementation of -dead_strip'
text = path.read_text()
if new not in text:
    if text.count(old) != 1:
        raise SystemExit("Could not safely apply the documented iOS dead-strip patch.")
    path.write_text(text.replace(old, new))
PY

cmake -S "$source_dir/llvm" -B "$host_build" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_PROJECTS= \
  -DLLVM_TARGETS_TO_BUILD= \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_ENABLE_ZLIB=OFF
cmake --build "$host_build" --target llvm-tblgen -j2

cmake -S "$source_dir/llvm" -B "$ios_build" -G Ninja \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_SYSROOT=iphoneos \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=17.0 \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_HOST_TRIPLE=arm64-apple-ios17.0 \
  -DLLVM_DEFAULT_TARGET_TRIPLE=arm64-apple-ios17.0 \
  -DLLVM_TARGET_ARCH=host \
  -DLLVM_TARGETS_TO_BUILD= \
  -DLLVM_ENABLE_PROJECTS= \
  -DLLVM_BUILD_TOOLS=OFF \
  -DLLVM_BUILD_UTILS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_ENABLE_ZLIB=OFF \
  -DLLVM_TABLEGEN="$host_build/bin/llvm-tblgen"
cmake --build "$ios_build" -j2

test -d "$ios_build/lib"
find "$ios_build/lib" -maxdepth 1 -name '*.a' -print -quit | grep -q .
echo "LLVM iOS static archives are ready: $ios_build/lib"
