{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.cli.enable {
    # Tmux - Terminal multiplexer
    programs.tmux = {
      enable = true;
      
      terminal = "tmux-256color";
      historyLimit = 50000;
      keyMode = "vi";
      
      # Start windows and panes at 1, not 0
      baseIndex = 1;
      
      # Mouse support
      mouse = true;
      
      
      # Custom key bindings
      extraConfig = ''
        # Better prefix key
        unbind C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix
        
        # Split panes using | and -
        bind | split-window -h
        bind - split-window -v
        unbind '"'
        unbind %
        
        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
        
        # Vi mode keys
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        
        # Pane navigation with vim keys
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        
        # Pane resizing
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5
        
        # Enable RGB color
        set -ga terminal-overrides ",*256col*:Tc"
        
        # Faster command sequences
        set -s escape-time 0
        
        # Activity monitoring
        setw -g monitor-activity on
        set -g visual-activity off

        # renumber windows on close
        set-option -g renumber-windows on
        
        # Catppuccin theme
        set -g status-style bg=#1e1e2e,fg=#cdd6f4
        set -g pane-border-style fg=#313244
        set -g pane-active-border-style fg=#89b4fa
        set -g window-status-current-style fg=#89b4fa,bold
      '';
    };
    
    # Zellij - Modern terminal multiplexer (alternative to tmux)
    programs.zellij = {
      enable = true;
      
      settings = {
        theme = "catppuccin-mocha";
        default_shell = "zsh";
        pane_frames = false;
        
        # Keybindings mode
        keybinds = {
          normal = {
            "bind \"Alt h\"" = { MoveFocus = "Left"; };
            "bind \"Alt l\"" = { MoveFocus = "Right"; };
            "bind \"Alt j\"" = { MoveFocus = "Down"; };
            "bind \"Alt k\"" = { MoveFocus = "Up"; };
          };
        };
      };
    };
    
    # Atuin - Better shell history
    programs.atuin = {
      enable = true;
      
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "https://api.atuin.sh";
        search_mode = "fuzzy";
        filter_mode = "global";
        style = "compact";
        inline_height = 20;
        show_preview = true;
        
        # Keybindings
        keymap_mode = "vim-normal";
      };
    };
    
    # Direnv - Automatic environment loading
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      
      # Better prompt integration
      config = {
        global = {
          load_dotenv = true;
          strict_env = false;
        };
      };
    };
    
    # Zoxide - Smarter cd
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    
    # FZF - Fuzzy finder
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
        "--inline-info"
        "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
        "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
        "--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
      ];
      
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetOptions = [ "--preview 'bat --color=always --line-range :500 {}'" ];
      
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    };
    
    # Bat - Better cat
    programs.bat = {
      enable = true;
      config = {
        theme = "Catppuccin-mocha";
        style = "numbers,changes,header";
        pager = "less -FR";
      };
    };
    
    # Eza - Better ls
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--icons"
      ];
    };
    
    # Ripgrep - Better grep
    programs.ripgrep = {
      enable = true;
      
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--glob=!.git/*"
        "--glob=!node_modules/*"
        "--glob=!target/*"
        "--smart-case"
        "--hidden"
      ];
    };
    
    # Bottom - Better top
    programs.bottom = {
      enable = true;
      
      settings = {
        flags = {
          color = "default";
          mem_as_value = true;
          tree = true;
          group_processes = true;
          case_sensitive = false;
          whole_word = false;
          regex = false;
        };
        
        colors = {
          high_battery_color = "green";
          medium_battery_color = "yellow";
          low_battery_color = "red";
        };
      };
    };

    # Btop - Resource monitor (Matugen themed)
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "noctalia";
        theme_background = false;
        presets = "cpu:1:default,proc:0:default cpu:0:default,proc:0:default";
      };
    };

    # Alacritty - Terminal Emulator (Matugen themed)
    programs.alacritty = {
      enable = true;
      settings = {
        import = [ "${config.xdg.configHome}/alacritty/themes/noctalia.toml" ];
        
        font = {
          normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
          bold = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
          italic = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
          size = 11;
        };
        
        window = {
          opacity = 0.95;
          padding = { x = 5; y = 5; };
          dynamic_padding = true;
        };
      };
    };
  };
}
