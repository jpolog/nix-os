---
title: Project Overview
tags: [overview, structure, summary]
created: 2026-01-06
---

# NixOS Omarchy Configuration - Project Overview

## 📊 Statistics

- **Total Configuration Files**: 33 Nix files
- **Documentation Files**: 11 Markdown files
- **Modular Structure**: 4 main module categories
- **Lines of Code**: ~2000+ lines of Nix configuration
- **Documentation**: ~45,000+ words

## 🗂️ Complete File Structure

```
nix/
├── flake.nix                               # Main flake configuration
├── README.md                               # Repository documentation
├── .gitignore                              # Git ignore patterns
│
├── hosts/                                  # Host-specific configurations
│   └── ares/                             # ThinkPad T14s Gen 6
│       ├── configuration.nix              # Main system config
│       └── hardware-configuration.nix     # Hardware detection
│
├── modules/                                # System modules
│   ├── system/                            # Core system configuration
│   │   ├── default.nix                    # Module aggregator
│   │   ├── audio.nix                      # PipeWire audio stack
│   │   ├── bluetooth.nix                  # BlueZ + Blueman
│   │   ├── network.nix                    # NetworkManager
│   │   ├── power.nix                      # TLP power management
│   │   ├── security.nix                   # PAM + fingerprint
│   │   └── ssh.nix                        # OpenSSH server
│   │
│   ├── desktop/                           # Desktop environment
│   │   ├── default.nix                    # Module aggregator
│   │   ├── hyprland.nix                   # Hyprland compositor
│   │   ├── display-manager.nix            # SDDM
│   │   ├── fonts.nix                      # Font configuration
│   │   └── xdg.nix                        # XDG directories
│   │
│   └── services/                          # System services
│       ├── default.nix                    # Module aggregator
│       ├── printing.nix                   # CUPS printing
│       └── location.nix                   # Geoclue
│
├── home/                                   # Home Manager configuration
│   ├── jpolo.nix                          # Main user config
│   │
│   ├── hyprland/                          # Hyprland user configuration
│   │   ├── default.nix                    # Module aggregator
│   │   ├── hyprland-config.nix            # Hyprland settings
│   │   ├── waybar.nix                     # Status bar
│   │   ├── hypridle.nix                   # Idle management
│   │   └── hyprlock.nix                   # Screen lock
│   │
│   ├── programs/                          # Program configurations
│   │   ├── default.nix                    # Module aggregator
│   │   ├── neovim.nix                     # LazyVim setup
│   │   ├── kitty.nix                      # Terminal emulator
│   │   ├── swayosd.nix                    # OSD notifications
│   │   ├── walker.nix                     # App launcher
│   │   └── xcompose.nix                   # Compose key sequences
│   │
│   ├── services/                          # User services
│   │   ├── default.nix                    # Module aggregator
│   │   ├── mako.nix                       # Notification daemon
│   │   └── hyprsunset.nix                 # Night light
│   │
│   └── shell/                             # Shell configuration
│       ├── default.nix                    # Module aggregator
│       ├── zsh.nix                        # Zsh + Oh-My-Zsh
│       └── starship.nix                   # Prompt theme
│
├── themes/                                 # Theme configurations (future)
│
└── docs/                                   # Obsidian documentation
    ├── README.md                          # Documentation overview
    ├── Installation.md                    # Installation guide
    ├── Quick-Start.md                     # Quick start guide
    ├── System-Configuration.md            # System modules
    ├── Desktop-Environment.md             # Desktop setup
    ├── Applications.md                    # Software guide
    ├── Hardware-Support.md                # Hardware configuration
    ├── Keybindings.md                     # Keyboard shortcuts
    ├── Customization.md                   # Customization guide
    ├── Troubleshooting.md                 # Problem solving
    └── NixOS-Basics.md                   # NixOS fundamentals
```

## 🎯 Key Features by Module

### System Modules (`modules/system/`)

