{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Networking
#
# Tailscale mesh VPN, nginx unified reverse proxy, Cloudflare tunnels,
# OpenSSH, firewall rules.
#
# Public apps (via Cloudflare)  → nginx virtualHosts on 0.0.0.0:80/443
# Internal apps (via Tailscale) → nginx virtualHost on tailscale0:80 (path-based)
###############################################################################
let
  tailscaleIp = "100.114.69.83";  # apollo's Tailscale IP
  tailnet = "hippo-pentatonic.ts.net";
in
{
  # ---------------------------------------------------------------------------
  # Tailscale — mesh VPN
  # ---------------------------------------------------------------------------
  services.tailscale = {
    enable = true;
    # Allow this node to act as an exit node / subnet router
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--hostname=apollo"
    ];
  };

  # ---------------------------------------------------------------------------
  # OpenSSH — Tailscale-only access
  # ---------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      # Only listen on Tailscale interface (or localhost for tunnels)
      ListenAddress = [ "${tailscaleIp}" "127.0.0.1" ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ---------------------------------------------------------------------------
  # Firewall
  #
  # Strategy:
  #   - Tailscale interface is fully trusted (all ports accessible)
  #   - Only ports 80/443 open to WAN for nginx → cloudflared
  #   - All service ports (Plex:32400, *arr, Grafana, etc.) are
  #     NOT exposed to LAN — only reachable via Tailscale or localhost
  # ---------------------------------------------------------------------------
  networking.firewall = {
    enable = true;
    # Allow everything on Tailscale
    trustedInterfaces = [ "tailscale0" ];
    # WAN: only HTTP/HTTPS for nginx
    allowedTCPPorts = [ 80 443 ];
    # LAN: also allow Plex discovery (DLNA/mDNS uses UDP)
    allowedUDPPorts = [];
    # Docker/podman manages its own iptables rules
    checkReversePath = "loose";
  };

  # ---------------------------------------------------------------------------
  # nginx — Unified reverse proxy for ALL services
  #
  # Pattern:
  #   - Public apps get domain-based virtualHosts (Cloudflare → localhost:80)
  #   - Internal apps use path-based routing on the Tailscale IP
  #   - Default route → Homepage dashboard
  # ---------------------------------------------------------------------------
  services.nginx = {
    enable = true;

    # Performance tuning
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Increase client body size for uploads (Nextcloud, Immich, Paperless)
    clientMaxBodySize = "100m";

    # -----------------------------------------------------------------------
    # Tailscale-only virtualHost — path-based routing for internal services
    # Access via: http://apollo.hippo-pentatonic.ts.net/<path>
    # -----------------------------------------------------------------------
    virtualHosts."apollo" = {
      listen = [
        { addr = tailscaleIp; port = 80; }
        { addr = "127.0.0.1"; port = 80; }
      ];

      # Default: Homepage dashboard
      locations."/" = {
        proxyPass = "http://127.0.0.1:10000";
        proxyWebsockets = true;
      };

      # === Media ===
      locations."/plex" = {
        proxyPass = "http://127.0.0.1:32400";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
        '';
      };
      locations."/qbit" = { proxyPass = "http://127.0.0.1:8080"; };
      locations."/sonarr" = { proxyPass = "http://127.0.0.1:8989"; proxyWebsockets = true; };
      locations."/sonarr-es" = { proxyPass = "http://127.0.0.1:8990"; proxyWebsockets = true; };
      locations."/radarr" = { proxyPass = "http://127.0.0.1:7878"; proxyWebsockets = true; };
      locations."/radarr-es" = { proxyPass = "http://127.0.0.1:7879"; proxyWebsockets = true; };
      locations."/lidarr" = { proxyPass = "http://127.0.0.1:8686"; proxyWebsockets = true; };
      locations."/bazarr" = { proxyPass = "http://127.0.0.1:6767"; proxyWebsockets = true; };
      locations."/prowlarr" = { proxyPass = "http://127.0.0.1:9696"; proxyWebsockets = true; };
      locations."/komga" = { proxyPass = "http://127.0.0.1:25600"; };
      locations."/threadfin" = { proxyPass = "http://127.0.0.1:34400"; };

      # === Photos & Files ===
      locations."/immich" = {
        proxyPass = "http://127.0.0.1:2283";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 500m;
        '';
      };
      locations."/nextcloud" = {
        proxyPass = "http://127.0.0.1:7777";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 10g;
          proxy_read_timeout 300s;
        '';
      };
      locations."/syncthing" = { proxyPass = "http://127.0.0.1:8384"; proxyWebsockets = true; };

      # === Monitoring ===
      locations."/grafana" = { proxyPass = "http://127.0.0.1:3000"; proxyWebsockets = true; };
      locations."/prometheus" = { proxyPass = "http://127.0.0.1:9090"; };
      locations."/scrutiny" = { proxyPass = "http://127.0.0.1:1121"; };
      locations."/gotify" = { proxyPass = "http://127.0.0.1:10200"; proxyWebsockets = true; };
      locations."/uptime" = { proxyPass = "http://127.0.0.1:3006"; proxyWebsockets = true; };

      # === Productivity ===
      locations."/vaultwarden" = { proxyPass = "http://127.0.0.1:8222"; proxyWebsockets = true; };
      locations."/mealie" = { proxyPass = "http://127.0.0.1:9925"; };
      locations."/firefly" = { proxyPass = "http://127.0.0.1:8280"; };
      locations."/paperless" = {
        proxyPass = "http://127.0.0.1:14000";
        extraConfig = ''
          client_max_body_size 200m;
        '';
      };
      locations."/hoarder" = { proxyPass = "http://127.0.0.1:3001"; };
      locations."/actual" = { proxyPass = "http://127.0.0.1:5006"; };
      locations."/stirling" = { proxyPass = "http://127.0.0.1:5005"; };
      locations."/dawarich" = { proxyPass = "http://127.0.0.1:6006"; };
      locations."/calibre-web" = { proxyPass = "http://127.0.0.1:16083"; };
      locations."/calibre" = { proxyPass = "http://127.0.0.1:16080"; };

      # === Books & Media ===
      locations."/audiobookshelf" = { proxyPass = "http://127.0.0.1:13378"; };

      # === Dev & AI ===
      locations."/ollama" = {
        proxyPass = "http://127.0.0.1:11434";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 600s;
        '';
      };
      locations."/chat" = {
        proxyPass = "http://127.0.0.1:3002";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_read_timeout 600s;
          client_max_body_size 50m;
        '';
      };

      # === Admin ===
      locations."/portainer" = { proxyPass = "http://127.0.0.1:9000"; proxyWebsockets = true; };
      locations."/dispatcharr" = { proxyPass = "http://127.0.0.1:3005"; };
    };

    # -----------------------------------------------------------------------
    # PUBLIC virtualHosts — Cloudflare proxied (cloudflared → localhost:80)
    # -----------------------------------------------------------------------

    # Mermaid Live Editor — mermaid.javierpolo.com
    virtualHosts."mermaid.javierpolo.com" = {
      listen = [
        { addr = "127.0.0.1"; port = 80; }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";  # mermaid container
        proxyWebsockets = true;
      };
    };

    # Overleaf — overleaf.javierpolo.com
    virtualHosts."overleaf.javierpolo.com" = {
      listen = [
        { addr = "127.0.0.1"; port = 80; }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:8081";  # overleaf sharelatex container
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Proto https;
          proxy_read_timeout 120s;
          client_max_body_size 50m;
        '';
      };
    };

    # n8n — n8n.javierpolo.com
    virtualHosts."n8n.javierpolo.com" = {
      listen = [
        { addr = "127.0.0.1"; port = 80; }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:5678";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header X-Forwarded-Proto https;
          client_max_body_size 100m;
        '';
      };
    };

    # Seerr — seerr.javierpolo.com
    virtualHosts."seerr.javierpolo.com" = {
      listen = [
        { addr = "127.0.0.1"; port = 80; }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:5055";
        proxyWebsockets = true;
      };
    };

    # Seerr ES — seerr-es.javierpolo.com
    virtualHosts."seerr-es.javierpolo.com" = {
      listen = [
        { addr = "127.0.0.1"; port = 80; }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:5056";
        proxyWebsockets = true;
      };
    };

    # Calibre — calibre.javierpolo.com
    virtualHosts."calibre.javierpolo.com" = {
      listen = [
        { addr = "127.0.0.1"; port = 80; }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:16083";
        proxyWebsockets = true;
      };
    };

    # Co-Creation Framework
    virtualHosts."co-creation.javierpolo.com" = {
      listen = [
        { addr = "127.0.0.1"; port = 80; }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:3002";  # co-creation runs on 3002 (Grafana=3000, Hoarder=3001)
        proxyWebsockets = true;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Cloudflared — Single tunnel replacing all per-project cloudflared containers
  #
  # The tunnel credentials must be provided via secrets management.
  # All ingress rules point to nginx on localhost:80 (which routes by Host header).
  # ---------------------------------------------------------------------------
  services.cloudflared = {
    enable = true;

    # Before deploying:
    # 1. Create a tunnel in the Cloudflare Zero Trust dashboard
    # 2. Store the tunnel credentials JSON in your sops-nix secrets file
    # 3. The credentialsFile path below references the sops-nix decrypted file

    tunnels = {
      # Replace <tunnel-uuid> with your actual tunnel UUID from Cloudflare
      "<tunnel-uuid>" = {
        credentialsFile = config.sops.secrets."cloudflared/tunnel-credentials".path;
        default = "http_status:404";
        ingress = {
          "mermaid.javierpolo.com"     = "http://localhost:80";
          "overleaf.javierpolo.com"    = "http://localhost:80";
          "n8n.javierpolo.com"         = "http://localhost:80";
          "seerr.javierpolo.com"       = "http://localhost:80";
          "seerr-es.javierpolo.com"    = "http://localhost:80";
          "calibre.javierpolo.com"     = "http://localhost:80";
          "co-creation.javierpolo.com" = "http://localhost:80";
        };
      };
    };
  };

  # ---------------------------------------------------------------------------
  # sops-nix secret for Cloudflared tunnel credentials
  # ---------------------------------------------------------------------------
  sops.secrets."cloudflared/tunnel-credentials" = {
    owner = "cloudflared";
    group = "cloudflared";
    mode = "0400";
  };

  # ---------------------------------------------------------------------------
  # fail2ban — SSH brute-force protection
  # (even though SSH is Tailscale-only, defense-in-depth)
  # ---------------------------------------------------------------------------
  services.fail2ban = {
    enable = true;
    bantime = "1h";
    maxretry = 5;
    ignoreIP = [
      "127.0.0.0/8"
      "100.64.0.0/10"  # Tailscale range
    ];
  };

  # ---------------------------------------------------------------------------
  # Nextcloud Tailscale sidecar access
  #
  # Nextcloud is accessible at: nextcloud.hippo-pentatonic.ts.net
  # The nextcloud-aio container is exposed on port 7777 and nginx proxies it.
  # Tailscale handles routing to the nextcloud subdomain automatically.
  # ---------------------------------------------------------------------------
}
