# Fixing "Git tree is dirty" Warning

## What does it mean?

The warning `Git tree '/etc/nixos' is dirty` appears when you have uncommitted changes in your NixOS configuration directory.

## How to fix it (3 options):

### Option 1: Commit your changes (Recommended)
```bash
cd /etc/nixos
git add .
git commit -m "Fix all deprecation warnings and cleanup packages"
sudo nixos-rebuild switch --flake .#ares
```

### Option 2: Temporarily ignore the warning
The warning is harmless and doesn't prevent building. You can ignore it if you're still making changes.

### Option 3: Disable the warning in nix.settings
Add to your configuration:
```nix
# In modules/system/optimization.nix or similar
nix.settings = {
  # ... existing settings ...
  warn-dirty = false;  # Disable dirty git tree warnings
};
```

## Current Status

All deprecation warnings and errors have been fixed:
- ✅ No more `pkgs.system` warnings (changed to `pkgs.stdenv.hostPlatform.system`)
- ✅ All package renames applied
- ✅ All deprecated options updated
- ✅ ZFS removed (kernel incompatibility)
- ✅ Duplicates removed

The only remaining warning is the "dirty git tree" which is just informational.

## Recommended Action

Just commit your changes:
```bash
cd /etc/nixos
git status  # See what changed
git add .
git commit -m "Apply NixOS best practices and fix all deprecations"
```

This warning will disappear after you commit.
