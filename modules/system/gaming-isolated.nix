{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.profiles.gaming.enable {
    # Gaming Infrastructure (System Level)
    # This module prepares the hardware and user isolation for gaming.
    # It DOES NOT install games or launchers system-wide (no bloat).
    
    # 1. Create Isolated Gaming User
    users.users.gaming = {
      isNormalUser = true;
      description = "Gaming/Testing (Sandboxed)";
      home = "/home/gaming";
      createHome = true;
      # Minimal groups - NO wheel (no sudo)
      extraGroups = [ "audio" "video" "input" "networkmanager" ];
      shell = pkgs.bash;
      uid = 2000;
    };
    
    # 2. Hardware Graphics (OpenGL/Vulkan)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;  # Required for 32-bit games
      
      extraPackages = with pkgs; [
        # VAAPI/VDPAU
        libva-vdpau-driver
        libvdpau-va-gl
        
        # Vulkan
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
      ];
      
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vulkan-loader
      ];
    };
    
    # 3. GameMode (Kernel Optimization)
    programs.gamemode = {
      enable = true;
      settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };
    };
    
    # 4. Controller Support (Udev Rules)
    services.udev.packages = with pkgs; [
      game-devices-udev-rules
    ];
    hardware.xone.enable = true;  # Xbox controllers
    
    # 5. Steam Hardware Support (Udev only, no package)
    hardware.steam-hardware.enable = true;
    
    # NOTE: programs.steam.enable is NOT set here to avoid installing
    # the steam binary system-wide. Steam will be installed in the
    # 'gaming' user's Home Manager profile.
    
    # 6. Security Isolation
    
    # Restrict gaming user resources
    systemd.services."user@2000" = {
      serviceConfig = {
        MemoryMax = "12G"; # Limit RAM
        CPUQuota = "600%"; # Limit Cores
      };
    };
    
    # Firejail (optional system tool for isolation)
    programs.firejail.enable = true;
    
    # Ensure home directory exists with correct permissions
    systemd.tmpfiles.rules = [
      "d /home/gaming 0700 gaming users -"
      "d /home/gaming/.config 0755 gaming users -"
      "d /home/gaming/.local 0755 gaming users -"
      "d /home/gaming/.local/state 0755 gaming users -"
      "d /home/gaming/.local/share 0755 gaming users -"
    ];
  };
}
