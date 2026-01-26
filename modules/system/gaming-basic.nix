{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.profiles.gaming.enable {
    # Gaming Infrastructure (System Level) - Simplified
    
    # 1. Create Gaming User (Basic)
    users.users.gaming = {
      isNormalUser = true;
      description = "Gaming User";
      home = "/home/gaming";
      createHome = true;
      initialPassword = "gaming"; # Set a default password so login works
      extraGroups = [ "audio" "video" "input" "networkmanager" ]; 
      shell = pkgs.bash;
      uid = 2000; # Keep same UID to avoid permission issues with existing files
    };
    
    # 2. Hardware Graphics (OpenGL/Vulkan)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
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
    
    # 3. GameMode
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
    
    # 4. Controller Support
    services.udev.packages = with pkgs; [
      game-devices-udev-rules
    ];
    hardware.xone.enable = true;
    
    # 5. Steam Hardware Support
    hardware.steam-hardware.enable = true;
    
    # Removed: Resource limits (CPUQuota, MemoryMax)
    # Removed: Firejail
  };
}
