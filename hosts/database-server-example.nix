# Example: Database Server Configuration
# PostgreSQL + Redis for application backends

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
      role = "database";
      
      services = {
        ssh = {
          enable = true;
          passwordAuth = false;
          port = 22;
        };
        
        database = {
          postgresql.enable = true;
          redis.enable = true;
          mysql.enable = false;
        };
        
        monitoring = {
          node-exporter.enable = true;
        };
        
        backup = {
          enable = true;
          restic.enable = true;
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
    hostName = "database-server";
    
    interfaces.ens18.ipv4.addresses = [{
      address = "192.168.1.102";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ "1.1.1.1" ];
  };

  system.stateVersion = "24.11";

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "postgres" ];
    openssh.authorizedKeys.keys = [
      # Add SSH keys
    ];
  };

  # PostgreSQL tuning for dedicated server
  services.postgresql.settings = {
    shared_buffers = "4GB";
    effective_cache_size = "12GB";
    maintenance_work_mem = "1GB";
    work_mem = "64MB";
    max_connections = 200;
  };

  # Automated PostgreSQL backups
  services.postgresqlBackup = {
    enable = true;
    location = "/var/backup/postgresql";
    startAt = "*-*-* 01:00:00";
  };

  # Firewall: Allow database access from internal network
  networking.firewall.allowedTCPPorts = [ 5432 6379 ];
}
