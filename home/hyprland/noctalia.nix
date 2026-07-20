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

    # 2. Declarative Noctalia Configuration (v5 layout)
    xdg.configFile."noctalia/settings.json".text = builtins.toJSON {
      "appLauncher" = {
        "autoPasteClipboard" = false;
        "clipboardWatchImageCommand" = "wl-paste --type image --watch cliphist store";
        "clipboardWatchTextCommand" = "wl-paste --type text --watch cliphist store";
        "clipboardWrapText" = true;
        "customLaunchPrefix" = "";
        "customLaunchPrefixEnabled" = false;
        "density" = "default";
        "enableClipPreview" = true;
        "enableClipboardChips" = true;
        "enableClipboardHistory" = false;
        "enableClipboardSmartIcons" = true;
        "enableSessionSearch" = true;
        "enableSettingsSearch" = true;
        "enableWindowsSearch" = true;
        "iconMode" = "tabler";
        "ignoreMouseInput" = false;
        "overviewLayer" = false;
        "pinnedApps" = [ ];
        "position" = "center";
        "screenshotAnnotationTool" = "";
        "showCategories" = true;
        "showIconBackground" = false;
        "sortByMostUsed" = true;
        "terminalCommand" = "alacritty -e";
        "viewMode" = "list";
      };
      "audio" = {
        "mprisBlacklist" = [ ];
        "preferredPlayer" = "";
        "spectrumFrameRate" = 30;
        "spectrumMirrored" = true;
        "visualizerType" = "linear";
        "volumeFeedback" = false;
        "volumeFeedbackSoundFile" = "";
        "volumeOverdrive" = false;
        "volumeStep" = 5;
      };
      "bar" = {
        "autoHideDelay" = 500;
        "autoShowDelay" = 150;
        "backgroundOpacity" = 0.93;
        "barType" = "simple";
        "capsuleColorKey" = "none";
        "capsuleOpacity" = 1;
        "contentPadding" = 0;
        "density" = "compact";
        "displayMode" = "always_visible";
        "enableExclusionZoneInset" = true;
        "fontScale" = 0.65;
        "frameRadius" = 12;
        "frameThickness" = 4;
        "hideOnOverview" = false;
        "marginHorizontal" = 4;
        "marginVertical" = 0;
        "middleClickAction" = "none";
        "middleClickCommand" = "";
        "middleClickFollowMouse" = false;
        "monitors" = [ ];
        "mouseWheelAction" = "none";
        "mouseWheelWrap" = true;
        "outerCorners" = true;
        "position" = "top";
        "reverseScroll" = false;
        "rightClickAction" = "controlCenter";
        "rightClickCommand" = "";
        "rightClickFollowMouse" = true;
        "screenOverrides" = [ ];
        "showCapsule" = true;
        "showOnWorkspaceSwitch" = true;
        "showOutline" = false;
        "useSeparateOpacity" = false;
        "widgetSpacing" = 6;
        "widgets" = {
          "left" = [
            ({
              "clockColor" = "none";
              "customFont" = "";
              "formatHorizontal" = "HH:mm";
              "formatVertical" = "HH mm - dd MM";
              "id" = "Clock";
              "tooltipFormat" = "HH:mm ddd, MMM dd";
              "useCustomFont" = false;
            })
            ({
              "compactMode" = true;
              "diskPath" = "/";
              "iconColor" = "none";
              "id" = "SystemMonitor";
              "showCpuCores" = false;
              "showCpuFreq" = false;
              "showCpuTemp" = true;
              "showCpuUsage" = true;
              "showDiskAvailable" = false;
              "showDiskUsage" = false;
              "showDiskUsageAsPercent" = false;
              "showGpuTemp" = false;
              "showLoadAverage" = false;
              "showMemoryAsPercent" = false;
              "showMemoryUsage" = true;
              "showNetworkStats" = false;
              "showSwapUsage" = false;
              "textColor" = "none";
              "useMonospaceFont" = true;
              "usePadding" = false;
            })
            ({
              "compactMode" = false;
              "hideMode" = "hidden";
              "hideWhenIdle" = false;
              "id" = "MediaMini";
              "maxWidth" = 145;
              "panelShowAlbumArt" = true;
              "scrollingMode" = "hover";
              "showAlbumArt" = true;
              "showArtistFirst" = true;
              "showProgressRing" = true;
              "showVisualizer" = false;
              "textColor" = "none";
              "useFixedWidth" = false;
              "visualizerType" = "linear";
            })
          ];
          "center" = [
            ({
              "characterCount" = 2;
              "colorizeIcons" = false;
              "emptyColor" = "secondary";
              "enableScrollWheel" = true;
              "focusedColor" = "primary";
              "followFocusedScreen" = false;
              "fontWeight" = "bold";
              "groupedBorderOpacity" = 1;
              "hideUnoccupied" = false;
              "iconScale" = 0.8;
              "id" = "Workspace";
              "labelMode" = "index";
              "occupiedColor" = "secondary";
              "pillSize" = 0.6;
              "showApplications" = false;
              "showApplicationsHover" = false;
              "showBadge" = true;
              "showLabelsOnlyWhenOccupied" = true;
              "unfocusedIconsOpacity" = 1;
            })
          ];
          "right" = [
            ({
              "blacklist" = [ ];
              "chevronColor" = "none";
              "colorizeIcons" = false;
              "drawerEnabled" = true;
              "hidePassive" = false;
              "id" = "Tray";
              "pinned" = [ ];
            })
            ({
              "displayMode" = "onhover";
              "iconColor" = "none";
              "id" = "Volume";
              "middleClickCommand" = "pwvucontrol || pavucontrol";
              "textColor" = "none";
            })
            ({
              "applyToAllMonitors" = false;
              "displayMode" = "onhover";
              "iconColor" = "none";
              "id" = "Brightness";
              "textColor" = "none";
            })
            ({
              "deviceNativePath" = "__default__";
              "displayMode" = "graphic";
              "hideIfIdle" = false;
              "hideIfNotDetected" = true;
              "id" = "Battery";
              "showNoctaliaPerformance" = false;
              "showPowerProfiles" = false;
            })
            ({
              "colorizeDistroLogo" = false;
              "colorizeSystemIcon" = "none";
              "colorizeSystemText" = "none";
              "customIconPath" = "";
              "enableColorization" = false;
              "icon" = "noctalia";
              "id" = "ControlCenter";
              "useDistroLogo" = false;
            })
          ];
        };
      };
      "brightness" = {
        "backlightDeviceMappings" = [ ];
        "brightnessStep" = 5;
        "enableDdcSupport" = false;
        "enforceMinimum" = true;
      };
      "calendar" = {
        "cards" = [
          ({
            "enabled" = true;
            "id" = "calendar-header-card";
          })
          ({
            "enabled" = true;
            "id" = "calendar-month-card";
          })
          ({
            "enabled" = true;
            "id" = "weather-card";
          })
        ];
      };
      "colorSchemes" = {
        "darkMode" = true;
        "generationMethod" = "tonal-spot";
        "manualSunrise" = "06:30";
        "manualSunset" = "18:30";
        "monitorForColors" = "";
        "predefinedScheme" = "Noctalia (default)";
        "schedulingMode" = "off";
        "syncGsettings" = true;
        "useWallpaperColors" = true;
      };
      "controlCenter" = {
        "cards" = [
          ({
            "enabled" = true;
            "id" = "profile-card";
          })
          ({
            "enabled" = true;
            "id" = "shortcuts-card";
          })
          ({
            "enabled" = true;
            "id" = "audio-card";
          })
          ({
            "enabled" = false;
            "id" = "brightness-card";
          })
          ({
            "enabled" = true;
            "id" = "weather-card";
          })
          ({
            "enabled" = true;
            "id" = "media-sysmon-card";
          })
        ];
        "diskPath" = "/";
        "position" = "close_to_bar_button";
        "shortcuts" = {
          "left" = [
            ({
              "id" = "Network";
            })
            ({
              "id" = "Bluetooth";
            })
            ({
              "id" = "WallpaperSelector";
            })
            ({
              "id" = "NoctaliaPerformance";
            })
          ];
          "right" = [
            ({
              "id" = "Notifications";
            })
            ({
              "id" = "PowerProfile";
            })
            ({
              "id" = "KeepAwake";
            })
            ({
              "id" = "NightLight";
            })
          ];
        };
      };
      "desktopWidgets" = {
        "enabled" = false;
        "gridSnap" = false;
        "gridSnapScale" = false;
        "monitorWidgets" = [ ];
        "overviewEnabled" = true;
      };
      "dock" = {
        "animationSpeed" = 1;
        "backgroundOpacity" = 1;
        "colorizeIcons" = false;
        "deadOpacity" = 0.6;
        "displayMode" = "auto_hide";
        "dockType" = "floating";
        "enabled" = true;
        "floatingRatio" = 1;
        "groupApps" = false;
        "groupClickAction" = "cycle";
        "groupContextMenuMode" = "extended";
        "groupIndicatorStyle" = "dots";
        "inactiveIndicators" = false;
        "indicatorColor" = "primary";
        "indicatorOpacity" = 0.6;
        "indicatorThickness" = 3;
        "launcherIcon" = "";
        "launcherIconColor" = "none";
        "launcherPosition" = "end";
        "launcherUseDistroLogo" = false;
        "monitors" = [ ];
        "onlySameOutput" = true;
        "pinnedApps" = [ ];
        "pinnedStatic" = false;
        "position" = "bottom";
        "showDockIndicator" = false;
        "showLauncherIcon" = false;
        "sitOnFrame" = false;
        "size" = 1;
      };
      "general" = {
        "allowPanelsOnScreenWithoutBar" = true;
        "allowPasswordWithFprintd" = false;
        "animationDisabled" = false;
        "animationSpeed" = 1;
        "autoStartAuth" = false;
        "avatarImage" = "/home/jpolo/.face";
        "boxRadiusRatio" = 1;
        "clockFormat" = "hh\\nmm";
        "clockStyle" = "custom";
        "compactLockScreen" = false;
        "dimmerOpacity" = 0.2;
        "enableBlurBehind" = true;
        "enableLockScreenCountdown" = true;
        "enableLockScreenMediaControls" = false;
        "enableShadows" = true;
        "forceBlackScreenCorners" = false;
        "iRadiusRatio" = 1;
        "keybinds" = {
          "keyDown" = [
            "Down"
          ];
          "keyEnter" = [
            "Return"
            "Enter"
          ];
          "keyEscape" = [
            "Esc"
          ];
          "keyLeft" = [
            "Left"
          ];
          "keyRemove" = [
            "Del"
          ];
          "keyRight" = [
            "Right"
          ];
          "keyUp" = [
            "Up"
          ];
        };
        "language" = "";
        "lockOnSuspend" = true;
        "lockScreenAnimations" = false;
        "lockScreenBlur" = 0;
        "lockScreenCountdownDuration" = 10000;
        "lockScreenMonitors" = [ ];
        "lockScreenTint" = 0;
        "passwordChars" = false;
        "radiusRatio" = 1;
        "reverseScroll" = false;
        "scaleRatio" = 1;
        "screenRadiusRatio" = 1;
        "shadowDirection" = "bottom_right";
        "shadowOffsetX" = 2;
        "shadowOffsetY" = 3;
        "showChangelogOnStartup" = true;
        "showHibernateOnLockScreen" = false;
        "showScreenCorners" = false;
        "showSessionButtonsOnLockScreen" = true;
        "smoothScrollEnabled" = true;
        "telemetryEnabled" = false;
      };
      "hooks" = {
        "colorGeneration" = "";
        "darkModeChange" = "";
        "enabled" = false;
        "performanceModeDisabled" = "";
        "performanceModeEnabled" = "";
        "screenLock" = "";
        "screenUnlock" = "";
        "session" = "";
        "startup" = "";
        "wallpaperChange" = "";
      };
      "idle" = {
        "customCommands" = "[]";
        "enabled" = false;
        "fadeDuration" = 5;
        "lockCommand" = "";
        "lockTimeout" = 660;
        "resumeLockCommand" = "";
        "resumeScreenOffCommand" = "";
        "resumeSuspendCommand" = "";
        "screenOffCommand" = "";
        "screenOffTimeout" = 600;
        "suspendCommand" = "";
        "suspendTimeout" = 1800;
      };
      "location" = {
        "analogClockInCalendar" = false;
        "autoLocate" = true;
        "firstDayOfWeek" = -1;
        "hideWeatherCityName" = false;
        "hideWeatherTimezone" = false;
        "name" = "";
        "showCalendarEvents" = true;
        "showCalendarWeather" = true;
        "showWeekNumberInCalendar" = false;
        "use12hourFormat" = false;
        "useFahrenheit" = false;
        "weatherEnabled" = true;
        "weatherShowEffects" = true;
        "weatherTaliaMascotAlways" = false;
      };
      "network" = {
        "bluetoothAutoConnect" = true;
        "bluetoothDetailsViewMode" = "grid";
        "bluetoothHideUnnamedDevices" = false;
        "bluetoothRssiPollIntervalMs" = 60000;
        "bluetoothRssiPollingEnabled" = false;
        "disableDiscoverability" = false;
        "networkPanelView" = "wifi";
        "wifiDetailsViewMode" = "grid";
      };
      "nightLight" = {
        "autoSchedule" = true;
        "dayTemp" = "6500";
        "enabled" = false;
        "forced" = false;
        "manualSunrise" = "06:30";
        "manualSunset" = "18:30";
        "nightTemp" = "4000";
      };
      "noctaliaPerformance" = {
        "disableDesktopWidgets" = true;
        "disableWallpaper" = true;
      };
      "notifications" = {
        "backgroundOpacity" = 1;
        "clearDismissed" = true;
        "criticalUrgencyDuration" = 15;
        "density" = "default";
        "enableBatteryToast" = true;
        "enableKeyboardLayoutToast" = true;
        "enableMarkdown" = false;
        "enableMediaToast" = false;
        "enabled" = true;
        "location" = "top_right";
        "lowUrgencyDuration" = 3;
        "monitors" = [ ];
        "normalUrgencyDuration" = 8;
        "overlayLayer" = true;
        "respectExpireTimeout" = false;
        "saveToHistory" = {
          "critical" = true;
          "low" = true;
          "normal" = true;
        };
        "sounds" = {
          "criticalSoundFile" = "";
          "enabled" = false;
          "excludedApps" = "discord,firefox,chrome,chromium,edge";
          "lowSoundFile" = "";
          "normalSoundFile" = "";
          "separateSounds" = false;
          "volume" = 0.5;
        };
      };
      "osd" = {
        "autoHideMs" = 2000;
        "backgroundOpacity" = 1;
        "enabled" = true;
        "enabledTypes" = [
          0
          1
          2
        ];
        "location" = "top_right";
        "monitors" = [ ];
        "overlayLayer" = true;
      };
      "plugins" = {
        "autoUpdate" = false;
        "notifyUpdates" = true;
      };
      "sessionMenu" = {
        "countdownDuration" = 10000;
        "enableCountdown" = true;
        "largeButtonsLayout" = "single-row";
        "largeButtonsStyle" = true;
        "position" = "center";
        "powerOptions" = [
          ({
            "action" = "lock";
            "enabled" = true;
            "keybind" = "1";
          })
          ({
            "action" = "suspend";
            "enabled" = true;
            "keybind" = "2";
          })
          ({
            "action" = "hibernate";
            "enabled" = true;
            "keybind" = "3";
          })
          ({
            "action" = "reboot";
            "enabled" = true;
            "keybind" = "4";
          })
          ({
            "action" = "logout";
            "enabled" = true;
            "keybind" = "5";
          })
          ({
            "action" = "shutdown";
            "enabled" = true;
            "keybind" = "6";
          })
          ({
            "action" = "rebootToUefi";
            "enabled" = true;
            "keybind" = "7";
          })
        ];
        "showHeader" = true;
        "showKeybinds" = true;
      };
      "settingsVersion" = 59;
      "systemMonitor" = {
        "batteryCriticalThreshold" = 5;
        "batteryWarningThreshold" = 20;
        "cpuCriticalThreshold" = 90;
        "cpuWarningThreshold" = 80;
        "criticalColor" = "";
        "diskAvailCriticalThreshold" = 10;
        "diskAvailWarningThreshold" = 20;
        "diskCriticalThreshold" = 90;
        "diskWarningThreshold" = 80;
        "enableDgpuMonitoring" = false;
        "externalMonitor" = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
        "gpuCriticalThreshold" = 90;
        "gpuWarningThreshold" = 80;
        "memCriticalThreshold" = 90;
        "memWarningThreshold" = 80;
        "swapCriticalThreshold" = 90;
        "swapWarningThreshold" = 80;
        "tempCriticalThreshold" = 90;
        "tempWarningThreshold" = 80;
        "useCustomColors" = false;
        "warningColor" = "";
      };
      "templates" = {
        "activeTemplates" = [ ];
        "enableUserTheming" = false;
      };
      "ui" = {
        "boxBorderEnabled" = false;
        "fontDefault" = "Noto Sans";
        "fontDefaultScale" = 1;
        "fontFixed" = "monospace";
        "fontFixedScale" = 1;
        "panelBackgroundOpacity" = 0.93;
        "panelsAttachedToBar" = true;
        "scrollbarAlwaysVisible" = true;
        "settingsPanelMode" = "attached";
        "settingsPanelSideBarCardStyle" = false;
        "tooltipsEnabled" = true;
        "translucentWidgets" = false;
      };
      "wallpaper" = {
        "automationEnabled" = false;
        "directory" = "/home/jpolo/Pictures/Wallpapers";
        "enableMultiMonitorDirectories" = false;
        "enabled" = true;
        "favorites" = [ ];
        "fillColor" = "#000000";
        "fillMode" = "crop";
        "hideWallpaperFilenames" = false;
        "linkLightAndDarkWallpapers" = true;
        "monitorDirectories" = [ ];
        "overviewBlur" = 0.4;
        "overviewEnabled" = false;
        "overviewTint" = 0.6;
        "panelPosition" = "follow_bar";
        "randomIntervalSec" = 300;
        "setWallpaperOnAllMonitors" = true;
        "showHiddenFiles" = false;
        "skipStartupTransition" = false;
        "solidColor" = "#1a1a2e";
        "sortOrder" = "name";
        "transitionDuration" = 1500;
        "transitionEdgeSmoothness" = 0.05;
        "transitionType" = [
          "fade"
          "disc"
          "stripes"
          "wipe"
          "pixelate"
          "honeycomb"
        ];
        "useOriginalImages" = false;
        "useSolidColor" = false;
        "useWallhaven" = false;
        "viewMode" = "single";
        "wallhavenApiKey" = "";
        "wallhavenCategories" = "111";
        "wallhavenOrder" = "desc";
        "wallhavenPurity" = "100";
        "wallhavenQuery" = "";
        "wallhavenRatios" = "";
        "wallhavenResolutionHeight" = "";
        "wallhavenResolutionMode" = "atleast";
        "wallhavenResolutionWidth" = "";
        "wallhavenSorting" = "relevance";
        "wallpaperChangeMode" = "random";
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

      [templates.kde]
      input_path = "${config.xdg.configHome}/matugen/templates/kdeglobals"
      output_path = "${config.xdg.configHome}/kdeglobals"
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

    # 2.10. Matugen template for KDE/Qt Colors (kdeglobals)
    xdg.configFile."matugen/templates/kdeglobals".text = ''
      [Colors:View]
      BackgroundAlternate={{colors.surface_container.default.rgb}}
      BackgroundNormal={{colors.surface.default.rgb}}
      DecorationFocus={{colors.primary.default.rgb}}
      DecorationHover={{colors.primary.default.rgb}}
      ForegroundActive={{colors.primary.default.rgb}}
      ForegroundInactive={{colors.on_surface_variant.default.rgb}}
      ForegroundLink={{colors.primary.default.rgb}}
      ForegroundNegative={{colors.error.default.rgb}}
      ForegroundNeutral={{colors.secondary.default.rgb}}
      ForegroundNormal={{colors.on_surface.default.rgb}}
      ForegroundPositive={{colors.tertiary.default.rgb}}
      ForegroundVisited={{colors.secondary.default.rgb}}

      [Colors:Window]
      BackgroundAlternate={{colors.surface_container_high.default.rgb}}
      BackgroundNormal={{colors.surface.default.rgb}}
      DecorationFocus={{colors.primary.default.rgb}}
      DecorationHover={{colors.primary.default.rgb}}
      ForegroundActive={{colors.primary.default.rgb}}
      ForegroundInactive={{colors.on_surface_variant.default.rgb}}
      ForegroundLink={{colors.primary.default.rgb}}
      ForegroundNegative={{colors.error.default.rgb}}
      ForegroundNeutral={{colors.secondary.default.rgb}}
      ForegroundNormal={{colors.on_surface.default.rgb}}
      ForegroundPositive={{colors.tertiary.default.rgb}}
      ForegroundVisited={{colors.secondary.default.rgb}}

      [Colors:Button]
      BackgroundAlternate={{colors.surface_container_low.default.rgb}}
      BackgroundNormal={{colors.surface_container.default.rgb}}
      DecorationFocus={{colors.primary.default.rgb}}
      DecorationHover={{colors.primary.default.rgb}}
      ForegroundActive={{colors.primary.default.rgb}}
      ForegroundInactive={{colors.on_surface_variant.default.rgb}}
      ForegroundLink={{colors.primary.default.rgb}}
      ForegroundNegative={{colors.error.default.rgb}}
      ForegroundNeutral={{colors.secondary.default.rgb}}
      ForegroundNormal={{colors.on_surface.default.rgb}}
      ForegroundPositive={{colors.tertiary.default.rgb}}
      ForegroundVisited={{colors.secondary.default.rgb}}

      [Colors:Selection]
      BackgroundAlternate={{colors.primary_container.default.rgb}}
      BackgroundNormal={{colors.primary.default.rgb}}
      DecorationFocus={{colors.primary.default.rgb}}
      DecorationHover={{colors.primary.default.rgb}}
      ForegroundActive={{colors.on_primary.default.rgb}}
      ForegroundInactive={{colors.on_primary_container.default.rgb}}
      ForegroundLink={{colors.on_primary.default.rgb}}
      ForegroundNegative={{colors.on_primary.default.rgb}}
      ForegroundNeutral={{colors.on_primary.default.rgb}}
      ForegroundNormal={{colors.on_primary.default.rgb}}
      ForegroundPositive={{colors.on_primary.default.rgb}}
      ForegroundVisited={{colors.on_primary.default.rgb}}

      [General]
      ColorScheme=NoctaliaGenerated
      Name=Noctalia Generated Theme
    '';


    # 3. Hyprland integration (auto-launch Noctalia)
    # Note: noctalia startup is handled in hyprland.nix extraConfig
    # and by the systemd service below. Do not use settings.exec-once here
    # as it generates invalid Lua syntax (hl.exec-once with hyphens).

    # 4. Systemd service for reliable auto-start with crash recovery
    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia Shell - Minimal Wayland Desktop";
        Documentation = "https://docs.noctalia.dev/";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        ExecStart = "${inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/noctalia";
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
