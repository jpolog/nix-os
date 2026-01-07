# Isolated Gaming/Testing Profile

Completely sandboxed environment for testing untrusted software.

## Overview

The gaming profile is a **fully isolated** user account designed to:
- Test potentially malicious software safely
- Run games in isolation
- Prevent any damage to the main system
- Contain all activity within strict boundaries

## Security Features

### 1. No Privileged Access
- ❌ **No sudo** - Cannot run administrative commands
- ❌ **No wheel group** - Not in privileged groups
- ❌ **No docker** - Cannot access containers
- ❌ **Polkit denied** - All administrative actions blocked

### 2. Filesystem Isolation
- ✅ **Separate home** - `/home/gaming` (isolated from main user)
- ✅ **Read-only system** - Cannot modify `/nix`, `/etc`, `/boot`
- ✅ **No access to main user** - `/home/jpolo` is inaccessible
- ✅ **Private temp** - Isolated temporary files

### 3. Resource Limits
- ✅ **Memory limit** - Max 8GB RAM
- ✅ **CPU limit** - Max 4 cores (400% CPU quota)
- ✅ **I/O priority** - Lower I/O weight

### 4. Sandboxing
- ✅ **Firejail** - Application-level sandboxing
- ✅ **AppArmor** - Kernel-level mandatory access control
- ✅ **Bubblewrap** - Low-level containerization
- ✅ **Systemd restrictions** - Service-level confinement

### 5. Network Isolation (Optional)
- Can disable network access completely
- Firewall rules can block outbound connections
- No remote access capabilities

## Usage

### Switching to Gaming Profile

**Method 1: Login Screen**
1. Log out from main user
2. Select "gaming" user at login screen
3. Enter password (if configured)
4. Select "Gaming Session (Isolated)" from session menu

**Method 2: From Main User**
```bash
# Switch to gaming user in terminal
sudo -u gaming bash

# Or with full sandboxing
sudo -u gaming firejail --private bash
```

### Running Games

Games are automatically sandboxed:

```bash
# Steam (sandboxed)
steam

# Lutris (for non-Steam games)
lutris

# Wine applications
wine game.exe

# AppImages
./game.AppImage
```

### Testing Untrusted Software

```bash
# Run in maximum isolation
firejail \
  --private \
  --private-dev \
  --private-tmp \
  --noroot \
  --caps.drop=all \
  --seccomp \
  --net=none \
  ./untrusted-binary

# Or use the sandbox wrapper
sandbox ./untrusted-binary
```

## What Gaming Profile CANNOT Do

The gaming profile is heavily restricted:

### System Access
- ❌ Cannot modify system configuration
- ❌ Cannot install system packages
- ❌ Cannot access kernel modules
- ❌ Cannot mount filesystems
- ❌ Cannot access raw disks
- ❌ Cannot modify BIOS/UEFI
- ❌ Cannot reboot/shutdown system

### File Access
- ❌ Cannot read main user files (`/home/jpolo`)
- ❌ Cannot read system secrets (`/root`, `/etc/nixos`)
- ❌ Cannot modify system files (`/etc`, `/boot`, `/nix`)
- ❌ Cannot access SSH keys from main user

### Process Control
- ❌ Cannot kill other users' processes
- ❌ Cannot trace other users' processes
- ❌ Cannot modify process priorities (nice)
- ❌ Cannot use capabilities (CAP_*)

### Network
- ❌ Cannot open privileged ports (< 1024)
- ❌ Cannot modify firewall rules
- ❌ Cannot sniff network traffic
- ❌ Cannot modify routing tables

## What It CAN Do

Limited to safe operations:

### Gaming
- ✅ Run Steam games with Proton support
- ✅ Run Lutris games  
- ✅ Run Wine applications
- ✅ Use controllers
- ✅ Access GPU (for gaming)
- ✅ Play audio
- ✅ Use GameMode for performance optimization

## Steam Configuration

The gaming profile includes a fully configured Steam installation with:

### Proton Support
- **Proton GE**: Custom Proton version with additional patches and fixes
- **Native Proton**: Valve's official compatibility layer
- **32-bit libraries**: Full support for older games
- **DXVK/VKD3D**: DirectX to Vulkan translation

### Steam Features
```bash
# Launch Steam
steam

# Launch Steam in Big Picture Mode
steam -bigpicture

# Enable Proton for all games:
# 1. Open Steam
# 2. Go to Settings → Steam Play
# 3. Check "Enable Steam Play for all other titles"
# 4. Select Proton version (recommend Proton GE)
```

### GameMode
GameMode automatically optimizes system performance when gaming:
```bash
# Games launched through Steam automatically use GameMode
# You'll see a notification when it activates

# Manually launch with GameMode
gamemoderun ./game-binary
```

### Controller Support
All major controllers are supported:
- Xbox controllers (wired and wireless)
- PlayStation controllers
- Nintendo controllers
- Generic USB controllers

### Performance Monitoring
```bash
# Monitor FPS and system stats in-game
mangohud ./game

# Or enable globally in Steam:
# Settings → Shader Pre-Caching → Enable Shader Pre-Caching
```

