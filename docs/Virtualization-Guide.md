# Virtualization Guide

Comprehensive guide for VM management on your NixOS system.

## Overview

Your system includes multiple virtualization solutions:

### 🖥️ Full Virtualization (VMs)
- **QEMU/KVM** - Industry-standard Linux virtualization
- **libvirt** - Unified API for VM management
- **virt-manager** - GTK GUI manager
- **GNOME Boxes** - Simple, user-friendly GUI
- **vmctl** - Power-user TUI (custom)
- **quickemu** - Rapid VM deployment
- **Cockpit** - Web-based management

### 📦 Containerization
- **Docker** - Standard containerization
- **Podman** - Daemonless containers
- **LXD** - System containers
- **Waydroid** - Android apps

## Quick Start

### Using vmctl (Recommended for Power Users)

Interactive TUI mode:
```bash
vmctl interactive
# or
vmctl tui
```

Command-line usage:
```bash
# List all VMs
vmctl list

# Create new VM (wizard)
vmctl create

# Quick VM from template
vmctl quick ubuntu 22.04
vmctl quick windows 11

# Start/stop VMs
vmctl start my-vm
vmctl stop my-vm

# VM information
vmctl info my-vm

# Snapshots
vmctl snapshot my-vm
vmctl snapshots my-vm
vmctl restore my-vm snapshot-name

# Clone VM
vmctl clone original-vm new-vm

# Monitor all VMs
vmctl monitor

# Connect to VM
vmctl console my-vm    # Serial console
vmctl vnc my-vm        # Graphical console
```

### Using virt-manager (GUI)

Simple graphical interface:
```bash
virt-manager
```

Features:
- Create VMs with wizard
- Visual resource allocation
- Live VM viewer
- Snapshot management
- Network configuration

### Using Virt-Manager (GUI)

Full-featured graphical interface:
```bash
virt-manager
```

Features:
- Complete VM lifecycle management
- Live VM viewer
- Snapshot management
- Network configuration
- Advanced storage options

### Using Quickemu (Rapid Deployment)

Quick VMs with pre-configured templates:
```bash
# Ubuntu
quickemu --vm ubuntu-22.04.conf

# Windows 11
quickemu --vm windows-11.conf

# macOS (requires specific hardware)
quickemu --vm macos-ventura.conf

# GUI for quickemu
quickgui
```

### Using Cockpit (Web Interface)

Access web management:
```bash
# Open browser
firefox http://localhost:8006
```

Features:
- Web-based management
- Multi-server support
- Resource monitoring
- Container management

## VM Creation

### Method 1: vmctl Interactive

```bash
vmctl create
```

Wizard will ask for:
- VM name
- OS type (Linux/Windows/Other)
- RAM allocation
- CPU cores
- Disk size
- ISO path or URL

### Method 2: virt-install (Manual)

```bash
virt-install \
  --name ubuntu-dev \
  --ram 4096 \
  --vcpus 4 \
  --disk size=30 \
  --cdrom ubuntu-22.04.iso \
  --os-variant ubuntu22.04 \
  --network network=default \
  --graphics spice \
  --console pty,target_type=serial
```

### Method 3: Quickemu (Template)

```bash
quickemu --vm ubuntu-22.04.conf --status-quo
```

### Method 4: virt-manager (GUI)

1. Open virt-manager
2. Click "Create New Virtual Machine"
3. Follow wizard
4. Configure resources
5. Start VM

## VM Management

### Listing VMs

```bash
# Using vmctl
vmctl list

# Using virsh
virsh list --all
vl  # Alias

# Using virt-manager
virt-manager
```

### Starting/Stopping VMs

```bash
# Start
vmctl start my-vm
vstart my-vm  # Alias
virsh start my-vm

# Stop gracefully
vmctl stop my-vm
vstop my-vm   # Alias
virsh shutdown my-vm

# Force stop
vmctl kill my-vm
vforce my-vm  # Alias
virsh destroy my-vm

# Restart
vmctl restart my-vm
virsh reboot my-vm
```

### VM Information

```bash
# Detailed info
vmctl info my-vm

# Resource usage
virt-top

# Real-time monitoring
vmctl monitor

# Statistics
virsh domstats my-vm
```

### Connecting to VMs

