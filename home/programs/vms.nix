{ config, pkgs, lib, ... }:

{
  # VM management tools for home-manager
  home.packages = with pkgs; [
    # Remote desktop
    remmina          # RDP/VNC/SSH client
    freerdp          # RDP client
    tigervnc         # VNC viewer
  ];
  
  # VM management aliases
  programs.zsh.shellAliases = {
    # libvirt aliases
    vl = "sudo virsh list --all";
    vls = "sudo virsh list --all";
    vstart = "sudo virsh start";
    vstop = "sudo virsh shutdown";
    vforce = "sudo virsh destroy";
    vinfo = "sudo virsh dominfo";
    vcon = "sudo virsh console";
    vview = "virt-viewer";
    
    # Quick VM creation
    qvm = "quickemu --vm";
    
    # Windows 11 shortcuts
    win11 = "win11-vm";
    w11 = "win11-vm";
    
    # VM snapshots
    vsnap = "sudo virsh snapshot-create-as";
    vsnaplist = "sudo virsh snapshot-list";
    vsnaprevert = "sudo virsh snapshot-revert";
    
    # VM cloning
    vclone = "sudo virt-clone";
    
    # VM networking
    vnet = "sudo virsh net-list --all";
    vnetstart = "sudo virsh net-start";
    vnetstop = "sudo virsh net-destroy";
  };
  
  # Configuration files
  xdg.configFile = {
    # libvirt connection config
    "libvirt/libvirt.conf".text = ''
      uri_default = "qemu:///system"
    '';
  };
}
