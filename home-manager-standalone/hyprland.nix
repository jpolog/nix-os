{ config, pkgs, inputs, ... }:

{
  # Create directories declaratively
  home.file."Pictures/Wallpapers/.keep".text = "";
  home.file."Pictures/Screenshots/.keep".text = "";

  # Hyprland packages
  home.packages = with pkgs; [
    # App launcher
    walker
    
    # Wayland utilities
    wl-clipboard
    cliphist
    hyprpicker
    
    # Screenshot
    grim
    slurp
    grimblast
    
    # System utilities
    brightnessctl
    libnotify
    
    # File managers
    thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    ranger
    yazi
    
    # OSD
    swayosd
    
    # Image viewers
    imv
    feh
    
    # Audio/Video control
    pavucontrol
    pwvucontrol
    
    # System tray apps
    networkmanagerapplet
    blueman
    
    # Applications
    bitwarden-desktop
    qalculate-gtk
    obsidian
    chromium
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
    ];
    
    settings = {
      monitor = [
        "eDP-1,2880x1800@90,0x0,1.5"
        ",preferred,auto,1"
      ];
      
      exec-once = [
        "waybar"
        "mako"
        "hypridle"
        "hyprpaper"
        "swayosd-server"
        "nm-applet --indicator"
        "blueman-applet"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];
      
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "MOZ_ENABLE_WAYLAND,1"
        "GDK_BACKEND,wayland,x11"
      ];
      
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "adaptive";
        
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
          drag_lock = true;
          scroll_factor = 0.5;
        };
      };
      
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_invert = true;
        workspace_swipe_create_new = true;
      };
      
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(313244aa)";
        layout = "dwindle";
        allow_tearing = false;
      };
      
      decoration = {
        rounding = 8;
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        drop_shadow = true;
        shadow_range = 20;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
        
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
        };
      };
      
      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };
      
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        vrr = 1;
        enable_swallow = true;
        swallow_regex = "^(kitty)$";
      };
      
      "$mod" = "SUPER";
      
      bind = [
        "$mod, Return, exec, kitty"
        "$mod SHIFT, F, exec, thunar"
        "$mod, B, exec, firefox"
        "$mod ALT, B, exec, firefox --private-window"
        "$mod SHIFT, N, exec, code"
        "$mod SHIFT, T, exec, kitty -e btop"
        "$mod, O, exec, obsidian"
        "$mod, R, exec, walker"
        "$mod, E, exec, thunar"
        
        "$mod, Q, killactive"
        "$mod, F, fullscreen, 0"
        "$mod, Space, togglefloating"
        "$mod, U, togglesplit"
        
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"
        
        "$mod CTRL, H, movecurrentworkspacetomonitor, -1"
        "$mod CTRL, L, movecurrentworkspacetomonitor, +1"
        
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        
        "$mod, grave, togglespecialworkspace, magic"
        "$mod SHIFT, grave, movetoworkspace, special:magic"
        
        ", Print, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast copy screen"
        "CTRL, Print, exec, grimblast save area ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
        
        "$mod, V, exec, cliphist list | walker --dmenu | cliphist decode | wl-copy"
        
        "$mod SHIFT, L, exec, hyprlock"
        "$mod SHIFT, Q, exit"
      ];
      
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      
      binde = [
        "$mod CTRL SHIFT, H, resizeactive, -40 0"
        "$mod CTRL SHIFT, L, resizeactive, 40 0"
        "$mod CTRL SHIFT, K, resizeactive, 0 -40"
        "$mod CTRL SHIFT, J, resizeactive, 0 40"
        
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];
      
      windowrule = [
        "float, ^(pavucontrol)$"
        "float, ^(blueman-manager)$"
        "float, ^(nm-connection-editor)$"
        "float, ^(qalculate-gtk)$"
        "float, ^(bitwarden)$"
      ];
    };
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 35;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "idle_inhibitor" "pulseaudio" "network" "bluetooth" "battery" "backlight" ];

        "hyprland/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
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
            urgent = "";
            default = "";
          };
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 50;
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y %H:%M:%S}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
          format-disconnected = "Disconnected ⚠";
          tooltip-format = "{ifname} via {gwaddr} ";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };

        bluetooth = {
          format = " {status}";
          format-disabled = "";
          format-connected = " {num_connections}";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        };

        backlight = {
          format = "{percent}% {icon}";
          format-icons = ["" ""];
        };

        tray = {
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }
      window#waybar {
        background: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
      }
      #workspaces button {
        padding: 0 5px;
        color: #6c7086;
      }
      #workspaces button.active {
        color: #89b4fa;
      }
      #workspaces button.urgent {
        color: #f38ba8;
      }
      #clock, #battery, #network, #pulseaudio, #bluetooth, #backlight, #tray, #idle_inhibitor {
        padding: 0 10px;
      }
      #battery.charging {
        color: #a6e3a1;
      }
      #battery.warning:not(.charging) {
        color: #fab387;
      }
      #battery.critical:not(.charging) {
        color: #f38ba8;
      }
    '';
  };

  services.mako = {
    enable = true;
    settings = {
      background-color = "#1e1e2eff";
      text-color = "#cdd6f4ff";
      border-color = "#89b4faff";
      progress-color = "over #313244ff";
      width = 350;
      height = 150;
      margin = "10";
      padding = "15";
      border-size = 2;
      border-radius = 10;
      default-timeout = 5000;
      font = "JetBrainsMono Nerd Font 11";
    };
    extraConfig = ''
      [urgency=low]
      border-color=#94e2d5ff
      default-timeout=3000
      [urgency=normal]
      border-color=#89b4faff
      default-timeout=5000
      [urgency=high]
      border-color=#f38ba8ff
      default-timeout=0
    '';
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      ipc = "on";
      preload = [ "~/Pictures/Wallpapers/default.jpg" ];
      wallpaper = [ ",~/Pictures/Wallpapers/default.jpg" ];
    };
  };

  services.hypridle = {
    enable = true;
    package = inputs.hypridle.packages.${pkgs.stdenv.hostPlatform.system}.hypridle;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        no_fade_in = false;
      };
      background = [{
        path = "~/Pictures/Wallpapers/default.jpg";
        blur_passes = 3;
        blur_size = 8;
      }];
      input-field = [{
        size = "250, 50";
        position = "0, -20";
        monitor = "";
        dots_center = true;
        fade_on_empty = false;
        font_color = "rgb(205, 214, 244)";
        inner_color = "rgb(30, 30, 46)";
        outer_color = "rgb(137, 180, 250)";
        outline_thickness = 2;
        placeholder_text = "Password...";
        shadow_passes = 2;
      }];
    };
  };
}
