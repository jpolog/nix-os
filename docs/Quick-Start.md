# Quick Start Guide

Get up and running with a fully declarative, reproducible NixOS system.

## Philosophy

This configuration is **100% declarative**:
- No manual configuration files
- No imperative commands
- Everything in Nix
- Fully reproducible across machines

## Prerequisites

- NixOS installed (minimal or from ISO)
- Internet connection

## Installation

### 1. Clone the Repository

```bash
cd ~/Projects
git clone https://github.com/yourusername/nix-omarchy.git
cd nix-omarchy/nix
```

### 2. Hardware Configuration

**IMPORTANT**: Hardware configuration is the ONLY non-declarative part:

```bash
# Generate hardware-specific settings
sudo nixos-generate-config --show-hardware-config > hosts/ares/hardware-configuration.nix
```

This file contains:
- Filesystem mounts
- Boot loader settings specific to your disk
- Hardware-specific kernel modules

Everything else is declarative!

### 3. Customize Variables (Optional)

Edit `hosts/ares/configuration.nix` for machine-specific settings:

```nix
{
  # Change hostname if needed (default: ares)
  networking.hostName = "your-hostname";
  
  # Change timezone if needed (default: Europe/Madrid)
  time.timeZone = "Your/Timezone";
  
  # User is defined declaratively - no manual user creation needed!
  # See users.users.jpolo in configuration.nix
}
```

Edit `home/programs/git.nix` for your Git identity:

```nix
{
  programs.git = {
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
}
```

### 4. Deploy (Single Command!)

```bash
sudo nixos-rebuild switch --flake .#ares
```

That's it! Everything is configured declaratively:
- User account created automatically
- All packages installed
- All services configured
- Shell and environment set up
- No manual configuration needed!

### 5. Reboot

```bash
sudo reboot
```

## Secrets Management (Declarative!)

This configuration uses **sops-nix** for declarative secrets management.

### First-Time Setup

The age key should be generated on the target machine:

```bash
# This is the ONLY imperative step for secrets
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

**Why this is needed**: The private key must remain on the machine and never be in git.

### Get Your Public Key

```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

### Update Configuration

Edit `.sops.yaml` with your public key:

```yaml
keys:
  - &your_key age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

creation_rules:
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
    - age:
      - *your_key
```

### Create Secrets (Declaratively!)

```bash
# Edit secrets file (encrypted automatically)
sops secrets/secrets.yaml
```

Add your secrets:

```yaml
wifi_password: "your-wifi-password"
user_password: "your-hashed-password"
ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
```

### Use Secrets in Configuration

Secrets are automatically decrypted at boot and available to your configuration:

```nix
# Example: WiFi password
sops.secrets.wifi_password = {
  sopsFile = ../secrets/secrets.yaml;
  owner = "jpolo";
};

# Use it declaratively
networking.wireless.networks."YourSSID".psk = 
  config.sops.secrets.wifi_password.path;
```

**No manual configuration files!** Everything is declared in Nix.

## Post-Installation (All Declarative!)

After reboot, everything is already configured:

✅ User account exists (declared in `configuration.nix`)  
✅ Shell is ZSH (declared in `users.users.jpolo.shell`)  
✅ All packages installed (declared in various modules)  
✅ All services running (declared in modules)  
✅ Hyprland configured (declared in `home/hyprland/`)  
✅ Git configured (declared in `home/programs/git.nix`)  

### Verify Installation

```bash
# Check system health (script installed declaratively)
check-system

# List available scripts (all declared in modules/system/scripts.nix)
scripts

# Interactive script browser
scriptctl interactive
```

### Explore Your System

```bash
# Create a development environment (uses declarative flake.nix shells)
dev-env myproject python
cd myproject
direnv allow  # Uses declarative .envrc from script

# All development tools already available!
python --version
nvim
git status
```

## Multi-Machine Deployment

To deploy on a second machine:

