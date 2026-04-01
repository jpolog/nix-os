{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.profiles.desktop.enable {
    # Display Manager - SDDM for Wayland support
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "breeze";
    };
    
    # Default session follows the configured desktop environment
    services.displayManager.defaultSession =
      if config.profiles.desktop.environment == "kde" then "plasma"
      else "hyprland";

    # SDDM packages
    environment.systemPackages = with pkgs; [
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5.qtquickcontrols2
    ];
  };
}
