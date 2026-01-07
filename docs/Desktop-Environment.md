---
title: Desktop Environment
tags: [hyprland, wayland, desktop, compositor]
created: 2026-01-06
related: [[README]], [[Hyprland-Guide]], [[Waybar-Configuration]]
---

# Desktop Environment

Complete documentation of the Hyprland-based desktop environment.

## 🎨 Overview

This configuration uses a modern Wayland-based desktop environment centered around **Hyprland**, a dynamic tiling compositor.

## 🏗️ Architecture

```
Display Manager (SDDM)
    ↓
Hyprland (Compositor)
    ├── Waybar (Status Bar)
    ├── Mako (Notifications)
    ├── Walker (Launcher)
    ├── Hypridle (Idle Manager)
    ├── Hyprlock (Screen Lock)
    └── Hyprsunset (Night Light)
```

## 🖥️ Core Components

### Hyprland

**Version**: Latest from flake input  
**Plugin**: hyprscroller (scrolling workspaces)

#### Features

- ✅ Dynamic tiling
- ✅ Smooth animations
- ✅ Multi-monitor support
- ✅ Gestures
- ✅ Eye candy effects
- ✅ Xwayland support

#### Configuration Location

- **System**: `modules/desktop/hyprland.nix`
- **User**: `home/hyprland/hyprland-config.nix`

See [[Hyprland-Guide]] for detailed usage.

### Display Manager

**Software**: [[SDDM]] (Simple Desktop Display Manager)

#### Features

- ✅ Wayland support
- ✅ Theme: Breeze
- ✅ Auto-login support (optional)

#### Configuration

```nix
services.displayManager.sddm = {
  enable = true;
  wayland.enable = true;
  theme = "breeze";
};
```

### Waybar

**Purpose**: Status bar with system information

#### Modules

**Left Side**:
- Workspaces (Hyprland)
- Window title

**Center**:
- Clock & date

**Right Side**:
- System tray
- Idle inhibitor
- Audio volume
- Network status
- Bluetooth status
- Battery level
- Brightness

#### Styling

- **Theme**: Catppuccin Mocha inspired
- **Font**: JetBrainsMono Nerd Font
- **Icons**: Font Awesome

See [[Waybar-Configuration]] for customization.

### Notifications

**Software**: [[Mako]]

#### Features

- ✅ Grouped notifications
- ✅ Urgency levels
- ✅ Custom styling
- ✅ History support

#### Configuration

- **Position**: Top-right
- **Timeout**: 5 seconds (normal)
- **Theme**: Catppuccin Mocha

#### Usage

```bash
# Send test notification
notify-send "Test" "This is a test notification"

# With urgency
notify-send -u critical "Important" "Critical message"
```

### Application Launcher

**Software**: [[Walker]]

#### Features

- ✅ Application launcher
- ✅ Command runner
- ✅ Web search
- ✅ File finder
- ✅ Custom styling

#### Keybinding

- **Launch**: `Super + R`

#### Search Modes

| Prefix | Mode | Example |
|--------|------|---------|
| (none) | Applications | firefox |
| `>` | Commands | >echo hello |
| `?` | Web search | ?nixos |
| `~` | Files | ~/documents |

See [[Walker-Guide]] for advanced usage.

## 🔐 Lock Screen & Idle

### Hyprlock

**Purpose**: Screen lock with blur effect

#### Features

- ✅ Screenshot blur
- ✅ Clock display
- ✅ Password input
- ✅ Fingerprint support
- ✅ Custom styling

#### Keybinding

- **Lock**: `Super + L`

### Hypridle

**Purpose**: Automatic idle management

#### Timeouts

| Time | Action |
|------|--------|
| 5 min | Dim display to 10% |
| 10 min | Lock screen |
| 11 min | Turn off display |
| 30 min | Suspend system |

#### Configuration

Edit timeouts in `home/hyprland/hypridle.nix`

