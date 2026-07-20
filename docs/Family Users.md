---
tags: [users, reference]
---

# Family Users

This page covers the additional user accounts configured for family members. These accounts are designed for general use with restricted permissions.

> [!IMPORTANT]
> All initial passwords **MUST** be changed on first login using the `passwd` command.

## elena
- **Description:** Family user on [[Janus]]
- **Shell:** `bash`
- **Initial password:** `elena` (CHANGE on first login)
- **Groups:** `networkmanager`, `video`, `audio`, `input`
- **Home Manager:** Imports shared modules and uses the default personal profile.
- **Desktop:** KDE Plasma (inherited from [[Janus]] machine default).
- **Purpose:** General use, multimedia, and communication.

## padres
- **Description:** Family user on [[Janus]]
- **Shell:** `bash`
- **Initial password:** `padres` (CHANGE on first login)
- **Groups:** `networkmanager`, `video`, `audio`, `input`
- **Home Manager:** Imports shared modules and uses the default personal profile.
- **Desktop:** KDE Plasma (inherited from [[Janus]] machine default).
- **Purpose:** Shared account for parents' general use.

## Security Note
- **No sudo access:** None of these users (`elena`, `padres`) belong to the `wheel` group. They cannot perform administrative tasks.
- **Privileged Access:** Only the primary developer account ([[User jpolo]]) has `wheel` (sudo) and `docker` group memberships.

---
**Related pages:** [[Ares]] · [[Janus]] · [[Security]] · [[Home Profiles]] · [[User jpolo]]
