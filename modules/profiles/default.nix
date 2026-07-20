{ lib, ... }:

{
  imports = [
    ./base.nix
    ./desktop.nix
    ./development.nix
    ./homelab.nix
    ./power-user.nix
    ./server.nix
  ];
}
