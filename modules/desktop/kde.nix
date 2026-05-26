{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf (config.profiles.desktop.enable && config.profiles.desktop.environment == "kde") {
    
    # Enable the KDE Plasma 6 Desktop Environment.
    services.desktopManager.plasma6.enable = true;

    # Enable SDDM (handled in display-manager.nix, but ensuring consistency)
    services.displayManager.sddm.enable = true;
    services.displayManager.defaultSession = "plasma";

    # Exclude some default packages if desired
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      elisa # music player
      # gwenview # image viewer
      # okular # pdf viewer
      kate # text editor
      # khelpcenter
      discover
      systemsettings
    ];

    # KDE specific packages (system-wide, all users)
    environment.systemPackages = with pkgs; [
      kdePackages.kcalc          # Calculator
      kdePackages.spectacle      # Screenshots (replaces per-user Flameshot for KDE)
      kdePackages.ark            # Archive manager (zip/tar/etc.)
      kdePackages.dolphin        # File manager
kdePackages.print-manager  # Printer management GUI (CUPS frontend)
      kdePackages.gwenview       # Image viewer (ensure it's present)
    ];
    
    # Enable Partition Manager
    programs.partition-manager.enable = true;
  };
}
