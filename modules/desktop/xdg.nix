{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf config.profiles.desktop.enable {
    # XDG Base Directory
    xdg = {
      autostart.enable = true;
      menus.enable = true;
      mime = {
        enable = true;
        defaultApplications = {
          "text/html" = "firefox.desktop";
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "x-scheme-handler/about" = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";
          "image/jpeg" = "imv.desktop";
          "image/png" = "imv.desktop";
          "image/gif" = "imv.desktop";
          "image/webp" = "imv.desktop";
          "application/pdf" = "org.kde.okular.desktop";
          "application/zip" = "org.kde.ark.desktop";
          "application/gzip" = "org.kde.ark.desktop";
          "application/x-tar" = "org.kde.ark.desktop";
          "application/x-rar" = "org.kde.ark.desktop";
          "application/x-7z-compressed" = "org.kde.ark.desktop";
          "video/mp4" = "mpv.desktop";
          "video/x-matroska" = "mpv.desktop";
          "video/webm" = "mpv.desktop";
          "text/plain" = "nvim.desktop";
          "text/markdown" = "nvim.desktop";
          "application/json" = "nvim.desktop";
          "application/x-shellscript" = "nvim.desktop";
          "inode/directory" = "org.kde.dolphin.desktop";
        };
      };
      icons.enable = true;
    };

    # XDG user directories
    environment.systemPackages = with pkgs; [
      xdg-utils
      xdg-user-dirs
    ];
  };
}