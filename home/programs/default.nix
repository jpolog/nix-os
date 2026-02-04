{ config, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./firefox.nix
    ./kitty.nix
    ./neovim.nix
    ./web-apps.nix
    ./vms.nix
    ./loupe.nix
    ./evince.nix
    ./ark.nix
    ./mpv.nix
  ];
}