1. **Generate hardware config** (only machine-specific part):
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/newmachine/hardware-configuration.nix
   ```

2. **Create host configuration** (copy and modify):
   ```bash
   cp -r hosts/ares hosts/newmachine
   # Edit hosts/newmachine/configuration.nix
   ```

3. **Add to flake.nix**:
   ```nix
   nixosConfigurations = {
     ares = { ... };
     newmachine = nixpkgs.lib.nixosSystem {
       # ... same as ares but pointing to hosts/newmachine
     };
   };
   ```

4. **Deploy**:
   ```bash
   sudo nixos-rebuild switch --flake .#newmachine
   ```

All your settings, packages, and configuration come with you!

## What's Declarative Here?

Everything except hardware-configuration.nix:

### ✅ Fully Declarative
- **User accounts** - declared in `configuration.nix`
- **Packages** - declared in various `.nix` files
- **Services** - declared in `modules/`
- **Shell configuration** - declared in `home/shell/zsh.nix`
- **Application settings** - declared in `home/programs/`
- **Hyprland config** - declared in `home/hyprland/`
- **Scripts** - declared in `modules/system/scripts.nix`
- **Secrets** - declared and encrypted with sops-nix
- **Git config** - declared in `home/programs/git.nix`
- **SSH keys** - can be managed with sops (see below)

### ❌ Not Declarative (By Design)
- **Hardware configuration** - machine-specific, auto-generated
- **Age private key** - must stay on machine for security

## SSH Keys (Declarative Option)

### Option 1: Generate on Machine (Traditional)
```bash
# Let NixOS generate for you (declarative!)
# Add to configuration.nix:
services.openssh.enable = true;
users.users.jpolo.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3... your-public-key"
];
```

### Option 2: Manage with Secrets (Fully Declarative!)

Store your SSH private key in secrets:

```bash
# Add to secrets/secrets.yaml
sops secrets/secrets.yaml
```

```yaml
ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
```

Use in configuration:

```nix
# In your configuration
sops.secrets.ssh_private_key = {
  sopsFile = ../secrets/secrets.yaml;
  path = "/home/jpolo/.ssh/id_ed25519";
  owner = "jpolo";
  mode = "0600";
};
```

**Result**: SSH key automatically deployed on all machines!

## Passwords (Declarative!)

User passwords can be managed declaratively:

### Option 1: Password Hash in Configuration

```nix
# Generate hash:
# mkpasswd -m sha-512

users.users.jpolo.hashedPassword = "$6$rounds=656000$...";
```

### Option 2: Password in Secrets (Recommended)

```bash
# Add to secrets/secrets.yaml
sops secrets/secrets.yaml
```

```yaml
jpolo_password: "$6$rounds=656000$..."
```

Use in configuration:

```nix
sops.secrets.jpolo_password.neededForUsers = true;

users.users.jpolo.hashedPasswordFile = 
  config.sops.secrets.jpolo_password.path;
```

**Result**: Same password on all machines, managed declaratively!

## Daily Workflow

### System Updates (Declarative!)

```bash
# Update flake inputs (declarative dependencies)
cd ~/Projects/nix-omarchy/nix
nix flake update

# Rebuild system (apply declarative configuration)
rebuild

# Everything updated declaratively!
```

### Add New Package (Declarative!)

Edit `home/jpolo.nix`:

```nix
home.packages = with pkgs; [
  # Add your package here
  neovim
];
```

Then rebuild:

```bash
rebuild
```

**No manual installation!** Package is now part of your declarative config.

### Modify System Settings (Declarative!)

Edit appropriate `.nix` file, then:

```bash
rebuild
```

All changes are:
- Version controlled
- Reproducible
- Rollback-able

## Troubleshooting

### Build Fails

```bash
# Validate flake
nix flake check

# Verbose output
sudo nixos-rebuild switch --flake .#ares --show-trace
```

### Rollback

Declarative configs can be rolled back:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback
sudo nixos-rebuild switch --rollback

# Or select at boot (GRUB/systemd-boot menu)
```

### Configuration Doesn't Apply

Ensure you rebuilt:

```bash
rebuild
```

Remember: Changes to `.nix` files don't apply until you rebuild!

## Best Practices

### ✅ DO
- Keep everything in Nix configuration
- Use sops for secrets
- Version control your config
- Test changes with `nixos-rebuild test` first
- Document your changes