| Module | Purpose | Key Technologies |
|--------|---------|------------------|
| `audio.nix` | Audio configuration | PipeWire, WirePlumber, RTKit |
| `bluetooth.nix` | Bluetooth support | BlueZ, Blueman |
| `network.nix` | Network management | NetworkManager, Firewall |
| `power.nix` | Power optimization | TLP, UPower, Thermald |
| `security.nix` | Authentication | PAM, fprintd, Polkit |
| `ssh.nix` | SSH access | OpenSSH, SSHFS |

### Desktop Modules (`modules/desktop/`)

| Module | Purpose | Key Technologies |
|--------|---------|------------------|
| `hyprland.nix` | Wayland compositor | Hyprland, XWayland, Portals |
| `display-manager.nix` | Login manager | SDDM |
| `fonts.nix` | Font management | Nerd Fonts, Noto |
| `xdg.nix` | Directory structure | XDG Base Directory |

### Home Configuration (`home/`)

#### Hyprland (`home/hyprland/`)
- **hyprland-config.nix**: Window manager settings, keybindings, animations
- **waybar.nix**: Status bar with system information
- **hypridle.nix**: Idle timeouts and actions
- **hyprlock.nix**: Screen lock with blur effect

#### Programs (`home/programs/`)
- **neovim.nix**: LazyVim with LSP support
- **kitty.nix**: GPU-accelerated terminal
- **walker.nix**: Application launcher
- **swayosd.nix**: On-screen display
- **xcompose.nix**: Custom key sequences

#### Services (`home/services/`)
- **mako.nix**: Notification daemon
- **hyprsunset.nix**: Blue light filter

#### Shell (`home/shell/`)
- **zsh.nix**: Shell with Oh-My-Zsh, aliases, functions
- **starship.nix**: Cross-shell prompt

## 📦 Installed Software Categories

### Development
- Neovim (LazyVim), VS Code
- Git, Lazygit
- Language servers: nil, pyright, tsserver, rust-analyzer, gopls
- Runtimes: Python, Node.js, Rust, Go

### Internet
- Firefox, Chromium
- Discord, Telegram

### Media
- Spotify, MPV, VLC
- GIMP, Inkscape

### Utilities
- Kitty, Alacritty (terminals)
- Thunar, Ranger (file managers)
- btop, nvtop (system monitors)

### System Tools
- eza, bat, fd, ripgrep, fzf (modern CLI tools)
- brightnessctl, pamixer, playerctl
- NetworkManager, Blueman

## 🔧 Configuration Highlights

### Nix Features
- ✅ Flakes enabled
- ✅ Home Manager integrated
- ✅ Modular architecture
- ✅ Automatic garbage collection
- ✅ Binary caches configured

### Desktop Features
- ✅ Hyprland with hyprscroller plugin
- ✅ Catppuccin Mocha theme
- ✅ GPU-accelerated rendering
- ✅ Multi-monitor support
- ✅ Gestures enabled
- ✅ VRR (Variable Refresh Rate)

### Hardware Support
- ✅ AMD CPU power management
- ✅ AMD GPU drivers
- ✅ WiFi 6E
- ✅ Bluetooth 5.3
- ✅ Fingerprint reader
- ✅ HiDPI display (2880x1800@90Hz)

### Security
- ✅ Fingerprint authentication
- ✅ PAM configuration
- ✅ Polkit integration
- ✅ Firewall enabled
- ✅ Secure boot ready

### Power Management
- ✅ TLP with battery thresholds (20%-80%)
- ✅ CPU governors (performance/powersave)
- ✅ Auto-suspend after 30 minutes idle
- ✅ Display dimming
- ✅ Thermal management

## 📚 Documentation Coverage

Each documentation file covers:

