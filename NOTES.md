# RAGE Mobile Lab

Goal: Evaluate whether a user-owned GTA V Windows installation can launch reproducibly on an iPhone 15 Pro through an open iOS compatibility stack.

Owner asked: 2026-09-28

Status: Microsoft VC++ x64 runtime is present. The unsigned build compiles the Swift app layer and now stops at the expected generated FEX header `FEXCore/Config/ConfigValues.inl`; native FEX iOS libraries have not yet been configured.

Next:
1. Configure and build FEX for iOS with `build/fex-ios/build.sh` on the owner's Mac.
2. Rerun the unsigned Xcode build and record the next missing native component.
3. Build Wine/DXMT chains in the upstream build order.
4. Configure the owner's signing team and sideload only after an unsigned build completes.

Build: Not established yet.

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
