{ config, pkgs, ... }:

{
  imports = [
    ./printing.nix
    ./location.nix
  ];
}
