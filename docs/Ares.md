---
tags:
  - host
  - laptop
  - ares
---

# Ares

> ThinkPad T14s Gen 6 AMD — primary development machine · Hyprland + Noctalia · ROCm-accelerated Ollama

## Overview

Ares is the main development laptop, configured for full-stack engineering, AI workloads, and research. It runs [[Hyprland]] with the Noctalia shell on SDDM (Wayland), and carries the most extensive profile stack of any host in the fleet. A secondary `gaming` user provides an isolated KDE session for leisure.

| Field | Value |
|---|---|
| Hostname | `ares` |
| State version | 25.11 |
| Host ID | `8425e34f` (ZFS requirement) |
| Boot | systemd-boot, `linuxPackages_latest` |
| Desktop | Hyprland + Noctalia (Wayland via SDDM) |
| System profiles | `base` + `desktop(hyprland)` + `development` |
| Home profiles (jpolo) | `desktop(hyprland)` + `cli` + `development` + `creative` + `power-user` + `work` + `research` + `master` + `personal` |

---

## Hardware

- **CPU**: AMD Ryzen AI 7 PRO 350 — HWP-aware, `amd_pstate=active` governor
- **iGPU**: AMD Radeon 860M (GFX1102) — VA-API/VDPAU via Mesa
- **RAM**: 32 GB+ LPDDR5
- **Storage**: NVMe SSD, BTRFS on LUKS (`cryptroot`) with `@`, `@home`, `@nix` subvolumes
- **TPM**: Firmware-level TPM via swtpm emulation (for Windows 11 VM)
- **Fingerprint**: Goodix (libfprint-2-tod1-goodix) — PAM-enabled for `login`, `sudo`, `hyprlock`
- **ThinkPad ACPI**: `thinkpad_acpi` loaded with `fan_control=1` for manual fan control
- **Kernel modules**: `nvme`, `xhci_pci`, `thunderbolt`, `kvm-amd`

Kernel parameters:

```
quiet splash amd_pstate=active
```

---

## Profiles & Modules

```mermaid
graph TD
    Ares["ares<br/><i>Dev laptop · ThinkPad T14s Gen 6</i>"]

    subgraph System Profiles
        Base["profiles.base"]
        Desktop["profiles.desktop<br/><i>environment = hyprland</i>"]
        Dev["profiles.development<br/><i>python · nodejs · docker · ai</i>"]
        GamingX["❌ profiles.gaming<br/><i>disabled — user-level only</i>"]
    end

    subgraph Host-Specific Modules
        TLP["TLP · thinkfan"]
        KMonad["KMonad<br/><i>standard layout · 3 layers</i>"]
        Eduroam["eduroam (UM)"]
        VPN["university-vpn (UM)"]
        FPrint["fprintd · Goodix"]
        PowerProfiles["power-profiles<br/><i>eco/balanced/performance scripts</i>"]
    end

    subgraph Home Manager — jpolo
        HDesktop["home.profiles.desktop<br/><i>→ Hyprland override</i>"]
        HCli["home.profiles.cli"]
        HDev["home.profiles.development<br/><i>Claude Code · AI tools</i>"]
        HCreative["home.profiles.creative<br/><i>video editing</i>"]
        HPower["home.profiles.power-user<br/><i>productivity · torrenting · upscayl</i>"]
        HWork["home.profiles.work<br/><i>Slack · Teams · Zoom · VPN</i>"]
        HResearch["home.profiles.research<br/><i>LaTeX · diagrams</i>"]
        HMaster["home.profiles.master"]
        HPersonal["home.profiles.personal<br/><i>Plex · Syncthing · Bitwarden</i>"]
        OllamaHM["services.ollama-service<br/><i>ROCm acceleration</i>"]
        Noctalia["Noctalia shell<br/><i>M3-Rainbow · matugen</i>"]
        KritaTheme["KDE theme<br/><i>Krita Dark Orange</i>"]
    end

    subgraph Home Manager — gaming
        GamingDesktop["home.profiles.desktop<br/><i>→ KDE override</i>"]
        GamingProfile["home.profiles.gaming<br/><i>Steam · utils</i>"]
    end

    subgraph VMs & Services
        Win11["Windows 11 VM<br/><i>8 GB · 4 vCPU · 80G disk</i>"]
        Syncthing["Syncthing (jpolo)"]
        PlexClient["Plex client firewall"]
    end

    Ares --> Base
    Ares --> Desktop
    Ares --> Dev
    Ares -.->|"disabled"| GamingX
    Ares --> TLP
    Ares --> KMonad
    Ares --> Eduroam
    Ares --> VPN
    Ares --> FPrint
    Ares --> PowerProfiles

    Ares --> HDesktop
    Ares --> HCli
    Ares --> HDev
    Ares --> HCreative
    Ares --> HPower
    Ares --> HWork
    Ares --> HResearch
    Ares --> HMaster
    Ares --> HPersonal
    Ares --> OllamaHM
    Ares --> Noctalia
    Ares --> KritaTheme

    Ares --> GamingDesktop
    Ares --> GamingProfile

    Ares --> Win11
    Ares --> Syncthing
    Ares --> PlexClient
```

