---
tags:
  - architecture
  - flake
---

# Flake Inputs

The NixOS configuration is managed as a Nix flake defined in `/etc/nixos/flake.nix`. This page documents every input, the overlay system, and the output structure.

## Inputs

### Core

| Input | Source | Purpose |
|-------|--------|---------|
| **nixpkgs** | `github:nixos/nixpkgs/nixos-unstable` | Primary package set. All hosts and home-manager configurations resolve packages from this input. |
| **nixpkgs-stable** | `github:nixos/nixpkgs/nixos-25.11` | Stable overlay (`pkgs.stable.*`). Used for packages that need a more conservative version — e.g. kernel modules, certain libraries that break on unstable. |

### Home Manager

| Input | Source | Purpose |
|-------|--------|---------|
| **home-manager** | `github:nix-community/home-manager` | Declarative user-environment management. Integrated as a NixOS module (`useGlobalPkgs`, `useUserPackages`) so home-manager shares the host's `nixpkgs` and overlays. Follows `nixpkgs`. |

### Hyprland Ecosystem

| Input | Source | Purpose |
|-------|--------|---------|
| **hyprland** | `git+https://github.com/hyprwm/Hyprland?submodules=1&ref=refs/tags/v0.53.1` | Hyprland Wayland compositor, pinned to **v0.53.1** via a tagged ref. Built with submodules for full functionality. Follows `nixpkgs`. |
| **hyprland-plugins** | `github:hyprwm/hyprland-plugins` | Official Hyprland plugins collection. Follows `hyprland` to stay ABI-compatible. |
| **hypridle** | `github:hyprwm/hypridle` | Idle daemon for Hyprland — triggers lock/suspend after inactivity. Follows `nixpkgs`. |
| **hyprlock** | `github:hyprwm/hyprlock` | Screen locker for Hyprland. Follows `nixpkgs`. |
| **hyprsunset** | `github:hyprwm/hyprsunset` | Blue-light filter for Hyprland (similar to redshift/gammastep). Follows `nixpkgs`. |
| **quickshell** | `git+https://github.com/outfoxxed/quickshell` | Qt-based shell/panel framework for Wayland compositors. Used by Noctalia and custom widgets. Follows `nixpkgs`. |
| **noctalia** | `github:noctalia-dev/noctalia-shell` | Noctalia shell theme — cohesive dark theme for Hyprland, Waybar, and related components. Follows `nixpkgs`. |

### Nix Utilities

| Input | Source | Purpose |
|-------|--------|---------|
| **nix-index-database** | `github:nix-community/nix-index-database` | Pre-built database for the `command-not-found` handler. Enables `comma` (``,`) to run one-off packages without installing them. Follows `nixpkgs`. |
| **nix-direnv** | `github:nix-community/nix-direnv` | Improved direnv integration — persistent GC roots so `direnv` environments aren't garbage-collected mid-session. Follows `nixpkgs`. |

### Package Extensions

| Input | Source | Purpose |
|-------|--------|---------|
| **firefox-addons** | `gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons` | NUR expressions for declarative Firefox extension management (by rycee). Exposed via an overlay so home-manager can reference `pkgs.firefox-addons.*`. Follows `nixpkgs`. |

### Secrets

| Input | Source | Purpose |
|-------|--------|---------|
| **sops-nix** | `github:Mic92/sops-nix` | Secrets management using SOPS (Secrets OPerationS) with age/GPG encryption. Decrypts secrets at activation time; never stored in the Nix store. Follows `nixpkgs`. |

---

## Overlay System

Three overlays are composed in order and applied globally via `nixpkgs.overlays` in `sharedModules`:

```nix
overlays = [
  # 1. Stable packages overlay
  (final: prev: {
    stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
  })

  # 2. Firefox addons overlay
  firefox-addons.overlays.default

  # 3. Custom packages overlay
  (final: prev: import ./overlays { inherit prev final; })
];
```

### 1. Stable overlay

Makes the full `nixpkgs-stable` package set available as `pkgs.stable.*`. Any package that requires a known-stable version (e.g. a kernel module or a library with a regression in unstable) can reference `pkgs.stable.<package>` instead of `pkgs.<package>`.

### 2. Firefox addons overlay

Exposes the `firefox-addons` input as an overlay, making Firefox extensions available as `pkgs.firefox-addons.*`. This allows the Firefox home-manager module to declare extensions declaratively:

```nix
programs.firefox.profiles.default.extensions = with pkgs.firefox-addons; [
  ublock-origin
  # …
];
```

### 3. Custom overlay

`./overlays/default.nix` provides a hook for site-local packages. Currently contains a placeholder (`my-custom-tool`). Add custom scripts and utilities here to make them available system-wide as `pkgs.*`.

---

## Outputs

### `nixosConfigurations`

Three hosts, each built from `sharedModules` plus a host-specific `configuration.nix`:

| Host | Role | Additional Modules |
|------|------|--------------------|
| **ares** | ThinkPad T14s Gen 6 AMD — primary dev laptop | `./hosts/ares/configuration.nix` |
| **janus** | Family desktop — KDE, users: jpolo/elena/padres | `./hosts/janus/configuration.nix` |
| **vega** | Headless GPU compute node (Vega 56) | `./hosts/vega/configuration.nix` |

All hosts receive `specialArgs = { inherit inputs self; }` so modules can reference flake inputs directly.

### `devShells`

Defined in `./dev-shells/` and imported as `import ./dev-shells { inherit pkgs; }`:

| Shell | Purpose |
|-------|---------|
| **default** | Base development environment |
| **python** | Python development |
| **node** | Node.js development |
| **rust** | Rust development |
| **go** | Go development |

Enter with `nix develop .#<name>` (or `nix develop` for default).

### `formatter`

```nix
formatter.${system} = pkgs.alejandra;
```

Run `nix fmt` to format all `.nix` files with [alejandra](https://github.com/kamadorueda/alejandra).

---

## sharedModules Composition

Every `nixosConfiguration` inherits the same `sharedModules` list, ensuring consistent baseline across all hosts:

```
sharedModules
├── ./modules/system              # System-level modules (audio, bluetooth, network, security, …)
├── ./modules/desktop             # Desktop modules (hyprland, kde, display-manager, fonts, xdg)
├── ./modules/services            # Service modules (printing, syncthing, kmonad, …)
├── ./modules/profiles            # System profiles (base, desktop, development, gaming, server)
├── ./modules/vms                 # VM management (windows11 QEMU/KVM)
├── nix-index-database module     # command-not-found + comma
│   └── programs.nix-index-database.comma.enable = true
├── sops-nix module               # SOPS secrets decryption
├── nixpkgs.overlays = overlays   # Apply all three overlays
├── nixpkgs.config.allowUnfree = true
└── home-manager module
    ├── useGlobalPkgs = true      # home-manager uses host pkgs (including overlays)
    ├── useUserPackages = true    # packages installed to system profile
    ├── extraSpecialArgs = { inherit inputs; flakePath = /etc/nixos; }
    └── home-manager.sharedModules
        ├── ./home/profiles       # Home profiles (base, cli, desktop, development, …)
        ├── ./home/programs       # Home programs (firefox, kitty, neovim, …)
        ├── ./home/services       # Home services (ollama, mako, hyprsunset, …)
        └── ./home/shell          # Shell config (zsh, starship, power-user-functions)
```

Each host then appends its own `configuration.nix` to this list, which enables the specific profiles and modules appropriate for that machine. See [[Architecture Overview]] for how modules compose into host configurations.

---

*See also: [[Architecture Overview]]*