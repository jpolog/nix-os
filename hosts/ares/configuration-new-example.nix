# Example: Minimal Laptop Configuration (ares - ThinkPad)
# This shows how to selectively enable only what you need

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Import profile system
    ../../modules/profiles
    # Import core system modules
    ../../modules/system
    ../../modules/services
  ];

  # === PROFILE CONFIGURATION ===
  # Enable only what you need for this machine
  
  profiles = {
    base.enable = true;  # Always enabled (essential tools)
    desktop.enable = true;  # Hyprland desktop environment
    
    development = {
      enable = true;
      languages = {
        python.enable = true;   # Enable Python
        nodejs.enable = true;   # Enable Node.js
        rust.enable = false;    # Disable Rust (save space)
        go.enable = false;      # Disable Go
        cpp.enable = true;      # Enable C/C++
        java.enable = false;    # Disable Java
        zig.enable = false;     # Disable Zig
      };
      tools = {
        docker.enable = true;      # Enable Docker
        cloud.enable = false;      # Disable cloud CLIs (save space)
        kubernetes.enable = false; # Disable k8s (not needed on laptop)
        databases.enable = true;   # Enable database tools
        api.enable = true;         # Enable API testing
      };
    };
    
    gaming.enable = false;  # Disable gaming (not needed on work laptop)
    
    power-user = {
      enable = true;
      scientific = {
        enable = false;       # Disable scientific tools
        octave.enable = false;  # Specifically disable Octave
        jupyter.enable = true;  # But keep Jupyter for data analysis
      };
      creative = {
        enable = true;          # Enable creative tools
        video.enable = false;   # Disable video editing (heavy)
        modeling3d.enable = false;  # Disable 3D modeling
      };
    };
  };

  # === HOST-SPECIFIC SETTINGS ===
  networking.hostName = "ares";
  system.stateVersion = "24.11";

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "quiet" "splash" "amd_pstate=active" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Timezone and Locale
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";

  # Users
  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "power" ];
    shell = pkgs.zsh;
  };
}
