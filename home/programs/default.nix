{ config, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./firefox.nix
    ./neovim.nix
    ./kitty.nix
    ./swayosd.nix
    ./walker.nix
    ./xcompose.nix
    ./terminal-tools.nix
    ./power-user.nix
    ./vms.nix
  ];
}
