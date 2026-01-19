# Home Manager Quick Reference

## ✅ Configuration Status: READY TO BUILD

All home-manager issues have been fixed and the configuration follows best practices.

---

## Build Commands

### Test the configuration (dry-run):
```bash
sudo nixos-rebuild dry-build --flake /etc/nixos#ares
```

### Build without switching:
```bash
sudo nixos-rebuild build --flake /etc/nixos#ares
```

### Build and test (boot into old config if issues):
```bash
sudo nixos-rebuild test --flake /etc/nixos#ares
```

### Build and switch:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

### Update flake inputs first:
```bash
nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

---

## Profile Management

### Current Profile Configuration (ares host):
```nix
home.profiles = {
  base.enable = true;              # ✅ Enabled
  desktop.enable = true;            # ✅ Enabled
  development.enable = true;        # ✅ Enabled
  personal.enable = true;           # ✅ Enabled
  creative.enable = true;           # ✅ Enabled
};
```

### What Each Profile Provides:

#### `base.enable = true` (Always recommended)
**Packages:**
- Core utilities: wget, curl, tree, file
- Archive tools: unzip, zip, p7zip, unrar
- Modern CLI: eza, bat, ripgrep, fd
- System monitoring: btop

**Programs:** None (just packages)

#### `desktop.enable = true`
**Programs:**
- firefox (with privacy extensions)
- kitty terminal
- walker (app launcher)
- swayosd (volume/brightness OSD)
- hyprland (window manager)
- waybar, hypridle, hyprlock

**Packages:**
- Browsers: chromium
- File managers: ranger, yazi
- Document viewers: okular, zathura
- Image viewers: imv, feh
- Office: libreoffice, obsidian
- And more...

#### `development.enable = true`
**Programs:**
- git (with extensive aliases)
- neovim (with LazyVim)
- gh, lazygit
- tmux, zellij
- atuin, direnv, zoxide
- fzf, bat, eza, ripgrep
- Advanced power-user tools

**Features:**
- Dev shells (Python, Node, Rust, Go)
- Direnv templates
- Shell launchers (dev-python, dev-node, etc.)

**Sub-options:**
```nix
development.devShells.enable = true;
development.devShells.enableLaunchers = true;
development.devShells.enableDirenvTemplates = true;
development.editors.vscode.enable = true;
development.editors.neovim.enable = true;
```

#### `personal.enable = true`
**Packages:**
- Communication: discord, telegram, slack, zoom
- Media: mpv, vlc, plexamp
- Productivity: timewarrior, taskwarrior, rclone, syncthing

**Sub-options:**
```nix
personal.communication.enable = true;
personal.media.enable = true;
personal.productivity.enable = true;
```

#### `creative.enable = true`
**Packages:**
- Graphics: gimp, inkscape, krita
- Video: kdenlive, obs-studio, wf-recorder
- Audio: audacity

**Sub-options:**
```nix
creative.graphics.enable = true;
creative.video.enable = true;
creative.audio.enable = true;
```

---

## Architecture Overview

```
Configuration Root: /etc/nixos
├── flake.nix                    # Main flake configuration
│   ├── inputs (nixpkgs, home-manager, hyprland, etc.)
│   ├── outputs
│   │   └── nixosConfigurations.ares
│   └── sharedModules (home-manager integration)
│
├── hosts/ares/
│   ├── configuration.nix        # Host-specific config
│   └── hardware-configuration.nix
│
├── home/
│   ├── users/jpolo.nix          # User configuration
│   │   └── imports: services, shell, profiles
│   │
│   ├── profiles/                # Profile system
│   │   ├── base.nix             (core packages)
│   │   ├── desktop.nix          (imports desktop programs)
│   │   ├── development.nix      (imports dev programs)
│   │   ├── personal.nix         (packages only)
│   │   └── creative.nix         (packages only)
│   │
│   ├── programs/                # Program modules (imported by profiles)
│   │   ├── git.nix              (conditional on development.enable)
│   │   ├── neovim.nix           (conditional on development.enable)
│   │   ├── firefox.nix          (conditional on desktop.enable)
│   │   ├── kitty.nix            (conditional on desktop.enable)
│   │   └── ...
│   │
│   ├── shell/                   # Shell configuration (always loaded)
│   │   ├── zsh.nix
│   │   └── starship.nix
│   │
│   ├── services/                # User services (always loaded)
│   │   ├── mako.nix
│   │   └── hyprsunset.nix
│   │
│   └── hyprland/                # Hyprland specific (imported by desktop profile)
│       ├── hyprland.nix
│       ├── waybar.nix
│       ├── hypridle.nix
│       └── hyprlock.nix
│
└── modules/                     # System-level modules
    ├── system/
    ├── desktop/
    ├── services/
    ├── development/
    └── profiles/
```

---

## How to Customize

### Add a new program to desktop profile:

1. Create `/home/programs/myprogram.nix`:
```nix
{ config, pkgs, lib, ... }:

{
  programs.myprogram = {
    enable = lib.mkDefault (config.home.profiles.desktop.enable or false);
    # ... configuration ...
  };
}
```

2. Import it in `/home/profiles/desktop.nix`:
```nix
imports = [
  ../programs/firefox.nix
  ../programs/kitty.nix
  ../programs/myprogram.nix  # Add this
  # ...
];
```

### Disable a specific program:

In `/home/users/jpolo.nix`:
```nix
programs.firefox.enable = false;  # Disable firefox even if desktop.enable = true
```

### Add a new profile:

1. Create `/home/profiles/gaming.nix`:
```nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.gaming = {
    enable = mkEnableOption "gaming profile";
  };

  config = mkIf config.home.profiles.gaming.enable {
    home.packages = with pkgs; [
      steam
      lutris
      # ...
    ];
  };
}
```

2. Import it in `/home/profiles/default.nix`

3. Enable in `/home/users/jpolo.nix`:
```nix
home.profiles.gaming.enable = true;
```

---

## Troubleshooting

### Check what's enabled:
```bash
# List all home packages
nix-store -q --references ~/.nix-profile | grep -v '.drv$'

# Check if a program is enabled
nix eval /etc/nixos#nixosConfigurations.ares.config.home-manager.users.jpolo.programs.firefox.enable
```

### Rebuild with verbose output:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares --show-trace
```

### Check for errors without building:
```bash
nix flake check /etc/nixos
```

### View the configuration:
```bash
nix eval /etc/nixos#nixosConfigurations.ares.config --json | jq .
```

---

## Documentation Files

- `HOME_MANAGER_FIXES_SUMMARY.md` - Complete list of all changes made
- `HOME_MANAGER_QUICK_REFERENCE.md` - This file
- See existing documentation for system modules and other features

---

## Summary

✅ All home-manager issues fixed  
✅ Conditional program loading implemented  
✅ Modular profile-based architecture  
✅ Following NixOS best practices  
✅ Ready to build!

**Next step:** Run `sudo nixos-rebuild switch --flake /etc/nixos#ares`
