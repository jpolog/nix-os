{ config, lib, pkgs, ... }:

with lib;

{
  # Import desktop program configurations
  imports = [
    ../programs/firefox.nix
    ../programs/kitty.nix
    ../programs/walker.nix
    ../programs/swayosd.nix
    ../hyprland
  ];

  options.home.profiles.desktop = {
    enable = mkEnableOption "desktop applications profile";
  };

  config = mkIf config.home.profiles.desktop.enable {

    home.packages = with pkgs; [
      # Browsers (firefox configured via programs.firefox in firefox.nix)
      chromium
      
      # Terminals
      kitty
      alacritty
      
      # File managers
      ranger
      yazi
      
      # Document viewers
      kdePackages.okular # PDF viewer
      zathura      # Minimal PDF viewer
      
      # Image viewers
      imv
      feh
      
      # Utilities
      cliphist           # Clipboard history
      wl-clipboard       # Wayland clipboard
      hyprpicker         # Color picker
      brightnessctl      # Brightness control
      
      # Screenshots
      grim
      slurp
      swappy
      
      # Password managers
      bitwarden-desktop   # Password manager

      
      # Network
      networkmanagerapplet
      
      # Audio control
      pavucontrol
      pwvucontrol
      
      # Office suite
      libreoffice-fresh
      
      # Note taking
      obsidian
      
      # Calculator
      qalculate-gtk
      
      # System info
      neofetch
      fastfetch
    ];

    # Desktop-specific session variables
    home.sessionVariables = {
      TERMINAL = mkDefault "kitty";
      BROWSER = mkDefault "firefox";
    };
  };
}
