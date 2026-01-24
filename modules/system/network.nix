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
      allowedUDPPorts = [ config.services.tailscale.port ]; # Allow Tailscale UDP port
      
      # Trust tailscale interface
      trustedInterfaces = [ "tailscale0" ];
    };
  };
  
  # Enable Tailscale service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    
    # Automatically authenticate using the key from secrets
    authKeyFile = config.sops.secrets.tailscale_key.path;
    extraUpFlags = [
      "--operator=${config.users.users.jpolo.name}" # Allow user to control tailscale
      "--ssh" # Enable Tailscale SSH
    ];
  };

  # Network tools
  environment.systemPackages = with pkgs; [
    networkmanager
    networkmanagerapplet
    wireguard-tools
    openresolv
    tailscale
  ];
}
