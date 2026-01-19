{ config, pkgs, lib, ... }:

{
  programs.kitty = {
    enable = lib.mkDefault true;
    font.name = "JetBrainsMono Nerd Font";
    font.size = 11;
  };
}
