{ config, pkgs, lib, ... }:

with lib;

let
  # Unified Tmux Sessionizer (ThePrimeagen + Active Sessions)
  tmux-sessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
    #!/usr/bin/env bash

    # 1. Gather all potential project paths
    projects=$( (
        find "$HOME/Projects" -mindepth 1 -maxdepth 3 -type d -not -path '*/.*' 2>/dev/null
        find "$HOME/Documents" -mindepth 1 -maxdepth 2 -type d -not -path '*/.*' 2>/dev/null
        echo "$HOME/.config/nixos"
        echo "$HOME"
    ) | grep -vE "/(node_modules|target|.git|dist|build|venv|.direnv|__pycache__)(/|$)" )

    # 2. Gather active sessions
    active_sessions=$(tmux list-sessions -F "#S" 2>/dev/null)

    # 3. Combine them for fzf
    # We add a visual indicator for active sessions
    all_targets=$( (
        while read -r s; do
            [ -n "$s" ] && echo "[ACTIVE] $s"
        done <<< "$active_sessions"
        echo "$projects"
    ) | sort -u )

    if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(echo "$all_targets" | fzf --header="Select Project or Active Session")
    fi

    if [[ -z $selected ]]; then
        exit 0
    fi

    # Handle the [ACTIVE] prefix if present
    if [[ "$selected" =~ ^\[ACTIVE\]\  ]]; then
        selected_name=$(echo "$selected" | sed 's/^\[ACTIVE\] //')
        # For active sessions, we don't need a path, we just attach/switch
        if [[ -z $TMUX ]]; then
            tmux attach-session -t "$selected_name"
        else
            tmux switch-client -t "$selected_name"
        fi
        exit 0
    fi

    # Standard path-based logic
    selected_name=$(basename "$selected" | tr . _)
    tmux_running=$(pgrep tmux)

    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s "$selected_name" -c "$selected"
        exit 0
    fi

    if ! tmux has-session -t="$selected_name" 2> /dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected"
    fi

    if [[ -z $TMUX ]]; then
        tmux attach-session -t "$selected_name"
    else
        tmux switch-client -t "$selected_name"
    fi
  '';

  # Power user kill session tool
  tmux-killer = pkgs.writeShellScriptBin "tmux-killer" ''
    #!/usr/bin/env bash
    if [[ $# -eq 1 ]]; then
        session=$1
    else
        session=$(tmux list-sessions -F "#S" 2>/dev/null | fzf --header="Kill Tmux Session")
    fi

    if [[ -n "$session" ]]; then
        # Check if it's the current session
        current_session=$(tmux display-message -p '#S' 2>/dev/null)
        if [[ "$session" == "$current_session" ]]; then
            echo "You are currently in '$session'. Switch to another session first."
            exit 1
        fi
        
        tmux kill-session -t "$session"
        echo "Killed session: $session"
    fi
  '';

  ts-tools = pkgs.writeShellScriptBin "ts-tools" ''
    #!/usr/bin/env bash
    if ! tmux has-session -t="ai" 2>/dev/null; then
        tmux new-session -d -s "ai" -n "claude" -c "$HOME"
        tmux send-keys -t "ai:claude" "claude" C-m
        echo "Started AI session"
    fi
    if ! tmux has-session -t="system" 2>/dev/null; then
        tmux new-session -d -s "system" -n "monitor" -c "$HOME"
        tmux send-keys -t "system:monitor" "btop" C-m
        echo "Started System session"
    fi
  '';
in
{
  config = mkIf config.home.profiles.cli.enable {
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      historyLimit = 100000;
      keyMode = "vi";
      baseIndex = 1;
      mouse = true;
      
      plugins = with pkgs.tmuxPlugins; [
        resurrect
        continuum
        yank
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavor 'mocha'
            
            # Window styling
            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator " "
            set -g @catppuccin_window_middle_separator " █"
            set -g @catppuccin_window_number_position "right"
            
            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W" # Show window name
            
            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W" # Show window name
            
            # Status bar modules
            set -g @catppuccin_status_modules_right "directory session"
            set -g @catppuccin_status_left_separator  " "
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_right_separator_inverse "no"
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"
            
            # Module configurations
            set -g @catppuccin_directory_text "#{pane_current_path}"
            set -g @catppuccin_session_text "#S"

            # Re-enforce naming rules within plugin
            set -g allow-rename off
            setw -g allow-rename off
            set -g automatic-rename off
            setw -g automatic-rename off
          '';
        }
      ];

      extraConfig = ''
        # --- Environment & Memory Fixes ---
        set -g update-environment "DISPLAY SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION WINDOWID XAUTHORITY"
        set -g @resurrect-capture-pane-contents 'on'
        set -g @continuum-restore 'on'
        set -as terminal-features ",xterm-256color:RGB"

        # --- Window Management & Naming ---
        # Strictly disable all automatic renames from ANY source
        set -g allow-rename off
        set -g automatic-rename off
        setw -g allow-rename off
        setw -g automatic-rename off
        set -g automatic-rename-format ""
        
        # Disable terminal emulator title updates (can sometimes trigger renames)
        set -g set-titles off

        # --- Clipboard integration ---
        set -s set-clipboard on
        bind-key -n C-v run "tmux set-buffer \"$(wl-paste)\"; tmux paste-buffer"

        # --- Prefix & Navigation ---
        unbind C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        set -s escape-time 0
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind-key -r f run-shell "tmux neww tmux-sessionizer"
        
        # --- UI & Styling ---
        set -g base-index 1
        setw -g pane-base-index 1
        set -g renumber-windows on
        set -g status-position top
        
        # Pane borders
        set -g pane-border-style fg=#313244
        set -g pane-active-border-style fg=#89b4fa
        
        # Message style
        set -g message-style bg=#1e1e2e,fg=#cdd6f4
      '';
    };

    home.packages = [ 
      tmux-sessionizer 
      tmux-killer
      ts-tools
    ];
  };
}
