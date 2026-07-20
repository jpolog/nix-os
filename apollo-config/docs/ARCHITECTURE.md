# Architecture

## Design Philosophy

The configuration follows these NixOS best practices:

1. **Non-monolithic** — Each category is a self-contained `.nix` file that can be
   enabled or disabled by commenting a single import in `default.nix`.
2. **Hybrid service strategy** — Services with mature NixOS modules run natively
   (Plex, PostgreSQL, Immich, Ollama). Everything else runs as OCI containers
   via `virtualisation.oci-containers` with the Podman backend.
3. **Database consolidation** — One PostgreSQL instance with multiple databases
   instead of five separate containers. One Redis instance with multiple logical
   DBs instead of six. This saves significant RAM on a 16 GB system.
4. **Security by default** — All service ports are bound to `127.0.0.1`.
   External access goes through nginx (reverse proxy) → Tailscale or Cloudflare.
   The firewall blocks everything except 80/443 on WAN.
5. **Declarative everything** — No manual container starts, no cron jobs for
   updates, no watchtower. Everything is defined in Nix and applied atomically.

## Module Graph

```
flake.nix
  └── default.nix  (global settings, kernel, GPU, podman)
        ├── hardware-configuration.nix  (auto-generated, not in repo)
        ├── networking.nix  ──→ nginx routes ──→ all other modules
        │     (Tailscale, nginx, cloudflared, firewall)
        ├── storage.nix  (USB mounts, swap, tmpfiles)
        ├── databases.nix  (postgres, redis, mariadb, mongo)
        │     └── consumers: productivity.nix, media.nix, development.nix
        ├── users.nix  (accounts, home-manager)
        ├── media.nix  (Plex, gluetun, *arr stack)
        ├── productivity.nix  (Immich, Vaultwarden, Syncthing, Paperless…)
        ├── monitoring.nix  (Prometheus, Grafana, Scrutiny, Homepage)
        └── development.nix  (Ollama, n8n, Overleaf, Mermaid, Anytype)
```

**Dependency direction**: `default.nix` → category modules. Category modules
define services that depend on things from `databases.nix` and route through
`networking.nix`. No circular imports.

## Service Strategy Matrix

| Category | Service | Why |
|----------|---------|-----|
| **Native NixOS** | PostgreSQL, Redis | One instance, multiple DBs — saves RAM |
| **Native NixOS** | MariaDB | Firefly III needs MySQL dialect |
| **Native NixOS** | MongoDB | Overleaf needs replica sets |
| **Native NixOS** | Tailscale | Kernel-level WireGuard, zero-trust |
| **Native NixOS** | nginx | Unified proxy replaces 4 Caddy + 1 Traefik |
| **Native NixOS** | Plex | Direct GPU access, no container overhead |
| **Native NixOS** | Immich | Mature module, reduces 4 containers → 1 service |
| **Native NixOS** | Vaultwarden | Simple Rust binary, built-in |
| **Native NixOS** | Syncthing | System-level file sync |
| **Native NixOS** | Prometheus + Grafana | Declarative scrape configs |
| **Native NixOS** | Ollama | Direct GPU access for inference |
| | | |
| **OCI container** | gluetun + qBittorrent + Jackett | VPN sidecar requires NET_ADMIN + /dev/net/tun |
| **OCI container** | Sonarr / Radarr / Lidarr / etc. | No NixOS module; LinuxServer.io images are mature |
| **OCI container** | Paperless-ngx + Gotenberg + Tika | Complex multi-container with internal networking |
| **OCI container** | Nextcloud AIO | Upstream-recommended meta-container |
| **OCI container** | Overleaf / ShareLaTeX | Complex multi-container, dedicated mongo/redis |
| **OCI container** | n8n | Fast-moving project, container tracks upstream closely |
| **OCI container** | Anytype | Very complex pod with ~12 containers, config generators |

## VPN Sidecar Pattern

Torrent traffic MUST go through NordVPN. Instead of a separate Docker network:

```
gluetun container  ← owns /dev/net/tun, establishes OpenVPN
  ├── qbittorrent  ← network_mode: "container:gluetun"
  └── jackett      ← network_mode: "container:gluetun"
```

Ports (8080 for qBittorrent, 9117 for Jackett) are declared on the **gluetun**
container. The dependent containers share its network namespace but don't
declare their own ports — traffic enters through gluetun's tunnel interface.

## Reverse Proxy Architecture

nginx serves two roles in a single instance:

### Public virtualHosts (Cloudflare fronted)
```
mermaid.javierpolo.com    → 127.0.0.1:8080  (mermaid container)
overleaf.javierpolo.com   → 127.0.0.1:8081  (sharelatex container)
n8n.javierpolo.com        → 127.0.0.1:5678  (n8n container)
seerr.javierpolo.com      → 127.0.0.1:5055  (seerr container)
seerr-es.javierpolo.com   → 127.0.0.1:5056  (seerr_es container)
calibre.javierpolo.com    → 127.0.0.1:16083 (calibre-web container)
```
These listen on `127.0.0.1:80`. cloudflared connects to localhost:80 and
Cloudflare handles TLS termination.

### Tailscale path-based routing
```
apollo.<tailnet>.ts.net/           → Homepage dashboard
apollo.<tailnet>.ts.net/plex       → Plex
apollo.<tailnet>.ts.net/sonarr     → Sonarr
apollo.<tailnet>.ts.net/grafana    → Grafana
...
```
These listen on the Tailscale IP (`100.114.69.83:80`). No TLS needed —
Tailscale provides end-to-end WireGuard encryption.

## Database Consolidation

### PostgreSQL 16 databases
| Database | App | Extension |
|----------|-----|-----------|
| `immich` | Immich | pgvecto-rs, vectors |
| `paperless` | Paperless-ngx | — |
| `mealie` | Mealie | — |
| `nextcloud` | Nextcloud AIO | — |
| `dawarich` | Dawarich | postgis |

### Redis databases
| DB # | App |
|------|-----|
| 0 | Immich |
| 1 | Paperless-ngx |
| 2 | Dawarich |
| 3 | Overleaf |
| 4 | Anytype (reserved) |
| 5 | Dispatcharr |

## Firewall Model

```
WAN (enp1s0)
  ├── ALLOW: 80/tcp, 443/tcp  → nginx
  └── BLOCK: everything else

LAN
  └── BLOCK: all service ports  (Plex:32400, *arr:8989, Grafana:3000, etc.)

tailscale0
  └── TRUST: all ports  (full access for authenticated Tailscale devices)

localhost
  └── TRUST: all ports  (internal service communication)
```

All services bind to `127.0.0.1` (or container networks). The only way to
reach them is through nginx on Tailscale or Cloudflare.

## Why Podman (not Docker)

- **Daemonless** — no persistent dockerd consuming RAM
- **Rootless** — containers run as non-root users where possible
- **Systemd integration** — `podman generate systemd` for native units
- **NixOS native support** — `virtualisation.podman.enable = true`
- **docker-compatible socket** — tools like Portainer and Nextcloud AIO still work

## Update Flow

```
nix flake update              ← update nixpkgs + all inputs
nixos-rebuild dry-build       ← verify the build
nixos-rebuild switch          ← apply atomically, restart changed services
```

No watchtower, no manual `docker pull`, no cron jobs for updates.
If a rebuild fails, roll back with `nixos-rebuild switch --rollback`.
