{ pkgs, lib, ... }:

let
  mkUser = (import ./lib.nix { inherit lib; }).mkUser;
in
mkUser {
  username = "padres";
  fullName = "Padres";
  email = "";
  
  profiles = {
    base.enable = true;      # Core system settings
    cli.enable = false;      # No terminal power tools
    
    desktop = {
      enable = true;
      environment = "kde";   # User friendly desktop
    };
    
    development.enable = false;
    creative.enable = false;
    
    # The "General Use" suite
    personal = {
      enable = true;
      # Enable full categories (sub-options default to true)
      office.enable = true;
      media.enable = true;
      communication.enable = true;
      productivity.enable = true;
      tools.enable = true;        # Image editing, Screenshots
    };
  };
}
