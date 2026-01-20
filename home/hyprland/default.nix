{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./noctalia.nix # TODO: Add Noctalia configuration
  ];
}
