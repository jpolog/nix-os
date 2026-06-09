{
  config,
  pkgs,
  lib,
  ...
}:

let
  # ==========================================================================
  # VFIO Device IDs - MUST be filled in from `lspci -nn` on the actual machine
  # ==========================================================================
  # Run: lspci -nn | grep -E "VGA|Audio|NVMe"
  # Example output:
  #   01:00.0 VGA compatible controller [0300]: NVIDIA ... [10de:2484]
  #   01:00.1 Audio device [0403]: NVIDIA ... [10de:228b]
  #   02:00.0 Non-Volatile memory controller [0108]: ... [1234:5678]
  #
  # Replace these placeholders with the actual IDs:
  gpuVideoId = "10de:XXXX"; # GPU VGA controller
  gpuAudioId = "10de:XXXX"; # GPU HDMI/DP audio controller
  nvmeControllerId = "XXXX:XXXX"; # NVMe controller of the "Windows bueno" drive (Unidad 1)

  # VM configuration
  vmName = "WindowsGaming";
  vmDiskDir = "/var/lib/libvirt/images";
  vmDiskPath = "${vmDiskDir}/${vmName}.qcow2";
  vmDiskSize = "200G";

  # ISO sources
  # Windows ISO hosted on local NAS (apollo)
  windowsIsoUrl = "http://apollo.local/isos/windows11.iso";
  windowsIsoPath = "${vmDiskDir}/windows11.iso";

  # VirtIO drivers - public stable URL from Fedora
  virtioIsoUrl = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso";
  virtioIsoPath = "${vmDiskDir}/virtio-win.iso";

  # Libvirt domain XML for the Windows Gaming VM
  vmDomainXml = pkgs.writeText "${vmName}.xml" ''
    <domain type='kvm'>
      <name>${vmName}</name>
      <memory unit='MiB'>12288</memory>
      <currentMemory unit='MiB'>12288</currentMemory>
      <vcpu placement='static'>10</vcpu>
      <cpu mode='host-passthrough' check='none' migratable='on'>
        <topology sockets='1' dies='1' cores='5' threads='2'/>
        <feature policy='require' name='topoext'/>
        <!-- Hide KVM signature from anti-cheat / anti-VM -->
        <feature policy='disable' name='hypervisor'/>
      </cpu>

      <os>
        <type arch='x86_64' machine='pc-q35-9.2'>hvm</type>
        <loader readonly='yes' type='pflash'>${pkgs.OVMFFull.fd}/FV/OVMF_CODE.ms.fd</loader>
        <nvram template='${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd'>/var/lib/libvirt/qemu/nvram/${vmName}_VARS.fd</nvram>
        <boot dev='hd'/>
      </os>

      <features>
        <acpi/>
        <apic/>
        <hyperv mode='custom'>
          <relaxed state='on'/>
          <vapic state='on'/>
          <spinlocks state='on' retries='8191'/>
          <vpindex state='on'/>
          <runtime state='on'/>
          <synic state='on'/>
          <stimer state='on'/>
          <reset state='on'/>
          <frequencies state='on'/>
          <vendor_id state='on' value='GenuineIntel'/>
        </hyperv>
        <kvm>
          <hidden state='on'/>
        </kvm>
        <vmport state='off'/>
        <ioapic driver='kvm'/>
      </features>

      <clock offset='localtime'>
        <timer name='rtc' tickpolicy='catchup'/>
        <timer name='pit' tickpolicy='delay'/>
        <timer name='hpet' present='no'/>
        <timer name='hypervclock' present='yes'/>
        <timer name='tsc' present='yes' mode='native'/>
      </clock>

      <on_poweroff>destroy</on_poweroff>
      <on_reboot>restart</on_reboot>
      <on_crash>destroy</on_crash>

      <devices>
        <emulator>${pkgs.qemu_kvm}/bin/qemu-system-x86_64</emulator>

        <!-- Main disk (qcow2 on the NixOS SSD - Unidad 2) -->
        <disk type='file' device='disk'>
          <driver name='qemu' type='qcow2' cache='writeback' io='threads' discard='unmap'/>
          <source file='${vmDiskPath}'/>
          <target dev='vda' bus='virtio'/>
        </disk>

        <!-- VirtIO CD-ROM for drivers during install -->
        <disk type='file' device='cdrom'>
          <driver name='qemu' type='raw'/>
          <source file='${vmDiskDir}/virtio-win.iso'/>
          <target dev='sda' bus='sata'/>
          <readonly/>
        </disk>

        <!-- NO network interfaces - total air-gap isolation -->

        <!-- GPU passthrough (VFIO) -->
        <hostdev mode='subsystem' type='pci' managed='yes'>
          <source>
            <address domain='0x0000' bus='0xXX' slot='0x00' function='0x0'/>
          </source>
          <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0' multifunction='on'/>
        </hostdev>

        <!-- GPU Audio passthrough (VFIO) -->
        <hostdev mode='subsystem' type='pci' managed='yes'>
          <source>
            <address domain='0x0000' bus='0xXX' slot='0x00' function='0x1'/>
          </source>
          <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x1'/>
        </hostdev>

        <!-- USB controller for keyboard/mouse passthrough -->
        <controller type='usb' model='qemu-xhci' ports='4'/>

        <!-- TPM 2.0 (for Windows 11 compatibility) -->
        <tpm model='tpm-tis'>
          <backend type='emulator' version='2.0'>
            <active_pcr_banks>
              <sha256/>
            </active_pcr_banks>
          </backend>
        </tpm>

        <!-- Spice fallback (for initial setup / BIOS access before GPU takes over) -->
        <graphics type='spice' port='5900' autoport='no' listen='127.0.0.1'>
          <listen type='address' address='127.0.0.1'/>
        </graphics>
        <video>
          <model type='none'/>
        </video>

        <!-- Input: PS/2 mouse + keyboard for BIOS/UEFI stage -->
        <input type='mouse' bus='ps2'/>
        <input type='keyboard' bus='ps2'/>

        <memballoon model='none'/>
      </devices>
    </domain>
  '';

  # Script to set up the VM declaratively (define + create disk)
  vmSetupScript = pkgs.writeShellScript "setup-gaming-vm" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath (with pkgs; [ libvirt qemu_kvm coreutils ])}:$PATH"

    # Create disk image if it doesn't exist
    if [ ! -f "${vmDiskPath}" ]; then
      echo "[dionysus] Creating ${vmName} disk image (${vmDiskSize})..."
      ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 "${vmDiskPath}" ${vmDiskSize}
      chown qemu-libvirtd:libvirtd "${vmDiskPath}"
      chmod 660 "${vmDiskPath}"
    fi

    # Define (or redefine) the VM from XML
    if virsh dominfo "${vmName}" &>/dev/null; then
      # VM exists - only redefine if not running
      if ! virsh domstate "${vmName}" | grep -q "running"; then
        virsh define "${vmDomainXml}"
        echo "[dionysus] VM '${vmName}' redefined from declarative XML."
      fi
    else
      virsh define "${vmDomainXml}"
      echo "[dionysus] VM '${vmName}' defined from declarative XML."
    fi
  '';

