{ config, pkgs, ... }:

{
  imports = [
    ./hyprsunset.nix
    ./mako.nix
    ./media-automations.nix
    ./ollama.nix
  ];
}
