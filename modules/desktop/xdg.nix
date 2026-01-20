{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.profiles.desktop.enable {
    # XDG Base Directory
    xdg = {
      autostart.enable = true;
      menus.enable = true;
      mime.enable = true;
      icons.enable = true;
    };

    # XDG user directories
    environment.systemPackages = with pkgs; [
      xdg-utils
      xdg-user-dirs
    ];
  };
}
