# Home Manager Standalone Configuration for jpolo

This directory contains the standalone home-manager configuration for the `jpolo` user on the `ares` host. This setup allows you to manage user-level packages and dotfiles independently from the system configuration.

## Overview

The configuration includes:
- **Hyprland** window manager with full ecosystem support
- **Waybar** status bar
- **Mako** notification daemon
- **Hypridle** idle manager
- **Hyprlock** screen locker
- **Hyprpaper** wallpaper manager
- Development tools (git, neovim, vscode, etc.)
- Shell configuration (zsh with starship prompt)

## Files

- `flake.nix` - Flake configuration with Hyprland ecosystem inputs
- `home.nix` - Main home-manager configuration
- `hyprland.nix` - Hyprland-specific configuration
- `setup.sh` - Automated setup script

## Installation

### Method 1: Using the Setup Script (Recommended)

As the `jpolo` user, run:

```bash
bash /etc/nixos/home-manager-standalone/setup.sh
```

Then follow the on-screen instructions.

### Method 2: Manual Setup

1. Create the home-manager config directory:
```bash
mkdir -p ~/.config/home-manager
```

2. Copy the configuration files:
```bash
cp /etc/nixos/home-manager-standalone/flake.nix ~/.config/home-manager/
cp /etc/nixos/home-manager-standalone/home.nix ~/.config/home-manager/
cp /etc/nixos/home-manager-standalone/hyprland.nix ~/.config/home-manager/
```

3. Create required directories:
```bash
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Pictures/Screenshots
```

4. Add a default wallpaper to `~/Pictures/Wallpapers/default.jpg`

5. Initialize home-manager:
```bash
cd ~/.config/home-manager
nix run home-manager/master -- switch --flake .#jpolo
```

## Updating the Configuration

After making changes to the configuration files in `~/.config/home-manager/`:

```bash
home-manager switch --flake ~/.config/home-manager#jpolo
```

## Key Features

### Hyprland Configuration
- **Monitor**: Configured for 2880x1800@90Hz with 1.5 scale
- **Plugins**: Hyprexpo for workspace overview
- **Keybindings**: Vi-style navigation (hjkl)
- **Theme**: Catppuccin Mocha colors
- **Animations**: Smooth window transitions

### Applications Included
- **Terminal**: Kitty with JetBrainsMono Nerd Font
- **Browser**: Firefox
- **Editor**: Neovim, VSCode (VSCodium)
- **File Manager**: Thunar
- **Launcher**: Walker
- **Screenshot**: Grimblast

### Services
- **Waybar**: Top status bar with system info
- **Mako**: Notifications
- **Hypridle**: Auto-lock after inactivity
- **Hyprlock**: Screen locker
- **Hyprpaper**: Wallpaper management

## Troubleshooting

### Missing Wallpaper
If you see errors about missing wallpaper:
```bash
cp /path/to/your/image.jpg ~/Pictures/Wallpapers/default.jpg
```

### Fonts Not Rendering
The configuration includes JetBrainsMono Nerd Font. After first switch, you may need to log out and back in.

### Hyprland Not Starting
Ensure the system has Hyprland enabled in `/etc/nixos/hosts/ares/configuration.nix`:
```nix
programs.hyprland.enable = true;
```

## Integration with System Config

This standalone configuration is designed to work with the system configuration at `/etc/nixos/hosts/ares/configuration.nix`. The system provides:
- Hyprland system-level packages
- Display manager (SDDM)
- Fonts
- XDG portals
- Polkit

The home-manager configuration adds:
- User-specific Hyprland settings
- Desktop applications
- Personal dotfiles

## Customization

Edit the files in `~/.config/home-manager/`:
- `home.nix` - General user packages and programs
- `hyprland.nix` - Hyprland-specific settings
- `flake.nix` - Only edit if you need to add new inputs

After changes, run:
```bash
home-manager switch --flake ~/.config/home-manager#jpolo
```

## System Requirements

- NixOS with flakes enabled
- User `jpolo` created on the system
- Hyprland enabled at system level
- Network connection for first-time setup (to download packages)
