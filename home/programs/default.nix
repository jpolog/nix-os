{ config, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./firefox.nix
    ./kitty.nix
    ./neovim.nix
    ./web-apps.nix
  ];
}
