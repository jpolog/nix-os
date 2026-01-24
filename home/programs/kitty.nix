{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.desktop.enable {
    programs.kitty = {
      enable = true;
      
      # Font configuration
      font = {
        name = "JetBrains Mono";
        size = 12;
      };
      
      settings = {
        # Window settings
        background_opacity = "0.9";
        window_padding_width = 8;
        
        # Cursor
        cursor_shape = "beam";
        cursor_blink_interval = 0;
        
        # Performance
        repaint_delay = 10;
        input_delay = 3;
        sync_to_monitor = "yes";

        # To allow reload by noctalia
        allow_remote_control = "yes";
      };
      
      # Include matugen-generated colors
      extraConfig = ''
        # Matugen color sync
        include ${config.xdg.configHome}/kitty/themes/noctalia.conf
      '';
    };
  };
}

