{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

with lib;

{
  config =
    mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland")
      {

        home.packages = with pkgs; [
          (pkgs.writeShellScriptBin "universal-copy" ''
            INFO=$(${pkgs.hyprland}/bin/hyprctl activewindow -j)
            CLASS=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r ".class")
            ADDR=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r ".address")

            if [[ "$CLASS" =~ ^(kitty|Alacritty)$ ]]; then
              ${pkgs.hyprland}/bin/hyprctl dispatch sendshortcut "CTRL SHIFT, C, address:$ADDR"
            else
              ${pkgs.hyprland}/bin/hyprctl dispatch sendshortcut "CTRL, C, address:$ADDR"
            fi
          '')

          (pkgs.writeShellScriptBin "universal-paste" ''
            INFO=$(${pkgs.hyprland}/bin/hyprctl activewindow -j)
            CLASS=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r ".class")
            ADDR=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r ".address")

            if [[ "$CLASS" =~ ^(kitty|Alacritty)$ ]]; then
              ${pkgs.hyprland}/bin/hyprctl dispatch sendshortcut "CTRL SHIFT, V, address:$ADDR"
            else
              ${pkgs.hyprland}/bin/hyprctl dispatch sendshortcut "CTRL, V, address:$ADDR"
            fi
          '')

          (pkgs.writeShellScriptBin "toggle-transparency" ''
            ACTIVE_OPACITY=$(${pkgs.hyprland}/bin/hyprctl getoption decoration:active_opacity | ${pkgs.gawk}/bin/awk '/float/ {print $2}')
            IS_OPAQUE=$(${pkgs.gawk}/bin/awk -v active_opacity="$ACTIVE_OPACITY" 'BEGIN {print (active_opacity >= 1.0)}')
            if [ "$IS_OPAQUE" = "1" ]; then
              ${pkgs.hyprland}/bin/hyprctl --batch "keyword decoration:active_opacity 0.9; keyword decoration:inactive_opacity 0.8"
            else
              ${pkgs.hyprland}/bin/hyprctl --batch "keyword decoration:active_opacity 1.0; keyword decoration:inactive_opacity 1.0"
            fi
          '')
        ];

        wayland.windowManager.hyprland = {
          enable = true;
          # Package is managed by system module (modules/desktop/hyprland.nix)
          # preventing version mismatches and double installation.
          package = null;

          # Enable Hyprland plugins
          plugins = [
            inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprscrolling
          ];

          settings = {
            # Monitors
            monitor = [
              "eDP-1,1920x1200@60,0x0,1"
              "HDMI-A-1,1920x1080@60,1920x0,1"
              "DP-1,1920x1080@60,3840x0,1,transform,1"
              ",preferred,auto,1"
            ];

            # Exec-once
            exec-once = [
              "hypridle"
              "mako"
              "fcitx5"
              "swayosd-server"
              "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
              "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "nm-applet --indicator"
              "blueman-applet"
              "hyprpm reload -n"
            ];

            # Environment
            env = [
              "XCURSOR_SIZE,18"
              "HYPRCURSOR_SIZE,18"
              "GDK_BACKEND,wayland,x11,*"
              "QT_QPA_PLATFORM,wayland;xcb"
              # "QT_STYLE_OVERRIDE,kvantum" # Disabled in favor of qt6ct
              "QT_QPA_PLATFORMTHEME,qt6ct"
              "SDL_VIDEODRIVER,wayland"
              "MOZ_ENABLE_WAYLAND,1"
              "ELECTRON_OZONE_PLATFORM_HINT,wayland"
              "OZONE_PLATFORM,wayland"
              "XDG_SESSION_TYPE,wayland"
              "XDG_CURRENT_DESKTOP,Hyprland"
              "XDG_SESSION_DESKTOP,Hyprland"
              "XCOMPOSEFILE,~/.XCompose"
              "GUM_CONFIRM_PROMPT_FOREGROUND,6"
              "GUM_CONFIRM_SELECTED_FOREGROUND,0"
              "GUM_CONFIRM_SELECTED_BACKGROUND,2"
              "GUM_CONFIRM_UNSELECTED_FOREGROUND,0"
              "GUM_CONFIRM_UNSELECTED_BACKGROUND,8"
            ];

            # General
            general = {
              gaps_in = 5;
              gaps_out = 10;
              border_size = 2;
              resize_on_border = false;
              allow_tearing = false;
              layout = "scrolling";
            };

            # Decoration
            decoration = {
              rounding = 3;
              active_opacity = 0.9;
              inactive_opacity = 0.8;

              shadow = {
                enabled = true;
                range = 2;
                render_power = 3;
              };

              blur = {
                enabled = true;
                size = 2;
                passes = 2;
                special = true;
                brightness = 0.60;
                contrast = 0.75;
              };
            };

            # Animations
            animations = {
              enabled = true;
              bezier = [
                "easeOutQuint,0.23,1,0.32,1"
                "easeInOutCubic,0.65,0.05,0.36,1"
                "linear,0,0,1,1"
                "almostLinear,0.5,0.5,0.75,1.0"
                "quick,0.15,0,0.1,1"
              ];
              animation = [
                "global, 1, 10, default"
                "border, 1, 5.39, easeOutQuint"
                "windows, 1, 4.79, easeOutQuint"
                "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
                "windowsOut, 1, 1.49, linear, popin 87%"
                "fadeIn, 1, 1.73, almostLinear"
                "fadeOut, 1, 1.46, almostLinear"
                "fade, 1, 3.03, quick"
                "layers, 1, 3.81, easeOutQuint"
                "layersIn, 1, 4, easeOutQuint, fade"
                "layersOut, 1, 1.5, linear, fade"
                "fadeLayersIn, 1, 1.79, almostLinear"
                "fadeLayersOut, 1, 1.39, almostLinear"
                "workspaces, 0, 0, ease"
              ];
            };

            # Input
            input = {
              kb_layout = "us,es";
              kb_options = "altwin:swap_alt_win,grp:alt_shift_toggle,compose:caps";
              numlock_by_default = true;
              repeat_rate = 40;
              repeat_delay = 600;
              touchpad = {
                natural_scroll = false;
                scroll_factor = 0.4;
              };
              sensitivity = 0;
              mouse_refocus = false;
            };

            # Plugin Settings
            plugin = {
              hyprscrolling = {
                column_width = 0.5;
                fullscreen_on_one_column = false;
                focus_fit_method = 1;
                follow_focus = true;
                follow_debounce_ms = 150;
              };
            };

            # Window Rules
            windowrulev2 = [
              "float,class:^(floating)$"
              "stayfocused, class:(zoom), title:(menu window)"
              
              # Workspace 4: Communications
              "workspace 4,class:^(zoom)$"
              "workspace 4,class:^(discord)$"
              "workspace 4,class:^(teams-for-linux)$"
              "workspace 4,class:^(chrome-web.whatsapp.com.*)$"
              
              # Workspace 10: Knowledge Base
              "workspace 10,class:^(obsidian)$"

              # Ensure initial placement for startup
              "workspace 4,initialClass:^(zoom)$"
              "workspace 4,initialClass:^(discord)$"
              "workspace 4,initialClass:^(teams-for-linux)$"
              "workspace 4,initialClass:^(chrome-web.whatsapp.com.*)$"
              "workspace 10,initialClass:^(obsidian)$"
            ];

            # Misc
            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              focus_on_activate = true;
              key_press_enables_dpms = true;
              mouse_move_enables_dpms = true;
              anr_missed_pings = 3;
            };

            # Group
            group = {
              groupbar = {
                height = 22;
              };
            };

            # Variables
            "$osdclient" =
              "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')\"";
            "$terminal" = "kitty";
            "$browser" = "firefox";

            # Bindings
            bind = [
              # Apps
              "SUPER, RETURN, exec, $terminal"
              "SUPER SHIFT, F, exec, dolphin"
              "SUPER, B, exec, $browser"
              "SUPER ALT, B, exec, $browser --private"
              "SUPER, D, exec, $terminal -e lazydocker"
              "SUPER SHIFT, T, exec, $terminal -e btop"
              "SUPER, O, exec, hyprctl clients | grep -i 'class: obsidian' && hyprctl dispatch focuswindow class:obsidian || obsidian"
              "SUPER, A, exec, gtk-launch perplexity"

              # Menus
              "SUPER, SPACE, exec, walker"
              "SUPER, N, exec, noctalia-shell ipc call controlCenter toggle"
              "SUPER SHIFT, P, exec, walker -m power-profiles" # Power Profiles Menu
              "SUPER ALT, SPACE, exec, kitty --class floating -e nix-search"
              "SUPER, ESCAPE, exec, noctalia-shell ipc call sessionMenu toggle"

              # Manual lock (keeps display on and tasks running)
              "SUPER SHIFT, L, exec, loginctl lock-session"

              # Lock and turn off display immediately (for when stepping away)
              "SUPER CTRL SHIFT, L, exec, loginctl lock-session && sleep 1 && hyprctl dispatch dpms off"

              # Clipboard
              "SUPER, C, exec, universal-copy"
              "SUPER, V, exec, universal-paste"
              "SUPER, X, sendshortcut, CTRL, X,"
              "SUPER CTRL, V, exec, walker -m clipboard"

              # Window Management
              "SUPER, W, killactive,"
              "CTRL ALT, DELETE, exit,"
              "SUPER, T, togglefloating,"
              "SUPER, F, fullscreen, 0"
              "SUPER ALT, F, fullscreen, 1"

              # Rotate Layout (Toggle between Row and Column mode for Hyprscrolling)
              "SUPER, R, exec, hyprctl dispatch scroller:setmode $(hyprctl getoption plugin:hyprscrolling:mode | grep -q 'col' && echo row || echo col)"

              # Special Workspace
              "SUPER, S, togglespecialworkspace, magic"
              "SUPER SHIFT, S, movetoworkspace, special:magic"

              # Web Apps
              "SUPER SHIFT, E, exec, gtk-launch outlook"
              "SUPER SHIFT, G, exec, chromium --app=https://github.com"

              # Toggle Transparency
              "SUPER, BackSpace, exec, toggle-transparency"

              # Scrolling Layout Specific
              "SUPER, period, layoutmsg, move +col"
              "SUPER, comma, layoutmsg, move -col"
              "SUPER, equal, layoutmsg, colresize +0.2"
              "SUPER, minus, layoutmsg, colresize -0.2"

              # Hyprscrolling Extras
              "SUPER, P, layoutmsg, promote" # Promote window to its own column
              "SUPER CTRL, period, layoutmsg, swapcol r" # Swap column right
              "SUPER CTRL, comma, layoutmsg, swapcol l" # Swap column left
              "SUPER SHIFT, H, layoutmsg, swapcol l"
              "SUPER SHIFT, L, layoutmsg, swapcol r"
              "SUPER SHIFT, J, movewindow, d"
              "SUPER SHIFT, K, movewindow, u"
              "SUPER, M, layoutmsg, togglefit" # Toggle between fit and center alignment

              # ===========================================================================
              # Numpad "Stream Deck" - Media, System & Apps Control
              # ===========================================================================

              # Row 1: Media Control
              "SUPER, KP_Home, exec, playerctl previous" # 7: Prev Track
              "SUPER, KP_Up, exec, playerctl play-pause" # 8: Play/Pause
              "SUPER, KP_Page_Up, exec, playerctl next" # 9: Next Track

              # Row 2: Audio & Mixer
              "SUPER, KP_Left, exec, pamixer --default-source -t" # 4: Mic Mute Toggle
              "SUPER, KP_Begin, exec, pamixer -t" # 5: Audio Mute Toggle
              "SUPER, KP_Right, exec, pavucontrol" # 6: Open Mixer

              # Row 3: Cool Power Tools
              "SUPER, KP_End, exec, walker -m clipboard" # 1: Clipboard History
              "SUPER, KP_Down, exec, grim -g \"$(slurp)\" - | tesseract - - | wl-copy" # 2: OCR (Select area -> Text to clipboard)
              "SUPER, KP_Next, layoutmsg, fit all" # 3: Fit All Columns (Overview)

              # Row 4: Toggles
              "SUPER, KP_Insert, exec, pkill -USR1 wlsunset" # 0: Toggle Night Light
              "SUPER, KP_Delete, exec, makoctl mode -t dnd" # .: Toggle Do Not Disturb

              # Side Column: Zoom & Utilities
              "SUPER, KP_Add, exec, hyprctl keyword misc:cursor_zoom_factor 2.0" # +: Zoom In
              "SUPER, KP_Subtract, exec, hyprctl keyword misc:cursor_zoom_factor 1.0" # -: Zoom Reset
              "SUPER, KP_Enter, exec, grimblast copy area" # Enter: Screenshot Region

              # Top Bar
              "SUPER, KP_Divide, exec, hyprpicker -a" # /: Color Picker
              "SUPER, KP_Multiply, exec, loginctl lock-session" # *: Lock Screen

              # Focus
              "SUPER, LEFT, movefocus, l"
              "SUPER, RIGHT, movefocus, r"
              "SUPER, UP, movefocus, u"
              "SUPER, DOWN, movefocus, d"
              "SUPER, H, movefocus, l"
              "SUPER, L, movefocus, r"
              "SUPER, J, movefocus, d"
              "SUPER, K, movefocus, u"

              # Move workspace to monitor
              "SUPER CTRL, L, movecurrentworkspacetomonitor, +1"
              "SUPER CTRL, H, movecurrentworkspacetomonitor, -1"

              # Move to workspace
              "SUPER, 1, workspace, 1"
              "SUPER, 2, workspace, 2"
              "SUPER, 3, workspace, 3"
              "SUPER, 4, workspace, 4"
              "SUPER, 5, workspace, 5"
              "SUPER, 6, workspace, 6"
              "SUPER, 7, workspace, 7"
              "SUPER, 8, workspace, 8"
              "SUPER, 9, workspace, 9"
              "SUPER, 0, workspace, 10"

              # Move active window to workspace
              "SUPER SHIFT, 1, movetoworkspace, 1"
              "SUPER SHIFT, 2, movetoworkspace, 2"
              "SUPER SHIFT, 3, movetoworkspace, 3"
              "SUPER SHIFT, 4, movetoworkspace, 4"
              "SUPER SHIFT, 5, movetoworkspace, 5"
              "SUPER SHIFT, 6, movetoworkspace, 6"
              "SUPER SHIFT, 7, movetoworkspace, 7"
              "SUPER SHIFT, 8, movetoworkspace, 8"
              "SUPER SHIFT, 9, movetoworkspace, 9"
              "SUPER SHIFT, 0, movetoworkspace, 10"

              # Group Navigation
              "SUPER ALT, LEFT, moveintogroup, l"
              "SUPER ALT, RIGHT, moveintogroup, r"
              "SUPER ALT, UP, moveintogroup, u"
              "SUPER ALT, DOWN, moveintogroup, d"
              "SUPER ALT, TAB, changegroupactive, f"

              ", PRINT, exec, grimblast copy area"
              "SHIFT, PRINT, exec, grimblast copy screen"
            ];

            binde = [
              "SUPER SHIFT, equal, resizeactive, 0 -20"
              "SUPER SHIFT, minus, resizeactive, 0 20"
            ];

            bindel = [
              ",XF86AudioRaiseVolume, exec, $osdclient --output-volume raise"
              ",XF86AudioLowerVolume, exec, $osdclient --output-volume lower"
              ",XF86AudioMute, exec, $osdclient --output-volume mute-toggle"
              ",XF86AudioMicMute, exec, $osdclient --input-volume mute-toggle"
              ",XF86MonBrightnessUp, exec, $osdclient --brightness raise"
              ",XF86MonBrightnessDown, exec, $osdclient --brightness lower"
              "ALT, XF86AudioRaiseVolume, exec, $osdclient --output-volume +1"
              "ALT, XF86AudioLowerVolume, exec, $osdclient --output-volume -1"
            ];

            bindl = [
              ", XF86AudioNext, exec, $osdclient --playerctl next"
              ", XF86AudioPause, exec, $osdclient --playerctl play-pause"
              ", XF86AudioPlay, exec, $osdclient --playerctl play-pause"
              ", XF86AudioPrev, exec, $osdclient --playerctl previous"
            ];

            bindm = [
              "SUPER, mouse:272, movewindow"
              "SUPER, mouse:273, resizewindow"
            ];
          };
        };
      };
}