See also: [[Profile System]], [[Home Profiles]], [[Module System]], [[System Modules]]

---

## Boot Configuration

| Setting | Value |
|---|---|
| Bootloader | `systemd-boot` |
| Configuration limit | 10 generations |
| Kernel | `linuxPackages_latest` |
| Kernel params | `quiet splash amd_pstate=active` |
| Kernel modules | `thinkpad_acpi` (fan control), `kvm-amd` |
| Modprobe | `options thinkpad_acpi fan_control=1` |
| EFI | `canTouchEfiVariables = true` |

Root filesystem is BTRFS on LUKS with subvolumes `@`, `@home`, `@nix`. See [[Architecture Overview]] for the full partition layout.

---

## Networking

| Component | Configuration |
|---|---|
| NetworkManager | ✅ enabled |
| Tailscale | ✅ enabled (mesh VPN, SSH access) — see [[Network & VPN]] |
| eduroam | ✅ `javier.polog@um.es`, MSCHAPv2, SOPS-managed password |
| University VPN | ✅ `vpn.um.es`, IKEv2 split-tunnel (`155.54.0.0/16`, DNS `um.es`) |
| IP forwarding | ✅ `net.ipv4.ip_forward = 1`, `net.ipv6.conf.all.forwarding = 1` (Docker) |

### Firewall

See [[Network & VPN]] for the shared network module.

| Port | Service |
|---|---|
| 12000 | Traefik HTTP |
| 12001 | Traefik Dashboard |
| 12010 | Auth Service |
| 12011 | Pipeline Config Service |
| 12012 | Artifacts Service |
| 12013 | LangGraph Orchestrator |
| 12014 | Webapp |
| 3000 | Langfuse (observability) |
| 8081 | Mongo Express (dev) |
| 11434 | Ollama |
| Docker bridges | `docker0`, `br-+` — INPUT/FORWARD accepted via iptables |

Docker manages its own iptables/nat rules (`iptables = true`, `ip6tables = true`). The `extraCommands` block ensures `docker0` and dynamic `br-+` bridges are trusted for both INPUT and FORWARD chains.

---

## Power Management

TLP is enabled; `power-profiles-daemon` is force-disabled to avoid conflicts.

| Setting | AC | Battery |
|---|---|---|
| CPU governor | `powersave` | `powersave` |
| Energy perf policy | `balance_performance` | `balance_power` |
| CPU boost | **disabled** | **disabled** |

**USB denylist**: `046d:c52b` (Logitech Unifying Receiver K850) — prevents autosuspend hang.

### thinkfan — Balanced Profile

7-level fan curve using `k10temp` (AMD Tctl) and `acpitz` (ACPI thermal zone) sensors:

| Level | Min °C | Max °C | Behavior |
|---|---|---|---|
| 0 | 0 | 42 | Fan off — silent |
| 1 | 38 | 48 | Very quiet |
| 2 | 45 | 55 | Quiet — moderate load |
| 3 | 52 | 62 | Comfortable — sustained work |
| 4 | 58 | 68 | Active cooling |
| 5 | 64 | 74 | Strong cooling |
| 6 | 70 | 78 | Aggressive cooling |
| 7 | 75 | ∞ | Maximum — emergency |

Custom power-profile scripts (`power-balanced`, `power-eco`, `power-performance`, etc.) swap the active thinkfan YAML at runtime.

See also: [[Power Management]]

---

## Desktop Environment

[[Hyprland]] with the **Noctalia** shell (QuickShell-based), SDDM Wayland session.

