---
tags: [hyprland, config, reference]
---

# Hyprland Config

This page covers the home-manager Hyprland configuration files, separate from the system-level Hyprland module (see [[Hyprland]] for system config).

## Configuration Files

All Hyprland home configs are in `home/hyprland/`:

| File | Purpose |
|------|---------|
| `default.nix` | Imports all submodules |
| `hyprland.nix` | Main window manager settings, keybinds, window rules |
| `hyprlock.nix` | Lock screen configuration |
| `hypridle.nix` | Idle daemon (screen dim, lock, suspend) |
| `waybar.nix` | Status bar configuration |
| `noctalia.nix` | Noctalia shell theme integration |

## Noctalia Shell

The Noctalia shell (from flake input `noctalia`) provides a themed Quickshell-based shell for Wayland. On Ares, it is configured with:

```json
{
  "General": { "scale": 1.0, "backend": "hyprland", "cursorTheme": "Bibata-Modern-Classic" },
  "Wallpaper": { "enabled": true, "directory": "/home/jpolo/Pictures/Wallpapers" },
  "Theme": { "mode": "dark", "useSystemColors": true, "blur": true, "fontFamily": "JetBrains Mono", "fontSize": 12 },
  "colorSchemes": { "schemeType": "M3-Rainbow", "useWallpaperColors": true },
  "Bar": { "enabled": true, "position": "top", "height": 42 },
  "ControlCenter": { "enabled": true, "position": "right", "width": 400 }
}
```

## Waybar

The Waybar status bar is configured in `home/hyprland/waybar.nix` and integrates with the Hyprland window manager.

## Hyprlock

The lock screen (`hyprlock.nix`) uses PAM for authentication, including fingerprint support (see [[Security]]).

## Hypridle

The idle daemon (`hypridle.nix`) manages screen dimming, locking, and suspend based on idle timeouts.

## Per-host customization

On Ares, the Hyprland configuration includes:
- Touchpad natural scrolling disabled (`natural_scroll = lib.mkForce false`)
- Custom wallpaper: `0-black-moon.jpg`
- Noctalia shell settings (see above)

On Janus, Hyprland is not used (KDE Plasma is the DE).

On Vega, there is no desktop environment.

## See also

- [[Hyprland]] — System-level Hyprland setup
- [[Ares]] — Host with Hyprland
- [[Home Programs]] — Other home-manager program configs
- [[Security]] — PAM/fingerprint for hyprlock