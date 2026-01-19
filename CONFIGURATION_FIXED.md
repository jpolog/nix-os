# NixOS Configuration - Complete Restructure Summary

## ✅ What Was Fixed

Your NixOS configuration has been completely restructured to follow best practices. Here's what changed:

### 1. **Re-integrated Home Manager**
- ✅ Added home-manager NixOS module back into `flake.nix`
- ✅ Configured to use global packages and user packages
- ✅ Passes `inputs` to home-manager for Hyprland ecosystem

### 2. **Activated Profile System**
- ✅ System profiles enabled in `hosts/ares/configuration.nix`
- ✅ Home profiles enabled in `home/users/jpolo.nix`
- ✅ Everything is now toggleable via `enable` options

### 3. **Separated Package Installation from Configuration**
- ✅ **System profiles** (`modules/profiles/`) now install packages
- ✅ **Home profiles** (`home/profiles/`) now only configure packages
- ✅ No more duplication

### 4. **Made Configuration Modular**
- ✅ Toggle profiles per host
- ✅ Toggle profiles per user
- ✅ Fine-grained control over what's installed

---

## 📁 New Architecture

```
/etc/nixos/
├── flake.nix                    # Main flake with home-manager integration
├── hosts/
│   └── ares/
│       └── configuration.nix    # Enables profiles, configures users
├── modules/                     # SYSTEM LEVEL (what to install)
│   └── profiles/
│       ├── base.nix            # ✅ Installs base packages
│       ├── desktop.nix         # ✅ Installs desktop apps
│       └── development.nix     # ✅ Installs dev tools
└── home/                        # USER LEVEL (how to configure)
    ├── users/
    │   └── jpolo.nix           # ✅ User config with profile enables
    └── profiles/
        ├── base.nix            # ✅ Configures shell, git, etc.
        ├── desktop.nix         # ✅ Configures Firefox, Kitty, etc.
        └── development.nix     # ✅ Configures tmux, direnv, etc.
```

---

## 🔧 How It Works Now

### hosts/ares/configuration.nix
```nix
# Enable SYSTEM profiles (installs packages)
profiles.base.enable = true;
profiles.desktop.enable = true;
profiles.development.enable = true;

# Configure which dev tools to install
profiles.development.languages.python.enable = true;
profiles.development.languages.nodejs.enable = true;
profiles.development.tools.docker.enable = true;

# User configuration with HOME profiles
home-manager.users.jpolo = import ../../home/users/jpolo.nix;
```

### home/users/jpolo.nix
```nix
# Enable HOME profiles (configures packages)
home.profiles.base.enable = true;
home.profiles.desktop.enable = true;
home.profiles.development.enable = true;

# User-specific git config
programs.git = {
  userName = "Javier Polo Gambin";
  userEmail = "javier.polog@outlook.com";
};
```

### What Each Profile Does

#### System Profiles (Install Packages)

**`profiles.base.enable`** installs:
- vim, nano, neovim
- wget, curl, git
- htop, btop, neofetch
- tree, eza, fd, ripgrep, bat
- unzip, zip, p7zip

**`profiles.desktop.enable`** installs:
- firefox, chromium
- kitty, alacritty
- thunar, ranger, yazi
- grimblast, swayosd
- bitwarden, obsidian
- walker, brightnessctl
- And all Hyprland ecosystem packages

**`profiles.development.enable`** installs:
- gh, lazygit, tmux
- jq, yq-go, fzf
- Python/Node.js/Rust/Go (if enabled)
- Docker (if enabled)
- Cloud tools (if enabled)

#### Home Profiles (Configure Packages)

**`home.profiles.base`** configures:
- Git aliases and settings
- Zsh with completions and aliases
- Starship prompt
- XDG directories
- Shell aliases (ls→eza, cat→bat, etc.)

**`home.profiles.desktop`** configures:
- Firefox settings and profiles
- Kitty terminal settings
- Neovim as default editor
- Hyprland window manager
- Waybar, Mako, Hypridle, Hyprlock
- SwayOSD systemd service