```bash
# Serial console
vmctl console my-vm
virsh console my-vm

# Graphical viewer
vmctl vnc my-vm
virt-viewer my-vm

# Remote desktop (if configured)
remmina
```

## Snapshots

### Creating Snapshots

```bash
# Using vmctl
vmctl snapshot my-vm

# Using virsh
virsh snapshot-create-as my-vm snapshot-name
vsnap my-vm snapshot-name  # Alias

# With description
virsh snapshot-create-as my-vm snapshot-name \
  --description "Before major update"
```

### Managing Snapshots

```bash
# List snapshots
vmctl snapshots my-vm
virsh snapshot-list my-vm
vsnaplist my-vm  # Alias

# Restore snapshot
vmctl restore my-vm snapshot-name
virsh snapshot-revert my-vm snapshot-name
vsnaprevert my-vm snapshot-name  # Alias

# Delete snapshot
virsh snapshot-delete my-vm snapshot-name
```

## Cloning VMs

```bash
# Using vmctl
vmctl clone original-vm cloned-vm

# Using virt-clone
virt-clone \
  --original original-vm \
  --name cloned-vm \
  --auto-clone

# Clone to specific disk
virt-clone \
  --original original-vm \
  --name cloned-vm \
  --file /var/lib/libvirt/images/cloned.qcow2
```

## Networking

### Default Network

VMs automatically use `default` network with NAT:
- Subnet: 192.168.122.0/24
- DHCP enabled
- Internet access via NAT

### Managing Networks

```bash
# List networks
vmctl network
virsh net-list --all
vnet  # Alias

# Start network
virsh net-start default
vnetstart default  # Alias

# Stop network
virsh net-destroy default
vnetstop default  # Alias

# Autostart on boot
virsh net-autostart default

# Network info
virsh net-info default
```

### Bridged Networking

For VMs to appear on LAN:

```bash
# Configuration in hosts/ares/configuration.nix
networking.bridges = {
  "br0" = {
    interfaces = [ "enp0s31f6" ];  # Your network interface
  };
};
```

Then create VM with bridged network:
```bash
virt-install \
  --network bridge=br0 \
  # ... other options
```

### Port Forwarding (NAT)

Forward port from host to VM:

```bash
# Edit network
virsh net-edit default

# Add forwarding rule
<forward mode='nat'>
  <nat>
    <port start='2222' end='2222'/>
  </nat>
</forward>
```

## Performance Optimization

### CPU Optimization

```bash
# Use host CPU model (best performance)
virsh edit my-vm

# Change CPU mode
<cpu mode='host-passthrough'/>

# Pin vCPUs to physical cores
<cputune>
  <vcpupin vcpu='0' cpuset='0'/>
  <vcpupin vcpu='1' cpuset='1'/>
</cputune>
```

### Memory Optimization

```bash
# Enable hugepages
virsh edit my-vm

# Add memory backing
<memoryBacking>
  <hugepages/>
</memoryBacking>
```

System already configured with:
- 8x 1GB hugepages
- Transparent hugepages: madvise
- KSM (Kernel Same-page Merging)

### Disk Optimization

```bash
# Use virtio-scsi (best performance)
<disk type='file' device='disk'>
  <driver name='qemu' type='qcow2' cache='none' io='native'/>
  <source file='/path/to/disk.qcow2'/>
  <target dev='sda' bus='scsi'/>
</disk>

# Use raw format for maximum performance
qemu-img convert -f qcow2 -O raw disk.qcow2 disk.raw

# Enable discard/trim
<driver name='qemu' type='qcow2' discard='unmap'/>
```

### Network Optimization

```bash
# Use virtio with multiqueue
<interface type='network'>
  <model type='virtio'/>
  <driver name='vhost' queues='4'/>
</interface>
```

### Graphics Optimization

For Linux VMs:
```xml
<video>
  <model type='virtio'/>
</video>
```

For Windows VMs:
```xml
<video>
  <model type='qxl'/>
</video>
```

## GPU Passthrough

For gaming VMs or GPU-intensive workloads:

### Prerequisites

```bash
# Enable IOMMU
# Add to hosts/ares/configuration.nix:
boot.kernelParams = [ 
  "intel_iommu=on"  # Intel
  # or
  "amd_iommu=on"    # AMD
];

# Isolate GPU
boot.extraModprobeConfig = ''
  options vfio-pci ids=10de:1234,10de:5678  # Your GPU PCI IDs
'';
```

