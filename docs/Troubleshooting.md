---
title: Troubleshooting Guide
tags: [troubleshooting, debugging, fixes, help]
created: 2026-01-06
related: [[README]], [[Installation]], [[FAQ]]
---

# Troubleshooting Guide

Solutions to common issues and problems.

## 🚨 Boot Issues

### System Won't Boot

**Symptoms**: Black screen, GRUB error, kernel panic

**Solutions**:

1. **Boot previous generation**:
   - At boot, press Space to show boot menu
   - Select previous generation
   - Once booted, rollback:
     ```bash
     sudo nixos-rebuild switch --rollback
     ```

2. **Boot from live USB**:
   - Mount your system
   - Fix configuration
   - Reinstall

3. **Check kernel parameters**:
   ```bash
   # Edit boot parameters in GRUB
   # Add: systemd.unit=rescue.target
   ```

### Boot Takes Too Long

**Solutions**:

1. **Check systemd services**:
   ```bash
   systemd-analyze blame
   systemd-analyze critical-chain
   ```

2. **Disable slow services**:
   ```nix
   systemd.services.slow-service.enable = false;
   ```

## 🖥️ Display Issues

### Black Screen After Login

**Symptoms**: Login works, but screen stays black

**Solutions**:

1. **Switch to TTY** (Ctrl+Alt+F2):
   ```bash
   # Check Hyprland logs
   journalctl -u display-manager -b
   
   # Try starting Hyprland manually
   Hyprland
   ```

2. **Check SDDM**:
   ```bash
   sudo systemctl status display-manager
   sudo systemctl restart display-manager
   ```

3. **Driver issues**:
   ```bash
   # Check loaded modules
   lsmod | grep amdgpu
   
   # Force module load
   sudo modprobe amdgpu
   ```

### Screen Tearing

**Solutions**:

1. **Enable VRR** in `home/hyprland/hyprland-config.nix`:
   ```nix
   misc = {
     vrr = 2;
   };
   ```

2. **Disable for troubleshooting**:
   ```nix
   misc = {
     vrr = 0;
   };
   ```

### Wrong Resolution

**Solution**:

Edit monitor configuration in `home/hyprland/hyprland-config.nix`:
```nix
monitor = [
  "eDP-1,2880x1800@90,0x0,1.5"
];
```

Find your monitor name:
```bash
hyprctl monitors
```

## 🔊 Audio Issues

### No Sound

**Solutions**:

1. **Check PipeWire status**:
   ```bash
   systemctl --user status pipewire
   systemctl --user status wireplumber
   ```

2. **Restart audio**:
   ```bash
   systemctl --user restart pipewire
   systemctl --user restart wireplumber
   ```

3. **Check volume**:
   ```bash
   pamixer --get-volume
   pamixer --unmute
   pamixer --set-volume 50
   ```

4. **Check output device**:
   ```bash
   pactl list sinks
   pavucontrol  # GUI
   ```

### Crackling/Distorted Audio

**Solutions**:

1. **Adjust buffer size** in PipeWire config:
   ```nix
   # Add to audio.nix
   environment.etc."pipewire/pipewire.conf.d/99-custom.conf".text = ''
     context.properties = {
       default.clock.rate = 48000
       default.clock.quantum = 1024
     }
   '';
   ```

2. **Disable power saving**:
   ```bash
   # Add to audio.nix
   sound.mediaKeys.enable = true;
   ```

### Bluetooth Audio Quality Poor

**Solutions**:

1. **Enable high-quality codec**:
   Already enabled in config (A2DP)

2. **Check Bluetooth connection**:
   ```bash
   bluetoothctl
   info <MAC_ADDRESS>
   ```

## 📡 Network Issues

### WiFi Not Working

**Solutions**:

1. **Check NetworkManager**:
   ```bash
   sudo systemctl status NetworkManager
   sudo systemctl restart NetworkManager
   ```

2. **Check interface**:
   ```bash
   nmcli device status
   nmcli radio wifi on
   ```

3. **Scan for networks**:
   ```bash
   nmcli device wifi list
   ```

4. **Check driver**:
   ```bash
   lspci -k | grep -A 3 Network
   ```

### WiFi Keeps Disconnecting

**Solutions**:

1. **Disable power saving**:
   ```nix
   # In network.nix
   networking.networkmanager.wifi.powersave = false;
   ```

2. **Check signal strength**:
   ```bash
   nmcli device wifi list
   ```

### Can't Connect to Network

**Solutions**:

1. **Forget and reconnect**:
   ```bash
   nmcli connection delete <SSID>
   nmcli device wifi connect <SSID> password <password>
   ```

2. **Check firewall**:
   ```bash
   sudo nix-shell -p iptables --run "iptables -L"
   ```

## 🔵 Bluetooth Issues

### Bluetooth Not Available

**Solutions**:

1. **Check service**:
   ```bash
   sudo systemctl status bluetooth
   sudo systemctl start bluetooth
   ```

2. **Unblock bluetooth**:
   ```bash
   rfkill unblock bluetooth
   ```

3. **Check hardware**:
   ```bash
   lsusb | grep -i bluetooth
   ```

### Can't Pair Device

**Solutions**:

1. **Reset Bluetooth**:
   ```bash
   bluetoothctl
   power off
   power on
   scan on
   ```

2. **Remove old pairing**:
   ```bash
   bluetoothctl
   devices
   remove <MAC_ADDRESS>
   ```

3. **Trust device**:
   ```bash
   bluetoothctl
   trust <MAC_ADDRESS>
   ```

## 🔋 Battery/Power Issues

### Battery Drains Fast

**Solutions**:

1. **Check power consumption**:
   ```bash
   sudo powertop
   ```

2. **Verify TLP is running**:
   ```bash
   sudo systemctl status tlp
   tlp-stat
   ```

3. **Check running processes**:
   ```bash
   btop
   ```

4. **Reduce display brightness**:
   ```bash
   brightnessctl set 30%
   ```

### Not Charging/Charging Slowly

**Solutions**:

1. **Check battery thresholds**:
   ```bash
   tlp-stat -b
   ```

2. **Temporarily disable thresholds**:
   ```bash
   sudo tlp fullcharge
   ```

3. **Check power adapter**:
   ```bash
   acpi -V
   ```

## 🖱️ Input Issues

### Touchpad Not Working

**Solutions**:

1. **Check device**:
   ```bash
   libinput list-devices
   ```

2. **Restart Hyprland**:
   ```bash
   Super + M  # Exit
   # Login again
   ```

3. **Check configuration**:
   Verify touchpad settings in `home/hyprland/hyprland-config.nix`

### Keyboard Keys Not Working

**Solutions**:

1. **Check layout**:
   ```bash
   hyprctl devices
   ```

2. **Reset keyboard**:
   ```bash
   # Unplug and replug USB keyboard
   # For built-in, restart
   ```

## 🔐 Authentication Issues

### Fingerprint Not Working

**Solutions**:

1. **Check fprintd**:
   ```bash
   sudo systemctl status fprintd
   ```

2. **Re-enroll**:
   ```bash
   fprintd-delete jpolo
   fprintd-enroll
   ```

3. **Verify PAM config**:
   Check `modules/system/security.nix`

### Can't Login

**Solutions**:

1. **TTY login** (Ctrl+Alt+F2):
   ```bash
   # Login with username and password
   ```

2. **Reset password**:
   ```bash
   passwd jpolo
   ```

3. **Check display manager**:
   ```bash
   sudo systemctl status display-manager
   ```

## 💻 Hyprland Issues

### Hyprland Crashes

**Solutions**:

1. **Check logs**:
   ```bash
   cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -n 1)/hyprland.log
   ```

2. **Disable plugins**:
   Comment out plugins in `home/hyprland/hyprland-config.nix`

3. **Reset config**:
   ```bash
   mv ~/.config/hypr ~/.config/hypr.bak
   ```

### Windows Not Tiling Properly

**Solutions**:

1. **Check layout**:
   ```nix
   general = {
     layout = "dwindle";  # or "master"
   };
   ```

2. **Reset layout**:
   ```bash
   Super + J  # Toggle split
   ```

### Animations Laggy

**Solutions**:

1. **Reduce animation complexity**:
   ```nix
   animations = {
     enabled = true;
     animation = [
       "windows, 1, 3, default"  # Faster
     ];
   };
   ```

2. **Disable blur**:
   ```nix
   decoration = {
     blur.enabled = false;
   };
   ```

## 📦 Package/Build Issues

### Build Fails

**Solutions**:

1. **Update flake inputs**:
   ```bash
   nix flake update
   ```

2. **Clean build**:
   ```bash
   nix-collect-garbage -d
   sudo nix-collect-garbage -d
   ```

3. **Check syntax**:
   ```bash
   nix flake check
   ```

### Package Not Found

**Solutions**:

1. **Search package**:
   ```bash
   nix search nixpkgs <package>
   ```

2. **Update nixpkgs**:
   ```bash
   nix flake lock --update-input nixpkgs
   ```

3. **Use unstable**:
   Already configured to use unstable

### Out of Disk Space

**Solutions**:

1. **Clean old generations**:
   ```bash
   sudo nix-collect-garbage -d
   nix-collect-garbage -d
   ```

2. **Delete old boot entries**:
   ```bash
   sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
   sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
   ```

3. **Check disk usage**:
   ```bash
   df -h
   du -sh /nix/store
   ```

## 🔧 General Tips

### Enable Debug Mode

**Hyprland**:
```bash
# Start with debug logging
Hyprland --log-level debug
```

### View System Logs

```bash
# All logs
journalctl -b

# Specific service
journalctl -u service-name

# Follow logs
journalctl -f

# Since last boot
journalctl -b -1
```

### Test Configuration

```bash
# Build without switching
sudo nixos-rebuild build --flake .#ares

# Test (reverts on reboot)
sudo nixos-rebuild test --flake .#ares
```

### Emergency Recovery

1. Boot from NixOS USB
2. Mount system:
   ```bash
   mount /dev/nvme0n1p2 /mnt
   mount /dev/nvme0n1p1 /mnt/boot
   ```
3. Fix configuration
4. Reinstall or rollback

## 📚 Getting Help

### Log Files

- **Hyprland**: `/tmp/hypr/*/hyprland.log`
- **System**: `journalctl -b`
- **X11 fallback**: `~/.xsession-errors`

### Useful Commands

```bash
# System info
neofetch
lshw -short

# Hardware
lspci -k
lsusb
dmesg

# Services
systemctl status
systemctl --failed
```

### Community Resources

- NixOS Discourse
- NixOS Wiki
- Hyprland Wiki
- GitHub Issues

## 📚 Related Documentation

- [[Installation]] - Installation help
- [[FAQ]] - Frequently asked questions
- [[Hardware-Support]] - Hardware issues
- [[System-Configuration]] - System config

---

**Last Updated**: 2026-01-06

## 💡 Pro Tips

1. Always check logs first
2. Test changes in VM or with `nixos-rebuild test`
3. Keep backups of working configurations
4. Use git to track changes
5. Don't panic - NixOS is rollback-friendly!
