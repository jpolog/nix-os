# ============================================================================
# Janus - Hardware Configuration (PLACEHOLDER)
# ============================================================================
#
# IMPORTANT: Replace this file with the actual hardware configuration
# generated on the target machine by running:
#
#   nixos-generate-config --show-hardware-config
#
# or copy /etc/nixos/hardware-configuration.nix after a live boot/install.
#
# Key things to configure for your specific hardware:
#  - boot.initrd.availableKernelModules (depends on storage controller)
#  - fileSystems (your actual partition layout / UUIDs)
#  - swapDevices (if any)
#  - GPU: see hardware.graphics.extraPackages in configuration.nix
#    * Intel iGPU:  add intel-media-driver (gen 8+) or vaapiIntel (older)
#    * AMD iGPU/dGPU: mesa already includes VA-API, nothing extra needed
#    * NVIDIA:      add nvidia drivers (see NixOS wiki)
# ============================================================================

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # --- Storage controller modules (REPLACE with actual) ---
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];  # or kvm-amd
  boot.extraModulePackages = [ ];

  # --- Filesystems (REPLACE with actual UUIDs from blkid) ---
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-ROOT-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-BOOT-UUID";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  # --- CPU ---
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
