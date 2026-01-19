{ config, pkgs, ... }:

{
  # Display Manager - SDDM for Wayland support
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";
  };
  
  # Set default session to Hyprland
  services.displayManager.defaultSession = "hyprland";

  # SDDM packages
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtsvg
    libsForQt5.qt5.qtquickcontrols2
  ];
}
