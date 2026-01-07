{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.development = {
    enable = mkEnableOption "development tools profile";
    
    editors = {
      vscode.enable = mkEnableOption "Visual Studio Code";
      neovim.enable = mkEnableOption "Neovim with LazyVim" // { default = true; };
    };
  };

  config = mkIf config.home.profiles.development.enable {
    # Import development program configurations
    imports = [
      ../programs/git.nix
      ../programs/neovim.nix
      ../programs/terminal-tools.nix
    ];

    home.packages = with pkgs; 
      # Always included
      [
        # Version control
        git
        gh
        lazygit
        tig
        delta
        
        # Terminal tools
        tmux
        screen
        zoxide
        fzf
        
        # Text processing
        jq
        yq-go
      ]
      ++
      # VSCode (optional)
      (optionals config.home.profiles.development.editors.vscode.enable [
        vscode
        vscodium
      ]);
  };
}
