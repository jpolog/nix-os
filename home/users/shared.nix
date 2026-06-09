# Shared Home Manager Configuration
#
# Common settings applied to ALL users on ALL machines.
# Put universal configurations here that every user should have.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Import shared program configurations
  imports = [
    ../programs
  ];

  # CLI / power-user packages — only for users with cli profile enabled
  home.packages = with pkgs;
    lib.optionals config.home.profiles.cli.enable [
      ncdu  # Disk usage analyser
      duf   # Better df
      age   # Encryption
      sops  # Secrets management
    ];

  # Centralized state version
  home.stateVersion = "25.11";

  xdg.userDirs.setSessionVariables = false;

  wayland.windowManager.hyprland.configType = lib.mkDefault "hyprlang";

  # Common session variables
  home.sessionVariables = {
    # Set common environment variables here
  };

  # Common programs configuration that doesn't need user-specific data
  programs = {
    # bash/zsh are configured per-user in shell/

    # direnv (project environments)
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # Command-not-found with nix-index
    nix-index.enable = true;
  };

  # Common services
  services = {
    # Add common user services here
  };
}
