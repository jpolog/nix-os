{ config, pkgs, inputs, lib, ... }:

with lib;

{
  config = mkIf (config.profiles.desktop.enable && config.profiles.desktop.environment == "hyprland") {
    # Enable Hyprland with plugins
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      xwayland.enable = true;
      
      # Enable plugins
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    # Required for Hyprland
    security.polkit.enable = true;
    
    # XDG Portal
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        # xdg-desktop-portal-hyprland already set via portalPackage above
        xdg-desktop-portal-gtk
      ];
      configPackages = [ inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland ];
    };

    # Environment variables for Wayland/Hyprland
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    # Essential Wayland packages
    environment.systemPackages = with pkgs; [
      # Wayland utilities
      wayland
      wayland-protocols
      wayland-utils
      wl-clipboard
      wlr-randr
      
      # Screenshot and screen recording
      grim
      slurp
      grimblast
      wf-recorder
      
      # Notification daemon
      mako
      libnotify
      
      # File manager
      thunar
      thunar-volman
      thunar-archive-plugin
      
      # Image viewer
      imv
      
      # PDF viewer
      zathura
      
      # Archive manager
      file-roller
      
      # Polkit agent
      polkit_gnome
    ];
  };
}
