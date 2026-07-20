{ config, pkgs, inputs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    programs.hyprlock = {
      enable = true;
      package = pkgs.hyprlock;
      
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          grace = 0;
          no_fade_in = false;
        };

        # Wallpaper background with blur effect
        background = [
          {
            monitor = "";
            path = "/home/jpolo/Pictures/Wallpapers/0-black-moon.jpg";
            blur_passes = 5;
            blur_size = 10;
            noise = 0.0117;
            contrast = 0.9;
            brightness = 0.7;
            vibrancy = 0.1;
            vibrancy_darkness = 0.0;
          }
        ];

        # Circular Profile Picture with refined macOS-style design
        image = [
          {
            monitor = "";
            path = "/home/jpolo/.face";
            size = 120;
            rounding = -1;  # Perfect circle
            border_size = 3;
            border_color = "rgba(255, 255, 255, 0.8)";
            position = "0, 180";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          # Time - prominent at top of the composition
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
            color = "rgba(255, 255, 255, 0.95)";
            font_size = 110;
            font_family = "JetBrains Mono ExtraBold";
            position = "0, 140";
            halign = "center";
            valign = "center";
          }
          # Date - subtle below time
          {
            monitor = "";
            text = ''cmd[update:60000] echo "$(date +"%A, %B %d")"'';
            color = "rgba(255, 255, 255, 0.6)";
            font_size = 22;
            font_family = "JetBrains Mono";
            position = "0, 60";
            halign = "center";
            valign = "center";
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "280, 50";
            outline_thickness = 2;
            dots_size = 0.25;
            dots_spacing = 0.15;
            dots_center = true;
            outer_color = "rgba(255, 255, 255, 0.15)";
            inner_color = "rgba(0, 0, 0, 0.3)";
            font_color = "rgb(255, 255, 255)";
            fade_on_empty = false;
            placeholder_text = ''<span foreground="##ffffff80">Password</span>'';
            hide_input = false;
            position = "0, 50";
            halign = "center";
            valign = "center";
            rounding = 12;
            check_color = "rgba(180, 167, 230, 0.6)";
            fail_color = "rgba(204, 34, 34, 0.7)";
          }
        ];
      };
    };
  };
}