| Setting | Value |
|---|---|
| Compositor | Hyprland (Wayland) |
| Shell | Noctalia v3 (QuickShell) |
| Bar | Top, 42px, workspaces · media · clock · network · volume · brightness · battery |
| Control center | Right panel, 400px |
| Theme | Material You (M3-Rainbow), matugen color generation |
| Cursor | Bibata-Modern-Classic (24px) |
| Font | JetBrains Mono, 12pt |
| Wallpaper | `/home/jpolo/Pictures/Wallpapers/0-black-moon.jpg` |

Touchpad is configured with tap-to-click and disabled natural scrolling (`natural_scroll = false` via `mkForce`). See [[Hyprland]] for full compositor settings.

---

## KMonad — Dual-Role Keyboard

Ares runs KMonad with the **standard layout** on three input devices:

1. **Laptop keyboard** (`platform-i8042-serio-0-event-kbd`)
2. **USB wireless keyboard** (`usb-CX_2.4G_Receiver-event-kbd`)
3. **Logitech K850** (`usb-Logitech_USB_Receiver-if02-event-kbd`)

### Dual-Role Keys

Each key acts normally on tap, and activates a layer or modifier on hold:

| Key | Tap | Hold (200–300ms) | Timeout |
|---|---|---|---|
| `Caps Lock` | `Esc` | **Control layer** | 200ms |
| `a` | `a` | `Left Ctrl` | 300ms |
| `s` | `s` | `Left Alt` | 300ms |
| `d` | `d` | **Symbols layer** | 300ms |
| `k` | `k` | **Numpad layer** | 300ms |
| `l` | `l` | `Left Alt` | 300ms |
| `;` | `;` | `Left Ctrl` | 200ms |

### Extra Layers

**Control layer** (hold `Caps Lock`):

All keys map to their `Ctrl+` equivalent. Arrow keys on `h/j/k/l`, navigation on `left/down/up/right`.

**Numpad layer** (hold `k`):

| | | | |
|---|---|---|---|
| `7` | `8` | `9` | |
| `4` | `5` | `6` | |
| `0` | `1` | `2` | `3` |

Mapped to the spatial position of `w/e/r`, `s/d/f`, `z/x/c/v` respectively.

**Symbols layer** (hold `d`):

Left side mirrors shifted numpad positions (same spatial memory):
`w→&`, `e→*`, `r→(`, `s→$`, `f→^`, `z→)`, `x→!`, `c→@`, `v→#`

