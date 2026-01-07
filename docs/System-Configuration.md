---
title: System Configuration
tags: [nixos, system, configuration, modules]
created: 2026-01-06
related: [[README]], [[Audio-Configuration]], [[Network-Configuration]]
---

# System Configuration

Detailed documentation of system-level configuration modules.

## 📁 Module Structure

The system configuration is split into modular components in `modules/system/`:

```
modules/system/
├── default.nix        # Module aggregator
├── audio.nix          # Audio configuration
├── bluetooth.nix      # Bluetooth support
├── network.nix        # Network management
├── power.nix          # Power management
├── security.nix       # Security & authentication
└── ssh.nix            # SSH configuration
```

## 🔊 Audio Configuration

**File**: `modules/system/audio.nix`

### Technology Stack

- **Sound Server**: [[PipeWire]]
  - Modern replacement for PulseAudio and JACK
  - Lower latency
  - Better Bluetooth support
  - Professional audio capabilities

### Features

- ✅ ALSA support
- ✅ PulseAudio compatibility layer
- ✅ JACK support for professional audio
- ✅ WirePlumber session manager
- ✅ Real-time audio scheduling (RTKit)

### Installed Packages

| Package | Purpose |
|---------|---------|
| `pavucontrol` | GUI volume control |
| `pulseaudio` | pactl/pacmd utilities |
| `pamixer` | CLI volume control |
| `playerctl` | Media player control |
| `easyeffects` | Audio effects & processing |

### Configuration

PipeWire is configured with:
```nix
services.pipewire = {
  enable = true;
  alsa.enable = true;
  pulse.enable = true;
  jack.enable = true;
};
```

See [[Audio-Configuration]] for detailed audio setup.

## 📡 Bluetooth Configuration

**File**: `modules/system/bluetooth.nix`

### Technology Stack

- **Bluetooth Stack**: [[BlueZ]]
- **GUI Manager**: [[Blueman]]

### Features

- ✅ Auto power-on at boot
- ✅ Experimental features enabled
- ✅ A2DP audio support
- ✅ GUI management interface

### Configuration

```nix
hardware.bluetooth = {
  enable = true;
  powerOnBoot = true;
  settings.General.Experimental = true;
};
```

### Usage

- **GUI**: `blueman-manager` (runs in system tray)
- **CLI**: `bluetoothctl`

See [[Bluetooth-Guide]] for detailed Bluetooth usage.

## 🌐 Network Configuration

**File**: `modules/system/network.nix`

### Technology Stack

- **Network Manager**: [[NetworkManager]]
- **GUI**: NetworkManager Applet

### Features

- ✅ Easy WiFi management
- ✅ WiFi power saving
- ✅ Firewall enabled
- ✅ WireGuard support

### Firewall

Default configuration:
- Firewall: **Enabled**
- Ping: **Allowed**
- Custom ports: Configure in `networking.firewall.allowed*Ports`

### Installed Tools

| Package | Purpose |
|---------|---------|
| `networkmanager` | Network management daemon |
| `networkmanagerapplet` | System tray applet |
| `wireguard-tools` | VPN support |
| `openresolv` | DNS management |

### Usage

- **GUI**: nm-applet (system tray)
- **CLI**: `nmcli`
- **TUI**: `nmtui`

See [[Network-Configuration]] for detailed network setup.

## 🔋 Power Management

**File**: `modules/system/power.nix`

### Technology Stack

- **Power Management**: [[TLP]]
- **Battery Monitor**: [[UPower]]
- **Thermal Management**: thermald

### TLP Configuration

Battery thresholds (for battery longevity):
- **Start charging**: 20%
- **Stop charging**: 80%

CPU Governors:
- **On AC**: Performance
- **On Battery**: Powersave

Platform Profiles:
- **On AC**: Performance
- **On Battery**: Low-power

### Power States

| Battery % | Action |
|-----------|--------|
| 20% | Low battery warning |
| 10% | Critical warning |
| 5% | Hibernate |

### Installed Tools

| Package | Purpose |
|---------|---------|
| `powertop` | Power consumption analysis |
| `acpi` | Battery status |
| `tlp` | Power management |

### Usage

```bash
# Check power status
acpi -V

# TLP status
tlp-stat

# Power consumption
sudo powertop
```

See [[Power-Management]] for optimization tips.

## 🔒 Security Configuration

**File**: `modules/system/security.nix`

### Features

- ✅ Polkit authorization
- ✅ Fingerprint authentication
- ✅ PAM configuration
- ✅ Secure sudo

### Fingerprint Reader

**Driver**: Goodix fingerprint reader (libfprint-2-tod1-goodix)

Fingerprint auth enabled for:
- Login
- Sudo
- Hyprlock (screen lock)

### PAM Configuration

Custom PAM rules for:
- Fingerprint authentication
- Password fallback
- Session management

### Sudo Configuration

- Timeout: 30 minutes
- Password feedback: Enabled (asterisks)

### Setup Fingerprint

```bash
# Enroll fingerprint
fprintd-enroll

# Verify fingerprint
fprintd-verify
```

See [[Security-Guide]] for detailed security configuration.

## 🔑 SSH Configuration

**File**: `modules/system/ssh.nix`

### OpenSSH Server

Configuration:
- **Root Login**: Disabled
- **Password Auth**: Enabled
- **Public Key Auth**: Enabled
- **Port**: 22

### Features

- ✅ SSH server
- ✅ SSHFS support
- ✅ Firewall configured

### Usage

```bash
# Start SSH service
sudo systemctl start sshd

# Enable on boot
sudo systemctl enable sshd

# Check status
sudo systemctl status sshd
```

### SSHFS

Mount remote filesystems:
```bash
sshfs user@host:/path /local/mount/point
```

See [[SSH-Guide]] for keys and advanced configuration.

## 🎛️ System Settings

### Locale & Timezone

**File**: `hosts/ares/configuration.nix`

```nix
time.timeZone = "America/New_York";
i18n.defaultLocale = "en_US.UTF-8";
```

### Kernel

- **Kernel**: Latest Linux kernel
- **Parameters**: 
  - `quiet` - Minimal boot messages
  - `splash` - Boot splash screen
  - `amd_pstate=active` - AMD CPU power management

### Nix Settings

- **Flakes**: Enabled
- **Auto-optimize**: Enabled
- **Garbage Collection**: Weekly, keep 7 days
- **Binary Caches**: NixOS + Hyprland

## 📚 Related Documentation

- [[Audio-Configuration]] - Detailed audio setup
- [[Bluetooth-Guide]] - Bluetooth usage
- [[Network-Configuration]] - Network setup
- [[Power-Management]] - Power optimization
- [[Security-Guide]] - Security hardening
- [[SSH-Guide]] - SSH configuration

---

**Last Updated**: 2026-01-06