## 🌅 Night Light

### Hyprsunset

**Purpose**: Blue light filter

#### Settings

- **Temperature**: 4500K (evening)
- **Auto-start**: Yes

#### Manual Control

```bash
# Set temperature
hyprsunset -t 3500

# Reset
hyprsunset -t 6500
```

## 🔊 On-Screen Display

### SwayOSD

**Purpose**: Visual feedback for volume/brightness

#### Features

- ✅ Volume changes
- ✅ Brightness changes
- ✅ Capslock indicator
- ✅ Custom styling

## 🎨 Themes & Styling

### Color Scheme

**Base Theme**: Catppuccin Mocha

#### Main Colors

| Element | Color | Hex |
|---------|-------|-----|
| Background | Mocha Base | `#1e1e2e` |
| Foreground | Mocha Text | `#cdd6f4` |
| Accent | Mocha Blue | `#89b4fa` |
| Success | Mocha Green | `#a6e3a1` |
| Warning | Mocha Yellow | `#f9e2af` |
| Error | Mocha Red | `#f38ba8` |

### Fonts

**Primary**: JetBrainsMono Nerd Font  
**Fallback**: Noto Sans, Font Awesome

All fonts configured in `modules/desktop/fonts.nix`

See [[Fonts-Configuration]] for font management.

## 📋 XDG Configuration

### Base Directories

```
~/.config      # Configuration files
~/.local/share # Data files
~/.local/state # State files
~/.cache       # Cache files
```

### User Directories

```
~/Desktop
~/Documents
~/Downloads
~/Music
~/Pictures
~/Videos
~/Templates
~/Public
```

Auto-created on first login.

## 🖼️ Screenshots & Recording

### Tools

| Tool | Purpose | Keybinding |
|------|---------|------------|
| `grimblast` | Screenshots | Print Screen |
| `grim` | Screenshot backend | - |
| `slurp` | Area selection | - |
| `wf-recorder` | Screen recording | - |

### Screenshot Keybindings

| Keys | Action |
|------|--------|
| `Print` | Copy area to clipboard |
| `Shift + Print` | Copy screen to clipboard |
| `Super + Print` | Save area to file |

Screenshots saved to: `~/Pictures/Screenshots/`

## 🚀 Performance

### Optimizations

- Hardware acceleration enabled
- VRR (Variable Refresh Rate) enabled
- GPU rendering for blur/shadows
- Optimized animation curves

### Monitor Configuration

Edit in `home/hyprland/hyprland-config.nix`:

```nix
monitor = [
  "eDP-1,2880x1800@90,0x0,1.5"  # Internal display
  ",preferred,auto,1"             # External displays
];
```

## 🎮 Input Configuration

### Touchpad

- ✅ Natural scrolling
- ✅ Tap to click
- ✅ Disable while typing
- ✅ Custom scroll speed

### Keyboard

- **Layout**: US
- **Repeat rate**: Default
- **Compose key**: XCompose support

See [[Input-Configuration]] for customization.

## 🔧 Advanced Features

### Window Rules

Automatic configuration for:
- Floating windows (dialogs, popups)
- Picture-in-Picture windows
- Opacity rules
- Position rules

### Workspaces

- **Default**: 10 workspaces
- **Switching**: `Super + 1-9,0`
- **Move window**: `Super + Shift + 1-9,0`
- **Scratchpad**: `Super + S`

### Gestures

- **3-finger swipe**: Switch workspaces
- **Configurable**: Sensitivity, distance, inversion

## 📚 Related Documentation

- [[Hyprland-Guide]] - Detailed Hyprland usage
- [[Waybar-Configuration]] - Waybar customization
- [[Walker-Guide]] - Application launcher
- [[Keybindings]] - All keyboard shortcuts
- [[Window-Rules]] - Window management
- [[Themes-Customization]] - Theme customization

---

**Last Updated**: 2026-01-06
