---
title: Customization Guide
tags: [customization, theming, configuration]
created: 2026-01-06
related: [[README]], [[Themes]], [[Configuration-Tips]]
---

# Customization Guide

How to customize your NixOS Omarchy configuration.

## 🎨 Themes

### Color Scheme

Current theme: **Catppuccin Mocha**

#### Changing Colors

Main color definitions are in:
- **Waybar**: `home/hyprland/waybar.nix`
- **Kitty**: `home/programs/kitty.nix`
- **Hyprland**: `home/hyprland/hyprland-config.nix`
- **Mako**: `home/services/mako.nix`

#### Catppuccin Colors

| Name | Hex | Usage |
|------|-----|-------|
| Base | `#1e1e2e` | Background |
| Mantle | `#181825` | Darker background |
| Crust | `#11111b` | Darkest background |
| Text | `#cdd6f4` | Foreground text |
| Subtext1 | `#bac2de` | Muted text |
| Blue | `#89b4fa` | Accent |
| Green | `#a6e3a1` | Success |
| Yellow | `#f9e2af` | Warning |
| Red | `#f38ba8` | Error |

### Wallpaper

Set wallpaper in Hyprland config:

```nix
exec-once = [
  "swaybg -i ~/Pictures/Wallpapers/wallpaper.jpg"
];
```

Or use `hyprpaper` for better integration.

### GTK Theme

Add to `home/jpolo.nix`:

```nix
gtk = {
  enable = true;
  theme = {
    name = "Catppuccin-Mocha-Standard-Blue-Dark";
    package = pkgs.catppuccin-gtk.override {
      accents = [ "blue" ];
      variant = "mocha";
    };
  };
  iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
};
```

### Qt Theme

```nix
qt = {
  enable = true;
  platformTheme = "gtk";
  style.name = "adwaita-dark";
};
```

## 🖼️ Waybar Customization

### Layout

Edit `home/hyprland/waybar.nix`:

```nix
modules-left = [ 
  "hyprland/workspaces" 
  "hyprland/window" 
];

modules-center = [ 
  "clock" 
];

modules-right = [ 
  "tray"
  "pulseaudio"
  "network"
  "battery"
];
```

### Styling

CSS styling in the `style` section:

```nix
style = ''
  * {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
  }
  
  window#waybar {
    background: rgba(30, 30, 46, 0.9);
  }
'';
```

### Custom Modules

Add custom modules:

```nix
"custom/weather" = {
  format = "{}°C";
  exec = "curl wttr.in/?format=%t";
  interval = 3600;
};
```

## 💻 Hyprland Customization

### Animations

Edit animation curves in `home/hyprland/hyprland-config.nix`:

```nix
animations = {
  enabled = true;
  bezier = [
    "myBezier, 0.05, 0.9, 0.1, 1.05"
  ];
  animation = [
    "windows, 1, 7, myBezier"
    "fade, 1, 7, default"
  ];
};
```

### Gaps & Borders

```nix
general = {
  gaps_in = 5;
  gaps_out = 10;
  border_size = 2;
  "col.active_border" = "rgba(33ccffee)";
  "col.inactive_border" = "rgba(595959aa)";
};
```

### Window Rules

Add custom window rules:

```nix
windowrulev2 = [
  "float,class:^(myapp)$"
  "workspace 2,class:^(firefox)$"
  "opacity 0.9,class:^(kitty)$"
];
```

### Keybindings

Add custom keybindings:

```nix
bind = [
  "$mainMod, B, exec, firefox"
  "$mainMod, N, exec, thunar"
];
```

## 🖥️ Terminal Customization

### Kitty Colors

Edit `home/programs/kitty.nix`:

```nix
settings = {
  foreground = "#CDD6F4";
  background = "#1E1E2E";
  # Add more colors...
};
```

### Kitty Font

```nix
font = {
  name = "JetBrainsMono Nerd Font";
  size = 11;
};
```

### Opacity

```nix
settings = {
  background_opacity = "0.95";
};
```

## 🐚 Shell Customization

### Starship Prompt

Edit `home/shell/starship.nix`:

