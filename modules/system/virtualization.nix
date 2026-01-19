{ config, pkgs, lib, ... }:

{
  # Virtualization support for VMs
  # 
  # To enable VM access for a user, add to host configuration:
  #   users.users.<username>.extraGroups = [ "libvirtd" "kvm" ];
  #
  # Or in the user definition in hosts/*/configuration.nix
  
  # Enable virtualization support
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  
  # Virtual Machine Management
  virtualisation = {
    # libvirt - Industry standard VM management
    libvirtd = {
      enable = true;
      
      # QEMU/KVM settings
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;  # TPM emulation
      };
      
      # Networking
      allowedBridges = [ "virbr0" "br0" ];
      
      # Enable hooks for better integration
      hooks.qemu = {
        # Add custom hooks here if needed
      };
      
      onBoot = "ignore";  # Don't auto-start VMs
      onShutdown = "shutdown";  # Graceful shutdown
    };
    
    # Spice USB redirection
    spiceUSBRedirection.enable = true;
  };
  
  # Enable docker for containerization (alternative to VMs)
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    # Use Docker with rootless mode for security
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  
  # Podman as alternative to Docker
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;  # Don't alias docker to podman
    defaultNetwork.settings.dns_enabled = true;
  };
  
  # Waydroid for Android apps
  virtualisation.waydroid.enable = true;
  
  # Enable nested virtualization
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_amd nested=1
  '';
  
  # System packages for VM management
  environment.systemPackages = with pkgs; [
    # QEMU/KVM tools
    qemu_kvm
    qemu-utils  # qemu-img, qemu-nbd, etc.
    
    # libvirt management - CLI
    libvirt
    # virt-manager has desktop file validation issues, use cockpit or virt-viewer instead
    # virt-manager      # GUI manager (GTK)
    virt-viewer       # VM display viewer
    virtiofsd         # Virtio filesystem daemon
    
    # CLI tools for power users
    libguestfs        # Tools for accessing/modifying VM images
    libguestfs-with-appliance
    guestfs-tools     # virt-* commands
    
    # Modern TUI for VMs
    # (Custom script - see below)
    
    # Quickemu - Quick VM creation
    quickemu
    quickgui          # GUI for quickemu
    
    # Looking Glass - Low latency KVM frame relay
    looking-glass-client
    
    # VM image tools are provided by guestfs-tools above
    # (virt-builder, virt-resize, virt-sparsify, etc.)
    
    # Cloud images
    cloud-utils       # cloud-localds for cloud-init
    
    # Networking
    bridge-utils      # brctl
    dnsmasq          # DHCP/DNS for VMs
    
    # Other VM tools
    packer           # Automated VM image creation
    vagrant          # Development environment manager
    
    # Windows VM optimization
    virtio-win       # Windows virtio drivers
    
    # Performance monitoring
    virt-top         # Like top but for VMs
    
    # Snapshot management
    snapper          # Snapshot tool
  ];
  
  # Add virtualization groups to all normal users
  # This approach avoids infinite recursion by not reading config.users.users
  users.groups.libvirtd = {};
  users.groups.kvm = {};
  
  # Networking for VMs
  networking.bridges = {
    "br0" = {
      interfaces = [];  # Add your network interface if you want bridged networking
    };
  };
  
  # Firewall rules for VM networking
  networking.firewall = {
    trustedInterfaces = [ "virbr0" "br0" ];
    # Allow VNC for remote VM access
    allowedTCPPorts = [ 
      5900  # VNC
      5901  # VNC
      5902  # VNC
      8006  # Cockpit (if enabled)
    ];
  };
  
  # Enable cockpit for web-based VM management (optional)
  services.cockpit = {
    enable = true;
    port = 8006;
    settings = {
      WebService = {
        AllowUnencrypted = true;  # Use reverse proxy for SSL
      };
    };
  };
  
  # Optimize for virtualization
  boot.kernel.sysctl = {
    # Increase max_map_count for VMs
    "vm.max_map_count" = 262144;
    
    # Optimize for KVM
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  
  # Enable hugepages for better VM performance
  boot.kernelParams = [ "hugepagesz=1G" "hugepages=8" ];
  
  # systemd service for huge pages
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise"
  ];
}
