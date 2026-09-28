# RAGE Mobile Lab

Goal: Evaluate whether a user-owned GTA V Windows installation can launch reproducibly on an iPhone 15 Pro through an open iOS compatibility stack.

Owner asked: 2026-09-28

Status: Microsoft VC++ x64 runtime and both FEX static libraries build on the owner's Mac. The unsigned Xcode build compiles all app sources and reaches the linker; it stops only because the project links stale `libJemallocLibs.a` while iOS FEX deliberately disables jemalloc. A narrow, tested local Xcode-project patch is ready.

Next:
1. Apply `scripts/patch-madeira-xcode-ios.sh` to remove the stale jemalloc archive reference, then rerun the unsigned Xcode build.
2. Build Wine/DXMT chains in the upstream build order once their first exact missing archive is identified.
3. Configure the owner's signing team and sideload only after an unsigned build completes.

Build: FEX iOS configured and linked into the Xcode target; the remaining immediate issue is only the stale jemalloc project reference.

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
