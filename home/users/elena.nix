{ pkgs, lib, ... }:

let
  mkUser = (import ./lib.nix { inherit lib; }).mkUser;
in
mkUser {
  username = "elena";
  fullName = "Elena";
  email = "";
  
  profiles = {
    base.enable = true;
    cli.enable = false;
    
    desktop = {
      enable = true;
      environment = "kde";
    };
    
    development.enable = false;
    creative.enable = false;
    
    personal = {
      enable = true;
      office.enable = true;
      media.enable = true;
      communication.enable = true;
      productivity.enable = true;
      tools.enable = true;        # Image editing, Screenshots
    };
  };
}
