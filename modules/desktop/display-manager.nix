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

    # Set SDDM background to match user wallpaper
    # Note: Using a fixed path that corresponds to where we'll place it
    systemd.tmpfiles.rules = [
      "d /usr/share/sddm/faces 0755 sddm sddm -"
      "L+ /usr/share/sddm/faces/jpolo.face.icon - - - - /home/jpolo/.face.icon"
    ];

    
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
