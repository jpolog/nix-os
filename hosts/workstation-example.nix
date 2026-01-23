# Example: Full-Featured Desktop Configuration
# This shows a heavy desktop setup with all features enabled

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/profiles
    ../../modules/system
    ../../modules/services
  ];

  # === PROFILE CONFIGURATION ===
  # Enable everything for a powerful workstation
  
  profiles = {
    base.enable = true;
    desktop.enable = true;
    
    development = {
      enable = true;
      languages = {
        python.enable = true;
        nodejs.enable = true;
        rust.enable = true;
        go.enable = true;
        cpp.enable = true;
        java.enable = true;
        zig.enable = true;
      };
      tools = {
        docker.enable = true;
        cloud.enable = true;
        kubernetes.enable = true;
        databases.enable = true;
        api.enable = true;
      };
    };
    
    gaming.enable = true;  # Enable gaming with isolation
    
    power-user = {
      enable = true;
      scientific = {
        enable = true;
        octave.enable = true;    # NOW Octave is available!
        jupyter.enable = true;
      };
      creative = {
        enable = true;
        video.enable = true;
        modeling3d.enable = true;
      };
    };
  };

  # === HOST-SPECIFIC SETTINGS ===
  networking.hostName = "workstation";
  system.stateVersion = "25.11";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "power" ];
    shell = pkgs.zsh;
  };
}
