{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.desktop.enable {
    programs.kitty = {
      enable = true;
    };
  };
}
