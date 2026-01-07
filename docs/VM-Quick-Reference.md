# VM Quick Reference Card

Fast reference for common VM operations.

## vmctl - Power User CLI

### Listing & Info
```bash
vmctl list                 # List all VMs
vmctl info <vm>            # VM details
vmctl stats <vm>           # Performance stats
vmctl monitor              # Live monitoring
```

### VM Control
```bash
vmctl start <vm>           # Start VM
vmctl stop <vm>            # Graceful shutdown
vmctl kill <vm>            # Force stop
vmctl restart <vm>         # Reboot VM
vmctl console <vm>         # Serial console
vmctl vnc <vm>             # Graphical viewer
```

### VM Management
```bash
vmctl create               # Creation wizard
vmctl clone <vm> <new>     # Clone VM
vmctl delete <vm>          # Delete VM
vmctl edit <vm>            # Edit configuration
```

### Snapshots
```bash
vmctl snapshot <vm>        # Create snapshot
vmctl snapshots <vm>       # List snapshots
vmctl restore <vm> <snap>  # Restore snapshot
```

### Quick VMs
```bash
vmctl quick ubuntu 22.04   # Ubuntu VM
vmctl quick windows 11     # Windows VM
vmctl quick fedora 39      # Fedora VM
```

## Aliases (Shorter Commands)

```bash
vl                         # List VMs
vstart <vm>                # Start
vstop <vm>                 # Stop
vforce <vm>                # Force stop
vinfo <vm>                 # Info
vcon <vm>                  # Console
vsnap <vm> <name>          # Snapshot
vsnaplist <vm>             # List snapshots
vsnaprevert <vm> <snap>    # Restore
vclone <old> <new>         # Clone
vnet                       # Network list
```

## GUI Tools

```bash
virt-manager               # Full-featured GUI
firefox localhost:8006     # Cockpit (web UI)
quickgui                   # Quickemu GUI
```

## virsh Commands

### Basic Operations
```bash
virsh list --all           # List all VMs
virsh start <vm>           # Start
virsh shutdown <vm>        # Stop
virsh destroy <vm>         # Force stop
virsh reboot <vm>          # Restart
virsh undefine <vm>        # Delete
```

### VM Information
```bash
virsh dominfo <vm>         # Basic info
virsh domstats <vm>        # Statistics
virsh domiflist <vm>       # Network interfaces
virsh domblklist <vm>      # Disk devices
virsh vncdisplay <vm>      # VNC port
virsh domifaddr <vm>       # IP address
```

### Snapshots
```bash
virsh snapshot-create-as <vm> <name>
virsh snapshot-list <vm>
virsh snapshot-revert <vm> <snap>
virsh snapshot-delete <vm> <snap>
```

### Networking
```bash
virsh net-list --all       # List networks
virsh net-start <net>      # Start network
virsh net-destroy <net>    # Stop network
virsh net-info <net>       # Network info
```

### Configuration
```bash
virsh edit <vm>            # Edit XML
virsh dumpxml <vm>         # Show XML
virsh define <xml>         # Create from XML
```

## VM Creation

### Interactive (vmctl)
```bash
vmctl create
# Follow wizard prompts
```

### Manual (virt-install)
```bash
virt-install \
  --name myvm \
  --ram 4096 \
  --vcpus 4 \
  --disk size=30 \
  --cdrom ubuntu.iso \
  --os-variant ubuntu22.04 \
  --network network=default \
  --graphics spice
```

### Quick (quickemu)
```bash
quickemu --vm ubuntu-22.04.conf
quickgui  # Or use GUI
```

### Cloud Image
```bash
# Download image
wget https://cloud-images.ubuntu.com/.../*.img

# Create cloud-init
cloud-localds seed.iso user-data

# Import
virt-install --import \
  --disk ubuntu.img \
  --disk seed.iso,device=cdrom
```

## Common Tasks

### Find VM IP
```bash
virsh domifaddr <vm>
# Or
virsh net-dhcp-leases default
```

