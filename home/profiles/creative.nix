{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.creative = {
    enable = mkEnableOption "creative tools profile";
    
    graphics.enable = mkEnableOption "graphics tools (GIMP, Inkscape, etc.)" // { default = true; };
    video.enable = mkEnableOption "video editing and recording tools";
    audio.enable = mkEnableOption "audio production tools";
    
    web = {
      enable = mkEnableOption "creative web apps" // { default = true; };
    };
  };

  config = mkIf config.home.profiles.creative.enable {
    # Enable Creative Web Apps
    programs.web-apps = mkIf config.home.profiles.creative.web.enable {
      enable = true;
      apps = {
        figma = true;
        canva = true;
        excalidraw = true;
      };
    };

    home.packages = with pkgs;
      # Graphics tools
      (optionals config.home.profiles.creative.graphics.enable [
        gimp
        inkscape
        krita
      ])
      ++
      # Video tools
      (optionals config.home.profiles.creative.video.enable [
        kdePackages.kdenlive
        obs-studio
        wf-recorder
      ])
      ++
      # Audio tools
      (optionals config.home.profiles.creative.audio.enable [
        audacity
      ]);
  };
}
