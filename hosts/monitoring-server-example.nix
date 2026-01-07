# Example: Monitoring Server Configuration
# Prometheus + Grafana + Loki for infrastructure monitoring

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
      role = "monitoring";
      
      services = {
        ssh = {
          enable = true;
          passwordAuth = false;
          port = 22;
        };
        
        monitoring = {
          node-exporter.enable = true;
          prometheus.enable = true;
          grafana.enable = true;
          loki.enable = true;
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
    hostName = "monitoring-server";
    
    interfaces.ens18.ipv4.addresses = [{
      address = "192.168.1.103";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" ];
  };

  system.stateVersion = "24.11";

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # Add SSH keys
    ];
  };

  # Grafana configuration
  services.grafana.settings = {
    server = {
      domain = "monitoring.example.com";
      root_url = "https://monitoring.example.com";
    };
    
    security = {
      admin_user = "admin";
      admin_password = "$__file{/run/secrets/grafana-admin-password}";
    };
  };

  # Prometheus - scrape all servers in homelab
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node";
      static_configs = [{
        targets = [
          "192.168.1.100:9100"  # web-server
          "192.168.1.101:9100"  # docker-host
          "192.168.1.102:9100"  # database-server
          "192.168.1.103:9100"  # monitoring-server (self)
        ];
      }];
    }
  ];

  # Firewall: Allow access to monitoring services
  networking.firewall.allowedTCPPorts = [ 
    3000   # Grafana
    9090   # Prometheus
    3100   # Loki
  ];
}