### Pass GPU to VM

```bash
virsh edit my-vm

# Add PCI device
<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
  </source>
</hostdev>
```

## Windows VMs

### Best Practices

1. **Use virtio drivers**:
   ```bash
   # Available in system: virtio-win
   # Attach virtio-win.iso during installation
   ```

2. **UEFI boot**:
   ```xml
   <os>
     <type arch='x86_64' machine='q35'>hvm</type>
     <loader readonly='yes' type='pflash'>/run/libvirt/nix-ovmf/OVMF_CODE.fd</loader>
   </os>
   ```

3. **Hyper-V enlightenments**:
   ```xml
   <features>
     <hyperv>
       <relaxed state='on'/>
       <vapic state='on'/>
       <spinlocks state='on' retries='8191'/>
     </hyperv>
   </features>
   ```

### Quick Windows VM

```bash
vmctl quick windows 11

# Or manually
virt-install \
  --name windows11 \
  --ram 8192 \
  --vcpus 4 \
  --disk size=60 \
  --cdrom windows11.iso \
  --disk /nix/store/.../virtio-win.iso,device=cdrom \
  --os-variant win11 \
  --network network=default \
  --graphics spice \
  --boot uefi
```

## Backup & Recovery

### Backup VM

```bash
# Using vm-backup script
vm-backup my-vm
vm-backup my-vm ~/Backups/VMs

# Manual backup
virsh dumpxml my-vm > my-vm.xml
cp /var/lib/libvirt/images/my-vm.qcow2 ~/Backups/
```

### Restore VM

```bash
# From backup
virsh define my-vm.xml
cp ~/Backups/my-vm.qcow2 /var/lib/libvirt/images/
virsh start my-vm
```

### Export/Import

```bash
# Export VM as OVA (for portability)
virt-v2v -o local -os ~/exports my-vm

# Import VM
virt-v2v -i libvirt -ic qemu:///system my-vm -o local -os /var/lib/libvirt/images
```

## Cloud Images

### Download Cloud Images

```bash
# Ubuntu
wget https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img

# Debian
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

# Fedora
wget https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39.qcow2
```

### Use Cloud-Init

```bash
# Create cloud-init config
cat > user-data << EOF
#cloud-config
users:
  - name: jpolo
    ssh-authorized-keys:
      - ssh-rsa AAAA...
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
EOF

# Create cloud-init ISO
cloud-localds seed.iso user-data

# Create VM with cloud image
virt-install \
  --name cloud-vm \
  --ram 2048 \
  --vcpus 2 \
  --disk ubuntu-22.04-cloudimg.qcow2 \
  --disk seed.iso,device=cdrom \
  --os-variant ubuntu22.04 \
  --network network=default \
  --graphics none \
  --console pty,target_type=serial \
  --import
```

## Container Integration

### Docker in VMs

VMs can access Docker on host:

```bash
# From VM, access host Docker socket
# (requires network configuration)
```

### LXD System Containers

Alternative to full VMs for Linux:

```bash
# Initialize LXD
lxd init

# Create container
lxc launch ubuntu:22.04 my-container

# Execute commands
lxc exec my-container -- bash

# List containers
lxc list
```

## Remote Management

### SSH to VMs

```bash
# Find VM IP
virsh domifaddr my-vm

# SSH
ssh user@192.168.122.X
```

### VNC Access

```bash
# Find VNC port
virsh vncdisplay my-vm

# Connect with viewer
virt-viewer my-vm

# Or VNC client
vncviewer :0
```

### Web Console (Cockpit)

```bash
# Access from any browser
firefox http://localhost:8006
```

## Troubleshooting

### VM Won't Start

```bash
# Check error
virsh start my-vm

# View logs
journalctl -u libvirtd -f

# Validate XML
virsh dumpxml my-vm | virt-xml-validate
```

### Performance Issues

```bash
# Check host resources
htop
iotop

# Check VM resources
virt-top

# Optimize VM
vm-optimize my-vm
```

### Network Issues

```bash
# Restart network
virsh net-destroy default
virsh net-start default

# Check connectivity
ping 192.168.122.1  # From VM

# Check firewall
sudo iptables -L -n | grep virbr0
```

### Disk Space

