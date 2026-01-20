{ config, pkgs, inputs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    programs.hyprlock = {
      enable = true;
      package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
      
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          grace = 0;
          no_fade_in = false;
        };

        label = [
          # Time
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
            font_size = 120;
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
          # Date
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
            font_size = 24;
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
          # User
          {
            monitor = "";
            text = "Hi $USER";
            font_size = 20;
            position = "0, -150";
            halign = "center";
            valign = "center";
          }
        ];
      };
      
      extraConfig = ''
        input-field {
          monitor =
          size = 300, 50
          position = 0, -80
          dots_center = true
          fade_on_empty = false
          outline_thickness = 3
          shadow_passes = 2
        }
      '';
    };
  };
}
