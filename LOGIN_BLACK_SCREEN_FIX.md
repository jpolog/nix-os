# Black Screen After Login - Fix

## Problem
After logging in as jpolo user, you get a black screen with blinking cursor because:
1. **No default session configured** - SDDM doesn't know to start Hyprland
2. **Home-manager profile directory missing** - Prevents shell from initializing properly

## Quick Fix (Do this NOW)

### Step 1: Fix the home-manager profile issue
```bash
# As root (from TTY or SSH)
mkdir -p /home/jpolo/.local/state/nix/profiles
chown -R jpolo:users /home/jpolo/.local/state
```

### Step 2: Add default session to your configuration
Add this to `/etc/nixos/hosts/ares/configuration.nix` after the user definition:

```nix
users.users.jpolo = {
  # ... existing config ...
  shell = pkgs.zsh;
};

# Add this right after the user definition:
services.displayManager.defaultSession = "hyprland";
```

### Step 3: Rebuild
```bash
sudo nixos-rebuild switch --flake .#ares
```

## Alternative: Manual Session Selection

If you can get to SDDM login screen:
1. Click on the session selector (gear icon or dropdown)
2. Select "Hyprland"
3. Login
4. This will work once, but you should still add the defaultSession

## Temporary Workaround (Emergency Access)

If you're stuck at black screen:
1. Press `Ctrl+Alt+F2` to get to TTY2
2. Login as jpolo
3. Run the profile directory fix above
4. Then run: `Hyprland` manually to start the desktop

Or switch to root:
1. Press `Ctrl+Alt+F3` to get to TTY3
2. Login as root
3. Apply the fixes above

## What's Happening

The black screen occurs because:
- ZSH is trying to activate home-manager configuration
- home-manager can't find profile directory
- Shell initialization fails
- No desktop environment launches

## Permanent Fix

Add to `/etc/nixos/modules/desktop/display-manager.nix`:

```nix
{ config, pkgs, ... }:

{
  # Display Manager - SDDM for Wayland support
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };
  
  # Set default session
  services.displayManager.defaultSession = "hyprland";

  # SDDM packages
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtquickcontrols2
  ];
}
```

Then rebuild!
