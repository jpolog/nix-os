{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./noctalia.nix 
  ];
}