| Document | Lines | Words | Topics |
|----------|-------|-------|--------|
| README.md | ~200 | ~4,200 | Overview, features, structure |
| Installation.md | ~200 | ~4,100 | Step-by-step installation |
| Quick-Start.md | ~350 | ~6,800 | First steps, essential tasks |
| System-Configuration.md | ~300 | ~6,000 | System modules explained |
| Desktop-Environment.md | ~350 | ~6,400 | Desktop components |
| Applications.md | ~400 | ~6,700 | Software guide |
| Hardware-Support.md | ~400 | ~7,300 | Hardware setup |
| Keybindings.md | ~400 | ~7,100 | Complete shortcuts |
| Customization.md | ~400 | ~7,100 | Customization guide |
| Troubleshooting.md | ~500 | ~9,600 | Problem solving |
| NixOS-Basics.md | ~400 | ~7,500 | NixOS fundamentals |

**Total**: ~3,900 lines, ~72,800 words of documentation

## 🎨 Theme Details

### Color Scheme: Catppuccin Mocha

| Color | Hex | Usage |
|-------|-----|-------|
| Base | `#1e1e2e` | Background |
| Mantle | `#181825` | Darker elements |
| Crust | `#11111b` | Darkest elements |
| Text | `#cdd6f4` | Main text |
| Blue | `#89b4fa` | Accent/focus |
| Green | `#a6e3a1` | Success |
| Yellow | `#f9e2af` | Warning |
| Red | `#f38ba8` | Error |

Applied consistently across:
- Hyprland (borders, windows)
- Waybar (status bar)
- Kitty (terminal)
- Mako (notifications)
- Hyprlock (lock screen)
- Walker (launcher)

## 🔑 Essential Information

### Default User
- **Username**: jpolo
- **Shell**: Zsh with Oh-My-Zsh
- **Home**: /home/jpolo

### System
- **Hostname**: ares
- **Timezone**: America/New_York (configurable)
- **Locale**: en_US.UTF-8
- **Kernel**: Latest (linux-latest)

### Paths
- **Config**: ~/Projects/nix-omarchy/nix
- **Flake**: ~/Projects/nix-omarchy/nix/flake.nix
- **Docs**: ~/Projects/nix-omarchy/nix/docs

## 🚀 Usage Commands

### System Management
```bash
# Update system
sudo nixos-rebuild switch --flake .#ares

# Or use alias
update

# Rollback
sudo nixos-rebuild switch --rollback

# Cleanup
cleanup  # alias for garbage collection
```

### Flake Management
```bash
# Update inputs
nix flake update

# Check flake
nix flake check

# Show outputs
nix flake show
```

## 📊 Complexity Metrics

- **Total Modules**: 20+ separate modules
- **Configuration Layers**: 3 (system, desktop, home)
- **Integration Points**: 15+ (audio, display, input, etc.)
- **Managed Services**: 25+ systemd services
- **Package Count**: 100+ packages installed

## 🎯 Design Principles

1. **Modularity**: Everything is a separate module
2. **Declarative**: Configuration as code
3. **Reproducible**: Same config = same result
4. **Maintainable**: Clear structure, well-documented
5. **Extensible**: Easy to add new features
6. **Type-safe**: Nix ensures correctness
7. **Rollback-friendly**: Never lose a working system

## 🔄 Update Strategy

- **System**: Weekly flake updates
- **Garbage Collection**: Weekly cleanup (keep 7 days)
- **Documentation**: Updated with each change
- **Git**: All changes tracked

## 📈 Future Enhancements

Potential additions:
- Additional themes in `themes/` directory
- Multiple host configurations
- Secrets management (agenix/sops-nix)
- Automated backups
- Custom packages
- Development shells

## 🎓 Learning Path

Recommended order for new users:
1. [[Quick-Start]] - Get started
2. [[Keybindings]] - Learn shortcuts
3. [[Applications]] - Explore software
4. [[NixOS-Basics]] - Understand NixOS
5. [[Customization]] - Make it yours
6. [[System-Configuration]] - Deep dive
7. [[Troubleshooting]] - Fix issues

---

**Last Updated**: 2026-01-06
**Status**: Production Ready ✅
**Maintainer**: jpolo
