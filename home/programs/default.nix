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
    ./ark.nix
    ./mpv.nix
    ./ai-tools.nix
    ./terminal-tools.nix
    ./tmux.nix
  ];
}
