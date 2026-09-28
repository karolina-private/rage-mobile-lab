# RAGE Mobile Lab

Goal: Evaluate whether a user-owned GTA V Windows installation can launch reproducibly on an iPhone 15 Pro through an open iOS compatibility stack.

Owner asked: 2026-09-28

Status: Repository created; waiting for the Proxmox broker confirmation to create `sb-rage-mobile-lab`.

Next:
1. Clone and inspect the Madeira source without creating a GitHub fork relationship.
2. Create a documented, minimal iOS build and sideload prerequisite checklist.
3. Build the upstream stack in the disposable sandbox where feasible.
4. Define a hardware test protocol for iPhone 15 Pro.

Build: Not established yet.

Sandbox: `sb-rage-mobile-lab` (requested; Debian, 4 CPU / 3072 MB RAM / 16 GB disk).

Decisions:
- Use an independent GitHub repository, not a GitHub fork.
- Preserve upstream attribution and GPL-3.0-or-later obligations for any derived code.
- Start with local single-player feasibility; multiplayer is explicitly out of scope until the runtime baseline exists.
- Never distribute GTA V assets or connect to GTA Online.

Log:
- 2026-09-28: Created public repository `karolina-private/rage-mobile-lab` and requested a dedicated disposable Debian build sandbox.
