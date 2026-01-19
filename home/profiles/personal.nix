{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.personal = {
    enable = mkEnableOption "personal applications profile";
    
    communication.enable = mkEnableOption "communication apps (Discord, Slack, etc.)" // { default = true; };
    media.enable = mkEnableOption "media apps (Spotify, VLC, etc.)" // { default = true; };
    productivity.enable = mkEnableOption "productivity apps" // { default = true; };
  };

  config = mkIf config.home.profiles.personal.enable {
    home.packages = with pkgs;
      # Communication
      (optionals config.home.profiles.personal.communication.enable [
        discord
        telegram-desktop
        slack
        zoom-us
      ])
      ++
      # Media
      (optionals config.home.profiles.personal.media.enable [
        mpv
        vlc
        plexamp
        # plex-media-player  # Uncomment if you want the player instead of just Plexamp
      ])
      ++
      # Productivity
      (optionals config.home.profiles.personal.productivity.enable [
        timewarrior
        taskwarrior
        taskwarrior-tui
        rclone
        syncthing
        transmission-gtk
        calibre
      ])
      ++
      # Fun
      [
        cmatrix
        pipes
        cbonsai
      ];
  };
}
