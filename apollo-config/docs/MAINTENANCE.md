# Maintenance Guide

Day-to-day operations for your NixOS home server.

---

## Routine Tasks

### Update all packages

```bash
cd /etc/nixos
nix flake update          # update nixpkgs + home-manager + other inputs
sudo nixos-rebuild dry-build --flake .#apollo   # verify it builds
sudo nixos-rebuild switch --flake .#apollo       # apply
```

The `dry-build` step is optional but recommended — it catches build errors
before they affect running services.

### Check system status

```bash
# NixOS generations
sudo nixos-rebuild list-generations

# Service health
systemctl status postgresql redis nginx tailscaled plex

# Container health
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Disk usage
df -h /mnt/das1 /mnt/elements /mnt/music_usb /

# Memory
free -h

# Recent errors
journalctl -p err -n 50 --no-pager
```

### Clean up old generations

NixOS keeps all previous system generations. This fills disk over time.

```bash
# Delete generations older than 30 days (configured automatically in default.nix)
sudo nix-collect-garbage --delete-older-than 30d

# Or manually: keep only the last 5 generations
sudo nixos-rebuild switch --flake .#apollo
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5
sudo nix-collect-garbage
```

The automatic GC in `default.nix` handles this weekly, but you can run it
manually if `/nix/store` grows large.

### Optimize the store

```bash
# Hard-link identical files (configured automatically)
nix store optimise

# Check store size
du -sh /nix/store
```

---

## Service Management

### Restart a native service

```bash
sudo systemctl restart postgresql
sudo systemctl restart nginx
sudo systemctl restart plex
sudo systemctl restart ollama
```

### Restart a container

```bash
# Restart a single container
podman restart sonarr_en

# View container logs
podman logs -f sonarr_en
podman logs --tail 100 sonarr_en

# Check container health
podman inspect sonarr_en --format '{{.State.Health.Status}}'
```

### Rebuild after config change

```bash
# Edit any .nix file, then:
sudo nixos-rebuild switch --flake /etc/nixos#apollo

# Only changed services/containers are restarted.
# Containers with unchanged config keep running.
```

### Add a new container image

Edit the relevant category file, add the container definition, rebuild:

```bash
# Example: add lidarr_es
# Edit media.nix, add the container block
sudo nixos-rebuild switch --flake /etc/nixos#apollo
```

---

## Monitoring

### Grafana dashboards

Access at `http://apollo.<tailnet>/grafana`. Default credentials:
- User: `admin`
- Password: set in `monitoring.nix` → `services.grafana.settings.security.admin_password`

Pre-configured datasource: Prometheus (localhost:9090).

### Key metrics to watch

| Panel | What to watch |
|-------|---------------|
| Node memory | Should stay under 90% |
| Node disk | `/mnt/das1` usage — currently at 94%, monitor closely |
| PostgreSQL | Connection count, query latency |
| nginx | Request rate, 4xx/5xx errors |

### Alerting

Prometheus alert rules are defined in `monitoring.nix`:
- **HighMemoryUsage**: > 90% for 10 minutes
- **HighDiskUsage**: `/mnt/das1` > 95% for 10 minutes

Alerts appear in Grafana under the Alerting panel.

### Gotify notifications

Push notification server at `http://apollo.<tailnet>/gotify`.
Connect Gotify to your monitoring and services for push alerts to your phone.

---

## Disk Space Management

### Check what's using space

```bash
# Storage mounts
df -h /mnt/*

# Nix store
du -sh /nix/store
nix store gc --dry-run    # see what would be deleted

# Container images
podman images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Container volumes
du -sh /var/lib/containers/*
```

### Clean up container images

```bash
# Remove unused images
podman image prune -a

# Remove stopped containers
podman container prune
```

### Free space on /mnt/das1 (94% full)

The largest consumers are typically:
- `mediaserver/movies/` — Plex/Radarr movie library
- `mediaserver/tvshows/` — Plex/Sonarr TV library
- `immich/` — Photo/video library (grows constantly)
- `paperless-ngx/media/` — Document archive

Consider adding more storage or pruning old/unwatched media.

---

## Secrets Management

Secrets are currently marked as `___SECRET_MANAGED___` placeholders.

### Recommended: sops-nix

