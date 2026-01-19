{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.base = {
    enable = mkEnableOption "base user profile" // { default = true; };
  };

  config = mkIf config.home.profiles.base.enable {
    # NO package installation - packages installed by system profile!
    # Only configuration here

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
    
    # Git, Zsh, Starship are configured in home/programs/ and home/shell/
    # No need to configure here - they're loaded via sharedModules
    
    # Bash as fallback
    programs.bash.enable = true;
  };
}
