{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.cli.enable {
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
        enter_accept = true;
        
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

    # Yazi - Terminal File Manager
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "yy";
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
          linemode = "size_mtime";
          ratio = [ 1 3 4 ];
        };
        status = {
          separator_open = "";
          separator_close = "";
          show_permissions = true;
        };
        opener = {
          view_image = [
            { run = ''imv "$@"''; desc = "View Image (imv)"; block = false; }
          ];
          edit_text = [
            { run = ''nvim "$@"''; desc = "Edit Text (nvim)"; block = true; }
          ];
        };
        open = {
          rules = [
            { mime = "image/*"; use = "view_image"; }
            { mime = "text/*"; use = "edit_text"; }
          ];
        };
      };
      keymap = {
        manager.prepend_keymap = [
          { on = [ "M" ]; run = "linemode"; desc = "Cycle linemode (size/mtime/permissions)"; }
          { on = [ "~" ]; run = "help"; desc = "Open help"; }
        ];
      };
    };

    # Custom Yazi Linemode: Size + Mtime
    xdg.configFile."yazi/init.lua".text = ''
      function Linemode:size_mtime()
        local time = os.date("%Y-%m-%d %H:%M", math.floor(self._file.cha.mtime or 0))
        local size = self._file:size()
        return ui.Line(string.format("%s | %s", size and ya.readable_size(size) or "-", time))
      end
    '';

    # Fastfetch - System information
    programs.fastfetch = {
      enable = true;
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

    # Interactive Bash Shell
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoredups" ];
    };

    home.packages = with pkgs; [
      bashInteractive
      shellcheck
      shfmt
    ];

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
