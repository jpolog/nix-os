---
tags: [desktop, fonts, xdg, reference]
---

# Fonts & XDG

The fonts and XDG modules provide consistent typography and default application handling across desktop environments.

## Fonts Module

**File:** `modules/desktop/fonts.nix`

Installs system-level font packages. The module is imported as part of the desktop module set when `profiles.desktop.enable = true`.

### Key font packages

- Core fonts for desktop rendering
- Monospace fonts for terminals and code
- Unicode coverage fonts

## XDG Module

**File:** `modules/desktop/xdg.nix`

Configures XDG default applications and portal settings.

### XDG Portal

The XDG portal configuration adapts based on the desktop environment:

- **Hyprland**: `xdg-desktop-portal-hyprland` + `xdg-desktop-portal-gtk`
- **KDE**: `xdg-desktop-portal-kde` + `xdg-desktop-portal-gtk`

This is configured in `home/profiles/desktop.nix` with a conditional based on `home.profiles.desktop.environment`.

### Default Applications

The home profile sets comprehensive MIME type defaults (see [[Home Profiles]]):

| Category | Application |
|----------|-------------|
| Text files | Neovim (`nvim.desktop`) |
| Web pages | Firefox (`firefox.desktop`) |
| PDF | Okular (`okular.desktop`) |
| Images | imv (`imv.desktop`) |
| Video | MPV (`mpv.desktop`) |
| Audio | MPV (`mpv.desktop`) |
| Directories | Dolphin (`dolphin.desktop`) |
| Archives | Ark (`ark.desktop`) |

## Cursor Theme

Configured in `home/profiles/desktop.nix`:

```nix
home.pointerCursor = {
  name = "Bibata-Modern-Classic";
  package = pkgs.bibata-cursors;
  size = 24;
  gtk.enable = true;
  x11.enable = true;
};
```

## See also

- [[Desktop Environment]] — DE selection mechanism
- [[Hyprland]] — Wayland-specific portal config
- [[KDE Plasma]] — KDE-specific portal config
- [[Home Profiles]] — MIME defaults and cursor settings