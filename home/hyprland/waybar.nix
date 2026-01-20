{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 35;
          spacing = 4;

          modules-left = [ 
            "hyprland/workspaces" 
            "hyprland/window" 
          ];
          
          modules-center = [ 
            "clock" 
          ];
          
          modules-right = [ 
            "tray"
            "idle_inhibitor"
            "pulseaudio"
            "network"
            "bluetooth"
            "battery"
            "backlight"
          ];

          "hyprland/workspaces" = {
            disable-scroll = false;
            all-outputs = true;
            warp-on-scroll = false;
            format = "{icon}";
            format-icons = {
              "1" = "一";
              "2" = "二";
              "3" = "三";
              "4" = "四";
              "5" = "五";
              "6" = "六";
              "7" = "七";
              "8" = "八";
              "9" = "九";
              "10" = "十";
              urgent = "";
              focused = "";
              default = "";
            };
          };

          "hyprland/window" = {
            format = "{}";
            max-length = 50;
            separate-outputs = true;
          };

          tray = {
            icon-size = 18;
            spacing = 10;
          };

          clock = {
            timezone = "America/New_York";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format = "{:%a %d %b  %H:%M}";
            format-alt = "{:%Y-%m-%d}";
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = ["" "" "" "" ""];
          };

          network = {
            format-wifi = " {signalStrength}%";
            format-ethernet = " {ipaddr}/{cidr}";
            tooltip-format = "{essid} ({signalStrength}%) ";
            format-linked = " {ifname} (No IP)";
            format-disconnected = "⚠ Disconnected";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = " Muted";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            on-click = "pamixer -t";
            on-click-right = "pavucontrol";
          };

          backlight = {
            format = "{icon} {percent}%";
            format-icons = ["" "" "" "" "" "" "" ""];
            on-scroll-up = "brightnessctl set +5%";
            on-scroll-down = "brightnessctl set 5%-";
          };

          bluetooth = {
            format = " {status}";
            format-disabled = "";
            format-connected = " {num_connections}";
            tooltip-format = "{device_alias}";
            tooltip-format-connected = "{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}";
            on-click = "blueman-manager";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
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
        }

        #workspaces button {
          padding: 0 8px;
          background: transparent;
          color: #bac2de;
          border-bottom: 3px solid transparent;
        }

        #workspaces button.active {
          color: #89b4fa;
          border-bottom: 3px solid #89b4fa;
        }

        #workspaces button.urgent {
          color: #f38ba8;
          border-bottom: 3px solid #f38ba8;
        }

        #workspaces button:hover {
          background: rgba(108, 112, 134, 0.2);
          border-bottom: 3px solid #a6adc8;
        }

        #window,
        #clock,
        #battery,
        #network,
        #pulseaudio,
        #backlight,
        #bluetooth,
        #tray,
        #idle_inhibitor {
          padding: 0 10px;
          margin: 3px 0;
        }

        #clock {
          color: #f9e2af;
          font-weight: bold;
        }

        #battery {
          color: #a6e3a1;
        }

        #battery.charging {
          color: #a6e3a1;
        }

        #battery.warning:not(.charging) {
          color: #fab387;
        }

        #battery.critical:not(.charging) {
          color: #f38ba8;
          animation: blink 0.5s linear infinite;
        }

        @keyframes blink {
          to {
            color: #11111b;
          }
        }

        #network {
          color: #89dceb;
        }

        #network.disconnected {
          color: #f38ba8;
        }

        #pulseaudio {
          color: #f5c2e7;
        }

        #pulseaudio.muted {
          color: #6c7086;
        }

        #backlight {
          color: #fab387;
        }

        #bluetooth {
          color: #89b4fa;
        }

        #bluetooth.disabled {
          color: #6c7086;
        }

        #idle_inhibitor {
          color: #f9e2af;
        }

        #idle_inhibitor.activated {
          color: #eba0ac;
        }

        #tray {
          background: transparent;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
        }
      '';
    };
  };
}