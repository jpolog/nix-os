{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.vms.windows11;
  
  # Windows 11 VM script with proper UEFI Secure Boot support
  win11Script = pkgs.writeShellApplication {
    name = "win11-vm";
    runtimeInputs = with pkgs; [ qemu curl swtpm coreutils gnugrep procps virt-viewer ];
    text = ''
      set -euo pipefail
      
      VM_NAME="windows11"
      VM_DIR="${cfg.vmDir}"
      DISK_IMAGE="$VM_DIR/$VM_NAME.qcow2"
      ISO_FILE="$VM_DIR/windows11.iso"
      VIRTIO_ISO="$VM_DIR/virtio-win.iso"
      TPM_DIR="$VM_DIR/tpm"
      OVMF_VARS="$VM_DIR/OVMF_VARS.fd"
      
      # Create directories
      mkdir -p "$VM_DIR" "$TPM_DIR"
      
      # Create disk image if it doesn't exist
      if [ ! -f "$DISK_IMAGE" ]; then
        echo "Creating Windows 11 disk image (${cfg.diskSize})..."
        qemu-img create -f qcow2 "$DISK_IMAGE" ${cfg.diskSize}
      fi
      
      # Copy OVMF variables template if doesn't exist (for Secure Boot)
      if [ ! -f "$OVMF_VARS" ]; then
        echo "Creating UEFI variables file with Secure Boot support..."
        cp ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd "$OVMF_VARS"
        chmod 644 "$OVMF_VARS"
      fi
      
      # Check for Windows 11 ISO
      if [ ! -f "$ISO_FILE" ]; then
        echo "ERROR: Windows 11 ISO not found at: $ISO_FILE"
        echo "Please download it using: win11-download-iso"
        exit 1
      fi
      
      # Download VirtIO drivers if needed
      if [ ! -f "$VIRTIO_ISO" ]; then
        echo "Downloading VirtIO drivers..."
        VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
        curl -L -o "$VIRTIO_ISO" "$VIRTIO_URL"
      fi
      
      # Check for and stop any existing VM instance
      if pgrep -f "qemu-system.*win11-vm" > /dev/null; then
        echo "Stopping existing Windows 11 VM instance..."
        pgrep -f "qemu-system.*win11-vm" | while read -r pid; do
          kill "$pid" 2>/dev/null || true
        done
        sleep 2
      fi
      
      # Clean up any orphaned TPM processes
      if pgrep -f "swtpm.*windows11" > /dev/null; then
        echo "Cleaning up TPM processes..."
        pgrep -f "swtpm.*windows11" | while read -r pid; do
          kill "$pid" 2>/dev/null || true
        done
        sleep 1
      fi
      
      # Remove old TPM socket if it exists
      rm -f "$TPM_DIR/swtpm-sock"
      
      # Start TPM emulator
      echo "Starting TPM 2.0 emulator..."
      swtpm socket \
        --tpmstate dir="$TPM_DIR" \
        --ctrl type=unixio,path="$TPM_DIR/swtpm-sock" \
        --tpm2 \
        --log level=20 \
        --daemon
      
      # Wait for TPM socket to be created
      for _ in {1..10}; do
        if [ -S "$TPM_DIR/swtpm-sock" ]; then
          break
        fi
        sleep 0.5
      done
      
      if [ ! -S "$TPM_DIR/swtpm-sock" ]; then
        echo "ERROR: TPM socket was not created!"
        exit 1
      fi
      
      echo "════════════════════════════════════════════════════════"
      echo "  Starting Windows 11 VM"
      echo "════════════════════════════════════════════════════════"
      echo "  Memory: ${toString cfg.memory} MB"
      echo "  CPUs: ${toString cfg.cpus}"
      echo "  Disk: $DISK_IMAGE"
      echo "  TPM: 2.0 (Enabled)"
      echo "  Secure Boot: Supported"
      echo "  UEFI: Enabled"
      echo "════════════════════════════════════════════════════════"
      echo ""
      
      # Launch QEMU with Windows 11 compatible settings
      qemu-system-x86_64 \
        -name "$VM_NAME,process=win11-vm" \
        -machine type=q35,accel=kvm,smm=on \
        -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_vendor_id=1234567890ab \
        -smp ${toString cfg.cpus},sockets=1,cores=${toString cfg.cpus},threads=1 \
        -m ${toString cfg.memory}M \
        -object iothread,id=io1 \
        -device virtio-blk-pci,drive=disk0,iothread=io1 \
        -drive if=none,id=disk0,cache=none,format=qcow2,aio=native,file="$DISK_IMAGE" \
        -cdrom "$ISO_FILE" \
        -drive file="$VIRTIO_ISO",media=cdrom,readonly=on \
        -drive if=pflash,format=raw,readonly=on,file=${pkgs.OVMF.fd}/FV/OVMF_CODE.fd \
        -drive if=pflash,format=raw,file="$OVMF_VARS" \
        -global driver=cfi.pflash01,property=secure,value=on \
        -chardev socket,id=chrtpm,path="$TPM_DIR/swtpm-sock" \
        -tpmdev emulator,id=tpm0,chardev=chrtpm \
        -device tpm-tis,tpmdev=tpm0 \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
        -device qxl-vga,vgamem_mb=64,ram_size_mb=64,vram_size_mb=64 \
        -spice port=5930,addr=127.0.0.1,disable-ticketing=on,seamless-migration=on \
        -device virtio-serial-pci \
        -chardev spicevmc,id=vdagent,name=vdagent \
        -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
        -device qemu-xhci \
        -device usb-tablet \
        -chardev spicevmc,name=usbredir,id=usbredirchardev1 \
        -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \
        -chardev spicevmc,name=usbredir,id=usbredirchardev2 \
        -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \
        -rtc base=localtime,clock=host \
        -global ICH9-LPC.disable_s3=1 \
        -daemonize \
        "''${@}"
      
      # Wait a moment for QEMU to start
      sleep 2
      
      # Launch virt-viewer to connect to the SPICE display
      exec remote-viewer spice://127.0.0.1:5930
    '';
  };
  
  # Registry bypass script for Windows 11 requirements (alternative method)
  win11BypassScript = pkgs.writeShellApplication {
    name = "win11-vm-bypass";
    runtimeInputs = with pkgs; [ qemu curl swtpm coreutils gnugrep procps virt-viewer ];
    text = ''
      set -euo pipefail
      
      VM_NAME="windows11"
      VM_DIR="${cfg.vmDir}"
      DISK_IMAGE="$VM_DIR/$VM_NAME.qcow2"
      ISO_FILE="$VM_DIR/windows11.iso"
      VIRTIO_ISO="$VM_DIR/virtio-win.iso"
      TPM_DIR="$VM_DIR/tpm"
      
      mkdir -p "$VM_DIR" "$TPM_DIR"
      
      # Check for and stop any existing VM instance
      if pgrep -f "qemu-system.*win11-vm" > /dev/null; then
        echo "Stopping existing Windows 11 VM instance..."
        pgrep -f "qemu-system.*win11-vm" | while read -r pid; do
          kill "$pid" 2>/dev/null || true
        done
        sleep 2
      fi
      
      if [ ! -f "$DISK_IMAGE" ]; then
        echo "Creating Windows 11 disk image (${cfg.diskSize})..."
        qemu-img create -f qcow2 "$DISK_IMAGE" ${cfg.diskSize}
      fi
      
      if [ ! -f "$ISO_FILE" ]; then
        echo "ERROR: Windows 11 ISO not found at: $ISO_FILE"
        exit 1
      fi
      
      if [ ! -f "$VIRTIO_ISO" ]; then
        echo "Downloading VirtIO drivers..."
        VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
        curl -L -o "$VIRTIO_ISO" "$VIRTIO_URL"
      fi
      
      echo "════════════════════════════════════════════════════════"
      echo "  Windows 11 VM - TPM/Secure Boot Check Bypass Mode"
      echo "════════════════════════════════════════════════════════"
      echo "  This mode bypasses Windows 11 TPM checks"
      echo "  Use if you encounter system requirements errors"
      echo ""
      echo "  DURING INSTALLATION:"
      echo "  Press Shift+F10 to open Command Prompt, then run:"
      echo "    reg add HKLM\\SYSTEM\\Setup\\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f"
      echo "    reg add HKLM\\SYSTEM\\Setup\\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f"
      echo "    exit"
      echo "════════════════════════════════════════════════════════"
      echo ""
      
      # Simple QEMU without TPM/Secure Boot complexity
      qemu-system-x86_64 \
        -name "$VM_NAME,process=win11-vm-bypass" \
        -machine type=q35,accel=kvm \
        -cpu host \
        -smp ${toString cfg.cpus} \
        -m ${toString cfg.memory}M \
        -drive if=virtio,format=qcow2,file="$DISK_IMAGE" \
        -cdrom "$ISO_FILE" \
        -drive file="$VIRTIO_ISO",media=cdrom \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
        -device qxl-vga,vgamem_mb=64,ram_size_mb=64,vram_size_mb=64 \
        -spice port=5930,addr=127.0.0.1,disable-ticketing=on,seamless-migration=on \
        -device virtio-serial-pci \
        -chardev spicevmc,id=vdagent,name=vdagent \
        -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
        -device usb-tablet \
        -chardev spicevmc,name=usbredir,id=usbredirchardev1 \
        -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \
        -chardev spicevmc,name=usbredir,id=usbredirchardev2 \
        -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \
        -daemonize \
        "''${@}"
      
      # Wait a moment for QEMU to start
      sleep 2
      
      # Launch virt-viewer to connect to the SPICE display
      exec remote-viewer spice://127.0.0.1:5930
    '';
  };
  
  # ISO download helper
  isoDownloadScript = pkgs.writeShellApplication {
    name = "win11-download-iso";
    runtimeInputs = with pkgs; [ quickemu coreutils ];
    text = ''
      VM_DIR="${cfg.vmDir}"
      mkdir -p "$VM_DIR"
      
      echo "Windows 11 ISO Automatic Download"
      echo "==================================="
      echo ""
      echo "Downloading Windows 11 using quickget..."
      echo "This may take a while depending on your connection."
      echo ""
      
      cd "$VM_DIR"
      ${pkgs.quickemu}/bin/quickget windows 11
      
      ISO_FILE=$(find "$VM_DIR" -name "*.iso" -type f | head -n 1)
      
      if [ -n "$ISO_FILE" ] && [ "$ISO_FILE" != "$VM_DIR/windows11.iso" ]; then
        echo "Moving ISO to standard location..."
        mv "$ISO_FILE" "$VM_DIR/windows11.iso"
      fi
      
      echo ""
      echo "✓ Windows 11 ISO downloaded successfully!"
      echo "✓ Location: $VM_DIR/windows11.iso"
      echo ""
      echo "You can now run: win11-vm"
    '';
  };
  
  # Helper script with instructions
  win11HelpScript = pkgs.writeShellScriptBin "win11-help" ''
    cat << 'EOFHELP'
    ════════════════════════════════════════════════════════════════════════
      WINDOWS 11 VM - TROUBLESHOOTING GUIDE
    ════════════════════════════════════════════════════════════════════════
    
    OPTION 1: Proper Method (with TPM 2.0 + Secure Boot)
    ────────────────────────────────────────────────────────────────────────
    Run: win11-vm
    
    This includes:
      ✓ TPM 2.0 emulation
      ✓ UEFI Secure Boot support
      ✓ Persistent NVRAM variables
    
    
    OPTION 2: Registry Bypass Method
    ────────────────────────────────────────────────────────────────────────
    If you still get "doesn't meet requirements" error:
    
    1. Run: win11-vm-bypass
    
    2. When Windows installer starts, press Shift+F10
    
    3. In Command Prompt, run these commands:
       reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f
       reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
       reg add HKLM\SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f
       exit
    
    4. Close Command Prompt and continue installation
    
    
    OPTION 3: Using Windows 10 ISO (easiest)
    ────────────────────────────────────────────────────────────────────────
    Windows 10 has no TPM requirements and works out of the box.
    
    
    VERIFYING TPM IN WINDOWS:
    ────────────────────────────────────────────────────────────────────────
    After installation, press Win+R, type: tpm.msc
    Should show "TPM is ready for use" with version 2.0
    
    
    FILES LOCATION:
    ────────────────────────────────────────────────────────────────────────
    VM Directory: ~/VMs/windows11/
      - windows11.qcow2    (disk image)
      - windows11.iso      (Windows ISO)
      - OVMF_VARS.fd       (UEFI variables with Secure Boot)
      - tpm/               (TPM state)
    
    EOFHELP
  '';

in
{
  config = mkIf (config.vms.enable && cfg.enable) {
    environment.systemPackages = [
      win11Script
      win11BypassScript
      isoDownloadScript
      win11HelpScript
    ];
  };
}
