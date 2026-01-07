{ config, pkgs, lib, ... }:

{
  # VM management tools for home-manager
  home.packages = with pkgs; [
    # Virt-manager plugins
    virt-manager-qt  # Qt version (lighter)
    
    # Remote desktop
    remmina          # RDP/VNC/SSH client
    freerdp          # RDP client
    
    # Utility scripts (defined below)
  ];
  
  # VM management aliases
  programs.zsh.shellAliases = {
    # libvirt aliases
    vl = "virsh list --all";
    vls = "virsh list --all";
    vstart = "virsh start";
    vstop = "virsh shutdown";
    vforce = "virsh destroy";
    vinfo = "virsh dominfo";
    vcon = "virsh console";
    
    # Quick VM creation
    qvm = "quickemu --vm";
    
    # Docker/Podman
    d = "docker";
    dc = "docker-compose";
    p = "podman";
    pc = "podman-compose";
    
    # VM snapshots
    vsnap = "virsh snapshot-create-as";
    vsnaplist = "virsh snapshot-list";
    vsnaprevert = "virsh snapshot-revert";
    
    # VM cloning
    vclone = "virt-clone";
    
    # VM networking
    vnet = "virsh net-list --all";
    vnetstart = "virsh net-start";
    vnetstop = "virsh net-destroy";
  };
  
  # Configuration files
  xdg.configFile = {
    # libvirt connection config
    "libvirt/libvirt.conf".text = ''
      uri_default = "qemu:///system"
    '';
    
    # Quickemu templates directory
    "quickemu/templates".source = ./vm-templates;
  };
  
  # Desktop entries for common VMs
  xdg.desktopEntries = {
    virt-manager = {
      name = "Virtual Machine Manager";
      genericName = "VM Manager";
      exec = "virt-manager";
      icon = "virt-manager";
      categories = [ "System" "Virtualization" ];
      comment = "Manage virtual machines";
    };
  };
}
