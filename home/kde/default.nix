{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "kde") {
    # KDE Plasma Home Manager Configuration
    # Most KDE configuration is done via GUI, but we can set some files here if needed.
    
    # Example: Create a simple autostart script
    # home.file.".config/autostart/welcome.desktop".text = ''
    #   [Desktop Entry]
    #   Type=Application
    #   Name=Welcome
    #   Exec=${pkgs.libnotify}/bin/notify-send "Welcome to KDE Plasma"
    # '';
  };
}
