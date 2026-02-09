{ config, pkgs, ... }:

{
  imports = [
    ./printing.nix
    ./location.nix
    ./syncthing.nix
    ./kmonad.nix
    ./github-copilot.nix
    ./plex-client.nix
  ];
}
