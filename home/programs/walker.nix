{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    # Walker - Application launcher
    # Note: Package is installed by system profile, but we add it here just in case
    home.packages = with pkgs; [
      walker
      elephant
    ];

    # Walker systemd service
    systemd.user.services.walker = {
      Unit = {
        Description = "Walker Application Launcher";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" "elephant.service" ];
        Requires = [ "elephant.service" ];
      };
      Service = {
        ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Elephant systemd service (Backend for Walker)
    systemd.user.services.elephant = {
      Unit = {
        Description = "Elephant Backend Service";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.elephant}/bin/elephant";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

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
          name = "custom";
          prefix = ":";
          src = {
            entries = [
              {
                label = "⚡ Performance Plus";
                sub = "Maximum performance mode";
                exec = "pkexec /run/current-system/sw/bin/power-performance-plus";
              }
              {
                label = "🔥 Performance";
                sub = "High performance mode";
                exec = "pkexec /run/current-system/sw/bin/power-performance";
              }
              {
                label = "⚖️ Balanced";
                sub = "Balanced power profile";
                exec = "pkexec /run/current-system/sw/bin/power-balanced";
              }
              {
                label = "🌱 Eco";
                sub = "Power saving mode";
                exec = "pkexec /run/current-system/sw/bin/power-eco";
              }
            ];
          };
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