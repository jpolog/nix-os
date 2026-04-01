{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    # Walker - Application launcher
    # Note: Package is installed by system profile, but we add it here just in case
    home.packages = with pkgs; [
      walker
      elephant
      (pkgs.writeShellScriptBin "power-profile-menu" ''
        set -e

        CURRENT=$(cat /var/lib/power-profiles/current 2>/dev/null || echo eco)

        entry() {
          local profile=$1
          local label=$2
          if [ "$CURRENT" = "$profile" ]; then
            echo "$label (current)"
          else
            echo "$label"
          fi
        }

        SELECTION=$(
          printf "%s\n" \
            "$(entry eco "🌱 Eco")" \
            "$(entry balanced-eco "🍃 Balanced-Eco")" \
            "$(entry balanced "⚖️ Balanced")" \
            "$(entry performance "🔥 Performance")" \
            "$(entry performance-plus "⚡ Performance Plus")" \
          | ${pkgs.walker}/bin/walker --dmenu -p "Power Profile"
        )

        case "$SELECTION" in
          "🌱 Eco"*) /run/current-system/sw/bin/power-eco ;;
          "🍃 Balanced-Eco"*) /run/current-system/sw/bin/power-balanced-eco ;;
          "⚖️ Balanced"*) /run/current-system/sw/bin/power-balanced ;;
          "🔥 Performance"*) /run/current-system/sw/bin/power-performance ;;
          "⚡ Performance Plus"*) /run/current-system/sw/bin/power-performance-plus ;;
          *) exit 0 ;;
        esac
      '')
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
                label = "⚡ Power Profiles";
                sub = "Change the active power profile";
                exec = "power-profile-menu";
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
