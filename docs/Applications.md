---
title: Applications & Tools
tags: [applications, software, programs]
created: 2026-01-06
related: [[README]], [[Development-Tools]]
---

# Applications & Tools

Complete list of installed applications and their purposes.

## 📝 Text Editors & IDEs

### Neovim (LazyVim)

**Purpose**: Primary text editor  
**Configuration**: `home/programs/neovim.nix`

#### Features

- ✅ LSP support for multiple languages
- ✅ Syntax highlighting
- ✅ Auto-completion
- ✅ Git integration
- ✅ File explorer
- ✅ Fuzzy finding

#### Supported Languages

| Language | LSP | Formatter | Linter |
|----------|-----|-----------|--------|
| Nix | nil | nixpkgs-fmt | - |
| Python | pyright | black | - |
| JavaScript/TypeScript | tsserver | prettier | eslint |
| Rust | rust-analyzer | rustfmt | - |
| Go | gopls | gofmt | - |
| Lua | lua-ls | stylua | selene |
| Bash | bash-ls | - | shellcheck |

#### Keybindings

See LazyVim documentation for full keybindings.

### VS Code

**Purpose**: Alternative IDE for complex projects

## 🌐 Web Browsers

### Firefox

**Purpose**: Primary web browser  
**Features**: Privacy-focused, extensions support

### Chromium

**Purpose**: Alternative browser for testing

## 💬 Communication

### Discord

**Purpose**: Chat and voice communication

### Telegram Desktop

**Purpose**: Messaging application

## 🎵 Media

### Music

- **Spotify**: Music streaming
- **MPV**: Lightweight media player
- **VLC**: Full-featured media player

### Video

- **MPV**: Primary video player
- **VLC**: Alternative player

## 🎨 Graphics & Design

### GIMP

**Purpose**: Image editing (Photoshop alternative)  
**Features**: Photo retouching, image composition, image authoring

### Inkscape

**Purpose**: Vector graphics editor (Illustrator alternative)  
**Features**: SVG editing, logos, diagrams, illustrations

## 📄 Office & Documents

### LibreOffice Fresh

**Purpose**: Office suite (Microsoft Office alternative)

**Includes**:
- Writer (Word processor)
- Calc (Spreadsheets)
- Impress (Presentations)
- Draw (Diagrams)
- Math (Formulas)

## 🖥️ Terminals

### Kitty

**Purpose**: Primary terminal emulator

#### Features

- ✅ GPU acceleration
- ✅ Ligature support
- ✅ Images in terminal
- ✅ Tabs and splits
- ✅ Configurable

#### Keybindings

| Keys | Action |
|------|--------|
| `Ctrl+Shift+C` | Copy |
| `Ctrl+Shift+V` | Paste |
| `Ctrl+Shift+T` | New tab |
| `Ctrl+Shift+Q` | Close tab |
| `Ctrl+Shift+Right` | Next tab |
| `Ctrl+Shift+Left` | Previous tab |
| `Ctrl+Shift+=` | Increase font size |
| `Ctrl+Shift+-` | Decrease font size |

### Alacritty

**Purpose**: Backup terminal emulator  
**Features**: GPU acceleration, minimal, fast

## 📁 File Managers

### Thunar

**Purpose**: Primary file manager

#### Features

- ✅ Bulk rename
- ✅ Custom actions
- ✅ Archive support
- ✅ Volume management

#### Plugins

- `thunar-volman`: Removable media
- `thunar-archive-plugin`: Archive extraction

### Ranger

**Purpose**: Terminal file manager  
**Features**: Vi-like keybindings, image preview

## 🛠️ System Utilities

### System Monitoring

| Tool | Purpose |
|------|---------|
| `htop` | Interactive process viewer |
| `btop` | Modern process/resource monitor |
| `nvtop` | GPU monitoring |

### File Operations

| Tool | Purpose |
|------|---------|
| `eza` | Modern `ls` replacement |
| `bat` | Modern `cat` with syntax highlighting |
| `fd` | Modern `find` replacement |
| `ripgrep` | Fast grep alternative |
| `fzf` | Fuzzy finder |
| `zoxide` | Smart `cd` replacement |

