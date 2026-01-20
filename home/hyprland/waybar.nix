{ config, pkgs, lib, inputs, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      
      settings = {
        mainBar = {
          "reload_style_on_change" = true;
          "layer" = "top";
          "position" = "top";
          "spacing" = 0;
          "height" = 26;
          
          "modules-left" = [
            "custom/menu"
            "hyprland/workspaces"
          ];
          
          "modules-center" = [
            "clock"
            "custom/update"
            "custom/screenrecording-indicator"
          ];
          
          "modules-right" = [
            "group/tray-expander"
            "bluetooth"
            "network"
            "pulseaudio"
            "cpu"
            "battery"
          ];

          "hyprland/workspaces" = {
            "on-click" = "activate";
            "format" = "{icon}";
            "format-icons" = {
              "default" = "";
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              "10" = "0";
              "active" = "󱓻";
            };
            "persistent-workspaces" = {
              "1" = [];
              "2" = [];
              "3" = [];
              "4" = [];
              "5" = [];
            };
          };

          "custom/menu" = {
            "format" = "󱓻"; # Close to the icon provided
            "on-click" = "walker";
            "on-click-right" = "kitty";
            "tooltip-format" = "Application Menu";
          };

          "custom/update" = {
            "format" = "";
            "on-click" = "kitty -e update-system";
            "tooltip-format" = "Click to update system";
            "interval" = 3600;
          };

          "cpu" = {
            "interval" = 5;
            "format" = "󰍛";
            "on-click" = "kitty -e btop";
          };

          "clock" = {
            "format" = "{:L%A %H:%M}";
            "format-alt" = "{:L%d %B W%V %Y}";
            "tooltip" = false;
          };

          "network" = {
            "format-icons" = [
              "󰤯"
              "󰤟"
              "󰤢"
              "󰤥"
              "󰤨"
            ];
            "format" = "{icon}";
            "format-wifi" = "{icon}";
            "format-ethernet" = "󰀂";
            "format-disconnected" = "󰤮";
            "tooltip-format-wifi" = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            "tooltip-format-ethernet" = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
            "tooltip-format-disconnected" = "Disconnected";
            "interval" = 3;
            "spacing" = 1;
            "on-click" = "nm-connection-editor";
          };

          "battery" = {
            "format" = "{icon} {capacity}%";
            "format-discharging" = "{icon} {capacity}%";
            "format-charging" = "{icon} {capacity}%";
            "format-plugged" = "";
            "format-icons" = {
              "charging" = [
                "󰢜"
                "󰂆"
                "󰂇"
                "󰂈"
                "󰢝"
                "󰂉"
                "󰢞"
                "󰂊"
                "󰂋"
                "󰂅"
              ];
              "default" = [
                "󰁺"
                "󰁻"
                "󰁼"
                "󰁽"
                "󰁾"
                "󰁿"
                "󰂀"
                "󰂁"
                "󰂂"
                "󰁹"
              ];
            };
            "format-full" = "󰂅";
            "tooltip-format-discharging" = "{power:>1.0f}W↓ {capacity}%";
            "tooltip-format-charging" = "{power:>1.0f}W↑ {capacity}%";
            "interval" = 5;
            "states" = {
              "warning" = 20;
              "critical" = 10;
            };
          };

          "bluetooth" = {
            "format" = "";
            "format-disabled" = "󰂲";
            "format-off" = "󰂲";
            "format-connected" = "󰂱";
            "format-no-controller" = "";
            "tooltip-format" = "Devices connected: {num_connections}";
            "on-click" = "blueman-manager";
          };

          "pulseaudio" = {
            "format" = "{icon}";
            "on-click" = "pavucontrol";
            "on-click-right" = "pamixer -t";
            "tooltip-format" = "Playing at {volume}%";
            "scroll-step" = 5;
            "format-muted" = "";
            "format-icons" = {
              "default" = [
                ""
                ""
                ""
              ];
            };
          };

          "group/tray-expander" = {
            "orientation" = "inherit";
            "drawer" = {
              "transition-duration" = 600;
              "children-class" = "tray-group-item";
            };
            "modules" = [
              "custom/expand-icon"
              "tray"
            ];
          };

          "custom/expand-icon" = {
            "format" = " ";
            "tooltip" = false;
          };

          "custom/screenrecording-indicator" = {
            "format" = "󰑊";
            "exec" = ''pgrep wf-recorder > /dev/null && echo '{"text": "REC", "class": "recording"}' || echo '{"text": "", "class": ""}' '';
            "interval" = 2;
            "return-type" = "json";
          };

          "tray" = {
            "icon-size" = 12;
            "spacing" = 12;
          };
        };
      };

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: rgba(30, 30, 46, 0.9);
          color: #cdd6f4;
          border-bottom: 1px solid rgba(137, 180, 250, 0.3);
        }

        #workspaces button {
          padding: 0 4px;
          background: transparent;
          color: #bac2de;
        }

        #workspaces button.active {
          color: #89b4fa;
        }

        #workspaces button.urgent {
          color: #f38ba8;
        }

        #custom-menu,
        #workspaces,
        #clock,
        #custom-update,
        #custom-screenrecording-indicator,
        #bluetooth,
        #network,
        #pulseaudio,
        #cpu,
        #battery,
        #tray {
          padding: 0 10px;
          margin: 0;
        }

        #custom-menu {
          color: #89b4fa;
          font-size: 16px;
        }

        #clock {
          color: #f9e2af;
          font-weight: bold;
        }

        #cpu {
          color: #fab387;
        }

        #battery {
          color: #a6e3a1;
        }

        #battery.critical:not(.charging) {
          color: #f38ba8;
          animation: blink 0.5s linear infinite;
        }

        @keyframes blink {
          to {
            background-color: #f38ba8;
            color: #11111b;
          }
        }

        #network {
          color: #89dceb;
        }

        #pulseaudio {
          color: #f5c2e7;
        }

        #bluetooth {
          color: #89b4fa;
        }

        #custom-update {
          color: #a6e3a1;
        }

        #custom-screenrecording-indicator.recording {
          color: #f38ba8;
          font-weight: bold;
        }
      '';
    };
  };
}