**`home.profiles.development`** configures:
- Tmux settings
- Direnv with nix-direnv
- Dev shell launcher scripts
- Direnv templates
- Lazygit configuration

---

## 🎯 Key Improvements

### 1. Modularity
```nix
# Want a server instead? Just change:
profiles.desktop.enable = false;
profiles.server.enable = true;

# Don't need development?
profiles.development.enable = false;
```

### 2. No Duplication
- **Before**: Packages installed in both system and home-manager
- **After**: Packages only in system, configs only in home-manager

### 3. Clear Separation
- **System**: "Install Firefox, Kitty, Python"
- **Home**: "Configure Firefox with these settings, Kitty with this font"

### 4. Per-User Customization
```nix
home-manager.users.jpolo = {
  home.profiles.desktop.enable = true;
};

home-manager.users.alice = {
  home.profiles.desktop.enable = false;  # Alice is CLI-only
};
```

---

## 📋 Current Configuration for Ares Host

### System Level
- ✅ Base profile: Essential tools
- ✅ Desktop profile: Hyprland + apps
- ✅ Development profile: Python + Node.js + Docker

### User jpolo
- ✅ Base profile: Shell configuration
- ✅ Desktop profile: Hyprland configuration
- ✅ Development profile: Dev tools configuration

---

## 🚀 How to Use

### Rebuild System
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

This will:
1. Install all packages from enabled system profiles
2. Configure all dotfiles from enabled home profiles
3. Apply user-specific settings

### Toggle Features

Edit `/etc/nixos/hosts/ares/configuration.nix`:

```nix
# Disable desktop
profiles.desktop.enable = false;

# Add Rust development
profiles.development.languages.rust.enable = true;

# Enable cloud tools
profiles.development.tools.cloud.enable = true;
```

Then rebuild.

### Add New User

```nix
# In hosts/ares/configuration.nix
users.users.alice = {
  isNormalUser = true;
  extraGroups = [ "wheel" ];
};

home-manager.users.alice = {
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  home.stateVersion = "25.11";
  
  # Alice only needs CLI
  home.profiles.base.enable = true;
  home.profiles.development.enable = true;
};
```

---

## 📦 What About home-manager-standalone?

The `home-manager-standalone/` directory is **no longer needed** but has been kept for reference. You're now using the integrated approach which is:
- ✅ More maintainable
- ✅ Rebuilt with system
- ✅ Properly integrated
- ✅ No manual steps needed

If you want to remove it:
```bash
rm -rf /etc/nixos/home-manager-standalone
```

---

## 🎓 Understanding the Pattern

### Example Flow: Installing Firefox

1. **System Profile** (`modules/profiles/desktop.nix`):
   ```nix
   environment.systemPackages = [ pkgs.firefox ];
   ```
   → Firefox binary installed system-wide

2. **Home Profile** (`home/profiles/desktop.nix`):
   ```nix
   programs.firefox = {
     enable = true;  # Don't re-install, just configure
     profiles.default.settings = { /* ... */ };
   };
   ```
   → Firefox configured with user preferences

3. **User File** (`home/users/jpolo.nix`):
   ```nix
   home.profiles.desktop.enable = true;
   ```
   → User jpolo gets the Firefox configuration

### Result
- Firefox installed once (system)
- Firefox configured per user (home-manager)
- User can toggle it on/off easily

---

## ✅ Checklist: What's Complete

- [x] Home Manager re-integrated into NixOS
- [x] System profiles activated in ares host
- [x] Home profiles activated for jpolo user
- [x] Package installation moved to system profiles
- [x] Configuration moved to home profiles
- [x] No package duplication
- [x] Everything modular and toggleable
- [x] Hyprland fully configured
- [x] Development tools properly split
- [x] User-specific settings in user file

---

## 🎉 Your Configuration Now Follows Best Practices!

Your NixOS setup is now:
- ✅ **Modular**: Toggle any feature easily
- ✅ **Maintainable**: Clear separation of concerns
- ✅ **Scalable**: Easy to add new hosts/users
- ✅ **Declarative**: Everything in version control
- ✅ **Idempotent**: Same config = same result

Enjoy your properly structured NixOS configuration! 🚀
