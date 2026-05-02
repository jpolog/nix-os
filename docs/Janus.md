---
tags:
  - host
  - desktop
  - janus
---

# Janus

> Family desktop — Intel i5-8265U (Coffee Lake) · KDE Plasma 6 · multi-user

## Overview

Janus is the household's shared desktop machine. It runs [[KDE Plasma|KDE Plasma 6]] on SDDM (Wayland session) and serves three users with different needs: system administration (jpolo), everyday use (elena), and family access (padres). Unlike [[Ares]] (the development laptop), Janus deliberately omits development tools — it's a general-purpose, media-capable workstation with full codec support, printing, and power management tuned for battery longevity.

| Field | Value |
|---|---|
| Hostname | `janus` |
| State version | 25.11 |
| Boot | systemd-boot, `linuxPackages_latest` |
| Desktop | KDE Plasma 6 (Wayland via SDDM) |
| Profiles | `base` + `desktop(kde)` |
| Development | **disabled** |

---

## Hardware

- **CPU**: Intel Core i5 8th gen (Coffee Lake) — HWP-aware, powersave governor
- **iGPU**: Intel UHD 620 — VA-API via iHD driver (`intel-media-driver`)
- **Battery**: Laptop form factor with TLP-managed charge thresholds

Kernel parameters:

```
quiet splash i915.enable_psr=1
```

`i915` is loaded in initrd for early display; Panel Self Refresh saves battery on the integrated GPU.

---

## Profiles & Modules

```mermaid
graph TD
    Janus["janus<br/><i>Family desktop</i>"]

    subgraph System Profiles
        Base["profiles.base"]
        Desktop["profiles.desktop<br/><i>environment = kde</i>"]
    end

    subgraph Home Manager – jpolo
        JPDesktop["home.profiles.desktop<br/><i>→ KDE override</i>"]
        JPPower["home.profiles.power-user<br/><i>lighter: no upscayl/torrenting</i>"]
        JPAi["programs.ai-tools<br/><i>Claude Code</i>"]
    end

    subgraph Home Manager – elena / padres
        ElenaDefaults["elena<br/><i>default configs</i>"]
        PadresDefaults["padres<br/><i>default configs</i>"]
    end

    subgraph Disabled
        DevX["❌ development"]
        WorkX["❌ work"]
        ResearchX["❌ research"]
        MasterX["❌ master"]
        CreativeX["❌ creative"]
    end

    Janus --> Base
    Janus --> Desktop
    Janus --> JPDesktop
    Janus --> JPPower
    Janus --> JPAi
    Janus --> ElenaDefaults
    Janus --> PadresDefaults
    Desktop -.->|disabled| DevX
    Desktop -.->|disabled| WorkX
    Desktop -.->|disabled| ResearchX
    Desktop -.->|disabled| MasterX
    Desktop -.->|disabled| CreativeX
```

See also: [[Profile System]], [[Home Profiles]]

---

## Boot Configuration

| Setting | Value |
|---|---|
| Bootloader | `systemd-boot` |
| Configuration limit | 10 generations |
| Kernel | `linuxPackages_latest` |
| Initrd modules | `i915` |
| Kernel params | `quiet splash i915.enable_psr=1` |
| EFI | `canTouchEfiVariables = true` |

---

## Desktop Environment

[[KDE Plasma|KDE Plasma 6]] on Wayland, managed by SDDM.

**Touchpad** (libinput):

| Setting | Value |
|---|---|
| Natural scrolling | ✅ enabled |
| Tap to click | ✅ enabled |
| Disable while typing | ✅ enabled |

---

## Media & Codec Support

Intel Coffee Lake's UHD 620 needs VA-API through the **iHD** driver for hardware-accelerated decode.

### Hardware Video Acceleration

| Component | Package |
|---|---|
| VA-API driver | `intel-media-driver` (iHD) |
| VDPAU→VA-API bridge | `libvdpau-va-gl` |
| Diagnostics | `libva-utils` (`vainfo`) |

Session variable: `LIBVA_DRIVER_NAME=iHD`

### Software Codec Stack

| Category | Packages |
|---|---|
| GStreamer core | `gstreamer`, `gst-plugins-base` |
| GStreamer good | AAC, MP4, AVI, FLAC, JPEG, PNG, WebM, OGG |
| GStreamer bad | HLS, DASH, FLAC, MPEG-TS, H.265 |
| GStreamer ugly | H.264, MP3, MPEG-2, AC3, x264 |
| GStreamer libav | ffmpeg-backed: nearly all remaining formats |
| GStreamer VA-API | Hardware-accelerated decode pipeline |
| FFmpeg | Full codec build |
| DVD | `libdvdcss`, `libdvdread`, `libdvdnav` |
| Codec libs | `x264`, `x265` |

