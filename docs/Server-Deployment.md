# Server Deployment Guide

Deploy **headless NixOS servers** for your homelab or Proxmox environment.

---

## Overview

The server profile enables you to run **minimal, optimized NixOS servers** with:
- ✅ No GUI (headless)
- ✅ SSH-only access
- ✅ Role-specific configurations (web, database, docker, monitoring)
- ✅ Automated security hardening
- ✅ Declarative service management

Perfect for: Proxmox VMs, cloud instances, bare-metal servers, home lab

---

## Quick Start

### 1. Create Server Configuration

```nix
# hosts/my-server/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/profiles
    ../../modules/system/network.nix
    ../../modules/system/security.nix
  ];

  profiles = {
    base.enable = true;
    server = {
      enable = true;
      role = "web";  # or database, docker, monitoring
      
      services = {
        ssh.enable = true;
        webserver.enable = true;
        docker.enable = true;
      };
    };
  };

  networking.hostName = "my-server";
  system.stateVersion = "24.11";

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3... your-key"
    ];
  };
}
```

### 2. Deploy

```bash
# Build locally
sudo nixos-rebuild build --flake .#my-server

# Deploy to remote server
nixos-rebuild switch --flake .#my-server --target-host admin@192.168.1.100 --use-remote-sudo
```

---

## Server Roles

### General Purpose Server

Minimal server with SSH and monitoring.

```nix
profiles.server = {
  enable = true;
  role = "general";
  
  services.ssh.enable = true;
};
```

**Use cases**: Jump box, bastion host, minimal VM

### Web Server

Nginx reverse proxy with SSL automation.

```nix
profiles.server = {
  enable = true;
  role = "web";
  
  services = {
    ssh.enable = true;
    webserver = {
      enable = true;
      acme = true;  # Let's Encrypt
    };
    docker.enable = true;
  };
};

# Configure virtual hosts
services.nginx.virtualHosts."example.com" = {
  enableACME = true;
  forceSSL = true;
  locations."/" = {
    proxyPass = "http://localhost:3000";
  };
};
```

**Use cases**: Reverse proxy, web hosting, API gateway

### Database Server

PostgreSQL and Redis with backup automation.

```nix
profiles.server = {
  enable = true;
  role = "database";
  
  services = {
    ssh.enable = true;
    database = {
      postgresql.enable = true;
      redis.enable = true;
    };
    backup.restic.enable = true;
  };
};
```

**Use cases**: Application database, caching layer

### Docker Host

Dedicated container runtime with Portainer UI.

```nix
profiles.server = {
  enable = true;
  role = "docker";
  
  services = {
    ssh.enable = true;
    docker = {
      enable = true;
      portainer = true;  # Web UI on :9443
    };
  };
};
```

**Use cases**: Microservices, containerized apps, CI/CD runners

### Monitoring Server

Prometheus, Grafana, and Loki for observability.

```nix
profiles.server = {
  enable = true;
  role = "monitoring";
  
  services = {
    ssh.enable = true;
    monitoring = {
      prometheus.enable = true;
      grafana.enable = true;
      loki.enable = true;
      node-exporter.enable = true;
    };
  };
};
```

**Use cases**: Infrastructure monitoring, log aggregation, alerting

### Storage Server

NFS and Samba file sharing.

```nix
profiles.server = {
  enable = true;
  role = "storage";
  
  services = {
    ssh.enable = true;
    storage = {
      nfs.enable = true;
      samba.enable = true;
    };
  };
};
```

**Use cases**: Shared storage, backup destination, media server

---

## Security Configuration

### SSH Hardening

```nix
profiles.server.services.ssh = {
  enable = true;
  passwordAuth = false;  # Key-based only
  port = 2222;           # Non-standard port
};

users.users.admin.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3Nza... user@laptop"
];
```

**Server profile automatically configures**:
- ✅ Protocol 2 only
- ✅ MaxAuthTries 3
- ✅ Strong ciphers (ChaCha20, AES256-GCM)
- ✅ No root login
- ✅ No X11 forwarding
- ✅ Fail2ban protection

### Firewall

```nix
networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 ];
  allowedUDPPorts = [ ];
  
  # Allow specific IPs only
  extraCommands = ''
    iptables -A nixos-fw -s 192.168.1.0/24 -j nixos-fw-accept
  '';
};
```

### AppArmor

Automatically enabled on servers for mandatory access control.

### Automatic Security Updates

```nix
profiles.server.optimization.autoUpgrade = true;

# Or manual control:
system.autoUpgrade = {
  enable = true;
  flake = "/etc/nixos";
  dates = "weekly";
  allowReboot = false;  # Set true for unattended
};
```

---

## Networking

### Static IP (Proxmox/VMware)

