# NixOS Omarchy Configuration

A **modular, profile-based NixOS configuration** for desktops, laptops, and servers. Deploy anywhere from ThinkPad laptops to Proxmox homelab infrastructure with selective feature installation.

## 🎯 What is This?

A **universal NixOS configuration** that adapts to your needs using **profiles**:
- 💻 **Desktops/Laptops**: Full Hyprland desktop with development tools
- 🖥️ **Servers**: Headless configurations for web, database, docker, monitoring
- 🏠 **Homelab**: Proxmox-ready VMs with role-based profiles
- 🔧 **Reproducible**: Same config, different machines, selective features

**Example Hosts**:
- `ares` - ThinkPad T14s Gen 6 AMD (development laptop)
- `web-server` - Nginx reverse proxy + Docker
- `database-server` - PostgreSQL + Redis
- `monitoring-server` - Prometheus + Grafana
- And more...

## ✨ Key Features

### 🎯 Profile System (NEW!)
- **Modular Architecture** - Enable only what you need per machine
- **6 Profiles**: base, desktop, development, gaming, power-user, server
- **Granular Control** - Toggle languages, tools, services independently
- **Disk Savings** - 8-12GB (minimal) vs 15-20GB (full installation)

### 💻 Desktop/Laptop Profile
- 🪟 **Hyprland** - Wayland compositor with hyprscroller plugin
- 📊 **Waybar** - Customizable status bar with Catppuccin theme
- ⌨️ **LazyVim** - Fully configured Neovim with LSP support
- 🐚 **Advanced ZSH** - 100+ aliases, VI mode, FZF integration
- 🎨 **Catppuccin Theme** - Consistent across all applications

### 🛠️ Development Profile
- **Languages** (toggle individually): Python, Node.js, Rust, Go, C/C++, Java, Zig
- **Tools** (toggle individually): Docker, Cloud CLIs, Kubernetes, Databases, API testing
- **LSP Servers**: nil, pyright, rust-analyzer, gopls, tsserver
- **Version Control**: Git, GitHub CLI, lazygit, delta diffs

### 🖥️ Server Profile (NEW!)
- **Headless** - No GUI, minimal overhead, optimized for servers
- **Roles**: web, database, docker, monitoring, storage, general
- **Services**: Nginx, PostgreSQL, Redis, Docker, Prometheus, Grafana, Loki
- **Security**: SSH hardening, Fail2ban, AppArmor, firewall
- **Automation**: Auto-updates, garbage collection, backups (restic)

### 🎮 Gaming Profile
- **Isolated Environment** - Sandboxed user, resource limits
- **Steam + Proton** - Latest compatibility layers
- **GameMode** - Performance optimization
- **Security** - No sudo, no docker, restricted filesystem

### 🔬 Power User Profile
- **Scientific**: Octave (MATLAB alternative), Jupyter notebooks
- **Creative**: GIMP, Inkscape, Krita, Blender, Kdenlive, OBS
- **Advanced Tools**: Terminal power-tools, network analysis, monitoring

### 🔐 System Features
- **Secrets Management** - sops-nix (encrypted in git)
- **Reproducible** - Same config builds identically
- **Rollback** - Boot menu or `nixos-rebuild --rollback`
- **Optimization** - BBR TCP, zram, kernel tuning
- **Scripts** - 10+ production-ready management scripts

## 🚀 Quick Start

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/nix-omarchy.git
   cd nix-omarchy/nix
   ```

2. **Generate hardware configuration** (only machine-specific part):
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/ares/hardware-configuration.nix
   ```

3. **Customize user settings** (all declarative!):
   - Edit `home/programs/git.nix` for your git identity
   - Edit `hosts/ares/configuration.nix` for timezone/hostname
   - Edit `home/jpolo.nix` for your packages

4. **Deploy** (single command!):
   ```bash
   sudo nixos-rebuild switch --flake .#ares
   ```

Everything else is configured automatically and declaratively!

### Secrets Setup (Optional)

For WiFi passwords, SSH keys, etc.:

1. **Generate age key**:
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

