{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ../desktop
  ];

  options.profiles.desktop = {
    enable = mkEnableOption "desktop environment profile";
    
    environment = mkOption {
      type = types.enum [ "hyprland" "kde" ];
      default = "hyprland";
      description = "Desktop environment to use";
    };
  };

  config = mkIf config.profiles.desktop.enable {
    modules.system.audio.enable = true;
    modules.system.bluetooth.enable = true;

    # ONLY System-level essentials
    # Things that are hard to run without or that everyone expects as "The OS"
    environment.systemPackages = with pkgs; [
      # Standard system tools
      fastfetch
      vim # Emergency editor
      wget
      curl
      pavucontrol # Audio GUI
    ] ++ (optionals (config.profiles.desktop.environment == "hyprland") [
      # Hyprland infrastructure (needs to be system-level for suid/etc)
      brightnessctl
      networkmanagerapplet
    ]);
  };
}