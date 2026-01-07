{ config, pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./display-manager.nix
    ./fonts.nix
    ./xdg.nix
  ];
}