### Attach ISO
```bash
virsh attach-disk <vm> /path/to.iso \
  hdc --type cdrom --mode readonly
```

### Increase Disk Size
```bash
# Stop VM first
qemu-img resize disk.qcow2 +10G
# Start VM and resize partition
```

### Clone VM
```bash
virt-clone --original <vm> \
  --name <new> --auto-clone
```

### Backup VM
```bash
vm-backup <vm>              # Custom script
# Or manual
virsh dumpxml <vm> > vm.xml
cp /var/lib/libvirt/images/vm.qcow2 backup/
```

### Convert Disk Format
```bash
qemu-img convert -f qcow2 -O raw \
  disk.qcow2 disk.raw
```

### Compress qcow2
```bash
virt-sparsify --compress \
  disk.qcow2 disk-compressed.qcow2
```

## Performance Optimization

### CPU
```bash
virsh edit <vm>
# Set: <cpu mode='host-passthrough'/>
```

### Memory (Hugepages)
```bash
# Already enabled system-wide
# Add to VM:
<memoryBacking>
  <hugepages/>
</memoryBacking>
```

### Disk (Virtio)
```bash
# Use virtio-scsi bus
<target dev='sda' bus='scsi'/>
<driver name='qemu' type='qcow2' 
        cache='none' io='native'/>
```

### Network (Multiqueue)
```bash
<interface type='network'>
  <model type='virtio'/>
  <driver name='vhost' queues='4'/>
</interface>
```

## Troubleshooting

### VM Won't Start
```bash
virsh start <vm>           # Check error
journalctl -u libvirtd -f  # Check logs
virsh dumpxml <vm> | virt-xml-validate
```

### No Network
```bash
virsh net-start default
ping 192.168.122.1  # From VM
```

### Low Performance
```bash
vm-optimize <vm>           # Optimization guide
virt-top                   # Check resources
```

### Disk Full
```bash
du -sh /var/lib/libvirt/images/*
virt-sparsify disk.qcow2   # Compress
virsh snapshot-delete <vm> <old>  # Remove snapshots
```

## File Locations

```
/var/lib/libvirt/images/   # VM disks
/etc/libvirt/qemu/         # VM XML configs
~/VMs/                     # quickemu VMs
~/Backups/VMs/             # VM backups
```

## Keyboard Shortcuts

### virt-viewer
- `Ctrl+Alt` - Release grab
- `Ctrl+Alt+F` - Fullscreen
- `Ctrl+Alt+R` - Resize window

### Console
- `Ctrl+]` - Disconnect

## Resource Limits

### Default Settings
- Host reserves: 2GB RAM, 2 CPU cores
- VM max: Host total - reserves

### Check Available
```bash
free -h                    # Memory
nproc                      # CPUs
df -h /var/lib/libvirt     # Disk
```

## Quick Tips

1. **Always snapshot before major changes**
2. **Use virtio drivers** for best performance
3. **Bridge networking** for LAN access, NAT for isolation
4. **qcow2** for snapshots, **raw** for speed
5. **Stop VMs** before backup
6. **Host-passthrough CPU** for best performance
7. **Hugepages** for large VMs (>4GB)
8. **Check logs** in journalctl for errors

## One-Liners

```bash
# List running VMs with IPs
for vm in $(vl | grep running | awk '{print $2}'); do
  echo "$vm: $(virsh domifaddr $vm | grep -oP '(\d+\.){3}\d+')"
done

# Snapshot all running VMs
for vm in $(vl | grep running | awk '{print $2}'); do
  vsnap $vm backup-$(date +%Y%m%d)
done

# Show resource usage
virt-top -1

# Clone multiple VMs
for i in {1..5}; do
  vclone template dev-$i
done
```

## Emergency Commands

```bash
# Force stop all VMs
for vm in $(vl | grep running | awk '{print $2}'); do
  vforce $vm
done

# Restart libvirt
sudo systemctl restart libvirtd

# Reset network
virsh net-destroy default
virsh net-start default
```

---

**Print this for quick reference!** 🖨️
