---
name: guardrails
description: Security guardrails to prevent destructive commands and enforce best practices for system safety.
globs:
  - "**/*"
---

# Pi Guardrails

These guardrails ensure that the agent operates safely and avoids making irreversible or dangerous changes to the system.

## Restricted Commands

The following commands or patterns must be double-checked or avoided entirely:

- `rm -rf /` or any variant targeting root or system directories.
- Commands that modify `/etc/nixos/` without a specific request and backup.
- Commands that expose or delete files in `secrets/`.
- Large-scale deletions in the home directory without confirmation.

## Best Practices

1. **Backup First**: Before modifying configuration files in `/etc/nixos/`, always create a `.backup` file.
2. **Dry Run**: When using `nixos-rebuild`, prefer building (`nh os build`) before switching (`nh os switch`).
3. **Isolation**: Respect the project root. Do not touch files outside the current project unless explicitly necessary.
4. **Verification**: After a change, verify that the system is still functional (e.g., check `nix flake check`).