Unfree packages are allowed (`nixpkgs.config.allowUnfree = true`) for codecs and `libdvdcss`.

---

## Printing

CUPS with a broad driver set and mDNS auto-discovery via Avahi.

| Driver | Purpose |
|---|---|
| `gutenprint` | Wide generic driver coverage |
| `hplip` | HP printers |
| `canon-cups-ufr2` | Canon printers |

Avahi is enabled with `nssmdns4` and the firewall port open for mDNS-based printer discovery.

---

## Power Management

TLP handles laptop power management; `power-profiles-daemon` is force-disabled to avoid conflicts.

| Setting | AC | Battery |
|---|---|---|
| CPU governor | `powersave` | `powersave` |
| Energy performance | `balance_performance` | `balance_power` |

**Battery care** (charge thresholds):

| Threshold | Value |
|---|---|
| Start charge | 20% |
| Stop charge | 80% |

This prolongs battery lifespan by keeping charge between 20–80%.

See also: [[Power Management]]

---

## Users

### jpolo — Admin

| Attribute | Value |
|---|---|
| Shell | `zsh` |
| Groups | `wheel`, `networkmanager`, `video`, `audio`, `input`, `power` |
| Home profiles | Desktop → **KDE override**, power-user (**lighter** — no upscayl, no torrenting) |
| Disabled profiles | development, work, research, master, creative |
| AI tools | Claude Code via `programs.ai-tools` (independent of dev profile) |
| Ollama | **disabled** (no ROCm on this machine) |
| File sync | [[#Syncthing]] (jpolo only) |

### elena

| Attribute | Value |
|---|---|
| Shell | `bash` |
| Groups | `networkmanager`, `video`, `audio`, `input` |
| Initial password | `elena` (must change on first login) |
| Home profiles | Default configs via `elena.nix` |

### padres

| Attribute | Value |
|---|---|
| Shell | `bash` |
| Groups | `networkmanager`, `video`, `audio`, `input` |
| Initial password | `padres` (must change on first login) |
| Home profiles | Default configs via `padres.nix` |

> [!warning] Initial passwords for `elena` and `padres` must be changed with `passwd` on first login.

---

## Syncthing & Media

- **Syncthing** runs for jpolo only (`services.syncthing-jpolo.enable = true`)
- **Plex client** with firewall rules for network discovery and downloads (`services.plex-client.enable = true`)

---

## Compatibility Layer

| Service | Purpose |
|---|---|
| `envfs` | `/usr/bin/env` resolution so shebangs work on NixOS |
| `nix-ld` | Run precompiled ELF binaries (e.g. AppImages) |

`nix-ld` includes: `stdenv.cc.cc.lib`, `zlib`, `openssl`, `glib`, `gtk3`, `nss`, `nspr`, `freetype`, `fontconfig`, `cairo`, `pango`, `atk`, `gdk-pixbuf`, `libxml2`.

---

## Locale & Localization

| Setting | Value |
|---|---|
| Default locale | `en_US.UTF-8` |
| `LC_ADDRESS` | `es_ES.UTF-8` |
| `LC_IDENTIFICATION` | `es_ES.UTF-8` |
| `LC_MEASUREMENT` | `es_ES.UTF-8` |
| `LC_MONETARY` | `es_ES.UTF-8` |
| `LC_NAME` | `es_ES.UTF-8` |
| `LC_NUMERIC` | `es_ES.UTF-8` |
| `LC_PAPER` | `es_ES.UTF-8` |
| `LC_TELEPHONE` | `es_ES.UTF-8` |
| `LC_TIME` | `es_ES.UTF-8` |
| Console keymap | `es` |

English system messages with Spanish number formats, dates, and measurements — appropriate for a household in Spain.

---

## System Optimizations

| Setting | Value |
|---|---|
| ZRAM swap | ✅ enabled (default 50%) |
| Documentation | ❌ disabled (`documentation.enable = false`) |
| Unfree packages | ✅ allowed |

Documentation is disabled to save disk space on this general-use machine. See [[System Modules]] for global module details.

---

## Cross-References

- [[Ares]] — Development laptop (Hyprland + Noctalia)
- [[Vega]] — Headless GPU compute node (ROCm)
- [[Architecture Overview]] — Full system architecture
- [[Module System]] — How NixOS modules are organized
- [[Profile System]] — Profile inheritance and overrides
- [[Home Profiles]] — Home Manager profile details
- [[KDE Plasma]] — KDE-specific module configuration
- [[Power Management]] — TLP and power settings across hosts
- [[Network & VPN]] — Networking configuration
- [[Deployment Guide]] — Rebuilding and deploying