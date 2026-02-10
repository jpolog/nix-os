{ config, pkgs, inputs, lib, flakePath, ... }:

with lib;

let
  wallpaperPng = pkgs.runCommand "wallpaper.png" { buildInputs = [ pkgs.imagemagick ]; } ''
    magick ${flakePath}/modules/themes/assets/thinknix-wallpaper.svg $out
  '';
in
{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    programs.hyprlock = {
      enable = true;
      package = pkgs.hyprlock;
      
      settings = {
        general = {
          disableLoadingBar = true;
          hideCursor = true;
          grace = 0;
          noFadeIn = false;
        };

        # Blurred background using wallpaper
        background = [
          {
            monitor = "";
            path = "${wallpaperPng}";
            blurPasses = 3;      # Number of blur passes
            blurSize = 7;        # Blur intensity
            noise = 0.0117;      # Adds subtle noise
            contrast = 0.8916;   # Slight contrast adjustment
            brightness = 0.8172; # Slightly dimmed
            vibrancy = 0.1696;   # Color vibrancy
            vibranciDarkness = 0.0;
          }
        ];

        label = [
          # Time
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
            color = "rgba(255, 255, 255, 0.9)";
            fontSize = 120;
            fontFamily = "JetBrains Mono";
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
          # Date
          {
            monitor = "";
            text = ''cmd[update:1000] echo "$(date +"%A, %B %d")"'';
            color = "rgba(255, 255, 255, 0.7)";
            fontSize = 24;
            fontFamily = "JetBrains Mono";
            position = "0, 80";
            halign = "center";
            valign = "center";
          }
          # User
          {
            monitor = "";
            text = "Hi $USER";
            color = "rgba(255, 255, 255, 0.8)";
            fontSize = 20;
            fontFamily = "JetBrains Mono";
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
          font_color = rgb(255, 255, 255)
          inner_color = rgba(0, 0, 0, 0.5)
          outer_color = rgba(255, 255, 255, 0.2)
          check_color = rgba(180, 167, 230, 0.8)
          fail_color = rgba(204, 34, 34, 0.8)
          placeholder_text = <span foreground="##ffffff80">Enter password...</span>
        }
      '';
    };
  };
}

