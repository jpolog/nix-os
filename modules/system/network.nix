{ config, pkgs, ... }:

{
  # NetworkManager for easy WiFi management
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
    
    # Firewall
    firewall = {
      enable = true;
      allowPing = true;
      # Add ports as needed
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  # Network tools
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
    wireguard-tools
    openresolv
  ];
}
