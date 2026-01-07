# ThinkPad T14s Gen 6 Hardware Configuration
# This is a template - run `nixos-generate-config` on actual hardware

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # CPU - AMD Ryzen (typical for T14s Gen 6)
  boot.initrd.availableKernelModules = [ 
    "nvme" 
    "xhci_pci" 
    "thunderbolt" 
    "usb_storage" 
    "sd_mod" 
    "rtsx_pci_sdmmc" 
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Filesystems - Adjust based on your actual setup
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # CPU
  hardware.cpu.amd.updateMicrocode = true;
  
  # GPU - AMD integrated graphics
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };

  # High DPI (common on T14s)
  hardware.video.hidpi.enable = true;

  # Power Management
  powerManagement.cpuFreqGovernor = "powersave";
  
  # Networking
  networking.useDHCP = lib.mkDefault true;
  
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
