{ config, lib, pkgs, ... }:

with lib;

{
  # Import desktop modules at top level
  imports = [
    ../desktop
  ];

  options.profiles.desktop = {
    enable = mkEnableOption "desktop environment profile";
  };

  config = mkIf config.profiles.desktop.enable {
    # Install desktop packages
    environment.systemPackages = with pkgs; [
      # Browsers
      firefox
      chromium
      
      # Terminals
      kitty
      alacritty
      
      # Editors
      neovim
      
      # File managers
      thunar
      thunar-volman
      thunar-archive-plugin
      ranger
      yazi
      
      # Document viewers
      zathura
      
      # Image viewers
      imv
      feh
      
      # Wayland utilities
      wl-clipboard
      cliphist
      hyprpicker
      brightnessctl
      
      # Screenshots
      grim
      slurp
      grimblast
      swappy
      
      # Password managers
      bitwarden-desktop
      
      # Network
      networkmanagerapplet
      blueman
      
      # Audio control
      pavucontrol
      pwvucontrol
      
      # OSD
      swayosd
      
      # Office suite
      libreoffice-fresh
      
      # Note taking
      obsidian
      
      # Calculator
      qalculate-gtk
      
      # System info
      fastfetch
      
      # App launcher
      walker
    ];
  };
}
