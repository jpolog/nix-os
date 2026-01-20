{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.cli = {
    enable = mkEnableOption "command line interface power tools" // { default = false; };
  };

  config = mkIf config.home.profiles.cli.enable {
    # This profile enables:
    # - Advanced Shell (Zsh + Starship)
    # - Git & GitHub CLI
    # - Neovim
    # - Terminal utilities (Tmux, FZF, Ripgrep, etc.)
    
    # Session variables for CLI users
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
