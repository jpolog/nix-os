{ config, pkgs, lib, ... }:

with lib;

{
  # Evince is a lightweight GNOME PDF viewer useful on Hyprland/mixed setups.
  # Regular KDE users get Okular instead, so we skip Evince for them.
  home.packages = with pkgs;
    optionals config.home.profiles.desktop.powerUserTools.enable [ evince ];
}