### Archive Tools

| Tool | Formats |
|------|---------|
| `unzip` | .zip |
| `zip` | .zip |
| `p7zip` | .7z, .zip, .rar |
| `unrar` | .rar |

## 🎨 Display & Graphics

### Color Picker

**Tool**: Hyprpicker  
**Usage**: Pick colors from screen  
**Format**: Hex color codes

### Screenshot Tools

See [[Desktop-Environment#Screenshots]] for screenshot tools.

## 📋 Clipboard

### Cliphist

**Purpose**: Clipboard manager with history

#### Features

- ✅ Text clipboard
- ✅ Image clipboard
- ✅ History
- ✅ Wayland native

#### Usage

```bash
# Show clipboard history
cliphist list | walker

# Copy from history
cliphist decode <item> | wl-copy
```

## 💡 Display Control

### Brightness

**Tool**: brightnessctl

#### Usage

```bash
# Increase brightness
brightnessctl set +5%

# Decrease brightness
brightnessctl set 5%-

# Set specific value
brightnessctl set 50%
```

#### Keybindings

- **Increase**: `Fn + F6` or `XF86MonBrightnessUp`
- **Decrease**: `Fn + F5` or `XF86MonBrightnessDown`

## 🎧 Audio Control

### Tools

| Tool | Purpose |
|------|---------|
| `pamixer` | CLI volume control |
| `pavucontrol` | GUI volume control |
| `playerctl` | Media player control |
| `easyeffects` | Audio effects |

### Media Control

```bash
# Play/Pause
playerctl play-pause

# Next track
playerctl next

# Previous track
playerctl previous
```

#### Keybindings

- **Play/Pause**: `Fn + F4` or `XF86AudioPlay`
- **Next**: `Fn + F3` or `XF86AudioNext`
- **Previous**: `Fn + F1` or `XF86AudioPrev`
- **Volume Up**: `Fn + F3` or `XF86AudioRaiseVolume`
- **Volume Down**: `Fn + F2` or `XF86AudioLowerVolume`
- **Mute**: `Fn + F1` or `XF86AudioMute`

## 🔍 Viewers

### Image Viewer

**Tool**: imv  
**Features**: Wayland-native, lightweight, fast

### PDF Viewer

**Tool**: Zathura  
**Features**: Minimal, keyboard-driven, fast

## 🗂️ Development Tools

See [[Development-Tools]] for comprehensive development setup.

### Version Control

- **Git**: Version control
- **Lazygit**: Terminal UI for git

### Build Tools

- **GCC**: C/C++ compiler
- **Make**: Build automation
- **CMake**: Build system generator

### Language Runtimes

- **Python 3**: Python runtime
- **Node.js**: JavaScript runtime
- **Cargo**: Rust package manager
- **Go**: Go runtime

## 🌐 Network Tools

| Tool | Purpose |
|------|---------|
| `curl` | Transfer data from URLs |
| `wget` | Download files |
| `openssh` | SSH client/server |
| `sshfs` | Mount remote filesystems |
| `wireguard-tools` | VPN |

## 🔧 Hardware Tools

| Tool | Purpose |
|------|---------|
| `pciutils` | PCI devices (`lspci`) |
| `usbutils` | USB devices (`lsusb`) |
| `lshw` | Hardware configuration |
| `dmidecode` | DMI/SMBIOS info |

## 📦 Package Management

### Nix Tools

```bash
# Search packages
nix search nixpkgs <package>

# Install temporarily
nix-shell -p <package>

# Update flake inputs
nix flake update

# Garbage collection
nix-collect-garbage -d
```

## 🎮 Polkit Agent

**Tool**: polkit-gnome

**Purpose**: Authentication prompts for privileged operations

## 📚 Related Documentation

- [[Development-Tools]] - Development environment
- [[Desktop-Environment]] - Desktop tools
- [[Shell-Configuration]] - Shell utilities
- [[Keybindings]] - Keyboard shortcuts

---

**Last Updated**: 2026-01-06