Right side provides bracket/operator grid:
`u→[`, `i→]`, `o→\`, `p→~`, `j→{`, `k→}`, `l→|`, `m→_`, `,→-`, `.→=`

---

## Users

### jpolo — Primary Developer

| Attribute | Value |
|---|---|
| Full name | Javier Polo Gambin |
| Shell | `zsh` |
| Groups | `wheel`, `networkmanager`, `video`, `audio`, `input`, `power`, `docker` |
| Home profiles | desktop(hyprland), cli, development, creative, power-user, work, research, master, personal |
| Development | Python, Node.js, Docker, AI tools (Claude Code) |
| Ollama | ✅ ROCm acceleration (`HSA_OVERRIDE_GFX_VERSION=11.0.0`) |
| Theme | Noctalia shell + KDE Krita Dark Orange color scheme |
| File sync | Syncthing |
| Media | Plex client |

**SSH known hosts** (via `programs.ssh.matchBlocks`):

| Host | User | Key | Notes |
|---|---|---|---|
| `dgx-spark` | `javierpg` | `~/.ssh/id_um` | Port 25004, X11 forward |
| `um-machine` | `javierpg` | `~/.ssh/id_um` | Port 25002 |
| `apollo` | `jpolo` | default | |
| `jureca` | `pologambn1` | `~/.ssh/cispa` | Jülich supercomputer |
| `aws-public` | `ec2-user` | `~/.ssh/WebserverKey-PUBLIC-Prac2.pem` | |

### gaming — Isolated Gaming User

| Attribute | Value |
|---|---|
| Shell | `bash` |
| Groups | `networkmanager`, `video`, `audio`, `input` |
| Initial password | `gaming` |
| Home profiles | desktop(KDE override), gaming (Steam, utils) |
| Development | **disabled** |

---

## Home Manager — jpolo

### Noctalia Shell Configuration

Noctalia is configured with:

- **General**: scale 1.0, Hyprland backend, Bibata-Modern-Classic cursor
- **Theme**: dark mode, system colors via matugen, blur enabled (0.9 opacity), 8px corners
- **Color scheme**: M3-Rainbow with wallpaper-derived colors
- **Bar**: top, 42px, workspaces · media · clock · updates · VPN · network · volume · brightness · battery · quicksettings
- **Control center**: right panel, 400px, brightness/volume/network/bluetooth/settings modules
- **Notifications**: top-right, 5s display, max 3 visible

### KDE Custom Color Scheme — Krita Dark Orange

A hand-crafted dark theme with warm orange (#FFA200) as the accent color, applied to both `kdeglobals` and the KDE color scheme file. Covers View, Window, Button, Selection, Tooltip, Complementary, and WM color sets.

### Dolphin Configuration

- Status bar visible
- Global view properties
- Alternating row colors disabled
- Places icon size: 22px

---

## Virtual Machines

### Windows 11

| Setting | Value |
|---|---|
| RAM | 8192 MB |
| vCPUs | 4 |
| Disk | 80 GB qcow2 |
| UEFI | OVMF with Secure Boot + swtpm TPM 2.0 |
| VirtIO | Network, block, balloon, rng |
| User | `jpolo` |
| VM directory | `~/VMs/windows11/` |
| Launch command | `win11-vm` |
| Bypass command | `win11-vm-bypass` (no TPM/SB) |
| ISO download | `win11-download-iso` |

KVM is enabled with `kvm-amd` module and nested virtualization. See [[Virtualization]] for module details.

---

## Gaming Hardware

Although `profiles.gaming` is **disabled** at the system level, hardware graphics support is configured directly on ares for the gaming user:

| Component | Value |
|---|---|
| `hardware.graphics.enable` | ✅ (with 32-bit) |
| VA-API/VDPAU | `libva-utils`, `libvdpau-va-gl` |
| GameMode | ✅ enabled (`amd_performance_level = high`) |

The `gaming` user gets KDE desktop via home-manager with `home.profiles.desktop.environment = "kde"`.

---

## Syncthing & Plex

- **Syncthing** runs for jpolo (`services.syncthing-jpolo.enable = true`) — data dir `/home/jpolo`, config dir `~/.config/syncthing`
- **Plex client** firewall rules enabled (`services.plex-client.enable = true`)

---

## Compatibility Layer

| Service | Purpose |
|---|---|
| `envfs` | `/usr/bin/env` shebang resolution |
| `nix-ld` | Run precompiled ELF binaries (AppImages, VS Code extensions) |

`nix-ld` libraries: `stdenv.cc.cc.lib`, `zlib`, `openssl`, `glib`, `gtk3`, `nss`, `nspr`, `freetype`, `fontconfig`, `cairo`, `pango`, `atk`, `gdk-pixbuf`, `libxml2`, `libxslt`.

---

## System Optimizations

| Setting | Value |
|---|---|
| ZRAM swap | ✅ enabled |
| Documentation | ❌ disabled (`documentation.enable = false`) |
| Unfree packages | ✅ allowed |
| Auto-optimise store | ✅ |

### Nix Caches

| Cache | URL |
|---|---|
| NixOS | `https://cache.nixos.org` |
| Hyprland | `https://hyprland.cachix.org` |
| Devenv | `https://devenv.cachix.org` |
| nixpkgs-python | `https://nixpkgs-python.cachix.org` |
| nix-community | `https://nix-community.cachix.org` |

---

## Cross-References

- [[Home]] — Home Manager architecture
- [[Architecture Overview]] — Full system overview
- [[Module System]] — NixOS module organization
- [[Profile System]] — Profile inheritance and composition
- [[Home Profiles]] — Home Manager profile details
- [[Flake Inputs]] — Flake dependencies
- [[Deployment Guide]] — Rebuilding and deploying
- [[Secrets Management]] — SOPS secrets (eduroam, Tailscale, VPN)
- [[Network & VPN]] — Tailscale, eduroam, university VPN
- [[System Modules]] — Audio, Bluetooth, Security, etc.
- [[Hyprland]] — Compositor and shell configuration
- [[KDE Plasma]] — KDE configuration (gaming user)
- [[Virtualization]] — VM module and Windows 11 setup
- [[Power Management]] — TLP, thinkfan, power profiles
- [[AI Agent Reference]] — Ollama, Claude Code, AI services