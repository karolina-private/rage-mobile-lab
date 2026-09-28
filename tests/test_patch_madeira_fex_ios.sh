#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
source="$tmp/Madeira/FEX/FEXCore/Source/Utils/ArchHelpers/Arm64.cpp"
mkdir -p "$(dirname "$source")"
cat >"$source" <<'CPP'
  MEMORY_BASIC_INFORMATION mbi {};
  const char* type = "?";
  if (VirtualQuery(reinterpret_cast<LPCVOID>(GPRs[AddressReg]), &mbi, sizeof(mbi))) {
    type = mbi.Type == MEM_IMAGE ? "MEM_IMAGE" : mbi.Type == MEM_MAPPED ? "MEM_MAPPED" : "MEM_PRIVATE";
  }
  LogMan::Msg::EFmt("[caspal128] MISALIGNED-UNSUPPORTED Size={} addrReg=x{} addr={:#x} misalign={} "
                    "crosses16B={} | region base={} size={:#x} prot={:#x} type={} state={:#x}",
                    Size, AddressReg, GPRs[AddressReg], GPRs[AddressReg] & 15,
                    (GPRs[AddressReg] & 15) ? "yes" : "no", mbi.BaseAddress, mbi.RegionSize,
                    mbi.Protect, type, mbi.State);
CPP

bash "$repo_root/scripts/patch-madeira-fex-ios.sh" "$tmp/Madeira"
grep -Fq '#if defined(_WIN32)' "$source"
grep -Fq 'region metadata is unavailable on this host' "$source"
bash "$repo_root/scripts/patch-madeira-fex-ios.sh" "$tmp/Madeira" | grep -Fq 'Already patched'
echo 'Madeira FEX iOS patch test passed.'
