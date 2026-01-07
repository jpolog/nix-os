---
title: Keybindings Reference
tags: [keybindings, shortcuts, hotkeys, reference]
created: 2026-01-06
related: [[Hyprland-Guide]], [[Desktop-Environment]]
---

# Keybindings Reference

Complete reference for all keyboard shortcuts.

## 🎮 Modifier Keys

| Modifier | Key | Symbol |
|----------|-----|--------|
| Super | Windows/Command | ⊞ |
| Shift | Shift | ⇧ |
| Ctrl | Control | ^ |
| Alt | Alt | ⎇ |

**Main Modifier**: `Super` (⊞)

## 🚀 Application Shortcuts

| Keybinding | Action |
|------------|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + R` | Application launcher (Walker) |
| `Super + E` | File manager (Thunar) |
| `Super + Q` | Close active window |
| `Super + M` | Exit Hyprland |
| `Super + L` | Lock screen (Hyprlock) |

## 🪟 Window Management

### Basic Operations

| Keybinding | Action |
|------------|--------|
| `Super + Q` | Kill active window |
| `Super + V` | Toggle floating |
| `Super + F` | Toggle fullscreen |
| `Super + P` | Pseudo-tile |
| `Super + J` | Toggle split |

### Focus Movement

| Keybinding | Action |
|------------|--------|
| `Super + ←` | Focus left |
| `Super + →` | Focus right |
| `Super + ↑` | Focus up |
| `Super + ↓` | Focus down |

### Move Windows

| Keybinding | Action |
|------------|--------|
| `Super + Mouse Left` | Move window |
| `Super + Mouse Right` | Resize window |

## 🗂️ Workspace Management

### Switch Workspace

| Keybinding | Action |
|------------|--------|
| `Super + 1` | Workspace 1 |
| `Super + 2` | Workspace 2 |
| `Super + 3` | Workspace 3 |
| `Super + 4` | Workspace 4 |
| `Super + 5` | Workspace 5 |
| `Super + 6` | Workspace 6 |
| `Super + 7` | Workspace 7 |
| `Super + 8` | Workspace 8 |
| `Super + 9` | Workspace 9 |
| `Super + 0` | Workspace 10 |
| `Super + Mouse Wheel Up` | Previous workspace |
| `Super + Mouse Wheel Down` | Next workspace |

### Move Window to Workspace

| Keybinding | Action |
|------------|--------|
| `Super + Shift + 1` | Move to workspace 1 |
| `Super + Shift + 2` | Move to workspace 2 |
| `Super + Shift + 3` | Move to workspace 3 |
| `Super + Shift + 4` | Move to workspace 4 |
| `Super + Shift + 5` | Move to workspace 5 |
| `Super + Shift + 6` | Move to workspace 6 |
| `Super + Shift + 7` | Move to workspace 7 |
| `Super + Shift + 8` | Move to workspace 8 |
| `Super + Shift + 9` | Move to workspace 9 |
| `Super + Shift + 0` | Move to workspace 10 |

### Special Workspace (Scratchpad)

| Keybinding | Action |
|------------|--------|
| `Super + S` | Toggle scratchpad |
| `Super + Shift + S` | Move window to scratchpad |

## 📸 Screenshots

| Keybinding | Action |
|------------|--------|
| `Print Screen` | Screenshot area → clipboard |
| `Shift + Print Screen` | Screenshot full screen → clipboard |
| `Super + Print Screen` | Screenshot area → file |

Screenshots saved to: `~/Pictures/Screenshots/`

## 🔊 Media Controls

### Audio

| Keybinding | Action |
|------------|--------|
| `XF86AudioMute` | Toggle mute |
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |

**Function Keys**:
- `Fn + F1`: Mute
- `Fn + F2`: Volume down
- `Fn + F3`: Volume up

### Media Player

| Keybinding | Action |
|------------|--------|
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

**Function Keys**:
- `Fn + F4`: Play/Pause
- `Fn + F10`: Next track
- `Fn + F9`: Previous track (if available)

## 💡 Brightness

| Keybinding | Action |
|------------|--------|
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

**Function Keys**:
- `Fn + F5`: Brightness down
- `Fn + F6`: Brightness up

## 📋 Kitty Terminal

### Tabs

| Keybinding | Action |
|------------|--------|
| `Ctrl + Shift + T` | New tab |
| `Ctrl + Shift + Q` | Close tab |
| `Ctrl + Shift + →` | Next tab |
| `Ctrl + Shift + ←` | Previous tab |

### Copy/Paste

| Keybinding | Action |
|------------|--------|
| `Ctrl + Shift + C` | Copy |
| `Ctrl + Shift + V` | Paste |

### Font Size

| Keybinding | Action |
|------------|--------|
| `Ctrl + Shift + =` | Increase font size |
| `Ctrl + Shift + -` | Decrease font size |
| `Ctrl + Shift + Backspace` | Reset font size |

## 📝 Neovim (LazyVim)

### Basic

| Keybinding | Action |
|------------|--------|
| `Space` | Leader key |
| `Space + e` | File explorer |
| `Space + f + f` | Find files |
| `Space + f + g` | Live grep |
| `Space + f + r` | Recent files |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `Ctrl + h` | Move to left window |
| `Ctrl + j` | Move to window below |
| `Ctrl + k` | Move to window above |
| `Ctrl + l` | Move to right window |

### LSP

| Keybinding | Action |
|------------|--------|
| `g + d` | Go to definition |
| `g + r` | Go to references |
| `K` | Hover documentation |
| `Space + c + a` | Code actions |
| `Space + r + n` | Rename symbol |

See LazyVim documentation for complete keybindings.

## 🎨 Walker (Launcher)

### Modes

| Input | Mode |
|-------|------|
| `text` | Search applications |
| `>text` | Run command |
| `?text` | Web search |
| `~text` | Find files |

### Navigation

| Keybinding | Action |
|------------|--------|
| `↑` / `↓` | Navigate items |
| `Enter` | Select item |
| `Esc` | Close launcher |

## 🔍 Ranger (File Manager)

| Keybinding | Action |
|------------|--------|
| `j` / `k` | Navigate down/up |
| `h` / `l` | Parent/Child directory |
| `Enter` | Open file |
| `Space` | Select file |
| `q` | Quit |
| `zh` | Toggle hidden files |
| `/` | Search |

## 🐚 Zsh Shell

### Navigation

| Keybinding | Action |
|------------|--------|
| `Ctrl + A` | Beginning of line |
| `Ctrl + E` | End of line |
| `Ctrl + U` | Clear line before cursor |
| `Ctrl + K` | Clear line after cursor |
| `Ctrl + R` | Reverse search history |
| `Ctrl + L` | Clear screen |

### Custom Aliases

| Alias | Command |
|-------|---------|
| `..` | cd .. |
| `...` | cd ../.. |
| `ll` | eza -lah --icons |
| `vim` | nvim |
| `g` | git |

## 🖱️ Touchpad Gestures

| Gesture | Action |
|---------|--------|
| 3-finger swipe left/right | Switch workspace |
| 3-finger swipe up/down | (Configurable) |
| Tap to click | Click |
| Two-finger scroll | Scroll |

## ⚙️ System Shortcuts

### Session Management

| Keybinding | Action |
|------------|--------|
| `Super + L` | Lock screen |
| `Super + M` | Exit Hyprland |

### Clipboard

Clipboard history via `cliphist` - access through Walker or custom keybinding.

## 🎛️ Custom Keybindings

You can add custom keybindings in:
- **Hyprland**: `home/hyprland/hyprland-config.nix`
- **Kitty**: `home/programs/kitty.nix`
- **Neovim**: LazyVim configuration

## 📚 Related Documentation

- [[Hyprland-Guide]] - Hyprland usage
- [[Desktop-Environment]] - Desktop features
- [[Customization]] - Customizing keybindings

---

**Last Updated**: 2026-01-06

## 💡 Tips

1. **Learn gradually**: Master basic window management first
2. **Use Super key**: Most shortcuts use Super modifier
3. **Terminal shortcuts**: Use Ctrl+Shift in terminal
4. **Function keys**: ThinkPad function keys are very useful
5. **Custom aliases**: Check `.zshrc` for command aliases
