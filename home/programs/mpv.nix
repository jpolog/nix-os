{ config, pkgs, lib, ... }:

with lib;

{
  # mpv is a power-user media player (keyboard-driven, minimal UI).
  # Regular users get VLC only. mpv can still be enabled via
  # personal.media.mpv if explicitly requested.
  home.packages = with pkgs;
    optionals config.home.profiles.desktop.powerUserTools.enable [ mpv ];
}
