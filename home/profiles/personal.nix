{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.profiles.personal;
in
{
  options.home.profiles.personal = {
    enable = mkEnableOption "personal applications profile (Daily Driver)";
    
    communication = {
      enable = mkEnableOption "communication apps" // { default = true; };
      discord = mkEnableOption "Discord" // { default = cfg.communication.enable; };
      telegram = mkEnableOption "Telegram" // { default = cfg.communication.enable; };
    };

    media = {
      enable = mkEnableOption "media apps" // { default = true; };
      spotify = mkEnableOption "Spotify" // { default = cfg.media.enable; };
      plexamp = mkEnableOption "Plexamp" // { default = cfg.media.enable; };
      plex = mkEnableOption "Plex Desktop" // { default = cfg.media.enable; };
      vlc = mkEnableOption "VLC" // { default = cfg.media.enable; };
      mpv = mkEnableOption "MPV" // { default = cfg.media.enable; };
    };

    productivity = {
      enable = mkEnableOption "productivity apps" // { default = true; };
      bitwarden = mkEnableOption "Bitwarden" // { default = cfg.productivity.enable; };
      syncthing = mkEnableOption "Syncthing" // { default = cfg.productivity.enable; };
    };

    office = {
      enable = mkEnableOption "office suite" // { default = true; };
      libreoffice = mkEnableOption "LibreOffice" // { default = cfg.office.enable; };
      okular = mkEnableOption "Okular" // { default = cfg.office.enable; };
    };
    
    tools = {
      enable = mkEnableOption "general utility tools" // { default = true; };
      image-editing = mkEnableOption "light image editing (Pinta)" // { default = cfg.tools.enable; };
      screenshot = mkEnableOption "screenshot tool (Flameshot)" // { default = cfg.tools.enable; };
      video-tools = mkEnableOption "easy video tools (LosslessCut)" // { default = cfg.tools.enable; };
    };
    
    web = {
      enable = mkEnableOption "common web apps" // { default = true; };
      communication = mkEnableOption "web communication (Gmail, WhatsApp)" // { default = cfg.web.enable; };
      media = mkEnableOption "web media (YouTube)" // { default = cfg.web.enable; };
    };
  };

  config = mkIf cfg.enable {
    # Enable Web Apps module
    programs.web-apps = mkIf cfg.web.enable {
      enable = true;
      apps = {
        gmail = cfg.web.communication;
        whatsapp = cfg.web.communication;
        youtube = cfg.web.media;
      };
    };

    home.packages = with pkgs;
      # Communication
      (optionals cfg.communication.discord [ discord ]) ++
      (optionals cfg.communication.telegram [ telegram-desktop ]) ++
      
      # Media
      (optionals cfg.media.spotify [ spotify ]) ++
      (optionals cfg.media.plexamp [ plexamp ]) ++
      (optionals cfg.media.plex [ plex-desktop ]) ++
      (optionals cfg.media.vlc [ vlc ]) ++
      (optionals cfg.media.mpv [ mpv ]) ++
      
      # Productivity (General only)
      (optionals cfg.productivity.bitwarden [ bitwarden-desktop ]) ++
      (optionals cfg.productivity.syncthing [ syncthing ]) ++
      
      # Office
      (optionals cfg.office.libreoffice [ libreoffice-fresh ]) ++
      (optionals cfg.office.okular [ 
        kdePackages.okular
        hunspell
        hunspellDicts.en_US
        hunspellDicts.es_ES
      ]) ++
      
      # General Tools
      (optionals cfg.tools.image-editing [ pinta ]) ++
      (optionals cfg.tools.screenshot [ flameshot ]) ++
      (optionals cfg.tools.video-tools [ losslesscut-bin ]) ++
      
      # Fun (Always enabled if profile is enabled)
      [
        cmatrix
        pipes
        cbonsai
      ];
  };
}