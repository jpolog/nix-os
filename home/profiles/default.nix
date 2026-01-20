{ lib, ... }:

{
  imports = [
    ./base.nix
    ./cli.nix
    ./desktop.nix
    ./development.nix
    ./work.nix
    ./power-user.nix
    ./creative.nix
    ./personal.nix
    ./gaming.nix
  ];
}
