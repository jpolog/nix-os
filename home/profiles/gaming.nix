{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.profiles.gaming;
in
{
  options.home.profiles.gaming = {
    enable = mkEnableOption "gaming tools and launchers";
    
    steam.enable = mkEnableOption "Steam" // { default = true; };
    wine.enable = mkEnableOption "Wine and Proton compatibility" // { default = true; };
    
    lutris.enable = mkEnableOption "Lutris";
    heroic.enable = mkEnableOption "Heroic Games Launcher";
    emulation.enable = mkEnableOption "RetroArch and emulators";
    utils.enable = mkEnableOption "Gaming utilities (MangoHud, Gamescope)" // { default = true; };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; 
      # Steam
      (optionals cfg.steam.enable [
        steam
      ]) ++
      
      # Wine / Proton
      (optionals cfg.wine.enable [
        wine
        wine64
        winetricks
        proton-caller
      ]) ++
      
      # Lutris
      (optionals cfg.lutris.enable [
        lutris
      ]) ++
      
      # Heroic
      (optionals cfg.heroic.enable [
        heroic
      ]) ++
      
      # Emulation
      (optionals cfg.emulation.enable [
        retroarch
      ]) ++
      
      # Utilities
      (optionals cfg.utils.enable [
        gamescope
        mangohud
        gamemode
      ]);
    
    # Allow unfree for Steam
    nixpkgs.config.allowUnfree = true;
  };
}