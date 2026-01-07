---
title: Installation Guide
tags: [nixos, installation, guide, setup]
created: 2026-01-06
related: [[README]], [[Post-Installation]]
---

# Installation Guide

Complete guide to installing the NixOS Omarchy configuration on your ThinkPad T14s Gen 6.

## Prerequisites

- ThinkPad T14s Gen 6 (or similar hardware)
- NixOS installation media (USB drive)
- Internet connection
- Basic familiarity with Linux terminal

## 📋 Installation Steps

### 1. Boot NixOS Installation Media

1. Download NixOS from https://nixos.org/download.html
2. Create bootable USB using `dd` or similar tool
3. Boot from USB (F12 on ThinkPad)
4. Select NixOS installer

### 2. Partition the Disk

Example partitioning scheme for a 512GB SSD:

```bash
# List disks
lsblk

# Use parted or fdisk to partition (example for /dev/nvme0n1)
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart primary 512MiB 100%
```

### 3. Format Partitions

```bash
# Format boot partition
mkfs.fat -F 32 -n boot /dev/nvme0n1p1

# Format root partition
mkfs.ext4 -L nixos /dev/nvme0n1p2
```

### 4. Mount Filesystems

```bash
# Mount root
mount /dev/disk/by-label/nixos /mnt

# Create boot directory and mount
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### 5. Generate Hardware Configuration

```bash
nixos-generate-config --root /mnt
```

This creates:
- `/mnt/etc/nixos/configuration.nix`
- `/mnt/etc/nixos/hardware-configuration.nix`

### 6. Clone This Repository

```bash
# Install git in the installer environment
nix-shell -p git

# Clone the repository
cd /mnt
git clone https://github.com/yourusername/nix-omarchy.git /mnt/home/jpolo/Projects/nix-omarchy
```

### 7. Update Hardware Configuration

Copy the generated hardware configuration:

```bash
cp /mnt/etc/nixos/hardware-configuration.nix \
   /mnt/home/jpolo/Projects/nix-omarchy/nix/hosts/ares/hardware-configuration.nix
```

Edit the file to match your actual UUIDs and hardware.

### 8. Customize Configuration

Edit the following files:

1. **User Information**: `home/jpolo.nix`
   - Update username, email, etc.

2. **Timezone**: `hosts/ares/configuration.nix`
   - Set your timezone

3. **Monitor**: `home/hyprland/hyprland-config.nix`
   - Adjust monitor resolution/refresh rate

### 9. Install NixOS

```bash
cd /mnt/home/jpolo/Projects/nix-omarchy/nix

# Enable flakes temporarily
export NIX_CONFIG="experimental-features = nix-command flakes"

# Install
nixos-install --flake .#ares
```

### 10. Set Root Password

```bash
nixos-enter --root /mnt
passwd
exit
```

### 11. Set User Password

```bash
nixos-enter --root /mnt
passwd jpolo
exit
```

### 12. Reboot

```bash
reboot
```

Remove the installation media when prompted.

## 📝 Post-Installation

See [[Post-Installation]] for next steps:
- Setting up fingerprint reader
- Configuring additional software
- Customizing themes
- Setting up development environment

## 🔧 Troubleshooting

### Boot Issues

If the system doesn't boot:
1. Boot from installation media
2. Mount your filesystems
3. Check `/boot` for kernel and initrd
4. Verify bootloader configuration

### Hardware Not Detected

If hardware isn't working:
1. Check `hardware-configuration.nix` has correct kernel modules
2. Verify firmware is installed
3. Check `dmesg` for errors

### Flake Errors

If you get flake-related errors:
1. Ensure git is initialized
2. Add files: `git add .`
3. Commit: `git commit -m "Initial commit"`
4. Try installation again

## 🎯 Quick Install (Advanced)

For experienced users with existing NixOS:

```bash
# Clone repo
git clone https://github.com/yourusername/nix-omarchy.git
cd nix-omarchy/nix

# Update hardware-configuration.nix
# Edit personal details

# Build and switch
sudo nixos-rebuild switch --flake .#ares
```

## 📚 Related Documentation

- [[README]] - Main documentation
- [[Post-Installation]] - After installation steps
- [[Hardware-Support]] - Hardware-specific setup
- [[Customization]] - Customizing the configuration

---

**Note**: Replace `jpolo` with your actual username throughout the configuration files before installation.