2. **Add public key to `.sops.yaml`** (your age public key)

3. **Create secrets**:
   ```bash
   sops secrets/secrets.yaml
   ```

See [secrets/README.md](secrets/README.md) for details.

## 📋 Daily Usage

### System Management
```bash
update                   # Update system and flake inputs
check                    # Check system health
clean                    # Clean old generations
backup                   # Backup important files
monitor                  # System resource monitor
rebuild                  # Rebuild system configuration
```

### Development
```bash
dev-env myapp python     # Create Python project environment
dev-env webapp node      # Create Node.js project environment
nix-search postgresql    # Search for Nix packages
docker-mon               # Monitor Docker containers

# Port management
ports                    # List all active ports
pf 3000                  # Find what's using port 3000
pk 8080                  # Kill process on port 8080
prec frontend            # Get recommended frontend port
```

### Shell Features
```bash
# FZF shortcuts
Ctrl+R                   # Search history with atuin
Ctrl+T                   # Search files
Alt+C                    # Change directory

# Custom functions
fe                       # Find and edit file
fcd                      # Find and change directory
fgl                      # Browse git log with FZF
fkill                    # Kill process with FZF
dsh                      # Jump into Docker container

# Git shortcuts (40+)
gs                       # git status (short)
ga                       # git add
gc                       # git commit
gp                       # git push
glg                      # git log (graph)
```

## 🎨 Customization

### Adding Packages (Declarative!)

**System-wide** (in `hosts/ares/configuration.nix`):
```nix
environment.systemPackages = with pkgs; [
  yourpackage
];
```

**User-level** (in `home/jpolo.nix`):
```nix
home.packages = with pkgs; [
  yourpackage
];
```

Then rebuild:
```bash
rebuild
```

### Modifying Settings

All configuration is in `.nix` files:
- **Hyprland**: `home/hyprland/hyprland.nix`
- **Shell**: `home/shell/zsh.nix`
- **Git**: `home/programs/git.nix`
- **System**: `hosts/ares/configuration.nix`

After editing, rebuild to apply:
```bash
rebuild
```

### Managing Secrets (Declarative!)

Store passwords, SSH keys, API tokens in encrypted secrets:

```bash
sops secrets/secrets.yaml
```

Use in configuration:
```nix
sops.secrets.example = {
  sopsFile = ./secrets/secrets.yaml;
};
```

See [Secrets README](secrets/README.md) for full guide.

## 📚 Documentation

- **[Scripts.md](docs/Scripts.md)** - Complete script system documentation
- **[Project-Overview.md](docs/Project-Overview.md)** - Architecture and design
- **[Quick-Start.md](docs/Quick-Start.md)** - Getting started guide
- **[Keybindings.md](docs/Keybindings.md)** - Hyprland shortcuts
- **[Troubleshooting.md](docs/Troubleshooting.md)** - Common issues and solutions

## 🔄 Updating

```bash
# Update flake inputs (declarative dependencies)
nix flake update

# Rebuild system (apply all declarative changes)
rebuild

# See what changed
diff-gen

# Clean old generations
cleanup
```

All changes are:
- ✅ Declarative (in .nix files)
- ✅ Reproducible (same on all machines)
- ✅ Rollback-able (via boot menu or `nixos-rebuild --rollback`)
- ✅ Version controlled (commit to git)

## 🗂️ Structure

```
nix/
├── flake.nix                    # Main flake configuration
├── .sops.yaml                   # Secrets configuration
├── hosts/
│   └── ares/                    # ThinkPad T14s Gen 6
│       ├── configuration.nix    # System configuration
│       └── hardware-configuration.nix
├── modules/
│   ├── system/                  # System modules
│   │   ├── optimization.nix     # Performance tuning
│   │   ├── secrets.nix          # Secrets management
│   │   └── scripts.nix          # Script installation
│   ├── desktop/                 # Desktop environment
│   ├── services/                # System services
│   └── development/             # Dev tools
├── home/
│   ├── jpolo.nix                # User configuration
│   ├── programs/                # Program configurations
│   │   ├── git.nix
│   │   ├── firefox.nix
│   │   └── terminal-tools.nix
│   ├── shell/                   # Shell configuration
│   │   ├── zsh.nix
│   │   └── starship.nix
│   └── hyprland/                # Hyprland configuration
├── scripts/                     # System scripts
│   ├── scriptctl                # Script manager
│   ├── system/                  # System scripts
│   ├── dev/                     # Development scripts
│   └── util/                    # Utility scripts
└── docs/                        # Documentation
```

