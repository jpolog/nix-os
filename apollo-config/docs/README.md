# apollo — NixOS Home Server Documentation

## System Overview

**apollo** is an Intel N100 home server running NixOS with a declarative,
modular configuration. It hosts ~50 services spanning media streaming,
productivity tools, monitoring, databases, and development platforms.

- **Hardware**: Intel N100 (4-core Alder Lake-N), 16 GB RAM, Intel UHD GPU
- **OS**: NixOS 24.11 (flakes-based)
- **Container runtime**: Podman (rootless-capable, daemonless)
- **Networking**: Tailscale mesh VPN + Cloudflare Tunnels

## Documentation Index

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Design philosophy, module structure, patterns |
| [SERVICES.md](./SERVICES.md) | Complete service inventory with ports and access |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | First-boot guide, data migration, secrets setup |
| [MAINTENANCE.md](./MAINTENANCE.md) | Updates, garbage collection, troubleshooting |

## Quick Reference

```
nixos/
├── docs/                      ← YOU ARE HERE
│   ├── README.md              ← This file
│   ├── ARCHITECTURE.md        ← Design & patterns
│   ├── SERVICES.md            ← Service catalog
│   ├── DEPLOYMENT.md          ← How to deploy
│   └── MAINTENANCE.md         ← Day-to-day operations
├── flake.nix                  ← Flake entry point
├── default.nix                ← Global defaults & imports
├── networking.nix             ← Tailscale, nginx, Cloudflare, firewall
├── storage.nix                ← USB drives, swap, data directories
├── databases.nix              ← PostgreSQL, Redis, MariaDB, MongoDB
├── media.nix                  ← Plex, gluetun VPN, *arr stack
├── productivity.nix           ← Immich, Vaultwarden, Syncthing, Paperless…
├── monitoring.nix             ← Prometheus, Grafana, Scrutiny, Homepage
├── development.nix            ← Ollama, n8n, Overleaf, Mermaid, Anytype
└── users.nix                  ← User accounts, home-manager hook
```

## Access Patterns

```
Internet
   │
   ├── Cloudflare Tunnels ──→ nginx (public virtualHosts) ──→ internal apps
   │                          *.javierpolo.com
   │
   └── Tailscale VPN ──→ nginx (path-based on apollo.ts.net) ──→ all apps
                          apollo.<tailnet>.ts.net/plex, /grafana, ...
```

- **Public apps** (Cloudflare): mermaid, overleaf, n8n, seerr, calibre
- **Tailscale-only** (VPN): all services — plex, sonarr, grafana, vaultwarden, etc.
- **No LAN exposure**: Firewall blocks all service ports on physical interfaces
