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
        "cursorSize" = 24;
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

    # 3. Hyprland integration (auto-launch Noctalia)
    wayland.windowManager.hyprland.settings = {
      # Remove manual exec-once if systemd is used, or keep it if systemd fails
      exec-once = [
        "systemctl --user start noctalia-shell"
      ];

      # Optional: Custom windowrules for Noctalia windows
      windowrulev2 = [
        # Quick settings panel
        "float, class:quickshell, title:control"
        "size 400 700, class:quickshell, title:control"
        "move 100%-w-20 20, class:quickshell, title:control"
        
        # Launcher
        "float, class:quickshell, title:launcher"
        "animation popin, class:quickshell, title:launcher"
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
          "WAYLAND_DISPLAY=wayland-1"
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
