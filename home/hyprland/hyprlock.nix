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

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 7;
            noise = 0.0117;
            contrast = 0.8916;
            brightness = 0.8172;
            vibrancy = 0.1696;
            vibrancy_darkness = 0.0;
          }
        ];

        input-field = [
          {
            size = "300, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 3;
            placeholder_text = "<span foreground='##cad3f5'>Password...</span>";
            shadow_passes = 2;
          }
        ];

        label = [
          # Time
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
            color = "rgba(202, 211, 245, 1.0)";
            font_size = 120;
            font_family = "JetBrainsMono Nerd Font";
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
          # Date
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
            color = "rgba(202, 211, 245, 1.0)";
            font_size = 24;
            font_family = "JetBrainsMono Nerd Font";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
          # User
          {
            monitor = "";
            text = "Hi $USER";
            color = "rgba(202, 211, 245, 1.0)";
            font_size = 20;
            font_family = "JetBrainsMono Nerd Font";
            position = "0, -150";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}