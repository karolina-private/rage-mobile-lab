# RAGE Mobile Lab

Goal: Evaluate whether a user-owned GTA V Windows installation can launch reproducibly on an iPhone 15 Pro through an open iOS compatibility stack.

Owner asked: 2026-09-28

Status: Microsoft VC++ x64 runtime, FEX, and the Wine iOS wineserver archive build on the owner's Mac. The next unsigned Xcode link stops at missing `libntdll_unix.a`. This cannot be responsibly built from the pinned Madeira sources: Wine `loader.c` unconditionally includes the absent `arm64ec_x64_export_iat.c`, which blocks ARM64EC configure/Makefile generation and thus the generated headers needed by the ntdll iOS build. The upstream project has a matching unresolved public issue (#20).

Next:
1. Monitor/verify an upstream fix that supplies `arm64ec_x64_export_iat.c`; do not invent a substitute for this runtime-critical ARM64EC code.
2. Once fixed, complete Wine ARM64EC header generation, GnuTLS, `libntdll_unix.a`, `libwin32u_unix.a`, and DXMT in order.
3. Configure signing and sideload only after an unsigned build completes.

Build: FEX iOS and `libwineserver.a` are linked; blocked at `libntdll_unix.a` by the missing upstream ARM64EC source file.

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
