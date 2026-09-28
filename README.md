# RAGE Mobile Lab

Research laboratory for running a **user-owned** GTA V Windows installation on an iPhone through open compatibility layers.

> **Status:** Discovery / feasibility spike. This is not an official Rockstar Games project and does not include GTA V files, Rockstar assets, Steam content, or a GTA Online client.

## Goal

Determine whether a user-owned copy of GTA V can reach a repeatable local single-player baseline on an iPhone 15 Pro before any multiplayer work is considered.

## Approach

The initial research target is [Madeira](https://github.com/willfaust/Madeira), an open GPL-3.0-or-later iOS compatibility stack combining Wine, FEX-Emu, and DXMT. This repository will keep our launcher experiments, reproducible test protocol, configuration profiles, logs without personal data, and patches that we are legally able to publish.

```text
GTA V for Windows (user supplied)
  -> Wine / Win32 compatibility
  -> FEX x86-64 to ARM64 translation
  -> DXMT Direct3D 11 to Metal
  -> iPhone GPU
```

## Non-goals

- Distributing GTA V executable files, assets, installers, keys, or DRM bypasses.
- Connecting to or modifying GTA Online.
- Circumventing security, anti-cheat, account checks, or platform protections.
- Claiming compatibility before it is verified on physical hardware.

## First milestone

A documented, reproducible result for a user-owned GTA V installation on iPhone 15 Pro:

1. compatibility stack builds and installs by sideload;
2. game starts to a usable menu;
3. story mode reaches an in-game frame;
4. launch logs and measured behaviour are recorded;
5. every result is clearly labelled pass, fail, or unverified.

See [NOTES.md](NOTES.md) for the active work log and [UPSTREAMS.md](UPSTREAMS.md) for dependency provenance.

## License

Code copied from or derived from Madeira must be distributed under GPL-3.0-or-later, as required by its upstream license. This repository will use GPL-3.0-or-later for such code. Game data remains property of its respective rights holders.
