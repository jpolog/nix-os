{ config, pkgs, inputs, lib, ... }:

with lib;

let
  cfg = config.home.profiles.desktop;
in {
  config = mkIf (cfg.enable && cfg.environment == "hyprland") {
    
    # 1. Essential packages with all dependencies for Noctalia v3
    home.packages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
      
      # Color generation for Material You theming
      matugen
      
      # System integrations
      playerctl        # Media controls
      brightnessctl    # Brightness control
      pamixer          # Volume mixer
      pavucontrol      # Audio GUI (optional)
      
      # Network/Bluetooth
      networkmanager
      bluez
      
      # Required for night light/wlsunset
      wlsunset
      
      # OCR
      tesseract
      
      # Color Picker
      hyprpicker
      
      # File utilities
      fd
      ripgrep
    ];

    # 2. Best-practice Noctalia configuration with all features
    xdg.configFile."quickshell/noctalia/settings.json".text = builtins.toJSON {
      # ===== GENERAL SETTINGS =====
      "General" = {
        "scale" = 1.0;                    # UI scale factor
        "backend" = "hyprland";           # Compositor (hyprland/niri/sway)
        "cursorTheme" = "Bibata-Modern-Classic";
      };

      # ===== BAR CONFIGURATION =====
      "Bar" = {
        "enabled" = true;
        "position" = "top";               # top, bottom, left, right
        "height" = 42;
        "floating" = false;               # Better for tiling
        "exclusivity" = "exclusive";      # Full height exclusion for tiling

        # Module layout: Left | Center | Right
        "modulesLeft" = [
          "workspaces"
        ];
        "modulesCenter" = [
          "media"
          "clock"
        ];
        "modulesRight" = [
          "updates"
          "network"
          "volume"
          "brightness"
          "battery"
          "quicksettings"
        ];
      };

      # ===== CONTROL CENTER / PANEL =====
      "ControlCenter" = {
        "enabled" = true;
        "position" = "right";             # right or left
        "width" = 400;
        "modulesEnabled" = [
          "brightness"
          "volume"
          "network"
          "bluetooth"
          "settings"
        ];
      };

      # ===== NOTIFICATION SETTINGS =====
      "Notifications" = {
        "enabled" = true;
        "position" = "top-right";
        "displayTime" = 5;                # seconds before auto-dismiss
        "maxNotifications" = 3;
      };

      # ===== THEME & APPEARANCE =====
      "Theme" = {
        "mode" = "dark";                  # dark or light
        "useSystemColors" = true;         # Use matugen colors
        "blur" = true;
        "blurOpacity" = 0.9;
        "cornerRadius" = 8;
        "accentColor" = "#b4a7e6";        # Noctalia's signature lavender
        "fontFamily" = "JetBrains Mono";
        "fontSize" = 12;
      };

      # ===== LAUNCHER CONFIGURATION =====
      "Launcher" = {
        "enabled" = true;
        "position" = "center";
        "width" = 400;
        "height" = 500;
        "showDescriptions" = true;
        "categoryIcons" = true;
      };

      # ===== WORKSPACE INDICATOR =====
      "Workspaces" = {
        "enabled" = true;
        "displayNumbers" = true;
        "displayNames" = true;
        "visibleWorkspaces" = 10;
        "scrollOnHover" = true;
      };

      # ===== MEDIA PLAYER WIDGET =====
      "Media" = {
        "enabled" = true;
        "showArtwork" = true;
        "visualizer" = false;
        "maxTitleLength" = 30;
      };

      # ===== CLOCK SETTINGS =====
      "Clock" = {
        "enabled" = true;
        "format" = "%H:%M";               # 24-hour format
        "showSeconds" = false;
        "showDate" = false;               # Hover to see full date
      };

      # ===== POWER/BATTERY =====
      "Battery" = {
        "enabled" = true;
        "showPercentage" = true;
        "showEstimate" = true;
        "lowBatteryWarning" = 20;
        "criticalBatteryLevel" = 5;
      };

      # ===== NIGHT LIGHT / WLSUNSET =====
      "NightLight" = {
        "enabled" = true;
        "startTime" = "20:00";
        "endTime" = "08:00";
        "temperature" = 4000;             # Kelvin (warmer = lower)
      };

      # ===== NETWORK INDICATOR =====
      "Network" = {
        "enabled" = true;
        "showDetails" = true;
        "showSignalStrength" = true;
      };

      # ===== VOLUME CONTROL =====
      "Volume" = {
        "enabled" = true;
        "maxVolume" = 150;                # Allow overshoot above 100%
      };

      # ===== BRIGHTNESS CONTROL =====
      "Brightness" = {
        "enabled" = true;
        "minBrightness" = 5;
        "maxBrightness" = 100;
      };

      # ===== SYSTEM UPDATES CHECK =====
      "Updates" = {
        "enabled" = true;
        "checkInterval" = 3600;           # Check every hour
      };
    };
    
    # 2.2 Configure Matugen to use the template
    xdg.configFile."matugen/config.toml".text = ''
      [config]
      reload_on_change = true
      
      [templates.kitty]
      input_path = "${config.xdg.configHome}/matugen/templates/kitty.conf"
      output_path = "${config.xdg.configHome}/kitty/themes/noctalia.conf"

      [templates.alacritty]
      input_path = "${config.xdg.configHome}/matugen/templates/alacritty.toml"
      output_path = "${config.xdg.configHome}/alacritty/themes/noctalia.toml"

      [templates.btop]
      input_path = "${config.xdg.configHome}/matugen/templates/btop.theme"
      output_path = "${config.xdg.configHome}/btop/themes/noctalia.theme"

      [templates.walker]
      input_path = "${config.xdg.configHome}/matugen/templates/walker.css"
      output_path = "${config.xdg.configHome}/walker/themes/noctalia.css"

      [templates.discord]
      input_path = "${config.xdg.configHome}/matugen/templates/discord.css"
      output_path = "${config.xdg.configHome}/vesktop/themes/noctalia.css"
    '';

        # 2.5. Matugen template for kitty terminal color sync
    xdg.configFile."matugen/templates/kitty.conf" = {
      text = ''
        # Kitty color scheme generated by matugen
        # Synced with Noctalia Material You theming
        
        # Base colors
        foreground {{colors.on_surface.default.hex}}
        background {{colors.surface.default.hex}}
        selection_foreground {{colors.on_primary.default.hex}}
        selection_background {{colors.primary.default.hex}}
        
        # Cursor colors
        cursor {{colors.primary.default.hex}}
        cursor_text_color {{colors.on_primary.default.hex}}
        
        # URL underline color
        url_color {{colors.tertiary.default.hex}}
        
        # Tab bar colors
        active_tab_foreground {{colors.on_primary_container.default.hex}}
        active_tab_background {{colors.primary_container.default.hex}}
        inactive_tab_foreground {{colors.on_surface_variant.default.hex}}
        inactive_tab_background {{colors.surface_container.default.hex}}
        tab_bar_background {{colors.surface.default.hex}}
        
        # Window border colors
        active_border_color {{colors.primary.default.hex}}
        inactive_border_color {{colors.surface_variant.default.hex}}
        
        # Terminal colors (0-7: normal, 8-15: bright)
        color0 {{colors.surface_dim.default.hex}}
        color1 {{colors.error.default.hex}}
        color2 {{colors.tertiary.default.hex}}
        color3 {{colors.secondary.default.hex}}
        color4 {{colors.primary.default.hex}}
        color5 {{colors.primary_container.default.hex}}
        color6 {{colors.tertiary_container.default.hex}}
        color7 {{colors.on_surface.default.hex}}
        
        color8 {{colors.surface_bright.default.hex}}
        color9 {{colors.error.default.hex}}
        color10 {{colors.tertiary.default.hex}}
        color11 {{colors.secondary.default.hex}}
        color12 {{colors.primary.default.hex}}
        color13 {{colors.primary_container.default.hex}}
        color14 {{colors.tertiary_container.default.hex}}
        color15 {{colors.on_surface_variant.default.hex}}
      '';
    };

    # 2.6. Matugen template for Alacritty
    xdg.configFile."matugen/templates/alacritty.toml".text = ''
      [colors.primary]
      background = "{{colors.surface.default.hex}}"
      foreground = "{{colors.on_surface.default.hex}}"
      dim_foreground = "{{colors.on_surface_variant.default.hex}}"
      bright_foreground = "{{colors.on_surface.default.hex}}"

      [colors.cursor]
      text = "{{colors.on_primary.default.hex}}"
      cursor = "{{colors.primary.default.hex}}"

      [colors.normal]
      black = "{{colors.surface_dim.default.hex}}"
      red = "{{colors.error.default.hex}}"
      green = "{{colors.tertiary.default.hex}}"
      yellow = "{{colors.secondary.default.hex}}"
      blue = "{{colors.primary.default.hex}}"
      magenta = "{{colors.primary_container.default.hex}}"
      cyan = "{{colors.tertiary_container.default.hex}}"
      white = "{{colors.on_surface.default.hex}}"

      [colors.bright]
      black = "{{colors.surface_bright.default.hex}}"
      red = "{{colors.error.default.hex}}"
      green = "{{colors.tertiary.default.hex}}"
      yellow = "{{colors.secondary.default.hex}}"
      blue = "{{colors.primary.default.hex}}"
      magenta = "{{colors.primary_container.default.hex}}"
      cyan = "{{colors.tertiary_container.default.hex}}"
      white = "{{colors.on_surface_variant.default.hex}}"
    '';

    # 2.7. Matugen template for Btop
    xdg.configFile."matugen/templates/btop.theme".text = ''
      # Main background, empty for terminal default, need to be empty if you want transparent background
      theme[main_bg]="{{colors.surface.default.hex}}"

      # Main text color
      theme[main_fg]="{{colors.on_surface.default.hex}}"

      # Title color for boxes
      theme[title]="{{colors.on_surface.default.hex}}"

      # Higlight color for keyboard shortcuts
      theme[hi_fg]="{{colors.primary.default.hex}}"

      # Background color of selected item in processes box
      theme[selected_bg]="{{colors.surface_container_highest.default.hex}}"

      # Foreground color of selected item in processes box
      theme[selected_fg]="{{colors.on_surface.default.hex}}"

      # Color of inactive/disabled text
      theme[inactive_fg]="{{colors.on_surface_variant.default.hex}}"

      # Color of text appearing on top of graphs, i.e uptime and current network graph scaling
      theme[graph_text]="{{colors.on_surface.default.hex}}"

      # Background color of the percentage meters
      theme[meter_bg]="{{colors.surface_container.default.hex}}"

      # Misc colors for processes box including mini cpu graphs, details memory graph and details status text
      theme[proc_misc]="{{colors.on_surface_variant.default.hex}}"

      # Cpu box outline color
      theme[cpu_box]="{{colors.primary.default.hex}}"

      # Memory box outline color
      theme[mem_box]="{{colors.tertiary.default.hex}}"

      # Net box outline color
      theme[net_box]="{{colors.secondary.default.hex}}"

      # Processes box outline color
      theme[proc_box]="{{colors.error.default.hex}}"

      # Box divider line and small boxes line color
      theme[div_line]="{{colors.outline.default.hex}}"

      # Temperature graph colors
      theme[temp_start]="{{colors.primary.default.hex}}"
      theme[temp_mid]="{{colors.tertiary.default.hex}}"
      theme[temp_end]="{{colors.error.default.hex}}"

      # CPU graph colors
      theme[cpu_start]="{{colors.primary.default.hex}}"
      theme[cpu_mid]="{{colors.tertiary.default.hex}}"
      theme[cpu_end]="{{colors.error.default.hex}}"

      # Mem/Disk free meter
      theme[free_start]="{{colors.primary.default.hex}}"
      theme[free_mid]="{{colors.tertiary.default.hex}}"
      theme[free_end]="{{colors.error.default.hex}}"

      # Mem/Disk cached meter
      theme[cached_start]="{{colors.primary.default.hex}}"
      theme[cached_mid]="{{colors.tertiary.default.hex}}"
      theme[cached_end]="{{colors.error.default.hex}}"

      # Mem/Disk available meter
      theme[available_start]="{{colors.primary.default.hex}}"
      theme[available_mid]="{{colors.tertiary.default.hex}}"
      theme[available_end]="{{colors.error.default.hex}}"

      # Mem/Disk used meter
      theme[used_start]="{{colors.primary.default.hex}}"
      theme[used_mid]="{{colors.tertiary.default.hex}}"
      theme[used_end]="{{colors.error.default.hex}}"

      # Download graph colors
      theme[download_start]="{{colors.primary.default.hex}}"
      theme[download_mid]="{{colors.tertiary.default.hex}}"
      theme[download_end]="{{colors.error.default.hex}}"

      # Upload graph colors
      theme[upload_start]="{{colors.primary.default.hex}}"
      theme[upload_mid]="{{colors.tertiary.default.hex}}"
      theme[upload_end]="{{colors.error.default.hex}}"
    '';

    # 2.8. Matugen template for Walker
    xdg.configFile."matugen/templates/walker.css".text = ''
      #window {
        background-color: {{colors.surface.default.hex}};
        color: {{colors.on_surface.default.hex}};
      }

      #input {
        background-color: {{colors.surface_container.default.hex}};
        color: {{colors.on_surface.default.hex}};
        border-bottom: 2px solid {{colors.primary.default.hex}};
      }

      #list {
        background-color: transparent;
      }

      .item {
        color: {{colors.on_surface.default.hex}};
      }

      .item.active {
        background-color: {{colors.secondary_container.default.hex}};
        color: {{colors.on_secondary_container.default.hex}};
      }
    '';

    # 2.9. Matugen template for Discord (Vencord)
    xdg.configFile."matugen/templates/discord.css".text = ''
      :root {
        --primary-color: {{colors.primary.default.hex}};
        --secondary-color: {{colors.secondary.default.hex}};
        --background-primary: {{colors.surface.default.hex}};
        --background-secondary: {{colors.surface_container.default.hex}};
        --background-tertiary: {{colors.surface_container_highest.default.hex}};
        --text-normal: {{colors.on_surface.default.hex}};
        --text-muted: {{colors.on_surface_variant.default.hex}};
      }
    '';


    # 3. Hyprland integration (auto-launch Noctalia)
    wayland.windowManager.hyprland.settings = {
      # Remove manual exec-once if systemd is used, or keep it if systemd fails
      exec-once = [
        "systemctl --user start noctalia-shell"
      ];

    };

    # 4. Systemd service for reliable auto-start with crash recovery
    systemd.user.services.noctalia-shell = {
      Unit = {
        Description = "Noctalia Shell - Minimal Wayland Desktop";
        Documentation = "https://docs.noctalia.dev/";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        ExecStart = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia-shell";
        Restart = "on-failure";
        RestartSec = 3;
        StandardOutput = "journal";
        StandardError = "journal";
        
        # Environment variables for proper Wayland detection
        Environment = [
          "QT_QPA_PLATFORM=wayland"
          "QT_AUTO_SCREEN_SCALE_FACTOR=1"
        ];
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