```nix
networking = {
  hostName = "web-server";
  domain = "lab.local";
  
  interfaces.ens18 = {
    ipv4.addresses = [{
      address = "192.168.1.100";
      prefixLength = 24;
    }];
  };
  
  defaultGateway = "192.168.1.1";
  nameservers = [ "1.1.1.1" "8.8.8.8" ];
};
```

### DHCP

```nix
networking = {
  hostName = "my-server";
  useDHCP = true;
};
```

### Multiple Interfaces

```nix
networking.interfaces = {
  ens18 = {  # Management
    ipv4.addresses = [{
      address = "192.168.1.100";
      prefixLength = 24;
    }];
  };
  
  ens19 = {  # Data network
    ipv4.addresses = [{
      address = "10.0.0.100";
      prefixLength = 24;
    }];
  };
};
```

---

## Service Configuration

### Web Server (Nginx)

#### Simple Reverse Proxy

```nix
services.nginx.virtualHosts."app.example.com" = {
  enableACME = true;
  forceSSL = true;
  
  locations."/" = {
    proxyPass = "http://localhost:3000";
    proxyWebsockets = true;
  };
};
```

#### Multiple Apps

```nix
services.nginx.virtualHosts = {
  "app1.example.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:3000";
  };
  
  "app2.example.com" = {
    enableACME = true;
    forceSSL = true;
    locations."/".proxyPass = "http://localhost:4000";
  };
};
```

#### Static Files

```nix
services.nginx.virtualHosts."static.example.com" = {
  enableACME = true;
  forceSSL = true;
  root = "/var/www/static";
};
```

### PostgreSQL

#### Basic Setup

```nix
services.postgresql = {
  enable = true;
  package = pkgs.postgresql_16;
  
  ensureDatabases = [ "myapp" ];
  ensureUsers = [{
    name = "myapp";
    ensureDBOwnership = true;
  }];
};
```

#### Performance Tuning

```nix
services.postgresql.settings = {
  shared_buffers = "4GB";
  effective_cache_size = "12GB";
  work_mem = "64MB";
  maintenance_work_mem = "1GB";
  max_connections = 200;
  
  # Logging
  log_statement = "all";
  log_duration = true;
};
```

#### Backups

```nix
services.postgresqlBackup = {
  enable = true;
  location = "/var/backup/postgresql";
  startAt = "*-*-* 02:00:00";  # 2 AM daily
  databases = [ "myapp" ];
};
```

### Docker

#### Auto-Prune

```nix
virtualisation.docker.autoPrune = {
  enable = true;
  dates = "daily";
  flags = [ "--all" "--volumes" ];
};
```

#### Storage Driver

```nix
virtualisation.docker.storageDriver = "overlay2";
```

#### Docker Compose

```nix
environment.systemPackages = [ pkgs.docker-compose ];

# Or use NixOS containers instead:
virtualisation.oci-containers.containers.myapp = {
  image = "nginx:latest";
  ports = [ "8080:80" ];
  volumes = [ "/data:/usr/share/nginx/html" ];
};
```

### Monitoring

#### Prometheus Scraping

```nix
services.prometheus.scrapeConfigs = [
  {
    job_name = "node";
    static_configs = [{
      targets = [
        "192.168.1.100:9100"  # web-server
        "192.168.1.101:9100"  # docker-host
        "192.168.1.102:9100"  # db-server
      ];
    }];
  }
  
  {
    job_name = "postgres";
    static_configs = [{
      targets = [ "192.168.1.102:9187" ];
    }];
  }
];
```

#### Grafana Dashboards

```nix
services.grafana = {
  enable = true;
  
  provision = {
    enable = true;
    datasources.settings.datasources = [{
      name = "Prometheus";
      type = "prometheus";
      url = "http://localhost:9090";
      isDefault = true;
    }];
  };
};
```

---

## Proxmox Integration

### Create NixOS VM in Proxmox

1. **Download NixOS ISO**
   ```bash
   cd /var/lib/vz/template/iso
   wget https://channels.nixos.org/nixos-24.11/latest-nixos-minimal-x86_64-linux.iso
   ```

2. **Create VM** (Web UI or CLI)
   ```bash
   qm create 100 --name nixos-web --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
   qm set 100 --ide2 local:iso/nixos-24.11-minimal-x86_64.iso,media=cdrom
   qm set 100 --scsi0 local-lvm:32
   qm set 100 --boot order=scsi0
   ```

3. **Install NixOS** (see [Installation Guide](Installation.md))

4. **Configure for Proxmox**
   ```nix
   # hosts/proxmox-vm/hardware-configuration.nix
   boot.loader.grub.device = "/dev/sda";
   
   # Virtio drivers
   boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" ];
   
   # Qemu guest agent
   services.qemu-guest-agent.enable = true;
   ```

### Clone VM Template

1. **Create template VM** with base NixOS + SSH
2. **Convert to template** in Proxmox
3. **Clone** for new servers
4. **Customize** via flake configuration

