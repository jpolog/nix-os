{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.profiles.desktop.enable {
    # Display Manager - SDDM for Wayland support
    services.displayManager.sddm = {
      enable = mkDefault true;
      # wayland.enable left at default (false) here for Qt5 SDDM compatibility.
      # Hosts using kdePackages.sddm (Qt6) must set wayland.enable = true — it is required.
      theme = "breeze";
    };

    # Set SDDM background to match user wallpaper
    # Note: Using the standard NixOS path for SDDM faces
    systemd.tmpfiles.rules = mkIf config.services.displayManager.sddm.enable [
      "d /var/lib/sddm/faces 0755 sddm sddm -"
      "L+ /var/lib/sddm/faces/jpolo.face.icon - - - - /home/jpolo/.face.icon"
    ];

    
    # Default session follows the configured desktop environment
    services.displayManager.defaultSession =
      if config.profiles.desktop.environment == "kde" then "plasma"
      else "hyprland";

    # SDDM packages (only if enabled)
    environment.systemPackages = mkIf config.services.displayManager.sddm.enable (with pkgs; [
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5.qtquickcontrols2
    ]);
  };
}
