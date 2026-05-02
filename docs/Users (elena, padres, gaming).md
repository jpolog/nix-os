---
tags: [users, reference]
---

# Other Users

> Family and gaming user accounts — [[User jpolo]] is covered separately.

## elena

- **Description:** Family user on [[Janus]]
- **Shell:** bash
- **Initial password:** `elena` — **MUST be changed on first login** with `passwd`
- **Groups:** networkmanager, video, audio, input
- **Home Manager:** Imports shared modules, default profile
- **Desktop:** KDE (inherited from [[Janus]] default)

## padres

- **Description:** Family user on [[Janus]]
- **Shell:** bash
- **Initial password:** `padres` — **MUST be changed on first login** with `passwd`
- **Groups:** networkmanager, video, audio, input
- **Home Manager:** Imports shared modules, default profile
- **Desktop:** KDE (inherited from [[Janus]] default)

## gaming

- **Description:** Isolated gaming user on [[Ares]]
- **Shell:** bash
- **Initial password:** `gaming` — **MUST be changed on first login** with `passwd`
- **Groups:** networkmanager, video, audio, input
- **Home Manager:** Imports `home/users/gaming.nix`, desktop environment set to KDE
- **Purpose:** Isolated gaming environment — no access to dev tools

## Security Note

- All initial passwords **MUST** be changed on first login.
- `gaming` has **no** `wheel`/`sudo` access.
- `elena` and `padres` have **no** `wheel`/`sudo` access.
- Only `jpolo` has the `wheel` group.

See [[Security]] for the full privilege model and [[Home Profiles]] for profile details.