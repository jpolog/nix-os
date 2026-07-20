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
            TERMINAL_REGEX="^(kitty|Alacritty|foot|org.wezfurlong.wezterm|wezterm|WezTerm)$"

            if [[ "$CLASS" =~ $TERMINAL_REGEX ]]; then
              # Terminal copy shortcut
              ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.send_shortcut({ mods = 'CTRL SHIFT', key = 'C', window = 'address:$ADDR' }))"
            else
              ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.send_shortcut({ mods = 'CTRL', key = 'C', window = 'address:$ADDR' }))"
            fi
          '')

          (pkgs.writeShellScriptBin "universal-paste" ''
            INFO=$(${pkgs.hyprland}/bin/hyprctl activewindow -j)
            CLASS=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r ".class")
            ADDR=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r ".address")
            TERMINAL_REGEX="^(kitty|Alacritty|foot|org.wezfurlong.wezterm|wezterm|WezTerm)$"

            if [[ "$CLASS" =~ $TERMINAL_REGEX ]]; then
              # Terminal paste shortcut
              ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.send_shortcut({ mods = 'CTRL SHIFT', key = 'V', window = 'address:$ADDR' }))"
            else
              ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.send_shortcut({ mods = 'CTRL', key = 'V', window = 'address:$ADDR' }))"
            fi
          '')

          (pkgs.writeShellScriptBin "toggle-transparency" ''
            ACTIVE_OPACITY=$(${pkgs.hyprland}/bin/hyprctl getoption decoration:active_opacity | ${pkgs.gawk}/bin/awk '/float/ {print $2}')
            IS_OPAQUE=$(${pkgs.gawk}/bin/awk -v active_opacity="$ACTIVE_OPACITY" 'BEGIN {print (active_opacity >= 1.0)}')
            if [ "$IS_OPAQUE" = "1" ]; then
              if [ -f /tmp/hypr_opacity_active ]; then
                read -r PREV_ACTIVE < /tmp/hypr_opacity_active
                read -r PREV_INACTIVE < /tmp/hypr_opacity_inactive
              else
                PREV_ACTIVE=0.9
                PREV_INACTIVE=0.8
              fi
              ${pkgs.hyprland}/bin/hyprctl eval "hl.config({ decoration = { active_opacity = $PREV_ACTIVE, inactive_opacity = $PREV_INACTIVE } })"
            else
              INACTIVE_OPACITY=$(${pkgs.hyprland}/bin/hyprctl getoption decoration:inactive_opacity | ${pkgs.gawk}/bin/awk '/float/ {print $2}')
              echo "$ACTIVE_OPACITY" > /tmp/hypr_opacity_active
              echo "$INACTIVE_OPACITY" > /tmp/hypr_opacity_inactive
              ${pkgs.hyprland}/bin/hyprctl eval "hl.config({ decoration = { active_opacity = 1.0, inactive_opacity = 1.0 } })"
            fi
          '')

          (pkgs.writeShellScriptBin "focus-obsidian" ''
            ADDR=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r '[.[] | select(.class == "obsidian")] | sort_by(.focusHistoryID) | .[0].address')

            if [ "$ADDR" != "null" ] && [ -n "$ADDR" ]; then
               ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.focuswindow('address:$ADDR'))"
            else
               obsidian
            fi
          '')

          (pkgs.writeShellScriptBin "walker-launcher" ''
            ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.submap('walker'))"
            ${pkgs.walker}/bin/walker
            ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.submap('reset'))"
          '')

          (pkgs.writeShellScriptBin "smart-resize" ''
            ORIENTATION=$1 # "h" or "v"
            DIRECTION=$2   # "up" or "down" (grow/shrink)
            MODE=$3        # "normal" or "fine"

            if [ "$MODE" = "fine" ]; then
              PX_STEP=20
              TIL_STEP=0.02
            else
              PX_STEP=100
              TIL_STEP=0.1
            fi

            IS_FLOATING=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.floating')

            if [ "$IS_FLOATING" = "true" ]; then
              if [ "$ORIENTATION" = "h" ]; then
                [ "$DIRECTION" = "up" ] && ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.resizeactive('$PX_STEP 0'))" || ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.resizeactive('-$PX_STEP 0'))"
              else
                [ "$DIRECTION" = "up" ] && ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.resizeactive('0 $PX_STEP'))" || ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.resizeactive('0 -$PX_STEP'))"
              fi
            else
              if [ "$ORIENTATION" = "h" ]; then
                [ "$DIRECTION" = "up" ] && ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.layout('colresize +$TIL_STEP'))" || ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.layout('colresize -$TIL_STEP'))"
              else
                [ "$DIRECTION" = "up" ] && ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.resizeactive('0 $PX_STEP'))" || ${pkgs.hyprland}/bin/hyprctl eval "hl.dispatch(hl.dsp.resizeactive('0 -$PX_STEP'))"
              fi
            fi
          '')
        ];

        services.cliphist = {
          enable = true;
          allowImages = true;
        };

        wayland.windowManager.hyprland = {
          enable = true;
          package = null;
          configType = "lua";

          # Prevent other modules from injecting settings that generate invalid Lua
          # (e.g. hl.exec-once with hyphens, hl.input which doesn't exist).
          # Everything is handled in extraConfig below.
          settings = lib.mkForce {};

          extraConfig = ''
            local mainMod = "SUPER"

            -- Variables
            local terminal = "kitty"
            local browser = "firefox"
            local osdclient = "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')\""

            -- Environment variables
            hl.env("XCURSOR_SIZE", "18")
            hl.env("HYPRCURSOR_SIZE", "18")
            hl.env("GDK_BACKEND", "wayland,x11,*")
            hl.env("QT_QPA_PLATFORM", "wayland;xcb")
            hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
            hl.env("SDL_VIDEODRIVER", "wayland")
            hl.env("MOZ_ENABLE_WAYLAND", "1")
            hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
            hl.env("OZONE_PLATFORM", "wayland")
            hl.env("XDG_SESSION_TYPE", "wayland")
            hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
            hl.env("XDG_SESSION_DESKTOP", "Hyprland")
            hl.env("XCOMPOSEFILE", os.getenv("HOME") .. "/.XCompose")
            hl.env("GUM_CONFIRM_PROMPT_FOREGROUND", "6")
            hl.env("GUM_CONFIRM_SELECTED_FOREGROUND", "0")
            hl.env("GUM_CONFIRM_SELECTED_BACKGROUND", "2")
            hl.env("GUM_CONFIRM_UNSELECTED_FOREGROUND", "0")
            hl.env("GUM_CONFIRM_UNSELECTED_BACKGROUND", "8")

            -- Monitors
            hl.monitor({ output = "eDP-1",   mode = "1920x1200@60", position = "0x0",    scale = 1 })
            hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "1920x0", scale = 1 })
            hl.monitor({ output = "DP-1",     mode = "1920x1080@60", position = "3840x0", scale = 1, transform = 1 })
            hl.monitor({ output = "",          mode = "preferred",    position = "auto",   scale = 1 })

            -- General configuration
            hl.config({
              general = {
                gaps_in = 5,
                gaps_out = 10,
                border_size = 2,
                resize_on_border = false,
                allow_tearing = false,
                layout = "scrolling",
              },

              scrolling = {
                column_width = 0.75,
                fullscreen_on_one_column = false,
                focus_fit_method = 1,
                follow_focus = true,
                direction = "right",
                wrap_focus = true,
                wrap_swapcol = true,
                explicit_column_widths = "0.5 0.33 0.75",
              },

              gestures = {
                workspace_swipe_distance = 300,
                workspace_swipe_cancel_ratio = 0.5,
                workspace_swipe_create_new = true,
                workspace_swipe_direction_lock = true,
                workspace_swipe_forever = false,
              },

              decoration = {
                rounding = 3,
                active_opacity = 0.9,
                inactive_opacity = 0.8,

                shadow = {
                  enabled = true,
                  range = 2,
                  render_power = 3,
                },

                blur = {
                  enabled = true,
                  size = 2,
                  passes = 2,
                  special = true,
                  brightness = 0.60,
                  contrast = 0.75,
                },
              },

              animations = {
                enabled = true,
              },

              input = {
                kb_layout = "us,es",
                kb_options = "altwin:swap_alt_win,grp:alt_shift_toggle,compose:caps",
                numlock_by_default = true,
                repeat_rate = 40,
                repeat_delay = 600,
                touchpad = {
                  natural_scroll = false,
                  tap_to_click = true,
                  disable_while_typing = true,
                  scroll_factor = 0.4,
                },
                sensitivity = 0,
                mouse_refocus = false,
              },

              misc = {
                disable_hyprland_logo = true,
                disable_splash_rendering = true,
                focus_on_activate = true,
                key_press_enables_dpms = true,
                mouse_move_enables_dpms = true,
                anr_missed_pings = 3,
              },

              group = {
                groupbar = {
                  height = 22,
                },
              },
            })

            -- Animation curves
            hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
            hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
            hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
            hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
            hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

            -- Animations
            hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
            hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
            hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, bezier = "easeOutQuint" })
            hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
            hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
            hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
            hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
            hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
            hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
            hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
            hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
            hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
            hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
            hl.animation({ leaf = "workspaces",    enabled = false, speed = 0,    bezier = "default" })

            -- Window rules
            hl.window_rule({ name = "floating",          match = { class = "^(floating)$" },                  float = true })
            hl.window_rule({ name = "zoom-menu-pin",  match = { class = "zoom", title = "menu window" },  pin = true })
            hl.window_rule({ name = "zoom-ws4",          match = { class = "^(zoom)$" },                     workspace = "4" })
            hl.window_rule({ name = "discord-ws4",       match = { class = "^(discord)$" },                  workspace = "4" })
            hl.window_rule({ name = "teams-ws4",         match = { class = "^(teams-for-linux)$" },          workspace = "4" })
            hl.window_rule({ name = "whatsapp-ws4",      match = { class = "^(chrome-web.whatsapp.com.*)$" },workspace = "4" })
            hl.window_rule({ name = "obsidian-ws10",     match = { class = "^(obsidian)$" },                 workspace = "10" })

            -- Initial class rules (for window placement on startup)
            -- (Removed because initialClass is unsupported by the Lua parser and redundant with the class rules above)

            -- Suppress maximize requests from apps (prevents apps from forcing fullscreen)
            hl.window_rule({
              name  = "suppress-maximize-events",
              match = { class = ".*" },
              suppress_event = "maximize",
            })

            -- Fix XWayland drag issues (ghost windows with no class/title)
            hl.window_rule({
              name  = "fix-xwayland-drags",
              match = {
                class      = "^$",
                title      = "^$",
                xwayland   = true,
                float      = true,
                fullscreen = false,
                pin        = false,
              },
              no_focus = true,
            })

            -- Autostart
            -- Note: hypridle and mako are managed by systemd (services.hypridle / services.mako),
            -- so they are NOT launched here to avoid duplicate instances.
            hl.on("hyprland.start", function()
              hl.exec_cmd("fcitx5 &")
              hl.exec_cmd("swayosd-server &")
              hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &")
              hl.exec_cmd("nm-applet --indicator &")
              hl.exec_cmd("blueman-applet &")
              hl.exec_cmd("systemctl --user start noctalia &")
              hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &")
              hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &")
            end)

            -- Touchpad gesture: 3-finger horizontal swipe to switch workspaces
            hl.gesture({
              fingers = 3,
              direction = "horizontal",
              action = "workspace",
            })

            -- Dynamic column width: single window = 0.75 centered, multiple = 0.5 each
            local function adjust_column_width()
              local ws = hl.get_active_workspace()
              if ws then
                if ws.windows <= 1 then
                  hl.config({ scrolling = { column_width = 0.75 } })
                else
                  hl.config({ scrolling = { column_width = 0.5 } })
                end
              end
            end

            hl.on("window.open", adjust_column_width)
            hl.on("window.close", adjust_column_width)
            hl.on("window.move_to_workspace", adjust_column_width)
            hl.on("workspace.active", adjust_column_width)

            -- Bindings
            local dsp = hl.dsp

            -- Apps
            hl.bind(mainMod .. " + Return",   dsp.exec_cmd(terminal))
            hl.bind(mainMod .. " + Y",        dsp.exec_cmd(terminal .. " --class floating -e tmux-sessionizer"))
            hl.bind(mainMod .. " + SHIFT + F", dsp.exec_cmd("dolphin"))
            hl.bind(mainMod .. " + B",        dsp.exec_cmd(browser))
            hl.bind(mainMod .. " + ALT + B",  dsp.exec_cmd(browser .. " --private"))
            hl.bind(mainMod .. " + D",        dsp.exec_cmd(terminal .. " -e lazydocker"))
            hl.bind(mainMod .. " + SHIFT + T", dsp.exec_cmd(terminal .. " -e btop"))
            hl.bind(mainMod .. " + O",        dsp.exec_cmd("focus-obsidian"))
            hl.bind(mainMod .. " + A",        dsp.exec_cmd("gtk-launch perplexity"))

            -- Web Apps
            hl.bind(mainMod .. " + SHIFT + E", dsp.exec_cmd("gtk-launch outlook"))
            hl.bind(mainMod .. " + SHIFT + G", dsp.exec_cmd("gtk-launch github"))

            -- Menus
            hl.bind(mainMod .. " + space",     dsp.exec_cmd("walker-launcher"))
            hl.bind(mainMod .. " + N",         dsp.exec_cmd("noctalia ipc call controlCenter toggle"))
            hl.bind(mainMod .. " + SHIFT + P", dsp.exec_cmd("power-profile-menu"))
            hl.bind(mainMod .. " + ALT + space", dsp.exec_cmd("kitty --class floating -e nix-search"))
            hl.bind(mainMod .. " + Escape",    dsp.exec_cmd("noctalia ipc call sessionMenu toggle"))

            -- Lock
            hl.bind(mainMod .. " + CTRL + SHIFT + L",       dsp.exec_cmd("loginctl lock-session && sleep 1 && hyprctl eval \"hl.dispatch(hl.dsp.dpms('off'))\""))

            -- Toggle Transparency
            hl.bind(mainMod .. " + BackSpace", dsp.exec_cmd("toggle-transparency"))

            -- Clipboard
            hl.bind(mainMod .. " + C",        dsp.exec_cmd("universal-copy"))
            hl.bind(mainMod .. " + V",        dsp.exec_cmd("universal-paste"))
            hl.bind(mainMod .. " + X",        dsp.send_shortcut({ mods = "CTRL", key = "X" }))
            hl.bind(mainMod .. " + CTRL + V", dsp.exec_cmd("walker -m clipboard"))

            -- Window Management
            hl.bind(mainMod .. " + W",        dsp.window.close())
            hl.bind("CTRL + ALT + Delete",    dsp.exit())
            hl.bind(mainMod .. " + T",        dsp.window.float({ action = "toggle" }))
            hl.bind(mainMod .. " + F",        dsp.window.fullscreen(0))
            hl.bind(mainMod .. " + ALT + F",  dsp.window.fullscreen(1))

            -- Scrolling Layout
            hl.bind(mainMod .. " + period",    dsp.layout("move +col"))
            hl.bind(mainMod .. " + comma",     dsp.layout("move -col"))
            hl.bind(mainMod .. " + R",         dsp.layout("setmode toggle"))
            hl.bind(mainMod .. " + P",         dsp.layout("promote"))
            hl.bind(mainMod .. " + SHIFT + H",  dsp.layout("swapcol l"))
            hl.bind(mainMod .. " + SHIFT + L",  dsp.layout("swapcol r"))
            hl.bind(mainMod .. " + CTRL + period", dsp.layout("swapcol r"))
            hl.bind(mainMod .. " + CTRL + comma",  dsp.layout("swapcol l"))
            hl.bind(mainMod .. " + SHIFT + J", dsp.window.move({ direction = "down" }))
            hl.bind(mainMod .. " + SHIFT + K", dsp.window.move({ direction = "up" }))
            hl.bind(mainMod .. " + M",         dsp.layout("togglefit"))

            -- Workspace Management
            hl.bind(mainMod .. " + S",         dsp.workspace.toggle_special("magic"))
            hl.bind(mainMod .. " + SHIFT + S", dsp.window.move({ workspace = "special:magic" }))

            for i = 1, 9 do
              hl.bind(mainMod .. " + " .. i,             dsp.focus({ workspace = i }))
              hl.bind(mainMod .. " + SHIFT + " .. i,     dsp.window.move({ workspace = i }))
            end
            hl.bind(mainMod .. " + 0",         dsp.focus({ workspace = 10 }))
            hl.bind(mainMod .. " + SHIFT + 0", dsp.window.move({ workspace = 10 }))

            -- Focus (arrow keys)
            hl.bind(mainMod .. " + left",  dsp.focus({ direction = "left" }))
            hl.bind(mainMod .. " + right", dsp.focus({ direction = "right" }))
            hl.bind(mainMod .. " + up",    dsp.focus({ direction = "up" }))
            hl.bind(mainMod .. " + down",  dsp.focus({ direction = "down" }))

            -- Focus (vim keys)
            hl.bind(mainMod .. " + H", dsp.focus({ direction = "left" }))
            hl.bind(mainMod .. " + L", dsp.focus({ direction = "right" }))
            hl.bind(mainMod .. " + K", dsp.focus({ direction = "up" }))
            hl.bind(mainMod .. " + J", dsp.focus({ direction = "down" }))

            -- Move workspace to monitor
            hl.bind(mainMod .. " + CTRL + L", dsp.workspace.move({ monitor = "+1" }))
            hl.bind(mainMod .. " + CTRL + H", dsp.workspace.move({ monitor = "-1" }))

            -- Resize (repeating)
            hl.bind(mainMod .. " + equal",                  dsp.exec_cmd("smart-resize h up normal"),   { repeating = true })
            hl.bind(mainMod .. " + minus",                  dsp.exec_cmd("smart-resize h down normal"), { repeating = true })
            hl.bind(mainMod .. " + ALT + equal",            dsp.exec_cmd("smart-resize h up fine"),     { repeating = true })
            hl.bind(mainMod .. " + ALT + minus",            dsp.exec_cmd("smart-resize h down fine"),   { repeating = true })
            hl.bind(mainMod .. " + SHIFT + equal",          dsp.exec_cmd("smart-resize v up normal"),   { repeating = true })
            hl.bind(mainMod .. " + SHIFT + minus",          dsp.exec_cmd("smart-resize v down normal"), { repeating = true })
            hl.bind(mainMod .. " + SHIFT + ALT + equal",    dsp.exec_cmd("smart-resize v up fine"),     { repeating = true })
            hl.bind(mainMod .. " + SHIFT + ALT + minus",    dsp.exec_cmd("smart-resize v down fine"),   { repeating = true })

            -- Numpad "Stream Deck"
            hl.bind(mainMod .. " + KP_Home",     dsp.exec_cmd("playerctl previous"))
            hl.bind(mainMod .. " + KP_Up",       dsp.exec_cmd("playerctl play-pause"))
            hl.bind(mainMod .. " + KP_Page_Up",  dsp.exec_cmd("playerctl next"))
            hl.bind(mainMod .. " + KP_Left",     dsp.exec_cmd("pamixer --default-source -t"))
            hl.bind(mainMod .. " + KP_Begin",    dsp.exec_cmd("pamixer -t"))
            hl.bind(mainMod .. " + KP_Right",    dsp.exec_cmd("pavucontrol"))
            hl.bind(mainMod .. " + KP_End",      dsp.exec_cmd("walker -m clipboard"))
            hl.bind(mainMod .. " + KP_Down",     dsp.exec_cmd("grim -g \"$(slurp)\" - | tesseract - - | wl-copy"))
            hl.bind(mainMod .. " + KP_Next",     dsp.layout("fit all"))
            hl.bind(mainMod .. " + KP_Insert",   dsp.exec_cmd("systemctl --user is-active --quiet hyprsunset && systemctl --user stop hyprsunset || systemctl --user start hyprsunset"))
            hl.bind(mainMod .. " + KP_Delete",   dsp.exec_cmd("makoctl mode -t dnd"))
            hl.bind(mainMod .. " + KP_Add",      dsp.exec_cmd("hyprctl keyword misc:cursor_zoom_factor 2.0"))
            hl.bind(mainMod .. " + KP_Subtract", dsp.exec_cmd("hyprctl keyword misc:cursor_zoom_factor 1.0"))
            hl.bind(mainMod .. " + KP_Enter",    dsp.exec_cmd("grimblast copy area"))
            hl.bind(mainMod .. " + KP_Divide",   dsp.exec_cmd("hyprpicker -a"))
            hl.bind(mainMod .. " + KP_Multiply", dsp.exec_cmd("loginctl lock-session"))

            -- Group Navigation (move window into group)
            hl.bind(mainMod .. " + ALT + left",  dsp.group.move_window({ direction = "left" }))
            hl.bind(mainMod .. " + ALT + right", dsp.group.move_window({ direction = "right" }))
            hl.bind(mainMod .. " + ALT + up",    dsp.group.move_window({ direction = "up" }))
            hl.bind(mainMod .. " + ALT + down",  dsp.group.move_window({ direction = "down" }))
            hl.bind(mainMod .. " + ALT + Tab",   dsp.group.next())

            -- Media Keys (locked + repeating = work on lockscreen, repeat on hold)
            hl.bind("XF86AudioRaiseVolume",      dsp.exec_cmd("pamixer -i 5; " .. osdclient .. " --output-volume raise"),          { locked = true, repeating = true })
            hl.bind("XF86AudioLowerVolume",      dsp.exec_cmd("pamixer -d 5; " .. osdclient .. " --output-volume lower"),          { locked = true, repeating = true })
            hl.bind("XF86AudioMute",             dsp.exec_cmd("pamixer -t; " .. osdclient .. " --output-volume mute-toggle"),      { locked = true, repeating = true })
            hl.bind("XF86AudioMicMute",          dsp.exec_cmd("pamixer --default-source -t; " .. osdclient .. " --input-volume mute-toggle"), { locked = true, repeating = true })
            hl.bind("XF86MonBrightnessUp",       dsp.exec_cmd("brightnessctl set +5%; " .. osdclient .. " --brightness raise"),    { locked = true, repeating = true })
            hl.bind("XF86MonBrightnessDown",     dsp.exec_cmd("brightnessctl set 5%-; " .. osdclient .. " --brightness lower"),    { locked = true, repeating = true })
            hl.bind("ALT + XF86AudioRaiseVolume", dsp.exec_cmd("pamixer -i 1; " .. osdclient .. " --output-volume +1"),            { locked = true, repeating = true })
            hl.bind("ALT + XF86AudioLowerVolume", dsp.exec_cmd("pamixer -d 1; " .. osdclient .. " --output-volume -1"),            { locked = true, repeating = true })

            -- Media Playback (locked = work on lockscreen)
            hl.bind("XF86AudioNext",  dsp.exec_cmd(osdclient .. " --playerctl next"),       { locked = true })
            hl.bind("XF86AudioPause", dsp.exec_cmd(osdclient .. " --playerctl play-pause"), { locked = true })
            hl.bind("XF86AudioPlay",  dsp.exec_cmd(osdclient .. " --playerctl play-pause"), { locked = true })
            hl.bind("XF86AudioPrev",  dsp.exec_cmd(osdclient .. " --playerctl previous"),   { locked = true })

            -- Screenshots
            hl.bind("Print",         dsp.exec_cmd("grimblast copy area"))
            hl.bind("SHIFT + Print", dsp.exec_cmd("grimblast copy screen"))

            -- Mouse binds
            hl.bind(mainMod .. " + mouse:272", dsp.window.drag(),   { mouse = true })
            hl.bind(mainMod .. " + mouse:273", dsp.window.resize(), { mouse = true })

            -- Walker Submap
            hl.define_submap("walker", function()
              hl.bind("ALT + Q", dsp.send_shortcut({ mods = "", key = "F1" }))
              hl.bind("ALT + W", dsp.send_shortcut({ mods = "", key = "F2" }))
              hl.bind("ALT + E", dsp.send_shortcut({ mods = "", key = "F3" }))
              hl.bind("ALT + R", dsp.send_shortcut({ mods = "", key = "F4" }))
              hl.bind("ALT + T", dsp.send_shortcut({ mods = "", key = "F5" }))
              hl.bind("ALT + Y", dsp.send_shortcut({ mods = "", key = "F6" }))
              hl.bind("ALT + U", dsp.send_shortcut({ mods = "", key = "F7" }))
              hl.bind("ALT + I", dsp.send_shortcut({ mods = "", key = "F8" }))
              hl.bind("ALT + O", dsp.send_shortcut({ mods = "", key = "F9" }))
              hl.bind("ALT + P", dsp.send_shortcut({ mods = "", key = "F10" }))
              hl.bind("ALT + A", dsp.send_shortcut({ mods = "", key = "F11" }))
              hl.bind("ALT + S", dsp.send_shortcut({ mods = "", key = "F12" }))
            end)
          '';
        };
      };
}
