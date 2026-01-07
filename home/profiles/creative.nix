{ config, lib, pkgs, ... }:

with lib;

{
  options.home.profiles.creative = {
    enable = mkEnableOption "creative tools profile";
    
    graphics.enable = mkEnableOption "graphics tools (GIMP, Inkscape, etc.)" // { default = true; };
    video.enable = mkEnableOption "video editing and recording tools";
    audio.enable = mkEnableOption "audio production tools";
  };

  config = mkIf config.home.profiles.creative.enable {
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
        kdenlive
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
