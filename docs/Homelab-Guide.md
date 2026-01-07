# Homelab Architecture Guide

Build a **complete homelab infrastructure** using Proxmox and NixOS with declarative configurations.

---

## Architecture Overview

```
┌───────────────────────────────────────────────────────────────┐
│                    Proxmox Host (192.168.1.10)                │
│                                                                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ web-server (192.168.1.100) - 2GB RAM, 2 CPU, 32GB     │  │
│  │ ├─ Nginx (reverse proxy)                               │  │
│  │ ├─ Docker (app containers)                             │  │
│  │ ├─ Portainer (container UI)                            │  │
│  │ └─ ACME/Let's Encrypt (SSL)                            │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ docker-host (192.168.1.101) - 4GB RAM, 4 CPU, 64GB    │  │
│  │ ├─ Docker daemon                                       │  │
│  │ ├─ Microservices                                       │  │
│  │ └─ CI/CD runners                                       │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ database-server (192.168.1.102) - 4GB RAM, 2 CPU, 64GB│  │
│  │ ├─ PostgreSQL 16                                       │  │
│  │ ├─ Redis                                               │  │
│  │ └─ Automated backups (restic)                          │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ monitoring (192.168.1.103) - 2GB RAM, 2 CPU, 32GB     │  │
│  │ ├─ Prometheus (metrics collector)                      │  │
│  │ ├─ Grafana (dashboards)                                │  │
│  │ ├─ Loki (log aggregation)                              │  │
│  │ └─ Alert Manager                                       │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ storage-server (192.168.1.104) - 2GB RAM, 2 CPU, 500GB│  │
│  │ ├─ NFS server                                          │  │
│  │ ├─ Samba/SMB shares                                    │  │
│  │ └─ Backup destination                                  │  │
│  └────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
            │
            ├─ Router/Firewall (192.168.1.1)
            └─ Internet
```

---

## Infrastructure Components

### 1. Web Server (Entry Point)

**Purpose**: Reverse proxy, SSL termination, public-facing services

**Specs**: 2GB RAM, 2 CPU cores, 32GB disk

**Services**:
- Nginx reverse proxy
- Docker (for web apps)
- Portainer (container management UI)
- ACME (automatic SSL certificates)
- Fail2ban (security)

**Incoming Traffic**:
- HTTP (80) → HTTPS redirect
- HTTPS (443) → Application backends
- SSH (22) → Admin access

### 2. Docker Host (Application Runtime)

**Purpose**: Dedicated container platform for microservices

**Specs**: 4GB RAM, 4 CPU cores, 64GB disk

**Services**:
- Docker daemon (overlay2 storage)
- Portainer agent
- Container monitoring
- Auto-pruning

**Containers**:
- Web applications
- APIs
- Background workers
- CI/CD runners

### 3. Database Server (Data Layer)

**Purpose**: Centralized database for applications

**Specs**: 4GB RAM, 2 CPU cores, 64GB disk

**Services**:
- PostgreSQL 16 (primary database)
- Redis (caching, sessions)
- Automated backups (daily)
- Performance monitoring

**Data**:
- Application databases
- User data
- Session storage
- Cache layer

### 4. Monitoring Server (Observability)

**Purpose**: Metrics, logs, and dashboards for entire infrastructure

**Specs**: 2GB RAM, 2 CPU cores, 32GB disk

**Services**:
- Prometheus (metrics database)
- Grafana (visualization)
- Loki (log aggregation)
- Alertmanager (notifications)

**Monitoring**:
- CPU, RAM, disk usage
- Network traffic
- Service health
- Application metrics
- Logs from all servers

### 5. Storage Server (File Sharing)

**Purpose**: Centralized storage, backups, media

**Specs**: 2GB RAM, 2 CPU cores, 500GB disk

**Services**:
- NFS (network file system)
- Samba (Windows sharing)
- Backup destination

**Shares**:
- User home directories
- Media files
- Backup archives
- Docker volumes

---

## Network Architecture

### IP Addressing

| Server | IP | Purpose |
|--------|-----|---------|
| Router | 192.168.1.1 | Gateway |
| Proxmox | 192.168.1.10 | Hypervisor |
| Web Server | 192.168.1.100 | Public entry |
| Docker Host | 192.168.1.101 | Containers |
| Database | 192.168.1.102 | Data layer |
| Monitoring | 192.168.1.103 | Observability |
| Storage | 192.168.1.104 | File shares |

### Port Map

**Web Server (192.168.1.100)**:
- 22 (SSH)
- 80 (HTTP → redirect to 443)
- 443 (HTTPS)
- 9443 (Portainer UI)

**Docker Host (192.168.1.101)**:
- 22 (SSH)
- 9443 (Portainer agent)

**Database Server (192.168.1.102)**:
- 22 (SSH)
- 5432 (PostgreSQL)
- 6379 (Redis)

