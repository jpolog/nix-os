{ config, lib, pkgs, ... }:

with lib;

{
  options.profiles.server = {
    enable = mkEnableOption "server profile (headless, minimal, optimized)";
    
    role = mkOption {
      type = types.enum [ "general" "web" "database" "docker" "storage" "monitoring" ];
      default = "general";
      description = ''
        Server role determines which packages and services are pre-configured.
        - general: Basic server with SSH, minimal tools
        - web: Nginx/Caddy, SSL certificates
        - database: PostgreSQL, Redis, backup tools
        - docker: Docker daemon, portainer, monitoring
        - storage: NFS, Samba, ZFS tools
        - monitoring: Prometheus, Grafana, Loki
      '';
    };
    
    services = {
      ssh = {
        enable = mkEnableOption "SSH server" // { default = true; };
        passwordAuth = mkEnableOption "allow password authentication";
        port = mkOption {
          type = types.int;
          default = 22;
          description = "SSH port";
        };
      };
      
      webserver = {
        enable = mkEnableOption "web server (nginx)";
        acme = mkEnableOption "automatic SSL certificates via ACME/Let's Encrypt";
      };
      
      docker = {
        enable = mkEnableOption "Docker daemon";
        portainer = mkEnableOption "Portainer web UI";
      };
      
      database = {
        postgresql.enable = mkEnableOption "PostgreSQL database";
        redis.enable = mkEnableOption "Redis cache";
        mysql.enable = mkEnableOption "MySQL/MariaDB database";
      };
      
      storage = {
        nfs.enable = mkEnableOption "NFS server";
        samba.enable = mkEnableOption "Samba/SMB server";
      };
      
      monitoring = {
        prometheus.enable = mkEnableOption "Prometheus metrics";
        grafana.enable = mkEnableOption "Grafana dashboards";
        loki.enable = mkEnableOption "Loki log aggregation";
        node-exporter.enable = mkEnableOption "Prometheus node exporter" // { default = true; };
      };
      
      backup = {
        enable = mkEnableOption "automated backup services";
        restic.enable = mkEnableOption "Restic backup client";
      };
    };
    
    optimization = {
      minimal = mkEnableOption "ultra-minimal (no docs, recommended packages)" // { default = true; };
      autoUpgrade = mkEnableOption "automatic system updates";
      autoGC = mkEnableOption "automatic garbage collection" // { default = true; };
    };
  };

  config = mkIf config.profiles.server.enable {
    # === BASE SERVER CONFIGURATION ===
    
    # Disable GUI completely
    services.xserver.enable = false;
    services.displayManager.enable = false;
    
    # No desktop environment
    environment.noXlibs = mkDefault true;
    
    # Minimal documentation (save space)
    documentation = mkIf config.profiles.server.optimization.minimal {
      enable = false;
      man.enable = false;
      info.enable = false;
      doc.enable = false;
      nixos.enable = false;
    };
    
    # No GUI packages
    services.udisks2.enable = false;
    programs.gnupg.agent.pinentryPackage = mkForce pkgs.pinentry-curses;
    
    # Essential server packages only
    environment.systemPackages = with pkgs; [
      # Core utilities
      vim
      wget
      curl
      git
      
      # System monitoring
      htop
      btop
      iotop
      ncdu
      
      # Network tools
      netcat
      nmap
      tcpdump
      traceroute
      dig
      mtr
      iftop
      
      # System tools
      tmux
      screen
      
      # Text processing
      jq
      yq-go
      
      # Archive tools
      unzip
      gzip
      tar
      
      # Security
      age
      sops
    ];
    
    # === SSH CONFIGURATION ===
    services.openssh = mkIf config.profiles.server.services.ssh.enable {
      enable = true;
      ports = [ config.profiles.server.services.ssh.port ];
      
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = config.profiles.server.services.ssh.passwordAuth;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        
        # Security hardening
        Protocol = 2;
        MaxAuthTries = 3;
        LoginGraceTime = 30;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
      };
      
      # Use strong ciphers only
      extraConfig = ''
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
        KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
      '';
    };
    
    # === WEB SERVER ===
    services.nginx = mkIf config.profiles.server.services.webserver.enable {
      enable = true;
      
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
    };
    
    # ACME/Let's Encrypt
    security.acme = mkIf (config.profiles.server.services.webserver.enable && config.profiles.server.services.webserver.acme) {
      acceptTerms = true;
      defaults.email = "admin@example.com";  # TODO: Make this configurable
    };
    
    # === DOCKER ===
    virtualisation.docker = mkIf config.profiles.server.services.docker.enable {
      enable = true;
      
      # Auto-prune
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
      
      # Optimize for server
      daemon.settings = {
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
      };
    };
    
    # Portainer (Docker UI)
    virtualisation.oci-containers = mkIf (config.profiles.server.services.docker.enable && config.profiles.server.services.docker.portainer) {
      backend = "docker";
      containers.portainer = {
        image = "portainer/portainer-ce:latest";
        ports = [ "9000:9000" "9443:9443" ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "portainer_data:/data"
        ];
        extraOptions = [ "--restart=always" ];
      };
    };
    
    # === DATABASES ===
    
    # PostgreSQL
    services.postgresql = mkIf config.profiles.server.services.database.postgresql.enable {
      enable = true;
      package = pkgs.postgresql_16;
      
      enableTCPIP = true;
      
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all 127.0.0.1/32 scram-sha-256
        host all all ::1/128 scram-sha-256
      '';
      
      settings = {
        shared_buffers = "256MB";
        effective_cache_size = "1GB";
        maintenance_work_mem = "64MB";
        work_mem = "4MB";
      };
    };
    
    # Redis
    services.redis.servers.default = mkIf config.profiles.server.services.database.redis.enable {
      enable = true;
      port = 6379;
      bind = "127.0.0.1";
      settings = {
        maxmemory = "256mb";
        maxmemory-policy = "allkeys-lru";
      };
    };
    
    # MySQL/MariaDB
    services.mysql = mkIf config.profiles.server.services.database.mysql.enable {
      enable = true;
      package = pkgs.mariadb;
      
      settings = {
        mysqld = {
          bind-address = "127.0.0.1";
          max_connections = 100;
          innodb_buffer_pool_size = "256M";
        };
      };
    };
    
    # === STORAGE SERVICES ===
    
    # NFS Server
    services.nfs.server = mkIf config.profiles.server.services.storage.nfs.enable {
      enable = true;
      exports = ''
        # Example: /export 192.168.1.0/24(rw,sync,no_subtree_check)
      '';
    };
    
    # Samba/SMB
    services.samba = mkIf config.profiles.server.services.storage.samba.enable {
      enable = true;
      securityType = "user";
      
      extraConfig = ''
        workgroup = WORKGROUP
        server string = NixOS Samba Server
        security = user
        
        # Performance optimization
        socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
        read raw = yes
        write raw = yes
        max xmit = 65535
      '';
      
      # Example share
      shares = {
        # public = {
        #   path = "/srv/samba/public";
        #   browseable = "yes";
        #   writable = "yes";
        #   "guest ok" = "yes";
        # };
      };
    };
    
    # === MONITORING ===
    
    # Prometheus configuration (unified)
    services.prometheus = {
      # Prometheus Node Exporter
      exporters.node = mkIf config.profiles.server.services.monitoring.node-exporter.enable {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "systemd"
          "processes"
          "cpu"
          "diskstats"
          "filesystem"
          "loadavg"
          "meminfo"
          "netdev"
          "stat"
        ];
      };
      
      # Prometheus Server
      enable = mkIf config.profiles.server.services.monitoring.prometheus.enable true;
      port = mkIf config.profiles.server.services.monitoring.prometheus.enable 9090;
      
      globalConfig = mkIf config.profiles.server.services.monitoring.prometheus.enable {
        scrape_interval = "15s";
        evaluation_interval = "15s";
      };
      
      scrapeConfigs = mkIf config.profiles.server.services.monitoring.prometheus.enable [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };
    
    # Grafana
    services.grafana = mkIf config.profiles.server.services.monitoring.grafana.enable {
      enable = true;
      
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = 3000;
        };
        
        analytics.reporting_enabled = false;
      };
    };
    
    # Loki (Log aggregation)
    services.loki = mkIf config.profiles.server.services.monitoring.loki.enable {
      enable = true;
      
      configuration = {
        server.http_listen_port = 3100;
        auth_enabled = false;
        
        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore.store = "inmemory";
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
        };
        
        schema_config.configs = [{
          from = "2024-01-01";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
        
        storage_config = {
          boltdb_shipper = {
            active_index_directory = "/var/lib/loki/boltdb-shipper-active";
            cache_location = "/var/lib/loki/boltdb-shipper-cache";
            cache_ttl = "24h";
            shared_store = "filesystem";
          };
          
          filesystem.directory = "/var/lib/loki/chunks";
        };
        
        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };
        
        chunk_store_config.max_look_back_period = "0s";
        
        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };
        
        compactor = {
          working_directory = "/var/lib/loki";
          shared_store = "filesystem";
          compactor_ring.kvstore.store = "inmemory";
        };
      };
    };
    
    # === BACKUP SERVICES ===
    
    # Restic backup
    services.restic.backups = mkIf config.profiles.server.services.backup.restic.enable {
      # Example backup configuration
      # Uncomment and configure as needed
      # daily = {
      #   paths = [ "/var/lib" "/home" ];
      #   repository = "sftp:backup@backup.example.com:/backups";
      #   passwordFile = "/etc/nixos/secrets/restic-password";
      #   timerConfig = {
      #     OnCalendar = "daily";
      #   };
      # };
    };
    
    # === SYSTEM OPTIMIZATION ===
    
    # Automatic system updates
    system.autoUpgrade = mkIf config.profiles.server.optimization.autoUpgrade {
      enable = true;
      flake = "/etc/nixos";
      dates = "weekly";
      allowReboot = false;  # Set to true for unattended reboots
    };
    
    # Automatic garbage collection
    nix.gc = mkIf config.profiles.server.optimization.autoGC {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    
    # Optimize nix store
    nix.settings.auto-optimise-store = true;
    
    # Server-optimized kernel parameters
    boot.kernel.sysctl = {
      # Network optimization
      "net.core.rmem_max" = 134217728;
      "net.core.wmem_max" = 134217728;
      "net.ipv4.tcp_rmem" = "4096 87380 67108864";
      "net.ipv4.tcp_wmem" = "4096 65536 67108864";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
      
      # Connection tracking
      "net.netfilter.nf_conntrack_max" = 262144;
      
      # File handles
      "fs.file-max" = 2097152;
      
      # Swap behavior (minimize swap usage)
      "vm.swappiness" = 10;
    };
    
    # Enable BBR TCP congestion control
    boot.kernelModules = [ "tcp_bbr" ];
    
    # Firewall configuration
    networking.firewall = {
      enable = true;
      allowPing = true;
      
      # SSH port
      allowedTCPPorts = mkIf config.profiles.server.services.ssh.enable 
        [ config.profiles.server.services.ssh.port ];
    };
    
    # Limit systemd journal size
    services.journald.extraConfig = ''
      SystemMaxUse=500M
      MaxRetentionSec=7day
    '';
    
    # Disable power-saving (for servers)
    powerManagement = {
      enable = false;
      cpuFreqGovernor = "performance";
    };
    
    # === SECURITY HARDENING ===
    
    # Fail2ban for SSH protection
    services.fail2ban = mkIf config.profiles.server.services.ssh.enable {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      
      jails = {
        sshd = ''
          enabled = true
          port = ${toString config.profiles.server.services.ssh.port}
        '';
      };
    };
    
    # AppArmor security
    security.apparmor.enable = true;
    
    # Disable unnecessary services
    services.printing.enable = false;
    services.avahi.enable = false;
    sound.enable = false;
    hardware.pulseaudio.enable = false;
  };
}
