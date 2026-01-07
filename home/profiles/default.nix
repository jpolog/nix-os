{ lib, ... }:

{
  imports = [
    ./base.nix
    ./desktop.nix
    ./development.nix
    ./creative.nix
    ./personal.nix
  ];
}