### ❌ DON'T
- Manually edit files in `/etc/` (they'll be overwritten)
- Install packages with `nix-env -i` (not declarative)
- Create users manually (declare them in config)
- Edit config files in `~/.config/` manually (use Home Manager)

## Understanding the Stack

```
Your Declarative Configuration (.nix files)
           ↓
    nix flake update (update dependencies)
           ↓
    nixos-rebuild switch (apply config)
           ↓
    System State (reproducible!)
```

Everything flows from your `.nix` files!

## Next Steps

1. **Understand the structure**:
   - Read [Project-Overview.md](Project-Overview.md)
   - Explore module files in `modules/`
   - Check `home/` for user config

2. **Customize**:
   - Edit `.nix` files (not config files!)
   - Rebuild to apply changes
   - Commit to git

3. **Learn NixOS**:
   - [NixOS Manual](https://nixos.org/manual/nixos/stable/)
   - [Nix Pills](https://nixos.org/guides/nix-pills/)
   - [Home Manager Manual](https://nix-community.github.io/home-manager/)

## Tips

- **Everything is code**: Your entire system is declared in `.nix` files
- **Git is your backup**: All config is version controlled
- **Rollbacks are easy**: Boot into previous generation if something breaks
- **No surprises**: System state matches your configuration files
- **Portable**: Same config works on multiple machines

---

**Welcome to fully declarative NixOS!** 🚀

Your system is now:
- ✅ Reproducible
- ✅ Version controlled
- ✅ Self-documenting
- ✅ Portable
- ✅ Rollback-able

## 🚀 First Boot

After installation and first login:

### 1. Verify System

```bash
# Check system info
neofetch

# Verify Hyprland is running
hyprctl version

# Check network
nmcli device status
```

### 2. Connect to WiFi

**GUI**: Click WiFi icon in Waybar (top-right)

**CLI**:
```bash
# List networks
nmcli device wifi list

# Connect
nmcli device wifi connect "SSID" password "password"
```

### 3. Update System

```bash
# Update flake inputs
cd ~/Projects/nix-omarchy/nix
nix flake update

# Rebuild system
sudo nixos-rebuild switch --flake .#ares
```

## ⌨️ Essential Keybindings

### Most Important

| Keys | Action |
|------|--------|
| `Super + Return` | Open terminal |
| `Super + R` | App launcher |
| `Super + Q` | Close window |
| `Super + E` | File manager |
| `Super + L` | Lock screen |
| `Super + 1-9` | Switch workspace |

**Super** = Windows key

See [[Keybindings]] for complete list.

## 🎯 Common Tasks

### Open Applications

Press `Super + R` and type:
- `firefox` - Web browser
- `code` - VS Code
- `discord` - Discord
- `spotify` - Music

### Take Screenshot

- `Print Screen` - Area to clipboard
- `Shift + Print` - Full screen to clipboard
- `Super + Print` - Area to file

### Volume Control

- `Fn + F1` - Mute
- `Fn + F2` - Volume down
- `Fn + F3` - Volume up

Or click volume icon in Waybar.

### Brightness

- `Fn + F5` - Decrease
- `Fn + F6` - Increase

## 🔧 Configuration

### Personal Details

Edit `home/jpolo.nix`:
```nix
programs.git = {
  userName = "Your Name";
  userEmail = "your@email.com";
};
```

### Timezone

Edit `hosts/ares/configuration.nix`:
```nix
time.timeZone = "America/New_York";  # Change this
```

### Monitor

Edit `home/hyprland/hyprland-config.nix`:
```nix
monitor = [
  "eDP-1,2880x1800@90,0x0,1.5"  # Adjust for your display
];
```

Find monitor name:
```bash
hyprctl monitors
```

### Apply Changes

```bash
cd ~/Projects/nix-omarchy/nix
sudo nixos-rebuild switch --flake .#ares
```

Or use the alias:
```bash
update
```

## 📱 Setup Tools

### Fingerprint Reader

```bash
# Enroll your fingerprint
fprintd-enroll

# Test it
fprintd-verify
```

Now you can use fingerprint for sudo and lock screen!

### Bluetooth Devices

1. Click Bluetooth icon in Waybar
2. Select "Setup New Device"
3. Follow pairing wizard

**CLI**:
```bash
bluetoothctl
scan on
pair <MAC_ADDRESS>
connect <MAC_ADDRESS>
trust <MAC_ADDRESS>
```

### SSH Keys

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub
```

### Git Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global init.defaultBranch main
```

## 📦 Installing Software

### Add System Package

Edit `hosts/ares/configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  your-package
];
```

### Add User Package

Edit `home/jpolo.nix`:
```nix
home.packages = with pkgs; [
  your-package
];
```

### Search Packages

```bash
nix search nixpkgs package-name
```

Or visit: https://search.nixos.org/packages

### Apply Changes

```bash
update
```

## 🎨 Customization

### Wallpaper

1. Save wallpaper to `~/Pictures/Wallpapers/`
2. Edit `home/hyprland/hyprland-config.nix`
3. Add to `exec-once`:
   ```nix
   exec-once = [
     "swaybg -i ~/Pictures/Wallpapers/wallpaper.jpg"
   ];
   ```

### Theme Colors

Main files to edit:
- **Waybar**: `home/hyprland/waybar.nix`
- **Kitty**: `home/programs/kitty.nix`
- **Mako**: `home/services/mako.nix`

See [[Customization]] for details.

## 💻 Development Setup

### Neovim (LazyVim)

First launch downloads plugins automatically:
```bash
nvim
```

Wait for plugins to install, then restart.

### VS Code

```bash
code
```

Install extensions as needed.

### Development Tools

Already installed:
- Git
- Node.js
- Python 3
- Rust (cargo)
- Go

## 📚 Learn More

### Navigation

- **Switch workspace**: `Super + 1-9`
- **Move window**: `Super + Shift + 1-9`
- **Scratchpad**: `Super + S`
- **Float window**: `Super + V`
- **Fullscreen**: `Super + F`

### Terminal

Default: Kitty
- **New tab**: `Ctrl + Shift + T`
- **Next tab**: `Ctrl + Shift + →`
- **Close tab**: `Ctrl + Shift + Q`

### File Manager

Thunar is the GUI file manager (`Super + E`)

Terminal file manager:
```bash
ranger
```

## 🆘 Getting Help

### View Logs

```bash
# System logs
journalctl -b

# Hyprland logs
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -n 1)/hyprland.log
```

### Rollback Changes

If something breaks:
```bash
sudo nixos-rebuild switch --rollback
```

### Documentation

- [[README]] - Overview
- [[Keybindings]] - All shortcuts
- [[Applications]] - Installed software
- [[Troubleshooting]] - Fix issues

## ✅ Checklist

After setup, you should:

- [ ] Connect to WiFi
- [ ] Update system
- [ ] Set timezone
- [ ] Configure git
- [ ] Enroll fingerprint
- [ ] Pair Bluetooth devices
- [ ] Set wallpaper
- [ ] Install additional software
- [ ] Customize theme (optional)
- [ ] Create backups

## 🎯 Next Steps

1. **Explore**: Try different applications
2. **Customize**: Make it yours
3. **Learn**: Read documentation
4. **Backup**: Keep configuration in git

### Useful Commands

```bash
# System info
neofetch

# Check resources
btop

# Check battery
acpi -V

# Check network
nmcli device status

# Check Bluetooth
bluetoothctl devices
```

## 💡 Pro Tips

1. **Use aliases**: `ll`, `vim`, `g` are pre-configured
2. **Clipboard history**: Access via Walker or cliphist
3. **Window rules**: Learn tiling shortcuts
4. **Starship prompt**: Shows git status, directory, etc.
5. **Zoxide**: Better `cd` - remembers your paths

### Aliases to Remember

```bash
ll          # List files (eza)
vim         # Opens neovim
g           # Git
update      # Update system
cleanup     # Clean old generations
edit-nix    # Edit configuration
```

## 📖 Documentation Structure

```
docs/
├── README.md                    # Overview
├── Installation.md              # Install guide
├── Quick-Start.md              # This file
├── Keybindings.md              # Shortcuts
├── Applications.md             # Software list
├── Desktop-Environment.md      # Desktop setup
├── System-Configuration.md     # System config
├── Hardware-Support.md         # Hardware guide
├── Customization.md            # Customize
├── Troubleshooting.md          # Fix issues
└── NixOS-Basics.md            # Learn NixOS
```

## 📚 Related Documentation

- [[Keybindings]] - Complete shortcuts list
- [[Applications]] - Software guide
- [[Customization]] - Make it yours
- [[Troubleshooting]] - When things break

---

**Last Updated**: 2026-01-06

**Welcome to your new NixOS system! 🎉**
