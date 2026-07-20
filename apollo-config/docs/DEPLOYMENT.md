# Deployment Guide

How to move from Ubuntu 24.04 + Docker to NixOS on your home server.

---

## Pre-Flight Checklist

Before touching the running server:

- [ ] **Back up all data** — especially `/mnt/das1/`, `/mnt/elements/`, and
      `/home/jpolo/` (docker-compose files, .env files, configs).
- [ ] **Dump all databases**:
  ```bash
  # For each postgres container, dump individually:
  pg_dump -h localhost -p 5432 -U immich immich > immich_dump.sql
  pg_dump -h localhost -p 5432 -U paperless paperless > paperless_dump.sql
  # ... repeat for mealie, nextcloud, dawarich

  # MariaDB (Firefly III):
  mysqldump -h localhost -u firefly firefly_iii > firefly_dump.sql
  ```
- [ ] **Export app configs** — many services store state in their config
      directories under `/home/jpolo/*/config/`. Copy these to backup.
- [ ] **Document secrets** — VPN credentials, Cloudflare tunnel token, API keys,
      database passwords. These go into sops-nix/agenix later.
- [ ] **Identify drive UUIDs**:
  ```bash
  lsblk -o name,uuid,mountpoint,size
  ```
  Update `storage.nix` with the real UUIDs.
- [ ] **Verify NixOS ISO** — download the latest NixOS 24.11 minimal ISO and
      write it to a USB stick. Boot it on the server to test hardware detection.

---

## Phase 1: Hardware Validation

Boot the NixOS live ISO and verify:

```bash
# Check all drives are detected
lsblk

# Generate initial hardware config
nixos-generate-config --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
```

Copy the generated `hardware-configuration.nix` to `nixos/`.

Verify it includes:
- NVMe root disk (`nvme0n1` or `/dev/sda`)
- USB storage devices (sdb, sdc, sdd)
- Intel GPU (i915 driver)
- Network interface (enp1s0)

---

## Phase 2: Install NixOS

1. **Partition** (keep your existing layout or use disko):
   ```bash
   # If keeping existing partitions, mount them:
   mount /dev/mapper/ubuntu--vg-ubuntu--lv /mnt
   mount /dev/sda2 /mnt/boot
   mount /dev/sda1 /mnt/boot/efi
   ```

2. **Clone your config** onto the live system:
   ```bash
   git clone <your-nixos-config-repo> /mnt/etc/nixos
   # Or copy from backup
   ```

3. **Edit `hardware-configuration.nix`** to match your disk layout.

4. **Install**:
   ```bash
   nixos-install --flake /mnt/etc/nixos#apollo
   ```

5. **Reboot** into NixOS.

---

## Phase 3: First Boot & Network

1. **SSH in** (if Tailscale not yet configured, use local console):
   ```bash
   ssh jpolo@<local-ip>
   ```

2. **Bring up Tailscale**:
   ```bash
   sudo tailscale up --hostname=apollo --advertise-tags=tag:server
   ```
   After authentication, your Tailscale IP should be the same (`100.114.69.83`).

3. **Verify nginx**:
   ```bash
   curl http://localhost:80  # should redirect to Homepage
   curl http://100.114.69.83:80/plex  # should proxy to Plex
   ```

4. **Set up Cloudflare tunnel**:
   - Create the tunnel in Cloudflare Zero Trust dashboard
   - Store the credentials JSON at `/run/secrets/cloudflared-tunnel.json`
   - Uncomment and configure the `services.cloudflared` block in `networking.nix`
   - Rebuild: `sudo nixos-rebuild switch --flake /etc/nixos#apollo`

---

## Phase 4: Database Migration

### PostgreSQL

1. **Start the shell**:
   ```bash
   sudo -u postgres psql
   ```

2. **For each database**, restore from the dump:
   ```bash
   sudo -u postgres psql -d immich < immich_dump.sql
   sudo -u postgres psql -d paperless < paperless_dump.sql
   # ... repeat for mealie, nextcloud, dawarich
   ```

3. **Set passwords** for each user:
   ```sql
   ALTER USER immich PASSWORD 'your-secure-password';
   ALTER USER paperless PASSWORD 'your-secure-password';
   -- ... etc
   ```

4. **Tighten authentication** in `databases.nix` after testing:
   ```nix
   authentication = pkgs.lib.mkOverride 10 ''
     local all all peer
     host  all all 127.0.0.1/32 scram-sha-256
   '';
   ```

### Redis

No data migration needed — Redis state is ephemeral or can be rebuilt.
Each app that needs Redis will reconnect and repopulate as needed.

### MariaDB (Firefly III)
```bash
sudo mysql -u root
CREATE DATABASE firefly_iii;
GRANT ALL PRIVILEGES ON firefly_iii.* TO 'firefly'@'localhost';
# Then restore:
sudo mysql -u firefly firefly_iii < firefly_dump.sql
```

### MongoDB (Overleaf, Anytype)
```bash
# Start mongo shell
mongosh
# Init replica set (handled by initialScript)
rs.initiate({_id: "overleaf", members: [{_id: 0, host: "127.0.0.1:27017"}]})
```

---

## Phase 5: Service Migration (by category)

Enable one category at a time and verify:

### databases.nix
```bash
sudo nixos-rebuild switch
systemctl status postgresql redis mysql mongodb
psql -h localhost -U immich -d immich -c "SELECT 1"
```

### media.nix
```bash
sudo nixos-rebuild switch
# Verify:
systemctl status plex
podman ps | grep -E "gluetun|qbittorrent|sonarr|radarr"
curl http://localhost:32400/web    # Plex
curl http://localhost:8989         # Sonarr
```

### productivity.nix
```bash
sudo nixos-rebuild switch
# Verify key services:
curl http://localhost:2283         # Immich
curl http://localhost:8222         # Vaultwarden
curl http://localhost:14000        # Paperless
```

### monitoring.nix
```bash
sudo nixos-rebuild switch
curl http://localhost:9090         # Prometheus
curl http://localhost:3000         # Grafana
curl http://localhost:10000        # Homepage
```

### development.nix
```bash
sudo nixos-rebuild switch
curl http://localhost:11434        # Ollama
curl http://localhost:5678         # n8n
```

---

## Phase 6: Verification

Test **every service** through both access paths:

```bash
# Tailscale access
curl http://apollo.<tailnet>.ts.net/plex
curl http://apollo.<tailnet>.ts.net/grafana
curl http://apollo.<tailnet>.ts.net/immich
# ... all services

# Cloudflare access (from external network or with curl -H)
curl -H "Host: n8n.javierpolo.com" http://localhost:80
curl -H "Host: overleaf.javierpolo.com" http://localhost:80
```

---

## Rollback

If something breaks:

```bash
# List available generations
sudo nixos-rebuild list-generations

# Roll back to previous generation
sudo nixos-rebuild switch --rollback

# Or to a specific generation
sudo nix-env -p /nix/var/nix/profiles/system --set /nix/var/nix/profiles/system-<N>-link
/nix/var/nix/profiles/system/bin/switch-to-configuration switch
```
