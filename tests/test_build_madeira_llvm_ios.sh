#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_root/scripts/build-madeira-llvm-ios.sh"

bash -n "$script"
grep -Fq 'pin="8dfdcc7b7bf66834a761bd8de445840ef68e4d1a"' "$script"
grep -Fq 'MATCHES "Darwin|iOS"' "$script"
grep -Fq -- '-DLLVM_TABLEGEN="$host_build/bin/llvm-tblgen"' "$script"
grep -Fq -- '-DCMAKE_SYSTEM_NAME=iOS' "$script"
grep -Fq 'cmake --build "$ios_build" -j2' "$script"
echo 'Madeira LLVM iOS build script test passed.'
