# Home Manager Setup Guide - Best Practices

## ✅ Your NixOS System is Working!

Now let's set up home-manager the right way.

## Quick Start

### 1. Copy Configuration to Your Home Directory

As user **jpolo** (not root):

```bash
su - jpolo

# Create home-manager config directory
mkdir -p ~/.config/home-manager

# Copy the flake
cp /etc/nixos/home-manager-standalone/flake.nix ~/.config/home-manager/
cp /etc/nixos/home-manager-standalone/home.nix ~/.config/home-manager/

# Navigate to it
cd ~/.config/home-manager
```

### 2. Initialize Home-Manager

```bash
# First time setup
nix run home-manager/master -- switch --flake ~/.config/home-manager
```

That's it! Home-manager is now managing your user environment.

### 3. Make Changes

Edit `~/.config/home-manager/home.nix`:

```bash
vim ~/.config/home-manager/home.nix
```

Apply changes:

```bash
home-manager switch --flake ~/.config/home-manager
```

## What's Included

The default configuration includes:

**Shell:**
- Zsh with autosuggestions and syntax highlighting
- Starship prompt
- Useful aliases (ls → eza, cat → bat, etc.)

**Development:**
- Git with your config
- GitHub CLI (gh)
- Neovim
- VSCode/VSCodium
- Direnv
- Tmux

**CLI Tools:**
- Modern replacements: eza, bat, ripgrep, fd
- htop, btop, neofetch
- Archive tools

**GUI Apps:**
- Firefox
- Kitty terminal

## Best Practices

### 1. Structure Your Config

For larger configs, split into modules:

```
~/.config/home-manager/
├── flake.nix          # Entry point
├── home.nix           # Main config
├── programs/
│   ├── git.nix
│   ├── neovim.nix
│   └── zsh.nix
└── profiles/
    ├── base.nix       # Essential tools
    ├── development.nix
    └── desktop.nix
```

Example modular `home.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./programs/git.nix
    ./programs/zsh.nix
    ./programs/neovim.nix
  ];

  home.username = "jpolo";
  home.homeDirectory = "/home/jpolo";
  home.stateVersion = "25.11";
  
  programs.home-manager.enable = true;
}
```

### 2. Use Version Control

```bash
cd ~/.config/home-manager
git init
git add .
git commit -m "Initial home-manager config"
```

### 3. Update Regularly

```bash
# Update flake inputs
nix flake update ~/.config/home-manager

# Apply updates
home-manager switch --flake ~/.config/home-manager
```

### 4. Common Commands

```bash
# Apply configuration
home-manager switch --flake ~/.config/home-manager

# Check what would change (dry-run)
home-manager build --flake ~/.config/home-manager

# List generations
home-manager generations

# Rollback to previous generation
home-manager generations | grep -m2 "id" | tail -n1 | awk '{print $7}' | xargs home-manager switch --flake
```

## Adding More Programs

### Example: Add Hyprland Config

In `home.nix`:

```nix
{
  # ... existing config ...

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, RETURN, exec, kitty"
        "$mod, Q, killactive"
        "$mod, M, exit"
      ];
    };
  };
}
```

### Example: Add More Packages

```nix
{
  home.packages = with pkgs; [
    discord
    spotify
    obsidian
    # ... more packages
  ];
}
```

## Integration with System Config

**System manages** (in `/etc/nixos`):
- Services (docker, ssh, etc.)
- Kernel and boot
- System-wide packages
- Network configuration

**Home-manager manages** (in `~/.config/home-manager`):
- User dotfiles
- User-specific programs
- Shell configuration
- User services

## Troubleshooting

### Issue: "collision between X and Y"

Two packages provide the same file. Solutions:

1. Disable one: `programs.X.enable = false;`
2. Or use `lib.mkForce` to override
3. Or use different package variants

### Issue: Changes not applying

```bash
# Clean and rebuild
home-manager switch --flake ~/.config/home-manager --refresh
```

### Issue: Want to start over

```bash
# Remove current generation
home-manager remove-generations all
home-manager switch --flake ~/.config/home-manager
```

## Advanced: Flake Templates

You can copy configs from the system flake if needed:

```nix
# In ~/.config/home-manager/flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    
    # Reference system config
    nixos-config.url = "path:/etc/nixos";
  };
  
  # Can now use inputs from system
}
```

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- Your system flake: `/etc/nixos/flake.nix`

## Next Steps

1. ✅ Copy config: `cp /etc/nixos/home-manager-standalone/* ~/.config/home-manager/`
2. ✅ Initialize: `nix run home-manager/master -- switch --flake ~/.config/home-manager`
3. ✅ Customize: Edit `~/.config/home-manager/home.nix`
4. ✅ Apply: `home-manager switch --flake ~/.config/home-manager`
5. ✅ Enjoy your declarative dotfiles!

Happy NixOS-ing! 🎉
