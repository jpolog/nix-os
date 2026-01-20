{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.home.profiles.cli.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
