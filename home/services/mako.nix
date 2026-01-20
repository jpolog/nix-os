{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.desktop.enable {
    services.mako = {
      enable = true;
      
      settings = {
        # Layout
        width = 350;
        height = 150;
        margin = "10";
        padding = "15";
        border-radius = 10;
        
        # Behavior
        default-timeout = 5000;
        ignore-timeout = false;
        
        # Position
        anchor = "top-right";
        
        # Icons
        icons = true;
        max-icon-size = 48;
        
        # Grouping
        group-by = "app-name";
      };
      
      # Extra config
      extraConfig = ''
        [urgency=low]
        default-timeout=3000

        [urgency=normal]
        default-timeout=5000

        [urgency=high]
        default-timeout=0
      '';
    };
  };
}