in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ============================================================================
  # System Identity
  # ============================================================================

  networking.hostName = "dionysus";
  system.stateVersion = "25.11"; # DO NOT CHANGE

  # ============================================================================
  # A. Headless Absolute - No GUI on host
  # ============================================================================

  # Force-disable all graphical targets
  services.xserver.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;

  # Boot into multi-user.target (text mode only)
  systemd.defaultUnit = "multi-user.target";

  # Disable desktop profile entirely
  profiles.desktop.enable = lib.mkForce false;

  # ============================================================================
  # Bootloader
  # ============================================================================

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    # B. VFIO + IOMMU: Kernel Parameters
    # "Secuestro de Tierra de Nadie" - claim devices before any driver loads
    kernelParams = [
      # Enable IOMMU
      "amd_iommu=on"
      "iommu=pt" # passthrough mode for best performance

      # Bind VFIO to specific PCI devices at boot (GPU + GPU Audio + NVMe "bueno")
      "vfio-pci.ids=${gpuVideoId},${gpuAudioId},${nvmeControllerId}"

      # C. Hypervisor Cloaking - prevent anti-VM crashes from game cracks
      "kvm.ignore_msrs=1"
      "kvm.report_ignored_msrs=0"

      # Disable framebuffer to avoid conflicts with VFIO GPU grab
      "video=efifb:off"
      "video=vesafb:off"
      "nofb"
      "nomodeset"
    ];

    # Load VFIO modules BEFORE any GPU driver in initrd
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    # KVM for AMD
    kernelModules = [ "kvm-amd" ];

    extraModprobeConfig = ''
      options kvm_amd nested=1
      # Ensure vfio-pci loads before nouveau/nvidia
      softdep nouveau pre: vfio-pci
      softdep nvidia pre: vfio-pci
      softdep nvidia_drm pre: vfio-pci
      softdep snd_hda_intel pre: vfio-pci
    '';
  };

  # ============================================================================
  # C. Virtualization Infrastructure (libvirtd + QEMU/KVM)
  # ============================================================================

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # TPM 2.0 emulation for Windows 11
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMFFull.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };

  # ============================================================================
  # ISO Provisioning (download from NAS or skip if already present / offline)
  # ============================================================================

  systemd.services.gaming-vm-provision-isos = {
    description = "Download VM ISOs from apollo NAS (best-effort)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ curl coreutils ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -euo pipefail
      mkdir -p "${vmDiskDir}"

      # --- VirtIO drivers (public, reliable) ---
      if [ ! -f "${virtioIsoPath}" ]; then
        echo "[dionysus] Downloading VirtIO drivers from Fedora..."
        if curl -fSL --connect-timeout 15 --retry 3 -o "${virtioIsoPath}.part" "${virtioIsoUrl}"; then
          mv "${virtioIsoPath}.part" "${virtioIsoPath}"
          echo "[dionysus] VirtIO ISO downloaded successfully."
        else
          rm -f "${virtioIsoPath}.part"
          echo "[dionysus] WARNING: Failed to download VirtIO ISO. Place it manually at: ${virtioIsoPath}"
        fi
      else
        echo "[dionysus] VirtIO ISO already present."
      fi

      # --- Windows ISO (from apollo NAS, best-effort) ---
      if [ ! -f "${windowsIsoPath}" ]; then
        echo "[dionysus] Downloading Windows ISO from apollo NAS..."
        if curl -fSL --connect-timeout 10 --retry 2 -o "${windowsIsoPath}.part" "${windowsIsoUrl}"; then
          mv "${windowsIsoPath}.part" "${windowsIsoPath}"
          echo "[dionysus] Windows ISO downloaded successfully."
        else
          rm -f "${windowsIsoPath}.part"
          echo "[dionysus] WARNING: apollo NAS unreachable. Place the ISO manually at: ${windowsIsoPath}"
          echo "[dionysus]   From another machine: scp windows11.iso jpolo@dionysus.local:${windowsIsoPath}"
        fi
      else
        echo "[dionysus] Windows ISO already present."
      fi

      # --- Summary ---
      echo ""
      echo "[dionysus] ISO provisioning status:"
      [ -f "${windowsIsoPath}" ] && echo "  Windows ISO:  OK" || echo "  Windows ISO:  MISSING - VM cannot start without it"
      [ -f "${virtioIsoPath}" ]  && echo "  VirtIO ISO:   OK" || echo "  VirtIO ISO:   MISSING - install will lack disk/net drivers"
    '';
  };

  # ============================================================================
  # Declarative VM Definition (setup on activation)
  # ============================================================================

  systemd.services.gaming-vm-define = {
    description = "Define the ${vmName} VM from declarative XML";
    after = [ "libvirtd.service" "gaming-vm-provision-isos.service" ];
    requires = [ "libvirtd.service" ];
    wants = [ "gaming-vm-provision-isos.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = vmSetupScript;
    };
  };

  # ============================================================================
  # D. Autostart Orchestration Service
  # ============================================================================

  systemd.services.gaming-vm-autostart = {
    description = "Autostart ${vmName} and poweroff host when VM shuts down";
    after = [ "libvirtd.service" "gaming-vm-define.service" ];
    requires = [ "libvirtd.service" "gaming-vm-define.service" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [ libvirt coreutils ];

    serviceConfig = {
      Type = "simple";
      Restart = "no";
    };

    script = ''
      set -euo pipefail

      echo "[dionysus] Waiting for libvirtd to be fully ready..."
      sleep 5

      # Start the VM if it's not already running
      if ! virsh domstate "${vmName}" 2>/dev/null | grep -q "running"; then
        echo "[dionysus] Starting ${vmName}..."
        virsh start "${vmName}"
      else
        echo "[dionysus] ${vmName} is already running."
      fi

      echo "[dionysus] Monitoring VM lifecycle. Host will poweroff when VM stops."

      # Monitor loop: check every 5 seconds if VM is still running
      while true; do
        sleep 5
        STATE=$(virsh domstate "${vmName}" 2>/dev/null || echo "unknown")
        if [ "$STATE" != "running" ]; then
          echo "[dionysus] ${vmName} is no longer running (state: $STATE)."
          echo "[dionysus] Initiating host shutdown in 3 seconds..."
          sleep 3
          systemctl poweroff
          exit 0
        fi
      done
    '';
  };

  # ============================================================================
  # Storage Setup
  # ============================================================================

  systemd.tmpfiles.rules = [
    "d ${vmDiskDir} 0755 root root -"
    "d /var/lib/libvirt/qemu/nvram 0755 root root -"
  ];

  # Aggressive GC (appliance doesn't need old generations)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };
  nix.settings.auto-optimise-store = true;

  # ============================================================================
  # Networking - Minimal (host needs network for NixOS updates only)
  # ============================================================================

  networking.networkmanager.enable = true;

  # Lock down firewall - appliance needs almost nothing open
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # SSH only for remote management
  };

  # ============================================================================
  # Remote Access (SSH) - the only way to manage this headless appliance
  # ============================================================================

  services.openssh.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # ============================================================================
  # System Profiles
  # ============================================================================

  profiles.base.enable = true;
  profiles.development.enable = false; # Appliance, not a dev box

  # Disable documentation to save space
  documentation.enable = false;
  documentation.nixos.enable = false;

  # ============================================================================
  # Nix Settings
  # ============================================================================

  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # ============================================================================
  # Localization
  # ============================================================================

  time.timeZone = "Europe/Madrid";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ============================================================================
  # Users
  # ============================================================================

  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin";
    extraGroups = [
      "wheel"
      "libvirtd"
      "kvm"
    ];
    shell = pkgs.zsh;
  };

  home-manager.users.jpolo = { lib, ... }: {
    imports = [ ../../home/users/jpolo.nix ];
    # Force headless - no desktop environment
    home.profiles.desktop.enable = lib.mkForce false;
  };

  # ============================================================================
  # System Packages (minimal appliance set)
  # ============================================================================

  environment.systemPackages = with pkgs; [
    # VM management
    libvirt
    virt-viewer # For remote SPICE access from another machine
    looking-glass-client # Ultra-low-latency VM display (optional)

    # Diagnostics
    pciutils # lspci -nn (needed to find VFIO IDs)
    usbutils

    # Helpers
    home-manager

    # Manual ISO provisioning helper
    (writeShellScriptBin "dionysus-provision" ''
      set -euo pipefail
      echo "=== Dionysus VM ISO Provisioning ==="
      echo ""
      echo "Target directory: ${vmDiskDir}"
      echo ""

      # Check current state
      echo "Current status:"
      [ -f "${windowsIsoPath}" ] && echo "  Windows ISO:  OK ($(du -h "${windowsIsoPath}" | cut -f1))" || echo "  Windows ISO:  MISSING"
      [ -f "${virtioIsoPath}" ]  && echo "  VirtIO ISO:   OK ($(du -h "${virtioIsoPath}" | cut -f1))" || echo "  VirtIO ISO:   MISSING"
      [ -f "${vmDiskPath}" ]     && echo "  VM Disk:      OK ($(du -h "${vmDiskPath}" | cut -f1))" || echo "  VM Disk:      Not created yet"
      echo ""

      case "''${1:-status}" in
        download-windows)
          echo "Downloading Windows ISO from apollo NAS..."
          ${curl}/bin/curl -fSL --progress-bar -o "${windowsIsoPath}.part" "${windowsIsoUrl}"
          mv "${windowsIsoPath}.part" "${windowsIsoPath}"
          echo "Done."
          ;;
        download-virtio)
          echo "Downloading VirtIO drivers from Fedora..."
          ${curl}/bin/curl -fSL --progress-bar -o "${virtioIsoPath}.part" "${virtioIsoUrl}"
          mv "${virtioIsoPath}.part" "${virtioIsoPath}"
          echo "Done."
          ;;
        download-all)
          exec "$0" download-virtio
          exec "$0" download-windows
          ;;
        status)
          echo "Commands:"
          echo "  dionysus-provision download-windows   Download Windows ISO from apollo NAS"
          echo "  dionysus-provision download-virtio    Download VirtIO drivers from Fedora"
          echo "  dionysus-provision download-all       Download both"
          echo ""
          echo "Manual transfer (if apollo is offline):"
          echo "  scp windows11.iso jpolo@dionysus.local:${windowsIsoPath}"
          echo "  scp virtio-win.iso jpolo@dionysus.local:${virtioIsoPath}"
          ;;
        *)
          echo "Unknown command: $1" >&2
          exec "$0" status
          ;;
      esac
    '')
  ];

  programs.zsh.enable = true;
  nixpkgs.config.allowUnfree = true;
}
