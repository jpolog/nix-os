{ config, pkgs, ... }:

{
  imports = [
    ../programs      # Import all program modules
    ../services
    ../shell
    ../profiles      # Import all profiles (via default.nix)
  ];

  home = {
    username = "jpolo";
    homeDirectory = "/home/jpolo";
    stateVersion = "25.11";
  };

  # Enable the profiles you want
  home.profiles = {
    base.enable = true;              # Always on (default anyway)
    desktop.enable = true;            # GUI apps
    development.enable = true;        # Dev tools
    
    # Development sub-options
    development.editors.vscode.enable = true;
    development.editors.neovim.enable = true;
    
    # Personal apps
    personal.enable = true;
    personal.communication.enable = true;
    personal.media.enable = true;
    personal.productivity.enable = false;  # Example: disable this
  };

  # User-specific overrides (non-profile stuff)
  programs.git.settings = {
    user = {
      name = "Javier Polo Gambin";
      email = "javier.polog@outlook.com";
    };
  };
}

