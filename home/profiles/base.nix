{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.base = {
    enable = mkEnableOption "base user profile" // { default = true; };
  };

  config = mkIf config.home.profiles.base.enable {
    # Essential tools every user should have
    home.packages = with pkgs; [
      # Core utilities
      wget
      curl
      tree
      file
      
      # Archive tools
      unzip
      zip
      p7zip
      unrar
      
      # Modern CLI replacements
      eza      # Better ls
      bat      # Better cat
      ripgrep  # Better grep
      fd       # Better find
      
      # System monitoring
      btop
      htop
    ];

    # Essential session variables
    home.sessionVariables = {
      EDITOR = mkDefault "nvim";
      VISUAL = mkDefault "nvim";
    };

    # Let Home Manager manage itself
    programs.home-manager.enable = true;

    # XDG base directory specification
    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "${config.home.homeDirectory}/Desktop";
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        music = "${config.home.homeDirectory}/Music";
        pictures = "${config.home.homeDirectory}/Pictures";
        videos = "${config.home.homeDirectory}/Videos";
        templates = "${config.home.homeDirectory}/Templates";
        publicShare = "${config.home.homeDirectory}/Public";
      };
    };
  };
}
