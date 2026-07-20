# Service Catalog

Every service running on apollo, grouped by category and access pattern.

## Legend

| Icon | Meaning |
|------|---------|
| 🔓 | Public (Cloudflare Tunnel — accessible from internet) |
| 🔒 | Tailscale only (VPN required) |
| 🏠 | Native NixOS service |
| 📦 | OCI container (Podman) |

---

## Media Stack

| Service | Type | Port | Access | URL |
|---------|------|------|--------|-----|
| **Plex** | 🏠 | 32400 | 🔒 | `http://apollo.<tailnet>/plex` |
| **qBittorrent** | 📦 | 8080 *(via gluetun)* | 🔒 | `http://apollo.<tailnet>/qbit` |
| **Jackett** | 📦 | 9117 *(via gluetun)* | 🔒 | `http://apollo:9117` |
| **Sonarr EN** | 📦 | 8989 | 🔒 | `http://apollo.<tailnet>/sonarr` |
| **Sonarr ES** | 📦 | 8990 | 🔒 | `http://apollo.<tailnet>/sonarr-es` |
| **Radarr EN** | 📦 | 7878 | 🔒 | `http://apollo.<tailnet>/radarr` |
| **Radarr ES** | 📦 | 7879 | 🔒 | `http://apollo.<tailnet>/radarr-es` |
| **Lidarr** | 📦 | 8686 | 🔒 | `http://apollo.<tailnet>/lidarr` |
| **Bazarr** | 📦 | 6767 | 🔒 | `http://apollo.<tailnet>/bazarr` |
| **Prowlarr** | 📦 | 9696 | 🔒 | `http://apollo.<tailnet>/prowlarr` |
| **FlareSolverr** | 📦 | 8191 | 🔒 | *(internal — used by Jackett/Prowlarr)* |
| **Seerr EN** | 📦 | 5055 | 🔓 | `https://seerr.javierpolo.com` |
| **Seerr ES** | 📦 | 5056 | 🔓 | `https://seerr-es.javierpolo.com` |
| **Threadfin** | 📦 | 34400 | 🔒 | `http://apollo.<tailnet>/threadfin` |
| **Komga** | 📦 | 25600 | 🔒 | `http://apollo.<tailnet>/komga` |
| **Dispatcharr** | 📦 | 3005 | 🔒 | `http://apollo.<tailnet>/dispatcharr` |
| **MakeMKV** | 📦 | 5800 | 🔒 | `http://apollo:5800` |

### Gluetun VPN

All torrent traffic (qBittorrent, Jackett) is routed through gluetun (NordVPN,
OpenVPN, Spain/Portugal/France servers). These containers share gluetun's
network namespace — if the VPN drops, torrent traffic stops (kill-switch).

---

## Photos, Files & Sync

| Service | Type | Port | Access | URL |
|---------|------|------|--------|-----|
| **Immich** | 🏠 | 2283 | 🔒 | `http://apollo.<tailnet>/immich` |
| **Nextcloud AIO** | 📦 | 7777 | 🔒 | `http://nextcloud.<tailnet>` *(Tailscale subdomain)* |
| **Syncthing** | 🏠 | 8384 | 🔒 | `http://apollo.<tailnet>/syncthing` |
| **Vaultwarden** | 🏠 | 8222 | 🔒 | `http://apollo.<tailnet>/vaultwarden` |

---

## Productivity

| Service | Type | Port | Access | URL |
|---------|------|------|--------|-----|
| **Paperless-ngx** | 📦 | 14000 | 🔒 | `http://apollo.<tailnet>/paperless` |
| **Mealie** | 📦 | 9925 | 🔒 | `http://apollo.<tailnet>/mealie` |
| **Firefly III** | 📦 | 8280 | 🔒 | `http://apollo.<tailnet>/firefly` |
| **Actual Budget** | 📦 | 5006 | 🔒 | `http://apollo.<tailnet>/actual` |
| **Stirling PDF** | 📦 | 5005 | 🔒 | `http://apollo.<tailnet>/stirling` |
| **Hoarder** | 📦 | 3000 | 🔒 | `http://apollo.<tailnet>/hoarder` |
| **Dawarich** | 📦 | 6006 | 🔒 | `http://apollo.<tailnet>/dawarich` |
| **Gotify** | 📦 | 10200 | 🔒 | `http://apollo.<tailnet>/gotify` |

---

## Books & Reading

| Service | Type | Port | Access | URL |
|---------|------|------|--------|-----|
| **Audiobookshelf** | 📦 | 13378 | 🔒 | `http://apollo.<tailnet>/audiobookshelf` |
| **Calibre** | 📦 | 16080 | 🔒 | `http://apollo.<tailnet>/calibre` |
| **Calibre-Web** | 📦 | 16083 | 🔓 | `https://calibre.javierpolo.com` |

---

## Monitoring & Admin

