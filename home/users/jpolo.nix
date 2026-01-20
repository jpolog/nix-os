{ pkgs, lib, ... }:

let
  mkUser = (import ./lib.nix { inherit lib; }).mkUser;
in
mkUser {
  username = "jpolo";
  fullName = "Javier Polo Gambin";
  email = "javier.polog@outlook.com";
  
  profiles = {
    desktop.enable = true;
    cli.enable = true;       # Enable CLI tools (Git, Zsh, Neovim)
    development = {
      enable = true;
      editors.vscode.enable = true;
    };
    creative = {
      enable = true;
      video.enable = true;
    };
    
    power-user = {
      enable = true;
      productivity.enable = true; # Obsidian, CLI tools
      cli-utils.enable = true;    # jq, ffmpeg, etc
      torrenting.enable = true;   # qBittorrent
    };
    
    # Enable Work Profile
    work = {
      enable = true;
      communication = {
        slack = true;
        teams = true;
        zoom = true;
      };
    };
    
    personal = {
      enable = true;
      
      # Selective Media
      media = {
        enable = true;
        spotify = false;
        plexamp = true;
        plex = true;
        vlc = true;
        mpv = true;
      };
      
      # Selective Office
      office.enable = false; # I don't use LibreOffice
      
      # Productivity (Basic)
      productivity = {
        enable = true;
        bitwarden = true;
        syncthing = true;
      };
      
      # General Tools
      tools = {
        enable = true;
        image-editing = true;
        screenshot = true;
        video-tools = true;
      };

      communication.enable = true;
    };
  };
  
  extraConfig = {
    # User-specific shell configuration
    imports = [
      ../shell
      ../services
    ];
  };
}
