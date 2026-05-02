---
tags: [desktop, display-manager, reference]
---

# Display Manager

The display manager handles graphical login and session selection.

## SDDM (Simple Desktop Display Manager)

All hosts with a desktop environment use **SDDM** with Wayland support, configured in `modules/desktop/display-manager.nix`.

```nix
services.displayManager.sddm.enable = true;
services.displayManager.sddm.wayland.enable = true;
```

### Per-host configuration

- **[[Ares]]**: SDDM Wayland enabled explicitly in host config
- **[[Janus]]**: SDDM Wayland enabled explicitly in host config, `services.displayManager.defaultSession = "plasma"` set via KDE module
- **[[Vega]]**: No display manager (headless)

## How session selection works

1. SDDM presents a login screen
2. User selects session type (Hyprland or Plasma)
3. The `profiles.desktop.environment` setting pre-configures the default session
4. On Ares (Hyprland), the default session is `hyprland`
5. On Janus (KDE), the default session is `plasma`

## Customization

To change the display manager theme or settings, edit `modules/desktop/display-manager.nix` or add overrides in the host configuration.

## See also

- [[Desktop Environment]] — how DE selection works
- [[Hyprland]] — Wayland compositor
- [[KDE Plasma]] — KDE Plasma 6
- [[Ares]] — primary host (Hyprland)
- [[Janus]] — family host (KDE)