## 🔧 Scripts

The configuration includes 10+ production-ready scripts:

- **System**: update-system, cleanup-system, check-system
- **Development**: dev-env, nix-search, docker-mon, portctl
- **Utilities**: quick-backup, sysmon, scriptctl

See [Scripts.md](docs/Scripts.md) for complete documentation.
See [Port-Management.md](docs/Port-Management.md) for port management details.

## 🛠️ Technologies

- **NixOS** - Declarative Linux distribution
- **Home Manager** - User environment management
- **Hyprland** - Wayland compositor
- **sops-nix** - Secrets management
- **nh** - Better nixos-rebuild wrapper
- **nix-index** - Fast command-not-found
- **direnv** - Per-directory environments

## 📝 License

This configuration is free to use and modify for personal use.

## 🙏 Credits

Inspired by and incorporates best practices from:
- [hlissner/dotfiles](https://github.com/hlissner/dotfiles)
- [Misterio77/nix-config](https://github.com/Misterio77/nix-config)
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [notusknot/dotfiles-nix](https://github.com/notusknot/dotfiles-nix)

## 💬 Contact

- **Author**: Javier Polo Gambin
- **Email**: javier.polog@outlook.com
- **GitHub**: https://github.com/yourusername

---

**Built with ❤️ using NixOS**

[![NixOS](https://img.shields.io/badge/NixOS-Unstable-blue.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-blue)](https://hyprland.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A comprehensive, modular NixOS configuration inspired by Omarchy, featuring Hyprland with modern Wayland tools, complete development environment, and multi-machine support.

![Screenshot](docs/assets/screenshot.png)
*Desktop environment with Hyprland, Waybar, and Catppuccin Mocha theme*

## ✨ Features

### Desktop Environment
- 🪟 **Hyprland** - Dynamic tiling Wayland compositor with **hyprscroller** plugin
- 📊 **Waybar** - Beautiful, customizable status bar
- ⌨️ **LazyVim** - Complete Neovim setup with LSP support
- 🎨 **Modern Tools** - Hypridle, Hyprlock, Hyprsunset, SwayOSD, Walker
- 🔌 **Hypr Plugins** - hyprscroller for advanced window layouts (all workspaces)

### Shell & Productivity
- 🐚 **Advanced ZSH** - 100+ aliases, custom functions, VI mode
- 🔍 **FZF Integration** - Fuzzy finding everywhere with Catppuccin theme
- 📜 **Script Manager** - DevOps-inspired scriptctl system
- ⚡ **Modern CLI** - eza, bat, ripgrep, fd, zoxide, atuin
- 🎯 **Oh-My-Zsh** - 15+ plugins for enhanced productivity

### Hardware & System
- 📡 **Full Hardware Support** - WiFi, Bluetooth, fingerprint reader
- 🔒 **Security** - SDDM login, fingerprint authentication, PAM configuration
- 🔋 **Power Management** - TLP battery optimization, thermal management
- 🎵 **PipeWire** - Modern audio stack with low latency

### Development (NEW! ⭐)
- 🐳 **Docker** - With auto-pruning and lazydocker
- 🔧 **Dev Tools** - 50+ development tools and CLIs
- 🌍 **Multi-Language** - Python, Node.js, Rust, Go, C/C++, Zig
- 📦 **Nix Shells** - Per-project development environments
- 🎯 **Direnv** - Automatic environment loading
- 🔍 **Nix-index** - Fast command-not-found with comma

### Configuration
- 📦 **Modular Design** - Easy to customize and extend
- 🖥️ **Multi-Machine** - Easy deployment across multiple systems
- 🔄 **Overlays** - Custom packages and stable/unstable mix
- 📚 **Comprehensive Docs** - Obsidian-compatible markdown docs

## 🖥️ Hardware

Designed for **ThinkPad T14s Gen 6 (AMD)**, easily adaptable to other systems:

- AMD Ryzen CPU with amd_pstate driver
- AMD Radeon integrated graphics
- 2.8K OLED display (2880x1800 @ 90Hz) or custom resolution
- WiFi 6E
- Bluetooth 5.3
- Goodix fingerprint reader

## 📦 What's Included

### Desktop Environment
- **Compositor**: Hyprland (latest from flake)
- **Display Manager**: SDDM with Wayland
- **Status Bar**: Waybar with system information
- **Notifications**: Mako notification daemon
- **Launcher**: Walker application launcher
- **Lock Screen**: Hyprlock with blur effects
- **Idle Manager**: Hypridle with auto-suspend
- **Night Light**: Hyprsunset blue light filter
- **OSD**: SwayOSD for volume/brightness

### Development Environment (NEW! ⭐)
- **Languages**: Python 3.12, Node.js 22, Rust, Go, Zig, C/C++
- **LSP Servers**: nil, pyright, rust-analyzer, gopls, tsserver, and more
- **Formatters**: alejandra, black, prettier, stylua, shfmt
- **Version Control**: Git with delta, GitHub CLI, lazygit, tig
- **Containers**: Docker, lazydocker, dive, kubectl, k9s, helm, kind
- **Databases**: SQLite, PostgreSQL, Redis, DBeaver
- **Cloud CLIs**: AWS, Google Cloud, Azure, Terraform, Ansible
- **Debugging**: gdb, lldb, valgrind, rr (record/replay)
- **Profiling**: hyperfine, flamegraph, perf-tools
- **API Testing**: Postman, Insomnia, httpie
- **Secrets**: sops-nix for encrypted secrets management
- **Terminal**: tmux, zellij, atuin (better history)
- **Quality**: pre-commit, gitleaks, shellcheck

### Applications
- **Terminal**: Kitty (GPU-accelerated)
- **Editor**: Neovim with LazyVim
- **Shell**: Zsh with Oh-My-Zsh and Starship prompt
- **Browser**: Firefox, Chromium
- **File Manager**: Thunar, Ranger
- **Media**: Spotify, MPV, VLC
- **Office**: LibreOffice
- **Graphics**: GIMP, Inkscape

### System Services
- **Audio**: PipeWire with WirePlumber
- **Network**: NetworkManager
- **Bluetooth**: BlueZ with Blueman
- **Power**: TLP with battery optimization
- **SSH**: OpenSSH server
- **Printing**: CUPS
- **Direnv**: Auto-load project environments
- **Secrets**: sops-nix for encrypted secrets
- **Optimization**: BBR TCP, zram swap, AppArmor security

## 🚀 Quick Start

### Prerequisites

- NixOS installation media
- Internet connection
- ThinkPad T14s Gen 6 (or similar hardware)

### Installation

1. **Boot NixOS installer**

2. **Partition and format disks**
   ```bash
   # Example for /dev/nvme0n1
   parted /dev/nvme0n1 -- mklabel gpt
   parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
   parted /dev/nvme0n1 -- set 1 esp on
   parted /dev/nvme0n1 -- mkpart primary 512MiB 100%
   
   mkfs.fat -F 32 -n boot /dev/nvme0n1p1
   mkfs.ext4 -L nixos /dev/nvme0n1p2
   ```

3. **Mount filesystems**
   ```bash
   mount /dev/disk/by-label/nixos /mnt
   mkdir -p /mnt/boot
   mount /dev/disk/by-label/boot /mnt/boot
   ```

4. **Clone repository**
   ```bash
   nix-shell -p git
   cd /mnt
   git clone https://github.com/yourusername/nix-omarchy.git /mnt/home/jpolo/Projects/nix-omarchy
   ```

5. **Generate hardware config**
   ```bash
   nixos-generate-config --root /mnt
   cp /mnt/etc/nixos/hardware-configuration.nix \
      /mnt/home/jpolo/Projects/nix-omarchy/nix/hosts/talos/hardware-configuration.nix
   ```

6. **Customize configuration**
   - Edit user details in `home/jpolo.nix`
   - Set timezone in `hosts/talos/configuration.nix`
   - Adjust monitor settings in `home/hyprland/hyprland-config.nix`

7. **Install**
   ```bash
   cd /mnt/home/jpolo/Projects/nix-omarchy/nix
   nixos-install --flake .#talos
   ```

8. **Set passwords and reboot**
   ```bash
   nixos-enter --root /mnt
   passwd
   passwd jpolo
   exit
   reboot
   ```

See [Installation Guide](docs/Installation.md) for detailed instructions.

## 📁 Repository Structure

```
.
├── flake.nix                    # Enhanced flake with overlays, dev shells
├── hosts/
│   └── talos/                   # Host-specific config
│       ├── configuration.nix    # Imports development module
│       └── hardware-configuration.nix
├── modules/
│   ├── system/                  # Core system (audio, network, power, etc.)
│   ├── desktop/                 # Desktop environment (Hyprland, SDDM, etc.)
│   ├── services/                # System services (printing, location)
│   └── development/             # NEW: Dev tools & languages
│       ├── direnv.nix          # Auto-load environments
│       ├── docker.nix          # Container tools
│       ├── languages.nix       # Programming languages
│       └── tools.nix           # Dev utilities
├── home/                        # Home Manager config
│   ├── jpolo.nix               # User configuration
│   ├── hyprland/               # Hyprland user config
│   ├── programs/               # Program configs
│   ├── services/               # User services
│   └── shell/                  # Shell config
├── overlays/                    # NEW: Custom packages
│   └── default.nix             # Package overlays
├── packages/                    # NEW: Package definitions
├── shells/                      # NEW: Development shells
└── docs/                        # Documentation
    ├── README.md
    ├── Installation.md
    ├── Quick-Start.md
    └── ...
```

## 🔧 Development Features

### Development Shells

Quick access to language-specific environments:

```bash
# Python development
nix develop .#python

# Node.js development
nix develop .#node

# Rust development
nix develop .#rust

# Go development
nix develop .#go
```

### Direnv Integration

Auto-load environment per project. Create `.envrc`:

```bash
# For nix shell
use nix

# For flake
use flake

# For specific shell
use flake .#python
```

### Docker Usage

```bash
# User in docker group - no sudo needed
docker ps
docker-compose up

# TUI for docker management
lazydocker

# Explore images
dive nginx:latest
```

### Command-not-found

Fast package discovery with comma:

```bash
# Run unavailable commands directly
, cowsay "Hello!"
# Automatically finds and runs from nixpkgs
```

## 📚 Documentation

Complete guides in the `docs/` directory:

### Getting Started
- [**Profile System**](docs/Profile-System.md) - **START HERE** - Understanding the profile system
- [**Quick Start**](docs/Quick-Start.md) - Get up and running quickly
- [**Installation**](docs/Installation.md) - Complete installation guide

### Configuration
- [**Server Deployment**](docs/Server-Deployment.md) - Deploy headless servers (Proxmox/homelab)
- [**Homelab Guide**](docs/Homelab-Guide.md) - Multi-server architecture example
- [**Customization**](docs/Customization.md) - Customize your system
- [**System Configuration**](docs/System-Configuration.md) - System modules explained

### Usage
- [**Desktop Environment**](docs/Desktop-Environment.md) - Hyprland and desktop tools
- [**Keybindings**](docs/Keybindings.md) - Complete shortcuts reference
- [**Scripts**](docs/Scripts.md) - System management scripts
- [**Troubleshooting**](docs/Troubleshooting.md) - Fix common issues

### Advanced
- [**Gaming Profile**](docs/Gaming-Profile.md) - Isolated gaming environment
- [**Power User Guide**](docs/Power-User-Guide.md) - Advanced features
- [**NixOS Basics**](docs/NixOS-Basics.md) - Learn NixOS fundamentals

All documentation is written in Obsidian-compatible markdown with tags and cross-references.

## ⌨️ Essential Keybindings

| Keybinding | Action |
|------------|--------|
| `Super + Return` | Terminal |
| `Super + R` | App launcher |
| `Super + E` | File manager |
| `Super + Q` | Close window |
| `Super + L` | Lock screen |
| `Super + 1-9` | Switch workspace |
| `Print Screen` | Screenshot |

See [Keybindings](docs/Keybindings.md) for complete list.

## 🔄 Updating

```bash
cd ~/Projects/nix-omarchy/nix

# Update with nh (recommended)
rebuild              # Switch to new configuration
nfu                  # Update flake inputs

# Or traditional way
nix flake update
sudo nixos-rebuild switch --flake .#talos

# Compare what changed
diff-gen

# Clean old generations
cleanup
```

## 🎨 Customization

This configuration is highly modular and easy to customize:

1. **Colors & Themes**: Edit theme files in each module
2. **Keybindings**: Modify `home/hyprland/hyprland-config.nix`
3. **Applications**: Add packages to `home/jpolo.nix`
4. **System Services**: Edit files in `modules/system/`
5. **Development Tools**: Edit files in `modules/development/`

See [Customization Guide](docs/Customization.md) for details.

## 🆕 What's New

### Latest Improvements (January 2026 - Phase 3)
- ✅ **Advanced Hyprland** - hyprscroller plugin on all workspaces
- ✅ **Script Management** - scriptctl DevOps-inspired system
- ✅ **9 Production Scripts** - update, cleanup, check, dev-env, backup
- ✅ **Advanced Shell** - 100+ aliases, 10+ custom functions
- ✅ **FZF Everywhere** - File search, directory jump, git log, process kill
- ✅ **VI Mode Enhanced** - Better cursors, history search, navigation
- ✅ **15+ Oh-My-Zsh Plugins** - For all major development tools
- ✅ **Modern CLI Suite** - eza, bat, ripgrep, fd, zoxide, atuin, bottom

### Phase 2 (January 2026)
- ✅ **System Optimization** - BBR TCP, zram, sysctl tuning
- ✅ **nh** - Better rebuild wrapper with cleanup
- ✅ **Secrets Management** - sops-nix for encrypted secrets
- ✅ **Advanced Git** - Delta diffs, 50+ aliases, lazygit TUI
- ✅ **Terminal Tools** - tmux, zellij, atuin, starship
- ✅ **Firefox Privacy** - uBlock, extensions, custom search
- ✅ **80+ Dev Tools** - rr, terraform, ansible, wireshark
- ✅ **Better Monitoring** - bottom, bandwhich, procs
- ✅ **Productivity** - Obsidian, Taskwarrior, Bitwarden

### Phase 1 (December 2025)
- ✅ Multi-machine support with shared modules
- ✅ Comprehensive development environment
- ✅ Docker with auto-pruning
- ✅ 50+ new development tools
- ✅ Nix-index for better package discovery
- ✅ Direnv integration
- ✅ Development shells for Python, Node, Rust, Go
- ✅ Overlays system for custom packages
- ✅ Separated stable/unstable channels

See [IMPROVEMENTS.md](IMPROVEMENTS.md) for detailed changelog.

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [NixOS](https://nixos.org/) - The purely functional Linux distribution
- [Hyprland](https://hyprland.org/) - Dynamic tiling Wayland compositor
- [Omarchy](https://github.com/omarchy) - Inspiration for this configuration
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Soothing pastel theme
- The NixOS and Hyprland communities

## 📧 Contact

For questions or issues:
- Open an issue on GitHub
- Check the [Troubleshooting Guide](docs/Troubleshooting.md)
- Visit NixOS Discourse

## 🌟 Star History

If you find this configuration useful, please consider giving it a star!

---

**Built with ❤️ using NixOS and Hyprland**
**Enhanced for Multi-Machine Development 🚀**
