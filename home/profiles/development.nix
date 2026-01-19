{ config, lib, pkgs, flakePath ? /etc/nixos, ... }:

with lib;

let
  # Use provided flake path with fallback
  effectiveFlakePath = flakePath;
in

{
  options.home.profiles.development = {
    enable = mkEnableOption "development tools profile";

    devShells = {
      enable = mkEnableOption "generic development shells" // { default = true; };
      enableLaunchers = mkEnableOption "shell launcher scripts" // { default = true; };
      enableDirenvTemplates = mkEnableOption "direnv templates" // { default = true; };
    };

    editors = {
      vscode.enable = mkEnableOption "Visual Studio Code configuration";
      neovim.enable = mkEnableOption "Neovim with LazyVim" // { default = true; };
    };
  };

  config = mkIf config.home.profiles.development.enable {
    # NO package installation - packages installed by system profile!
    # Only configuration/dotfiles here
    
    # ========================================================================
    # Tmux Configuration
    # ========================================================================
    
    programs.tmux = {
      enable = true;
      terminal = "tmux-256color";
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      
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
      '';
    };

    # ========================================================================
    # Dev Shell Integration (Conditional)
    # ========================================================================

    # Enable direnv integration
    programs.direnv = mkIf config.home.profiles.development.devShells.enable {
      enable = true;
      nix-direnv.enable = true;

      config = {
        global = {
          warn_timeout = "30s";
        };
      };
    };

    # Create launcher scripts and direnv templates
    home.file = mkMerge [
      # Launcher scripts
      (mkIf (config.home.profiles.development.devShells.enable &&
             config.home.profiles.development.devShells.enableLaunchers) {

        ".local/bin/dev-python" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            echo "🐍 Launching Python development shell..."
            nix develop ${toString effectiveFlakePath}#python
          '';
        };

        ".local/bin/dev-node" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            echo "🟢 Launching Node.js development shell..."
            nix develop ${toString effectiveFlakePath}#node
          '';
        };

        ".local/bin/dev-rust" = {
          executable = true;
          text = ''
            #!/usr:bin/env bash
            echo "🦀 Launching Rust development shell..."
            nix develop ${toString effectiveFlakePath}#rust
          '';
        };

        ".local/bin/dev-go" = {
          executable = true;
          text = ''
            #!/usr/bin/env bash
            echo "🐹 Launching Go development shell..."
            nix develop ${toString effectiveFlakePath}#go
          '';
        };
      })

      # Direnv templates
      (mkIf (config.home.profiles.development.devShells.enable &&
             config.home.profiles.development.devShells.enableDirenvTemplates) {

        ".config/direnv/templates/python.envrc".text = ''
          use flake ${toString effectiveFlakePath}#python
        '';

        ".config/direnv/templates/node.envrc".text = ''
          use flake ${toString effectiveFlakePath}#node
        '';

        ".config/direnv/templates/rust.envrc".text = ''
          use flake ${toString effectiveFlakePath}#rust
        '';

        ".config/direnv/templates/go.envrc".text = ''
          use flake ${toString effectiveFlakePath}#go
        '';

        ".config/direnv/templates/README.md".text = ''
          # Direnv Templates

          Copy a template to your project directory:

          ```bash
          cp ~/.config/direnv/templates/python.envrc .envrc
          direnv allow
          ```
        '';
      })
    ];
    
    # ========================================================================
    # Lazygit Configuration
    # ========================================================================
    
    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          theme = {
            lightTheme = false;
            activeBorderColor = [ "blue" "bold" ];
            inactiveBorderColor = [ "white" ];
          };
        };
      };
    };
  };
}

