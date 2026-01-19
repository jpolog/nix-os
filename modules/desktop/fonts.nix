{ config, pkgs, ... }:

{
  # Font configuration
  fonts = {
    enableDefaultPackages = true;
    
    packages = with pkgs; [
      # Nerd Fonts - now individual packages in NixOS 24.11+
      # Old: (nerd-fonts.override { fonts = [...] })
      # New: individual packages
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      nerd-fonts.meslo-lg
      nerd-fonts.ubuntu-mono
      
      # Standard fonts (updated names for NixOS 24.11+)
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      font-awesome
      dejavu_fonts
      ubuntu-classic
      
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "DejaVu Serif" ];
        sansSerif = [ "Noto Sans" "DejaVu Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" "FiraCode Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
