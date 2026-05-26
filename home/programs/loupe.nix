{ config, pkgs, lib, ... }:

with lib;

{
  # Loupe is the GNOME image viewer. KDE users have Gwenview built-in,
  # so only install Loupe for power-user / Hyprland setups.
  home.packages = with pkgs;
    optionals config.home.profiles.desktop.powerUserTools.enable [ loupe ];
}
