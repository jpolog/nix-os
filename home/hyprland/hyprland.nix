{ config, pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    
    # Enable Hyprland plugins
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprscroller
    ];
    
    settings = {
      # Plugin configuration
      plugin = {
        # Hyprscroller - available on all workspaces
        scroller = {
          column_default_width = "onehalf";
          focus_wrap = false;
          # Make it work on all workspaces
          monitor = "";
        };
      };
      
      # Monitor configuration
      monitor = [
        "eDP-1,2880x1800@90,0x0,1.5"
        ",preferred,auto,1"
      ];
      
      # Workspace configuration
      workspace = [
        "1, monitor:eDP-1, default:true"
        "2, monitor:eDP-1"
        "3, monitor:eDP-1"
        "4, monitor:eDP-1"
        "5, monitor:eDP-1"
        "6, monitor:eDP-1"
        "7, monitor:eDP-1"
        "8, monitor:eDP-1"
        "9, monitor:eDP-1"
      ];
      
      # Execute at launch
      exec-once = [
        "waybar"
        "mako"
        "hypridle"
        "hyprpaper"
        "nm-applet --indicator"
        "blueman-applet"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];
      
      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "MOZ_ENABLE_WAYLAND,1"
        "GDK_BACKEND,wayland,x11"
      ];
      
      # Input configuration
      input = {
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "";
        kb_rules = "";
        
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
      
      # Gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_forever = false;
      };
      
      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        
        # Catppuccin Mocha colors
        "col.active_border" = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(313244aa)";
        
        layout = "scroller";  # Use hyprscroller
        allow_tearing = false;
      };
      
      # Decoration
      decoration = {
        rounding = 8;
        
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        fullscreen_opacity = 1.0;
        
        drop_shadow = true;
        shadow_range = 20;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
        
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          xray = false;
          ignore_opacity = false;
          noise = 0.0117;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
          popups = true;
          popups_ignorealpha = 0.2;
        };
      };
      
      # Animations
      animations = {
        enabled = true;
        
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
          "linear, 0.0, 0.0, 1.0, 1.0"
        ];
        
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 180, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
          "specialWorkspace, 1, 5, wind, slidevert"
        ];
      };
      
      # Layout-specific settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = false;
        smart_resizing = true;
      };
      
      master = {
        new_is_master = true;
        new_on_top = false;
        mfact = 0.5;
      };
      
      # Miscellaneous
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        vrr = 1;
        enable_swallow = true;
        swallow_regex = "^(kitty)$";
        focus_on_activate = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        render_ahead_of_time = false;
        render_ahead_safezone = 1;
      };
      
      # XWayland
      xwayland = {
        force_zero_scaling = true;
      };
      
      # Bindings
      "$mod" = "SUPER";
      
      bind = [
        # Application launchers
        "$mod, Return, exec, kitty"
        "$mod, R, exec, walker"
        "$mod, E, exec, thunar"
        "$mod, B, exec, firefox"
        
        # Window management
        "$mod, Q, killactive"
        "$mod, F, fullscreen, 0"
        "$mod SHIFT, F, fullscreen, 1"
        "$mod, Space, togglefloating"
        "$mod, P, pseudo"
        "$mod, S, togglesplit"
        
        # Focus movement (vim keys)
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        
        # Move windows (vim keys)
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"
        
        # Hyprscroller specific bindings
        "$mod, bracketleft, scroller:movefocus, l"
        "$mod, bracketright, scroller:movefocus, r"
        "$mod SHIFT, bracketleft, scroller:movewindow, l"
        "$mod SHIFT, bracketright, scroller:movewindow, r"
        "$mod CTRL, bracketleft, scroller:setmode, row"
        "$mod CTRL, bracketright, scroller:setmode, col"
        "$mod, C, scroller:alignwindow, c"
        "$mod, M, scroller:alignwindow, m"
        
        # Workspace switching
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        
        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        
        # Special workspace (scratchpad)
        "$mod, grave, togglespecialworkspace, magic"
        "$mod SHIFT, grave, movetoworkspace, special:magic"
        
        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        
        # Screenshots
        ", Print, exec, grimblast copy area"
        "SHIFT, Print, exec, grimblast copy screen"
        "CTRL, Print, exec, grimblast save area ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
        
        # Screen lock
        "$mod, L, exec, hyprlock"
        
        # System controls
        "$mod SHIFT, Escape, exec, systemctl poweroff"
        "$mod SHIFT, R, exec, systemctl reboot"
        "$mod CTRL, L, exec, systemctl suspend"
        
        # Reload Hyprland
        "$mod SHIFT, C, exec, hyprctl reload"
        
        # Exit Hyprland
        "$mod SHIFT, Q, exit"
      ];
      
      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      
      # Repeat bindings for resize
      binde = [
        # Resize windows
        "$mod CTRL, h, resizeactive, -40 0"
        "$mod CTRL, l, resizeactive, 40 0"
        "$mod CTRL, k, resizeactive, 0 -40"
        "$mod CTRL, j, resizeactive, 0 40"
        
        # Volume control
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        
        # Brightness control
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];
      
      # Window rules
      windowrule = [
        "float, ^(pavucontrol)$"
        "float, ^(blueman-manager)$"
        "float, ^(nm-connection-editor)$"
        "float, ^(org.gnome.Calculator)$"
        "float, ^(qalculate-gtk)$"
        
        "opacity 0.95 0.95, ^(thunar)$"
        "opacity 0.95 0.95, ^(code)$"
        
        "workspace special:magic silent, ^(Spotify)$"
        "workspace special:magic silent, ^(discord)$"
      ];
      
      windowrulev2 = [
        "float, class:^(.*)(qalculate-gtk)(.*)$"
        "size 800 600, class:^(.*)(qalculate-gtk)(.*)$"
        "center, class:^(.*)(qalculate-gtk)(.*)$"
        
        "opacity 0.0 override 0.0 override, class:^(xwaylandvideobridge)$"
        "noanim, class:^(xwaylandvideobridge)$"
        "nofocus, class:^(xwaylandvideobridge)$"
        "noinitialfocus, class:^(xwaylandvideobridge)$"
        
        # Picture-in-picture
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"
        "size 640 360, title:^(Picture-in-Picture)$"
        "move 1230 690, title:^(Picture-in-Picture)$"
      ];
    };
  };
}
