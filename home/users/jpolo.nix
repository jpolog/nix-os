# 1. Update arguments to accept osConfig (with a default of null for safety)
{ pkgs, lib, osConfig ? null, ... }:

let
  mkUser = (import ./lib.nix { inherit lib; }).mkUser;
in
mkUser {
  username = "jpolo";
  fullName = "Javier Polo Gambin";
  email = "javier.polog@outlook.com";
  
  profiles = {
    desktop = {
      enable = true;
    };

    cli.enable = true;       
    development = {
      enable = true;
      editors.vscode.enable = false;
      ai.tools.claude-code.enable = true;
    };
    creative = {
      enable = true;
      video.enable = true;
    };
    
    power-user = {
      enable = true;
      productivity.enable = true;
      cli-utils.enable = true;
      torrenting.enable = true;
    };
    
    work = {
      enable = true;
      communication = {
        slack = true;
        teams = true;
        zoom = true;
      };
    };

    research = {
      enable = true;
      latex.enable = true;
      tools.enable = true;
      diagrams.enable = true;
    };
    
    master.enable = true;
    
    personal = {
      enable = true;
      media = {
        enable = true;
        spotify = false;
        plexamp = true;
        plex = true;
        vlc = true;
        mpv = true;
      };
      office.enable = false; 
      productivity = {
        enable = true;
        bitwarden = true;
        syncthing = true;
      };
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
  
            imports = [
  
              ../shell
  
              ../services
  
            ];
  
            
  
            # Explicitly enable desktop profile and set environment
  
            home.profiles.desktop.enable = true;
  
            home.profiles.desktop.environment = "hyprland";
  
            home.profiles.desktop.browsers = {
              firefox = true;
              chromium = false;
            };
  
            home.firefox.vimNavigation.enable = true;

            home.file = {
              "Documents/important/.keep".text = "";
              "Documents/books/.keep".text = "";
              "Documents/scans/.keep".text = "";
              "Documents/work/.keep".text = "";
            };

            programs.web-apps.apps.outlook = true;
          };
}
