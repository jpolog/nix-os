{ config, pkgs, ... }:

{
  # Basic user information
  home.username = "jpolo";
  home.homeDirectory = "/home/jpolo";
  home.stateVersion = "25.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable home profiles based on what the user needs
  home.profiles.base.enable = true;
  home.profiles.desktop.enable = true;
  home.profiles.development.enable = true;

  # User-specific git configuration (not in profiles)
  programs.git.settings = {
    user = {
      name = "Javier Polo Gambin";
      email = "javier.polog@outlook.com";
    };
  };
}
