{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.desktop.enable {
    services.mako = {
      enable = true;
      
      settings = {
        # Appearance
        background-color = "#1e1e2eff";
        text-color = "#cdd6f4ff";
        border-color = "#89b4faff";
        progress-color = "over #313244ff";
        
        # Layout
        width = 350;
        height = 150;
        margin = "10";
        padding = "15";
        border-size = 2;
        border-radius = 10;
        
        # Behavior
        default-timeout = 5000;
        ignore-timeout = false;
        
        # Position
        anchor = "top-right";
        
        # Font
        font = "JetBrainsMono Nerd Font 11";
        
        # Icons
        icons = true;
        max-icon-size = 48;
        
        # Grouping
        group-by = "app-name";
      };
      
      # Extra config
      extraConfig = ''
        [urgency=low]
        border-color=#94e2d5ff
        default-timeout=3000

        [urgency=normal]
        border-color=#89b4faff
        default-timeout=5000

        [urgency=high]
        border-color=#f38ba8ff
        default-timeout=0

        [app-name=Spotify]
        border-color=#a6e3a1ff
      '';
    };
  };
}
