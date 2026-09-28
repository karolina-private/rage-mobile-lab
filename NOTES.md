# RAGE Mobile Lab

Goal: Evaluate whether a user-owned GTA V Windows installation can launch reproducibly on an iPhone 15 Pro through an open iOS compatibility stack.

Owner asked: 2026-09-28

Status: Full public Madeira checkout is reproducible in the sandbox. The owner's Mac preflight passed with Xcode 26.6 and the iPhoneOS 26.5 SDK; next is an unsigned baseline Xcode build to expose missing upstream artifacts.

Next:
1. Run `scripts/preflight-macos.sh` on the owner's Mac against a recursive Madeira checkout.
2. Supply the documented Apple/Xcode-only and redistributable build inputs on that Mac.
3. Attempt the upstream Debug IPA build with the owner's signing team.
4. Define the iPhone 15 Pro runtime/JIT installation steps only after a signed IPA exists.

Build: Not established yet.

Sandbox: `sb-rage-mobile-lab` (requested; Debian, 4 CPU / 3072 MB RAM / 16 GB disk).

Decisions:
- Use an independent GitHub repository, not a GitHub fork.
- Preserve upstream attribution and GPL-3.0-or-later obligations for any derived code.
- Start with local single-player feasibility; multiplayer is explicitly out of scope until the runtime baseline exists.
- Never distribute GTA V assets or connect to GTA Online.

Log:
- 2026-09-28: Created public repository `karolina-private/rage-mobile-lab` and requested a dedicated disposable Debian build sandbox.
- 2026-09-28: Sandbox CT 105 installed; full recursive public Madeira checkout passed at `8c050d03f4d89096e1e2e2c8bb44479fffd86619` (2.3 GB). Added and sandbox-tested `scripts/preflight-macos.sh`.
- 2026-09-28: Owner ran macOS preflight successfully: Xcode 26.6 / iPhoneOS 26.5 SDK, recursive Madeira checkout complete. Signing team must be changed from upstream's value before a signed build.
