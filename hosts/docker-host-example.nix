# Example: Docker Host Configuration
# Dedicated server for running containerized applications

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/profiles
    ../../modules/system/network.nix
    ../../modules/system/security.nix
  ];

  # === PROFILE CONFIGURATION ===
  
  profiles = {
    base.enable = true;
    server = {
      enable = true;
      role = "docker";
      
      services = {
        ssh = {
          enable = true;
          passwordAuth = false;
          port = 22;
        };
        
        docker = {
          enable = true;
          portainer = true;
        };
        
        monitoring = {
          node-exporter.enable = true;
          prometheus.enable = false;  # Monitor from dedicated server
          grafana.enable = false;
        };
      };
      
      optimization = {
        minimal = true;
        autoUpgrade = false;
        autoGC = true;
      };
    };
  };

  # === HOST-SPECIFIC SETTINGS ===
  networking = {
    hostName = "docker-host";
    
    interfaces.ens18.ipv4.addresses = [{
      address = "192.168.1.101";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" ];
  };

  system.stateVersion = "25.11";

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH keys
    ];
  };

  # Docker storage optimization
  virtualisation.docker.storageDriver = "overlay2";
  
  # Prune more aggressively on docker host
  virtualisation.docker.autoPrune.dates = "daily";

  # Allow docker ports
  networking.firewall.allowedTCPPorts = [ 9443 ];  # Portainer
}
