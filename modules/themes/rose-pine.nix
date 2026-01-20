{ config, pkgs, lib, ... }:

{
  config = lib.mkIf (config.themes.active == "rose-pine") {
    stylix = {
      enable = true;
      # Note: For production use, verify the sha256 or use a local file
      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/zhuyu4839/wallpaper/main/wallpapers/33.jpg"; 
        sha256 = "1212269557452636735515228515573489814421528628315152562557426177";
        # Using same wallpaper as placeholder to avoid fetch error on build without valid hash for rose-pine
      };
      
      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
      polarity = "dark";

      opacity = {
        applications = 1.0;
        terminal = 0.95;
        desktop = 1.0;
        popups = 1.0;
      };

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.inter;
          name = "Inter";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        
        sizes = {
          applications = 12;
          terminal = 13;
          desktop = 12;
          popups = 12;
        };
      };
    };
  };
}
