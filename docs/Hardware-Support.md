---
title: Hardware Support
tags: [hardware, thinkpad, drivers, firmware]
created: 2026-01-06
related: [[README]], [[System-Configuration]]
---

# Hardware Support

Complete guide to hardware support on ThinkPad T14s Gen 6.

## 💻 System Specifications

### ThinkPad T14s Gen 6 (AMD)

| Component | Specification |
|-----------|---------------|
| **CPU** | AMD Ryzen 7000 Series |
| **GPU** | AMD Radeon Integrated |
| **RAM** | Up to 64GB LPDDR5 |
| **Storage** | NVMe PCIe 4.0 SSD |
| **Display** | 14" 2.8K OLED (2880x1800) @ 90Hz |
| **WiFi** | MediaTek/Qualcomm WiFi 6E |
| **Bluetooth** | Bluetooth 5.3 |
| **Webcam** | 1080p with IR |
| **Audio** | Dolby Audio, Dual Speakers |
| **Fingerprint** | Goodix Fingerprint Reader |
| **Ports** | USB-C, USB-A, HDMI, Audio Jack |

## 🖥️ Display

### Configuration

**File**: `home/hyprland/hyprland-config.nix`

```nix
monitor = [
  "eDP-1,2880x1800@90,0x0,1.5"
];
```

### Settings

- **Resolution**: 2880x1800
- **Refresh Rate**: 90Hz
- **Scale**: 1.5x (for HiDPI)
- **VRR**: Enabled

### Brightness Control

Managed by `brightnessctl`:
```bash
# Increase
brightnessctl set +5%

# Decrease
brightnessctl set 5%-

# Set specific
brightnessctl set 50%
```

Keybindings: `Fn+F5` (decrease), `Fn+F6` (increase)

### External Monitors

Automatic detection via Hyprland:
```nix
monitor = [
  "eDP-1,2880x1800@90,0x0,1.5"
  ",preferred,auto,1"  # Auto-configure external
];
```

## 🎮 Graphics (AMD)

### Driver

**Driver**: AMDGPU (open-source)

### OpenGL Support

Configured in `hardware-configuration.nix`:

```nix
hardware.opengl = {
  enable = true;
  driSupport = true;
  driSupport32Bit = true;
  extraPackages = [
    amdvlk
    rocm-opencl-icd
    rocm-opencl-runtime
  ];
};
```

### Features

- ✅ Vulkan support (AMDVLK)
- ✅ OpenCL support (ROCm)
- ✅ Hardware acceleration
- ✅ Video encoding/decoding

### GPU Monitoring

```bash
# GPU usage
nvtop

# Detailed info
lspci -k | grep -A 3 VGA

# AMD GPU stats
watch -n 1 cat /sys/class/drm/card0/device/gpu_busy_percent
```

## 🔌 CPU (AMD)

### Power Management

**Driver**: amd_pstate (active mode)

```nix
boot.kernelParams = [ "amd_pstate=active" ];
```

### Microcode

Automatic updates enabled:
```nix
hardware.cpu.amd.updateMicrocode = true;
```

### Governors

See [[Power-Management]] for CPU governor configuration.

## 📡 WiFi

### Chipset

MediaTek MT7922 or Qualcomm (depending on configuration)

### Configuration

**Manager**: NetworkManager

```bash
# List networks
nmcli device wifi list

# Connect
nmcli device wifi connect <SSID> password <password>

# Status
nmcli device status
```

### Power Saving

Enabled by default:
```nix
networking.networkmanager.wifi.powersave = true;
```

### Troubleshooting

If WiFi is unstable:
```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Reset WiFi
nmcli radio wifi off
nmcli radio wifi on
```

## 🔵 Bluetooth

### Chipset

Integrated Bluetooth 5.3

### Configuration

