# Shared Home Manager Configuration
#
# Common settings applied to ALL users on ALL machines.
# Put universal configurations here that every user should have.

{ config, lib, pkgs, ... }:

{
  # Import shared program configurations
  imports = [
    ../programs/git.nix
    ../programs/neovim.nix
  ];

  # Common packages for all users (beyond base profile)
  # These are tools that everyone needs regardless of role
  home.packages = with pkgs; [
    # Essential CLI tools (if not in base profile)
    ncdu      # Disk usage analyzer
    duf       # Better df
    
    # Security
    age       # Encryption
    sops      # Secrets management
  ];

  # Centralized state version
  home.stateVersion = "25.11";

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
