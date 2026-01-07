# Example: Web Server Configuration
# Nginx reverse proxy with SSL for hosting web applications

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/profiles
    ../../modules/system/network.nix
    ../../modules/system/security.nix
    ../../modules/system/secrets.nix
  ];

  # === PROFILE CONFIGURATION ===
  
  profiles = {
    base.enable = true;
    server = {
      enable = true;
      role = "web";
      
      services = {
        ssh = {
          enable = true;
          passwordAuth = false;  # Key-based auth only
          port = 22;
        };
        
        webserver = {
          enable = true;
          acme = true;  # Automatic SSL certificates
        };
        
        docker = {
          enable = true;
          portainer = true;  # Web UI on port 9443
        };
        
        monitoring = {
          node-exporter.enable = true;
          prometheus.enable = true;
          grafana.enable = true;
        };
        
        backup = {
          enable = true;
          restic.enable = true;
        };
      };
      
      optimization = {
        minimal = true;
        autoUpgrade = false;  # Manual updates for production
        autoGC = true;
      };
    };
  };

  # === HOST-SPECIFIC SETTINGS ===
  networking = {
    hostName = "web-server";
    domain = "example.com";
    
    # Static IP configuration (example for Proxmox)
    interfaces.ens18 = {
      ipv4.addresses = [{
        address = "192.168.1.100";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  system.stateVersion = "24.11";

  # Users
  users.users.admin = {
    isNormalUser = true;
    description = "Server Administrator";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here
      # "ssh-ed25519 AAAAC3... user@machine"
    ];
  };

  # Example nginx virtual host
  services.nginx.virtualHosts."example.com" = {
    enableACME = true;
    forceSSL = true;
    
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";  # Example: Node.js app
      proxyWebsockets = true;
    };
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