See [[System-Configuration#Bluetooth]]

### Pairing Devices

**GUI**: Blueman Manager
```bash
blueman-manager
```

**CLI**: bluetoothctl
```bash
bluetoothctl
scan on
pair <MAC_ADDRESS>
connect <MAC_ADDRESS>
trust <MAC_ADDRESS>
```

### Audio Devices

A2DP profile enabled for high-quality audio.

## 🔊 Audio

### Chipset

Realtek ALC257 or similar

### Stack

**Sound Server**: PipeWire

See [[System-Configuration#Audio]] for details.

### Speakers & Microphone

- **Speakers**: Stereo speakers (Dolby Audio)
- **Microphone**: Dual-array microphone
- **Headphone Jack**: 3.5mm combo jack

### Testing

```bash
# Speaker test
speaker-test -c2

# Microphone test
arecord -f cd -d 5 test.wav && aplay test.wav

# Volume control
pamixer --get-volume
pamixer --set-volume 50
```

## 🖱️ Input Devices

### Touchpad

**Driver**: libinput

Configuration in `home/hyprland/hyprland-config.nix`:

```nix
touchpad = {
  natural_scroll = true;
  tap-to-click = true;
  disable_while_typing = true;
  scroll_factor = 0.5;
};
```

### Keyboard

- **Layout**: US (configurable)
- **Backlight**: Controlled by system
- **Function Keys**: Hyprland hotkeys

### TrackPoint

Supported via libinput (if model has TrackPoint).

## 🔐 Fingerprint Reader

### Hardware

**Model**: Goodix fingerprint reader

### Driver

```nix
services.fprintd = {
  enable = true;
  tod = {
    enable = true;
    driver = pkgs.libfprint-2-tod1-goodix;
  };
};
```

### Enrollment

```bash
# Enroll fingerprint
fprintd-enroll

# Verify
fprintd-verify

# List enrolled
fprintd-list <username>

# Delete fingerprint
fprintd-delete <username>
```

### Usage

Enabled for:
- ✅ Login screen (SDDM)
- ✅ Sudo authentication
- ✅ Hyprlock (screen lock)

## 📷 Webcam

### Hardware

1080p webcam with IR for Windows Hello (IR not used in Linux)

### Testing

```bash
# List video devices
v4l2-ctl --list-devices

# Test with mpv
mpv av://v4l2:/dev/video0

# Or with ffplay
ffplay /dev/video0
```

### Privacy

Physical privacy shutter included on hardware.

## 🔋 Battery

### Capacity

Typical: 57Wh (check your specific model)

### Management

**Tool**: TLP

Configuration in `modules/system/power.nix`:

```nix
START_CHARGE_THRESH_BAT0 = 20;
STOP_CHARGE_THRESH_BAT0 = 80;
```

### Monitoring

```bash
# Battery status
acpi -V

# Detailed battery info
upower -i /org/freedesktop/UPower/devices/battery_BAT0

# Power consumption
sudo powertop
```

### Optimization

See [[Power-Management]] for battery optimization tips.

## 🌡️ Thermal Management

### Monitoring

```bash
# CPU temperature
sensors

# Watch temperature
watch -n 1 sensors
```

### Thermal Daemon

```nix
services.thermald.enable = true;
```

Automatically manages thermal thresholds.

## 🔌 USB & Thunderbolt

### Ports

- **USB-C**: Thunderbolt 4 / USB4
- **USB-A**: USB 3.2 Gen 1

### Configuration

Kernel modules loaded automatically:
```nix
boot.initrd.availableKernelModules = [ 
  "thunderbolt" 
  "usb_storage" 
];
```

### Thunderbolt

```bash
# List thunderbolt devices
boltctl list

# Authorize device
boltctl authorize <DEVICE>
```

## 💾 Storage

### NVMe SSD

**Interface**: PCIe 4.0 x4

### TRIM

Enabled automatically for SSD maintenance:
```bash
# Manual TRIM
sudo fstrim -av

# Check TRIM status
sudo systemctl status fstrim.timer
```

## 🎧 Audio Jack

3.5mm combo jack (headphone + microphone)

Automatic detection via PipeWire.

## 🖨️ Printing & Scanning

See [[System-Configuration#Printing]]

CUPS enabled for network printers.

## ⚡ Firmware Updates

### fwupd

Install fwupd for firmware updates:

```nix
services.fwupd.enable = true;
```

```bash
# Check for updates
fwupdmgr get-updates

# Install updates
fwupdmgr update

# Check device info
fwupdmgr get-devices
```

## 🔧 Troubleshooting

### Hardware Not Detected

1. Check kernel modules:
```bash
lspci -k
lsusb
dmesg | grep -i firmware
```

2. Verify in hardware config:
```bash
nixos-generate-config --show-hardware-config
```

3. Add missing modules to `hardware-configuration.nix`

### Performance Issues

1. Check CPU governor:
```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

2. Monitor resources:
```bash
btop
```

3. Check power profile:
```bash
tlp-stat
```

## 📚 Related Documentation

- [[System-Configuration]] - System configuration
- [[Power-Management]] - Power optimization
- [[Audio-Configuration]] - Audio setup
- [[Display-Configuration]] - Display settings

---

**Last Updated**: 2026-01-06
