{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/services/homelab
  ];

  # ============================================================================
  # System Identity
  # ============================================================================
  networking.hostName = "apollo";
  system.stateVersion = "24.11"; # DO NOT CHANGE after first install

  # ============================================================================
  # Profiles
  # ============================================================================
  profiles.base.enable = true;
  profiles.homelab.enable = true;
  profiles.desktop.enable = false; # Headless

  # ============================================================================
  # Networking
  # ============================================================================
  networking.networkmanager.enable = true;
}