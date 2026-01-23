# User Definitions
#
# This module provides a clean way to define users with their specific
# configurations while sharing common settings.

{ lib, ... }:

let
  # Helper function to create user configurations
  mkUser = { username, fullName, email, profiles ? {}, extraConfig ? {} }: {
    imports = [
      ./shared.nix  # Shared configuration for all users
      ../profiles   # Import all home-manager profiles
    ];

    home = {
      username = username;
      homeDirectory = "/home/${username}";
      stateVersion = "25.11";
    };

    # User-specific git identity
    programs.git = {
      userName = fullName;
      userEmail = email;
    };

    # Profile selections (user can override)
    home.profiles = lib.mkMerge [
      # Defaults
      {
        base.enable = lib.mkDefault true;
      }
      # User-specified profiles
      profiles
    ];
  } // extraConfig;

in
{
  # Export user configurations
  # Usage in flake.nix: home-manager.users = (import ./home/users).all;
  
  # Primary user: Javier Polo
  jpolo = mkUser {
    username = "jpolo";
    fullName = "Javier Polo Gambin";
    email = "javier.polog@outlook.com";
    
    profiles = {
      desktop.enable = true;
      development = {
        enable = true;
        editors.vscode.enable = true;
      };
      creative = {
        enable = true;
        video.enable = true;
      };
      personal.enable = true;
    };
    
    extraConfig = {
      # User-specific shell configuration
      imports = [
        ../shell
        ../services
      ];
    };
  };

  # Example: Work user (minimal setup)
  workuser = mkUser {
    username = "workuser";
    fullName = "Work User";
    email = "work@company.com";
    
    profiles = {
      desktop.enable = true;
      development = {
        enable = true;
        editors.vscode.enable = false;  # Use only neovim
      };
      creative.enable = false;  # No creative tools
      personal = {
        enable = true;
        communication.enable = true;  # Only communication apps
        media.enable = false;          # No media apps
        productivity.enable = true;
      };
    };
  };

  # Example: Server admin user (minimal GUI)
  admin = mkUser {
    username = "admin";
    fullName = "System Administrator";
    email = "admin@example.com";
    
    profiles = {
      desktop.enable = false;      # No desktop apps
      development.enable = true;   # Development tools
      creative.enable = false;     # No creative tools
      personal.enable = false;     # No personal apps
    };
  };

  # Helper to get users for a specific host
  # Usage: (import ./home/users).forHost "ares"
  forHost = hostname: {
    # Return user configurations based on hostname
    # For now, return all users (can be customized per-host)
    inherit jpolo;  # Always include primary user
    
    # Conditional users based on hostname
    # workuser = if hostname == "workstation" then workuser else null;
  };

  # Export all users (for manual selection in flake)
  all = {
    inherit jpolo workuser admin;
  };

