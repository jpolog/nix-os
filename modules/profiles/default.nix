{ lib, ... }:

{
  imports = [
    ./base.nix
    ./desktop.nix
    ./development.nix
    ./gaming.nix
    ./power-user.nix
    ./server.nix
    # ./style.nix # Replaced by modules/themes
  ];
}