**Monitoring Server (192.168.1.103)**:
- 22 (SSH)
- 3000 (Grafana)
- 9090 (Prometheus)
- 3100 (Loki)

**Storage Server (192.168.1.104)**:
- 22 (SSH)
- 2049 (NFS)
- 445 (SMB)

### Firewall Rules

```
Internet → Router (192.168.1.1)
  └─> Port forward 443 → Web Server (192.168.1.100:443)
  └─> Port forward 22 → Web Server (192.168.1.100:22)

Internal Network (192.168.1.0/24)
  └─> All servers can communicate
  └─> Monitoring server scrapes all node exporters (:9100)
```

---

## Configuration Repository

### Directory Structure

```
nix-omarchy/nix/
├── flake.nix                   # Defines all hosts
├── hosts/
│   ├── web-server/
│   │   ├── configuration.nix   # Server config
│   │   └── hardware-configuration.nix
│   ├── docker-host/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── database-server/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── monitoring-server/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── storage-server/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/
│   └── profiles/
│       └── server.nix          # Server profile
└── secrets/
    └── homelab.yaml            # Encrypted secrets
```

### Flake Configuration

```nix
# flake.nix
{
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      web-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/web-server/configuration.nix ];
      };
      
      docker-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/docker-host/configuration.nix ];
      };
      
      database-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/database-server/configuration.nix ];
      };
      
      monitoring-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/monitoring-server/configuration.nix ];
      };
      
      storage-server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/storage-server/configuration.nix ];
      };
    };
  };
}
```

---

## Deployment Workflow

### 1. Initial Setup

```bash
# Clone configuration repo
git clone https://github.com/yourusername/nix-omarchy.git
cd nix-omarchy/nix

# Create server configurations
cp hosts/web-server-example.nix hosts/web-server/configuration.nix

# Generate hardware configs for each VM
# (Boot from NixOS ISO in Proxmox, install, generate config)
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/web-server/
```

### 2. Build Configurations

```bash
# Build all servers
nix build .#nixosConfigurations.web-server.config.system.build.toplevel
nix build .#nixosConfigurations.docker-host.config.system.build.toplevel
nix build .#nixosConfigurations.database-server.config.system.build.toplevel
nix build .#nixosConfigurations.monitoring-server.config.system.build.toplevel
nix build .#nixosConfigurations.storage-server.config.system.build.toplevel

# Check for errors
nix flake check
```

### 3. Deploy to Servers

```bash
# Deploy web server
nixos-rebuild switch --flake .#web-server \
  --target-host admin@192.168.1.100 \
  --use-remote-sudo

# Deploy all servers (script)
for host in web-server docker-host database-server monitoring-server storage-server; do
  echo "Deploying $host..."
  nixos-rebuild switch --flake .#$host \
    --target-host admin@$host \
    --use-remote-sudo
done
```

### 4. Verify Deployment

```bash
# SSH to each server
ssh admin@192.168.1.100  # web-server
systemctl status nginx

ssh admin@192.168.1.101  # docker-host
docker ps

ssh admin@192.168.1.102  # database-server
sudo -u postgres psql -c "SELECT version();"

ssh admin@192.168.1.103  # monitoring-server
curl http://localhost:9090/-/healthy

ssh admin@192.168.1.104  # storage-server
showmount -e localhost
```

---

## Common Workflows

### Adding a New Service

Example: Deploy a web application

1. **Create Docker container on docker-host**:

```nix
# hosts/docker-host/configuration.nix
virtualisation.oci-containers.containers.myapp = {
  image = "myapp:latest";
  ports = [ "3000:3000" ];
  environment = {
    DATABASE_URL = "postgresql://myapp@192.168.1.102/myapp";
    REDIS_URL = "redis://192.168.1.102:6379";
  };
};
```

2. **Add nginx reverse proxy on web-server**:

```nix
# hosts/web-server/configuration.nix
services.nginx.virtualHosts."myapp.example.com" = {
  enableACME = true;
  forceSSL = true;
  locations."/" = {
    proxyPass = "http://192.168.1.101:3000";
  };
};
```

3. **Create database on database-server**:

```nix
# hosts/database-server/configuration.nix
services.postgresql = {
  ensureDatabases = [ "myapp" ];
  ensureUsers = [{
    name = "myapp";
    ensureDBOwnership = true;
  }];
};
```

4. **Deploy changes**:

```bash
nixos-rebuild switch --flake .#web-server --target-host admin@192.168.1.100 --use-remote-sudo
nixos-rebuild switch --flake .#docker-host --target-host admin@192.168.1.101 --use-remote-sudo
nixos-rebuild switch --flake .#database-server --target-host admin@192.168.1.102 --use-remote-sudo
```

### Scaling Services

**Add more Docker hosts**:

```nix
# flake.nix - add new host
docker-host-2 = nixpkgs.lib.nixosSystem {
  modules = [ ./hosts/docker-host-2/configuration.nix ];
};
```

**Load balance with nginx**:

```nix
# hosts/web-server/configuration.nix
services.nginx.upstreams.myapp = {
  servers = {
    "192.168.1.101:3000" = {};
    "192.168.1.105:3000" = {};  # new host
  };
};

services.nginx.virtualHosts."myapp.example.com".locations."/" = {
  proxyPass = "http://myapp";
};
```

### Backup Strategy

**Database backups** (database-server):

```nix
services.postgresqlBackup = {
  enable = true;
  location = "/mnt/backup/postgresql";
  startAt = "02:00";
};

# Sync to storage server
systemd.services.backup-sync = {
  script = ''
    ${pkgs.rsync}/bin/rsync -avz /mnt/backup/ admin@192.168.1.104:/exports/backups/
  '';
  startAt = "03:00";
};
```

**Config backups** (all servers):

```bash
# Automated git push
systemd.timers.config-backup = {
  wantedBy = [ "timers.target" ];
  timerConfig.OnCalendar = "daily";
};

systemd.services.config-backup = {
  script = ''
    cd /etc/nixos
    git add .
    git commit -m "Auto-backup $(date)"
    git push
  '';
};
```

---

## Monitoring Dashboard

### Grafana Setup

Access: `http://192.168.1.103:3000`

**Dashboards**:
1. **Infrastructure Overview**
   - All servers CPU/RAM/Disk
   - Network traffic
   - Service uptime

2. **Web Server**
   - Nginx request rate
   - Response times
   - SSL certificate expiry

3. **Docker Host**
   - Container status
   - Resource usage per container
   - Image sizes

4. **Database Server**
   - PostgreSQL connections
   - Query performance
   - Cache hit ratio (Redis)

5. **Application Metrics**
   - Custom app metrics
   - Error rates
   - User activity

### Alerts

```nix
# monitoring-server/configuration.nix
services.prometheus.rules = [
  ''
    groups:
      - name: infrastructure
        rules:
          - alert: ServerDown
            expr: up == 0
            for: 5m
            labels:
              severity: critical
          
          - alert: HighCPU
            expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
            for: 10m
            labels:
              severity: warning
          
          - alert: DiskSpaceLow
            expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) < 0.1
            for: 5m
            labels:
              severity: warning
  ''
];
```

---

## Disaster Recovery

### VM Snapshots (Proxmox)

```bash
# Create snapshot before changes
qm snapshot <vmid> pre-update

# Rollback if needed
qm rollback <vmid> pre-update
```

### NixOS Rollback

```bash
# Boot into previous generation
# (select in boot menu)

# Or via SSH
ssh admin@192.168.1.100
sudo nixos-rebuild switch --rollback
```

### Configuration Restore

```bash
# Clone from git
git clone https://github.com/yourusername/nix-omarchy.git

# Deploy
nixos-rebuild switch --flake .#web-server
```

### Data Restoration

```bash
# Restore PostgreSQL
ssh admin@192.168.1.102
sudo -u postgres psql myapp < /mnt/backup/postgresql/myapp.sql

# Restore from restic
restic -r s3:bucket/backup restore latest --target /
```

---

## Maintenance

### Updates

**Monthly updates**:

```bash
# Update flake inputs
cd nix-omarchy/nix
nix flake update

# Test on one server
nixos-rebuild build --flake .#web-server
nixos-rebuild test --flake .#web-server --target-host admin@192.168.1.100

# Deploy to all if successful
for host in web-server docker-host database-server monitoring-server storage-server; do
  nixos-rebuild switch --flake .#$host --target-host admin@$host --use-remote-sudo
done
```

### Cleanup

**Automatic** (configured in server profile):

```nix
profiles.server.optimization.autoGC = true;
```

**Manual**:

```bash
# On each server
ssh admin@192.168.1.100
sudo nix-collect-garbage -d

# Clean old docker images
docker system prune -a
```

---

## Cost & Resource Summary

**Total Resources**:
- RAM: 14 GB
- CPU: 12 cores
- Disk: 712 GB

**Typical Homelab Server** (example):
- CPU: AMD Ryzen 5 / Intel i5 (8-16 cores)
- RAM: 32-64 GB
- Storage: 1-2 TB SSD

This setup uses ~45% of a modest homelab server, leaving room for more VMs.

---

## Next Steps

1. **Deploy your first server** - Start with web-server
2. **Add monitoring** - Deploy monitoring-server
3. **Scale gradually** - Add services as needed
4. **Document changes** - Keep configs in git
5. **Automate backups** - Set up restic + offsite storage

For detailed setup instructions, see:
- [Server Deployment Guide](Server-Deployment.md)
- [Profile System](Profile-System.md)
- [Installation Guide](Installation.md)

Happy homelabbing! 🏠🖥️