```bash
# Check disk usage
du -sh /var/lib/libvirt/images/*

# Compress qcow2
virt-sparsify --compress disk.qcow2 disk-compressed.qcow2

# Remove old snapshots
virsh snapshot-list my-vm
virsh snapshot-delete my-vm old-snapshot
```

## Advanced Features

### Live Migration

```bash
# Migrate to another host
virsh migrate --live my-vm qemu+ssh://otherhost/system
```

### USB Passthrough

```bash
# List USB devices
lsusb

# Attach to VM
virsh attach-device my-vm usb-device.xml --live
```

### Shared Folders

```bash
# virtiofs shared folder
<filesystem type='mount' accessmode='passthrough'>
  <source dir='/home/jpolo/shared'/>
  <target dir='shared'/>
</filesystem>
```

## Scripts Reference

### vmctl Commands

```bash
vmctl list              # List VMs
vmctl create            # Create wizard
vmctl start <vm>        # Start VM
vmctl stop <vm>         # Stop VM
vmctl kill <vm>         # Force stop
vmctl restart <vm>      # Restart
vmctl delete <vm>       # Delete VM
vmctl info <vm>         # VM info
vmctl console <vm>      # Serial console
vmctl vnc <vm>          # VNC viewer
vmctl clone <old> <new> # Clone VM
vmctl snapshot <vm>     # Create snapshot
vmctl snapshots <vm>    # List snapshots
vmctl restore <vm> <s>  # Restore snapshot
vmctl edit <vm>         # Edit XML
vmctl stats <vm>        # Statistics
vmctl monitor           # Monitor all VMs
vmctl quick <os> <ver>  # Quick VM
vmctl network           # Network management
vmctl interactive       # TUI mode
```

### Aliases

```bash
vl                      # virsh list --all
vstart <vm>             # virsh start
vstop <vm>              # virsh shutdown
vforce <vm>             # virsh destroy
vinfo <vm>              # virsh dominfo
vcon <vm>               # virsh console
vsnap <vm> <name>       # Create snapshot
vsnaplist <vm>          # List snapshots
vsnaprevert <vm> <snap> # Revert snapshot
vclone <old> <new>      # Clone VM
vnet                    # Network list
vnetstart <net>         # Start network
vnetstop <net>          # Stop network
```

## Best Practices

### Resource Allocation

1. **Don't over-allocate**:
   - Leave 2GB RAM for host
   - Leave 2 CPU cores for host

2. **Use appropriate disk formats**:
   - qcow2: Snapshots, thin provisioning
   - raw: Maximum performance

3. **Network design**:
   - NAT for isolated VMs
   - Bridge for LAN access

### Security

1. **Isolate untrusted VMs**:
   - Use separate network
   - No shared folders
   - Limited resources

2. **Use snapshots before changes**

3. **Regular backups**

### Performance

1. **Use virtio drivers** for everything
2. **Enable hugepages** for large VMs
3. **Pin vCPUs** for consistent performance
4. **Use host CPU mode** for best performance

## Tips & Tricks

### Quick Operations

```bash
# One-liner VM creation
qvm ubuntu 22.04

# Quick clone
vclone template-vm dev-vm

# Bulk operations
for vm in $(vl | grep running | awk '{print $2}'); do
  vsnap $vm backup-$(date +%Y%m%d)
done
```

### Keyboard Shortcuts

In virt-viewer:
- `Ctrl+Alt` - Release mouse/keyboard
- `Ctrl+Alt+F` - Fullscreen
- `Ctrl+Alt+R` - Resize to fit

### Automation

Use Packer for automated VM builds:
```bash
packer build ubuntu-template.pkr.hcl
```

## Summary

Your virtualization setup includes:
- ✅ **QEMU/KVM** - High-performance VMs
- ✅ **Multiple interfaces** - CLI, TUI, GUI, Web
- ✅ **Quick templates** - Rapid deployment
- ✅ **Advanced features** - GPU passthrough, live migration
- ✅ **Container integration** - Docker, Podman, LXD
- ✅ **Fully optimized** - Hugepages, virtio, CPU pinning
- ✅ **Production-ready** - Backup, snapshot, monitoring

Choose your interface:
- **Power users** → vmctl interactive
- **GUI users** → virt-manager for full control
- **Web admins** → Cockpit
- **Quick VMs** → quickemu

---

**Happy virtualizing!** 🖥️✨
