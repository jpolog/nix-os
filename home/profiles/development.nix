{ config, lib, pkgs, flakePath ? /etc/nixos, ... }:

with lib;

let
  # Use provided flake path with fallback
  effectiveFlakePath = flakePath;
in

{
  imports = [
    ../programs/ai-tools.nix
  ];

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
    
    web = {
      enable = mkEnableOption "development web apps" // { default = true; };
    };

    ai = {
      enable = mkEnableOption "AI development tools" // { default = true; };
      tools = {
        gemini-cli.enable = mkEnableOption "Gemini CLI" // { default = true; };
        github-copilot-cli.enable = mkEnableOption "GitHub Copilot CLI" // { default = true; };
        claude-code.enable = mkEnableOption "Claude Code" // { default = false; };
        goose.enable = mkEnableOption "Goose CLI agent" // { default = true; };
        aider.enable = mkEnableOption "Aider AI pair programmer" // { default = true; };
      };
    };
  };

  config = mkIf config.home.profiles.development.enable {
    # Enable AI Development Tools
    programs.ai-tools = {
      enable = config.home.profiles.development.ai.enable;
      tools = {
        gemini-cli.enable = config.home.profiles.development.ai.tools.gemini-cli.enable;
        github-copilot-cli.enable = config.home.profiles.development.ai.tools.github-copilot-cli.enable;
        claude-code.enable = config.home.profiles.development.ai.tools.claude-code.enable;
        goose.enable = config.home.profiles.development.ai.tools.goose.enable;
        aider.enable = config.home.profiles.development.ai.tools.aider.enable;
      };
    };

    # Enable Development Web Apps
    programs.web-apps = mkIf config.home.profiles.development.web.enable {
      enable = true;
      apps = {
        github = true;
        gitlab = true;
        overleaf = true;
        chatgpt = true;
      };
    };

    # VS Code
    home.packages = with pkgs; (lib.optionals config.home.profiles.development.editors.vscode.enable [
      vscode
    ]);

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