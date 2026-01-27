{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    # Walker - Application launcher
    # Note: Package is installed by system profile, but we add it here just in case
    home.packages = with pkgs; [
      walker
    ];

    # Walker configuration
    xdg.configFile."walker/config.json".text = builtins.toJSON {
      placeholder = "Search...";
      fullscreen = false;
      list = {
        height = 400;
      };
      modules = [
        {
          name = "applications";
          prefix = "";
        }
        {
          name = "runner";
          prefix = ">";
        }
        {
          name = "websearch";
          prefix = "?";
        }
        {
          name = "finder";
          prefix = "~";
        }
        {
          name = "power-profiles";
          prefix = ":"; # A unique prefix for power profiles
          command = "find /etc/nixos/scripts/power -type f -executable -name \"*.sh\" -printf \"%f\n\" | sed 's/\.sh$//'";
          # The action for each item will be to execute the script
          action = "sudo /etc/nixos/scripts/power/%s.sh";
        }
      ];
      websearch = {
        engines = [
          {
            name = "Google";
            url = "https://www.google.com/search?q=%s";
          }
          {
            name = "DuckDuckGo";
            url = "https://duckduckgo.com/?q=%s";
          }
        ];
      };
    };

    # Walker CSS styling - Imports Matugen generated theme
    xdg.configFile."walker/style.css".text = ''
      @import "themes/noctalia.css";
      
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }
      
      /* Base overrides if needed, otherwise handled by noctalia.css */
    '';
  };
}