| Service | Type | Port | Access | URL |
|---------|------|------|--------|-----|
| **Homepage** | 📦 | 10000 | 🔒 | `http://apollo.<tailnet>/` *(default landing)* |
| **Grafana** | 🏠 | 3000 | 🔒 | `http://apollo.<tailnet>/grafana` |
| **Prometheus** | 🏠 | 9090 | 🔒 | `http://apollo.<tailnet>/prometheus` |
| **cAdvisor** | 📦 | 9200 | 🔒 | *(Prometheus scrape target)* |
| **Node Exporter** | 🏠 | 9100 | 🔒 | *(Prometheus scrape target)* |
| **Scrutiny** | 📦 | 1121 | 🔒 | `http://apollo.<tailnet>/scrutiny` |
| **Portainer** | 📦 | 9000 | 🔒 | `http://apollo.<tailnet>/portainer` |

---

## Development & AI

| Service | Type | Port | Access | URL |
|---------|------|------|--------|-----|
| **Ollama** | 🏠 | 11434 | 🔒 | `http://apollo.<tailnet>/ollama` — *LAN: `http://apollo:11434`* |
| **n8n** | 📦 | 5678 | 🔓 | `https://n8n.javierpolo.com` |
| **Mermaid Live** | 📦 | 8080 | 🔓 | `https://mermaid.javierpolo.com` |
| **Overleaf** | 📦 | 8081 | 🔓 | `https://overleaf.javierpolo.com` |
| **Co-Creation FE** | 📦 | 3001 | 🔓 | *(via Cloudflare)* |
| **Anytype** | 📦 | *(various)* | 🔒 | *(self-hosted sync backend)* |

---

## Databases

| Service | Type | Port | Access | Notes |
|---------|------|------|--------|-------|
| **PostgreSQL 16** | 🏠 | 5432 | 🔒 localhost | 5 databases: immich, paperless, mealie, nextcloud, dawarich |
| **Redis** | 🏠 | 6379 | 🔒 localhost | DBs 0–15: shared by all apps |
| **MariaDB** | 🏠 | 3306 | 🔒 localhost | Firefly III only |
| **MongoDB CE** | 🏠 | 27017 | 🔒 localhost | Overleaf (replSet: overleaf) |

---

## Networking Infrastructure

| Service | Type | Port | Access | Notes |
|---------|------|------|--------|-------|
| **nginx** | 🏠 | 80, 443 | 🔓 WAN + 🔒 Tailscale | Unified reverse proxy |
| **Tailscale** | 🏠 | — | 🔒 VPN | Mesh VPN, IP: `100.114.69.83` |
| **cloudflared** | 🏠 | — | 🔓 CF Tunnel | Single tunnel, 7 ingress rules |
| **OpenSSH** | 🏠 | 22 | 🔒 | Tailscale IP + localhost only |

---

## Services NOT Migrated (removed)

| Service | Reason |
|---------|--------|
| **Watchtower** | NixOS declarative updates (`nixos-rebuild switch`) |
| **Caddy (4 instances)** | Replaced by `services.nginx` |
| **cloudflared (6 instances)** | Replaced by single `services.cloudflared` |
| **Traefik** | Replaced by `services.nginx` |
| **immich_postgres** | Consolidated into shared PostgreSQL |
| **immich_redis** | Consolidated into shared Redis |
| **paperless-db, paperless-broker** | Consolidated into shared PostgreSQL/Redis |
| **mealie-postgres** | Consolidated into shared PostgreSQL |
| **dawarich_db, dawarich_redis** | Consolidated into shared PostgreSQL/Redis |
| **Pi-hole** | Was stopped; available as `services.pihole` if needed |

---

## Data Storage Map

```
/mnt/das1/ (7.3 TB ext4 — TerraMaster TDAS)
├── mediaserver/
│   ├── movies/         ← Radarr EN
│   ├── tvshows/        ← Sonarr EN
│   ├── tvrecordings/   ← Plex DVR
│   ├── spanish/
│   │   ├── movies/     ← Radarr ES
│   │   └── tvshows/    ← Sonarr ES
│   ├── videos/         ← Plex
│   ├── courses/        ← Plex
│   └── comics/         ← Komga
├── immich/             ← Immich photo/video library
├── paperless-ngx/
│   ├── data/           ← Paperless DB data
│   ├── media/          ← Paperless document archive
│   └── export/         ← Paperless exports
├── mealie/
│   └── mealie-data/    ← Mealie recipes
├── nextcloud_data/     ← Nextcloud AIO data directory
├── hoarder/
│   ├── data/           ← Hoarder bookmarks
│   └── meilisearch/    ← Hoarder search index
├── dawarich/           ← Dawarich location data
├── n8n/
│   ├── data/           ← n8n workflows & credentials
│   └── files/          ← n8n file storage
├── actual-data/        ← Actual Budget
├── obsidian/           ← Syncthing Obsidian vault
├── books_and_podcasts/
│   └── books/
│       ├── ebooks/     ← Calibre library
│       └── audiobooks/ ← Audiobookshelf
├── gotify/data/        ← Gotify notifications
└── backup/             ← Backup destination

/mnt/elements/ (5.5 TB NTFS — WD Elements)
├── mediaserver/
│   ├── downloads/      ← qBittorrent download target
│   └── MakeMKV/output/ ← DVD/Blu-ray rips
├── books/
│   ├── podcasts/       ← Audiobookshelf
│   └── ebooks/         ← Audiobookshelf
└── books-server/       ← Calibre/Audiobookshelf configs

/mnt/music_usb/ (116 GB exFAT — USB flash)
└── mediaserver/
    └── music/          ← Lidarr + Plex music library
```