```bash
# Add to flake.nix inputs:
sops-nix.url = "github:Mic92/sops-nix";

# Create secrets file:
sops secrets.yaml

# Reference in config:
sops.secrets."vpn_password" = { };
services.someService.passwordFile = config.sops.secrets."vpn_password".path;
```

### Fallback: manual files

If not using sops-nix yet, store secrets in `/run/secrets/`:

```bash
sudo mkdir -p /run/secrets
echo "my-password" | sudo tee /run/secrets/db-password
sudo chmod 600 /run/secrets/db-password
```

Then reference in configs:
```nix
services.postgresql.initialScript = pkgs.writeText "init.sql" ''
  ALTER USER immich PASSWORD 'real-password-from-secrets';
'';
```

---

## Backup Strategy

### What to back up

| Path | Contents | Priority |
|------|----------|----------|
| `/mnt/das1/` | All media, photos, documents | HIGH |
| `/var/lib/postgresql/` | Database data | HIGH |
| `/var/lib/containers/config/` | Container configurations | MEDIUM |
| `/home/jpolo/` | User data, configs | MEDIUM |
| `/etc/nixos/` | NixOS config (should be in git!) | HIGH |
| `/nix/store/` | Can be rebuilt, don't back up | NONE |

### Quick backup

```bash
# Database dumps (run weekly via systemd timer)
sudo -u postgres pg_dumpall > /mnt/das1/backup/postgres_all_$(date +%Y%m%d).sql

# Config backup
sudo rsync -a /etc/nixos/ /mnt/das1/backup/nixos/

# Git push (if your config is in a repo)
cd /etc/nixos && git add -A && git commit -m "backup $(date)" && git push
```

### Restore from backup

```bash
# Restore PostgreSQL
sudo -u postgres psql < /mnt/das1/backup/postgres_all_20260101.sql

# Restore config from git
cd /etc/nixos && git pull
sudo nixos-rebuild switch --flake .#apollo
```

---

## Troubleshooting

### Container won't start

```bash
# Check why
podman logs <container-name> --tail 50
podman inspect <container-name> | jq '.[0].State'

# Check if port is in use
sudo ss -tlnp | grep <port>

# Check dependencies
podman ps -a --format "{{.Names}} {{.Status}}"
```

### Service won't start

```bash
# Check the unit status
systemctl status <service>
journalctl -u <service> -n 50 --no-pager

# Check for config errors
sudo nixos-rebuild dry-build --flake .#apollo 2>&1 | head -50
```

### Gluetun VPN not connecting

```bash
podman logs gluetun --tail 100
# Check NordVPN credentials
# Verify /dev/net/tun exists: ls -la /dev/net/tun
```

### nginx returns 502 (bad gateway)

The backend service is down or not listening on the expected port:

```bash
# Check if backend is listening
sudo ss -tlnp | grep <backend-port>

# Check nginx error log
sudo journalctl -u nginx -n 20 --no-pager
```

### Podman container can't reach host services

Containers reach host services via `host.containers.internal`:

```bash
# From inside a container:
podman exec <container> curl http://host.containers.internal:5432

# If it fails, check the service is listening on 127.0.0.1:
sudo ss -tlnp | grep 5432
```

### Drive didn't mount (booted without USB drive)

`nofail` prevents boot hang. To mount after boot:

```bash
sudo mount /mnt/das1
sudo mount /mnt/elements
sudo mount /mnt/music_usb

# Then restart services that depend on them:
sudo systemctl restart plex
podman restart sonarr_en radarr_en bazarr komga  # etc.
```

---

## Quick Commands Reference

```bash
# System
sudo nixos-rebuild switch --flake /etc/nixos#apollo  # apply config
sudo nixos-rebuild test --flake /etc/nixos#apollo     # test without making boot default
sudo nixos-rebuild dry-build --flake /etc/nixos#apollo # verify only
sudo nixos-rebuild list-generations                    # show generations

# Garbage collection
sudo nix-collect-garbage --delete-older-than 30d
nix store optimise

# Containers
podman ps                        # running containers
podman ps -a                     # all containers
podman logs -f <name>            # follow logs
podman restart <name>            # restart one
podman exec -it <name> sh        # shell into container

# Services
systemctl status <service>
journalctl -u <service> -f       # follow service logs
journalctl -p err -n 50          # recent errors

# Flake
nix flake update                 # update all inputs
nix flake lock --update-input nixpkgs  # update just nixpkgs
```
