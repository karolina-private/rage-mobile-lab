# RAGE Mobile Lab

Goal: Evaluate whether a user-owned GTA V Windows installation can launch reproducibly on an iPhone 15 Pro through an open iOS compatibility stack.

Owner asked: 2026-09-28

Status: Microsoft VC++ x64 runtime, FEX, iOS FreeType/GnuTLS, `libwineserver.a`, and `libntdll_unix.a` build on the owner's Mac. The unsigned Xcode Debug link now reaches DXMT and stops only because `app/Madeira/libdxmt_combined.a` does not exist.

Next:
1. Initialize the pinned DXMT submodule and assemble the documented iOS LLVM 15 build prerequisite.
2. Build `libdxmt_combined.a`, then `libwin32u_unix.a` in linker order.
3. Configure signing and sideload only after an unsigned build completes.

Build: FEX iOS, `libwineserver.a`, and `libntdll_unix.a` are ready; DXMT requires the missing `toolchains/llvm-ios-build/` static libraries.

Sandbox: `sb-rage-mobile-lab` (CT 105; Debian, 4 CPU / 3072 MB RAM / 16 GB disk). The seven-day setup window is open until 2026-10-05 10:40 Europe/Tirane. The verified recursive upstream checkout is `/root/madeira` at `8c050d03f4d89096e1e2e2c8bb44479fffd86619`; the project clone is `/root/rage-mobile-lab`.

Decisions:
- Use an independent GitHub repository, not a GitHub fork.
- Preserve upstream attribution and GPL-3.0-or-later obligations for any derived code.
- Start with local single-player feasibility; multiplayer is explicitly out of scope until the runtime baseline exists.
- Never distribute GTA V assets or connect to GTA Online.

Log:
- 2026-09-28: Created public repository `karolina-private/rage-mobile-lab` and requested a dedicated disposable Debian build sandbox.
- 2026-09-28: Sandbox CT 105 installed; full recursive public Madeira checkout passed at `8c050d03f4d89096e1e2e2c8bb44479fffd86619` (2.3 GB). Added and sandbox-tested `scripts/preflight-macos.sh`.
- 2026-09-28: Owner ran macOS preflight successfully: Xcode 26.6 / iPhoneOS 26.5 SDK, recursive Madeira checkout complete. Signing team must be changed from upstream's value before a signed build.
- 2026-09-28: First unsigned Xcode build stopped before compilation because Xcode lacks the iOS 26.5 platform component. Added a regression test so preflight detects this condition instead of reporting a false pass.
- 2026-09-28: After installing the iOS 26.5 platform and Metal Toolchain, the owner ran the first unsigned Debug build. It reached the linker but failed because the Microsoft VC++ runtime resource directory is absent; the saved log needs a focused linker-error extraction.
- 2026-09-28: Extracted all 12 required VC++ x64 runtime DLLs from the current Microsoft redistributable. The next unsigned build compiles the app layer and fails on the missing generated FEX configuration header, confirming the FEX iOS build chain is next.
- 2026-09-28: Manual FEX iOS CMake configure succeeded with `CMAKE_SYSTEM_PROCESSOR=arm64`, `TUNE_CPU=none`, and `FEX_IOS_HOST`. `FEXCore_Base` built; `FEXCore` reached its final object before an unguarded Win32-only `VirtualQuery` diagnostic in `Arm64.cpp` failed on iOS. Added a tested, idempotent local source-patch helper to guard that diagnostic by `_WIN32`.
- 2026-09-28: After the FEX patch, both static libraries built successfully. The unsigned Xcode build compiled Objective-C, Objective-C++, and Swift app sources, then failed at link because `libJemallocLibs.a` remains referenced even though the Apple FEX configuration disables jemalloc. Added a tested project-file patch helper that removes only this stale reference.
- 2026-09-28: With jemalloc removed, the unsigned link reaches `libwineserver.a`. Madeira's own wineserver script requires an untracked pre-existing base archive, so it cannot serve a clean build. Added a tested bootstrap helper that compiles the non-replaced Wine server objects into a base iOS archive before Madeira patches it.
- 2026-09-28: Wine host configure found the ARM64EC cross-compiler and generated `include/config.h`, then failed while creating its complete Makefile because a generated ARM64EC export source is absent. The config header was sufficient: the bootstrap and iOS-specific wineserver patch build completed, producing `app/Madeira/libwineserver.a` (1,258,168 bytes).
- 2026-09-28: The next Xcode link found `libntdll_unix.a` missing. Verified that `wine/dlls/ntdll/loader.c` includes absent `arm64ec_x64_export_iat.c`; this exactly matches Madeira upstream issue #20. The missing code is runtime-critical, so the project is blocked rather than patched with an invented stub.
- 2026-09-28: Located the exact missing source in closed `willfaust/wine` PR #2 (head `c9c186e9998270015d12ebd6a11de264421df98c`), which added the matching helper and loader integration. The recovered file is 3,826 bytes, SHA-256 `06710c6d80624bbb7dd570553c9639f71418c18dc2983365f0136230d987331d`; added a verified retrieval helper.
- 2026-09-28: The owner applied the verified helper and then fixed the exact `sync.c` include-order failure by placing `config.h` first. Both Wine macOS/aarch64 and ARM64EC configure passes completed and generated Makefiles; unsupported desktop features are expected for this iOS-focused build.
- 2026-09-28: FreeType and iOS GnuTLS/GMP/Nettle/Hogweed built successfully. A guarded SDK patch restored the server object on current iPhoneOS SDKs. The ntdll runner resolved the actual Wine IDL headers requested by DirectWrite and built all 31 objects; verified `app/Madeira/libntdll_unix.a` is 1,648,120 bytes.
- 2026-09-28: Unsigned Debug Xcode link progressed through FEX, Wine server, and ntdll, then stopped at the next genuine artifact boundary: missing `libdxmt_combined.a`. DXMT's pinned submodule and `toolchains/llvm-ios-build/` are absent locally; do not retry the Xcode link until the DXMT unix archive exists.