```nix
settings = {
  character = {
    success_symbol = "[➜](bold green)";
    error_symbol = "[✗](bold red)";
  };
  
  directory = {
    truncation_length = 3;
    style = "bold cyan";
  };
};
```

### Zsh Aliases

Add custom aliases in `home/shell/zsh.nix`:

```nix
shellAliases = {
  myalias = "command";
  update = "sudo nixos-rebuild switch --flake .#ares";
};
```

### Zsh Plugins

```nix
oh-my-zsh = {
  plugins = [ 
    "git" 
    "docker"
    "your-plugin"
  ];
};
```

## 📝 Neovim Customization

### LazyVim Configuration

Create `~/.config/nvim/lua/config/options.lua`:

```lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
```

### Custom Plugins

Create `~/.config/nvim/lua/plugins/custom.lua`:

```lua
return {
  {
    "your/plugin",
    config = function()
      -- plugin config
    end
  }
}
```

## 🔔 Notification Customization

### Mako Styling

Edit `home/services/mako.nix`:

```nix
services.mako = {
  backgroundColor = "#1e1e2eff";
  textColor = "#cdd6f4ff";
  borderColor = "#89b4faff";
  borderRadius = 10;
  font = "JetBrainsMono Nerd Font 11";
};
```

### Urgency Levels

```nix
extraConfig = ''
  [urgency=low]
  border-color=#94e2d5ff
  
  [urgency=high]
  border-color=#f38ba8ff
  default-timeout=0
'';
```

## 🎯 Application Launcher

### Walker Configuration

Edit `home/programs/walker.nix`:

```nix
xdg.configFile."walker/config.json".text = builtins.toJSON {
  placeholder = "Search...";
  fullscreen = false;
  modules = [
    { name = "applications"; }
    { name = "runner"; prefix = ">"; }
  ];
};
```

### Walker Styling

Edit CSS in `xdg.configFile."walker/style.css"`.

## 🖱️ Input Configuration

### Touchpad

Edit `home/hyprland/hyprland-config.nix`:

```nix
input = {
  touchpad = {
    natural_scroll = true;
    tap-to-click = true;
    scroll_factor = 0.5;
  };
};
```

### Keyboard Layout

```nix
input = {
  kb_layout = "us";
  kb_variant = "dvorak";  # Optional
};
```

## 🔧 System Customization

### Power Management

Edit `modules/system/power.nix`:

```nix
services.tlp.settings = {
  START_CHARGE_THRESH_BAT0 = 20;
  STOP_CHARGE_THRESH_BAT0 = 80;
  CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
};
```

### Audio

Edit `modules/system/audio.nix` for PipeWire settings.

### Network

Edit `modules/system/network.nix` for firewall rules.

## 📦 Adding Software

### System Packages

Edit `hosts/ares/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  your-package
];
```

### User Packages

Edit `home/jpolo.nix`:

```nix
home.packages = with pkgs; [
  your-package
];
```

### Flake Inputs

Add external packages in `flake.nix`:

```nix
inputs = {
  your-input = {
    url = "github:user/repo";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

## 🔄 Applying Changes

### System Changes

```bash
sudo nixos-rebuild switch --flake .#ares
```

### Home Manager Changes

```bash
home-manager switch --flake .#jpolo@ares
```

### Both

```bash
sudo nixos-rebuild switch --flake .#ares && \
home-manager switch --flake .#jpolo@ares
```

Or use the alias:
```bash
update
```

## 💡 Tips

1. **Test changes**: Build without switching first:
   ```bash
   nixos-rebuild build --flake .#ares
   ```

2. **Rollback**: If something breaks:
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

3. **Git tracking**: Keep your config in git:
   ```bash
   git add .
   git commit -m "Change description"
   ```

4. **Modular approach**: Create separate files for large changes

5. **Check syntax**: Use `nix flake check` before rebuilding

## 📚 Related Documentation

- [[Themes]] - Theme customization
- [[Configuration-Tips]] - Advanced tips
- [[Troubleshooting]] - Fix common issues
- [[Hyprland-Guide]] - Hyprland specifics

---

**Last Updated**: 2026-01-06
