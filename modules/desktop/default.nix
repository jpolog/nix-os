{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./kde.nix
    ./display-manager.nix
    ./fonts.nix
    ./xdg.nix
  ];
}
