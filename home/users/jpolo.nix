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
      editors.vscode.enable = true;
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
  
            
  
            home.firefox.vimNavigation.enable = true;
  
          };}

