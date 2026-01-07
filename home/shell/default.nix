{ config, pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./power-user-functions.nix
  ];
}