```bash
# Clone template
qm clone 100 101 --name web-server

# Start and customize
qm start 101
ssh admin@192.168.1.100
sudo nano /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

---

## Deployment Methods

### Local Build

Build on your laptop, deploy to server:

```bash
# Build locally
nix build .#nixosConfigurations.web-server.config.system.build.toplevel

# Copy to server
scp ./result admin@192.168.1.100:/tmp/new-system

# Activate on server
ssh admin@192.168.1.100
sudo nix-env --profile /nix/var/nix/profiles/system --set /tmp/new-system
sudo /tmp/new-system/bin/switch-to-configuration switch
```

### Remote Build

Build and activate remotely:

```bash
nixos-rebuild switch \
  --flake .#web-server \
  --target-host admin@192.168.1.100 \
  --use-remote-sudo \
  --build-host admin@192.168.1.100
```

### CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy Servers

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v22
      
      - name: Build configuration
        run: |
          nix build .#nixosConfigurations.web-server.config.system.build.toplevel
      
      - name: Deploy to server
        run: |
          nixos-rebuild switch \
            --flake .#web-server \
            --target-host ${{ secrets.SERVER_HOST }} \
            --build-host localhost
```

---

## Backup Strategies

### Restic (Recommended)

```nix
services.restic.backups.daily = {
  paths = [ "/var/lib" "/home" "/etc/nixos" ];
  repository = "s3:s3.amazonaws.com/my-backups";
  passwordFile = "/run/secrets/restic-password";
  
  environmentFile = "/run/secrets/restic-env";  # AWS credentials
  
  pruneOpts = [
    "--keep-daily 7"
    "--keep-weekly 4"
    "--keep-monthly 6"
  ];
  
  timerConfig = {
    OnCalendar = "daily";
    Persistent = true;
  };
};
```

### Database Backups

```nix
# PostgreSQL
services.postgresqlBackup = {
  enable = true;
  location = "/var/backup/postgresql";
  startAt = "02:00";
};

# Then backup /var/backup with Restic
```

### Config Backup (Git)

```bash
# Commit configuration changes
cd /etc/nixos
git add .
git commit -m "Update web server config"
git push
```

---

## Monitoring Setup

### Complete Stack

```nix
# monitoring-server configuration
profiles.server.services.monitoring = {
  prometheus.enable = true;
  grafana.enable = true;
  loki.enable = true;
};

# On each server
profiles.server.services.monitoring.node-exporter.enable = true;

# Firewall rules
networking.firewall.allowedTCPPorts = [
  3000   # Grafana
  9090   # Prometheus
  3100   # Loki
];
```

### Alerting

```nix
services.prometheus.alertmanagers = [{
  static_configs = [{
    targets = [ "localhost:9093" ];
  }];
}];

services.prometheus.rules = [
  ''
    groups:
      - name: example
        rules:
          - alert: InstanceDown
            expr: up == 0
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Instance {{ $labels.instance }} down"
  ''
];
```

---

## Troubleshooting

### SSH Access Issues

```bash
# Check SSH service
systemctl status sshd

# Check firewall
nix-shell -p nmap --run "nmap -p 22 localhost"

# Test from another machine
ssh -v admin@192.168.1.100
```

### Service Not Starting

```bash
# Check service status
systemctl status nginx

# View logs
journalctl -u nginx -f

# Check configuration
nixos-rebuild build --flake .#web-server
```

### Network Issues

```bash
# Check IP configuration
ip addr show

# Test connectivity
ping 192.168.1.1

# Check DNS
dig example.com

# Firewall rules
iptables -L -n -v
```

### Disk Space

```bash
# Check usage
df -h
du -sh /nix/store

# Clean old generations
nix-collect-garbage -d
```

---

## Best Practices

1. **Use SSH Keys** - Never enable password auth
2. **Automated Backups** - restic + offsite storage
3. **Monitoring** - Prometheus + Grafana for all servers
4. **Firewall** - Only open required ports
5. **Updates** - Weekly manual updates (production) or automated (homelab)
6. **Secrets** - Use sops-nix, never commit passwords
7. **Documentation** - Comment your configurations
8. **Git** - Version control all configs
9. **Testing** - Use `nixos-rebuild test` before `switch`
10. **Rollback** - Keep boot menu accessible for recovery

---

## Example: Full Homelab Setup

See [Homelab Guide](Homelab-Guide.md) for complete multi-server architecture with:
- Web server (reverse proxy)
- Docker host (containers)
- Database server (PostgreSQL/Redis)
- Monitoring server (Prometheus/Grafana)
- Storage server (NFS/Samba)

All managed from **one flake configuration**.

---

## Next Steps

- [Profile System](Profile-System.md) - Understanding profiles
- [Homelab Guide](Homelab-Guide.md) - Multi-server architecture
- [Secrets Management](../modules/system/secrets.nix) - Using sops-nix
- [Troubleshooting](Troubleshooting.md) - Common issues

Deploy your first server today! 🚀
