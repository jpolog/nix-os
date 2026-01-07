{ config, pkgs, ... }:

{
  # Font configuration
  fonts = {
    enableDefaultPackages = true;
    
    packages = with pkgs; [
      # Nerd Fonts
      (nerdfonts.override { fonts = [ 
        "FiraCode" 
        "JetBrainsMono" 
        "Iosevka"
        "Meslo"
        "UbuntuMono"
      ]; })
      
      # Standard fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      font-awesome
      dejavu_fonts
      ubuntu_font_family
      
      # Windows fonts (optional)
      corefonts
      vistafonts
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
