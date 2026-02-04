{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ./windows11.nix
  ];

  options.vms = {
    enable = mkEnableOption "virtual machine management and tools";
    
    windows11 = {
      enable = mkEnableOption "Windows 11 VM configuration";
      
      user = mkOption {
        type = types.str;
        default = "jpolo";
        description = "User who owns the Windows 11 VM";
      };
      
      memory = mkOption {
        type = types.int;
        default = 8192;
        description = "RAM in MB for Windows 11 VM";
      };
      
      cpus = mkOption {
        type = types.int;
        default = 4;
        description = "Number of CPUs for Windows 11 VM";
      };
      
      diskSize = mkOption {
        type = types.str;
        default = "80G";
        description = "Disk size for Windows 11 VM";
      };
      
      vmDir = mkOption {
        type = types.str;
        default = "/home/${config.vms.windows11.user}/VMs/windows11";
        description = "Directory for Windows 11 VM files";
      };
    };
  };
  
  config = mkIf config.vms.enable {
    # Ensure virtualization groups exist
    users.groups.libvirtd = {};
    users.groups.kvm = {};
    
    # Optimize for virtualization
    boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_amd nested=1
    '';
    
    # System packages for VM management
    environment.systemPackages = with pkgs; [
      virt-viewer
      libvirt
      libguestfs
      guestfs-tools
      virtio-win
      OVMF
      swtpm
    ];
    
    # Networking for VMs
    networking.firewall.trustedInterfaces = [ "virbr0" ];
    
    # Create VM directories with proper permissions
    systemd.tmpfiles.rules = mkIf config.vms.windows11.enable [
      "d ${config.vms.windows11.vmDir} 0755 ${config.vms.windows11.user} users -"
      "d ${config.vms.windows11.vmDir}/tpm 0755 ${config.vms.windows11.user} users -"
      "d /var/lib/libvirt/images 0755 root root -"
    ];
  };
}
