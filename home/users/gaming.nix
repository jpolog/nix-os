{ pkgs, lib, ... }:

let
  mkUser = (import ./lib.nix { inherit lib; }).mkUser;
in
mkUser {
  username = "gaming";
  fullName = "Gaming User";
  email = "";

  profiles = {
    # Base system
    base.enable = true;
    cli.enable = false; # No dev tools

    # Desktop Environment (KDE is good for gaming compatibility)
    desktop = {
      enable = true;
      environment = lib.mkDefault "hyprland"; # switched to hyprland for stability
    };

    # The actual gaming apps
    gaming = {
      enable = true;
      steam.enable = true;
      wine.enable = true;
      utils.enable = true;
      lutris.enable = false;
      heroic.enable = false;
      emulation.enable = false;
    };

    # Minimal other tools
    development.enable = false;
    creative.enable = false;
    personal.enable = false;
    power-user.enable = false;
  };

  extraConfig = {
    imports = [
      ../shell
      ../services
    ];
  };
}