### Troubleshooting Steam

**Proton not working:**
```bash
# Force specific Proton version
# Right-click game → Properties → Compatibility
# Select desired Proton version
```

**Missing libraries:**
```bash
# The system includes common game libraries
# If needed, check Steam logs:
~/.steam/steam/logs/
```

**Performance issues:**
```bash
# Check GameMode is active
gamemoded -s

# Monitor GPU
nvidia-smi  # For NVIDIA
radeontop   # For AMD
```

### File Operations (in own directory)
- ✅ Read/write files in `/home/gaming`
- ✅ Create subdirectories
- ✅ Download files (to own home)

### Network (if enabled)
- ✅ HTTP/HTTPS connections
- ✅ Game servers
- ✅ Steam downloads

## Configuration

### Enabling/Disabling

The gaming profile is configured in `modules/system/gaming-isolated.nix`.

To disable:
```nix
# In hosts/ares/configuration.nix
# Comment out or remove:
# imports = [ ../../modules/system/gaming-isolated.nix ];
```

### Adjusting Resource Limits

Edit `modules/system/gaming-isolated.nix`:

```nix
systemd.services."user@2000" = {
  serviceConfig = {
    MemoryMax = "16G";      # Increase RAM limit
    CPUQuota = "800%";      # Allow 8 cores
  };
};
```

### Configuring Network Access

```nix
# Completely block network
boot.extraModprobeConfig = ''
  install networking /bin/true
'';

# Or use firejail
--net=none  # No network access
```

### Adding Allowed Applications

```nix
# In gaming-isolated.nix
programs.firejail.wrappedBinaries = {
  myapp = {
    executable = "${pkgs.myapp}/bin/myapp";
    extraArgs = [ "--private-tmp" "--noroot" ];
  };
};
```

## Testing the Isolation

### Verify No Sudo Access
```bash
sudo ls
# Should fail: "gaming is not in the sudoers file"
```

### Verify File Access Restrictions
```bash
ls /home/jpolo
# Should fail: Permission denied

cat /etc/nixos/configuration.nix
# Should fail: Permission denied
```

### Verify Process Isolation
```bash
ps aux | grep jpolo
# Should only show system processes, not main user's processes

kill <pid-of-main-user-process>
# Should fail: Operation not permitted
```

### Verify Resource Limits
```bash
# Try to allocate more than limit
stress-ng --vm 1 --vm-bytes 10G
# Should be killed by OOM or cgroup limit
```

## Gaming Performance

Despite isolation, gaming performance is excellent:

- ✅ Full GPU access (AMD/Intel/NVIDIA)
- ✅ Controller support
- ✅ Audio playback
- ✅ GameMode for performance boost
- ✅ MangoHud for FPS overlay

### Performance Tools

```bash
# Enable GameMode (automatic for many games)
gamemoderun ./game

# Monitor performance
mangohud ./game

# System monitoring
nvtop         # GPU monitor (NVIDIA)
radeontop     # GPU monitor (AMD)
```

## Recovery

If something goes wrong in the gaming profile:

### Reset Gaming Home Directory
```bash
# From main user
sudo rm -rf /home/gaming
sudo mkdir -p /home/gaming
sudo chown gaming:gaming /home/gaming
```

### No Impact on Main System
- Gaming profile changes don't affect main user
- System configuration is read-only
- Rebooting clears any temporary changes

## Best Practices

1. **Never run untrusted code as main user**
2. **Use gaming profile for ALL testing**
3. **Keep gaming profile packages minimal**
4. **Monitor resource usage** (can't affect main user)
5. **Review logs** in main user after testing
6. **Don't share files** between profiles
7. **Use separate network** if testing malware

## Advanced: Additional Isolation

### Using Namespaces

```bash
# Full namespace isolation
unshare --user --pid --net --mount --uts --ipc \
  firejail --private ./untrusted
```

### Using VMs (Maximum Isolation)

For absolute safety:
```bash
# Quick VM with quickemu
quickemu --vm test --os linux

# Or use container
podman run --rm -it --network none alpine
```

## Monitoring

### Check Gaming User Activity

From main user:
```bash
# View gaming user processes
ps -u gaming

# View resource usage
systemctl status user@2000

# View logs
journalctl -u user@2000
```

### Security Audit

```bash
# Check permissions
sudo -u gaming ls -la /home/jpolo
# Should fail

# Check capabilities
sudo -u gaming capsh --print
# Should show no capabilities

# Check AppArmor profile
sudo apparmor_status | grep gaming
```

## Summary

The gaming profile provides:
- ✅ **Complete isolation** from main system
- ✅ **No privilege escalation** possible
- ✅ **Resource limits** prevent DOS
- ✅ **Filesystem protection** via multiple layers
- ✅ **Network isolation** (optional)
- ✅ **Full rollback** - just delete /home/gaming
- ✅ **Zero impact** on main system

**Safe testing environment without VMs!** 🔒🎮

---

**Note**: This is NOT a VM. It's containerization/sandboxing. For maximum isolation from kernel exploits, use a real VM.
