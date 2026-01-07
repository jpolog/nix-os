{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./hypridle.nix
    ./hyprlock.nix
  ];
}
