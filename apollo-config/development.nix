{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Development & Creative Services
#
# Native NixOS:   Ollama
# OCI containers: n8n, Overleaf, Mermaid, Anytype, Penpot, Co-Creation FE
#
# Services removed from original setup:
#   - 2x Caddy → replaced by nginx in networking.nix
#   - 2x cloudflared → replaced by services.cloudflared in networking.nix
#   - 1x Traefik → replaced by nginx in networking.nix
###############################################################################
let
  das1 = "/mnt/das1";
in
{
  # ===========================================================================
  # OLLAMA — Local LLM inference (native NixOS module)
  #
  # Replaces: ollama container
  # Model files are stored at /var/lib/ollama
  # ===========================================================================
  services.ollama = {
    enable = true;
    # Bind to localhost only — nginx proxies it via Tailscale
    host = "127.0.0.1";
    port = 11434;

    # Intel N100 (Alder Lake-N) has no CUDA or ROCm.
    # CPU-only inference works fine for 3B-8B models on 16 GB RAM.
    acceleration = null;

    # Pre-load models at boot (choose up to 2 models for 16 GB RAM):
    #   llama3.2:3b  ~2 GB RAM
    #   qwen2.5:7b   ~5 GB RAM
    #   deepseek-r1:8b ~5 GB RAM
    loadModels = [
      # "llama3.2:3b"
    ];
  };

  # ===========================================================================
  # OCI Containers — Development & Creative tools
  # ===========================================================================
  virtualisation.oci-containers.containers = {

    # =========================================================================
    # N8N — Workflow Automation
    #
    # Old: n8n + traefik + cloudflared (3 containers)
    # New: n8n container + host nginx + system cloudflared
    # =========================================================================
    n8n = {
      image = "docker.n8n.io/n8nio/n8n";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "127.0.0.1:5678:5678" ];
      environment = {
        N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
        N8N_HOST = "n8n.javierpolo.com";
        N8N_PORT = "5678";
        N8N_PROTOCOL = "https";
        N8N_RUNNERS_ENABLED = "true";
        NODE_ENV = "production";
        WEBHOOK_URL = "https://n8n.javierpolo.com/";
        GENERIC_TIMEZONE = "Europe/Madrid";
        TZ = "Europe/Madrid";
      };
      volumes = [
        "${das1}/n8n/data:/home/node/.n8n"
        "${das1}/n8n/files:/files"
      ];
    };

    # =========================================================================
    # MERMAID — Live Diagram Editor
    #
    # Old: mermaid + caddy + cloudflared (3 containers)
    # New: mermaid container + host nginx + system cloudflared
    # =========================================================================
    mermaid = {
      image = "ghcr.io/mermaid-js/mermaid-live-editor:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "127.0.0.1:8080:8080" ];
    };

    # =========================================================================
    # OVERLEAF / SHARELATEX — Collaborative LaTeX Editor
    #
    # Old: sharelatex + mongo + redis + caddy + cloudflared (5 containers)
    # New: sharelatex + mongo + redis containers (3 containers)
    #       + host nginx for proxy + system cloudflared
    #
    # NOTE: mongo and redis for overleaf could use the shared instances.
    # However, overleaf's mongo needs a specific replSet, so we keep it
    # as a dedicated container to avoid conflicts.
    # =========================================================================
    overleaf-mongo = {
      image = "docker.io/mongo:8.0";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "127.0.0.1:27018:27017" ];  # 27018 avoids collision with native mongodb on 27017
      cmd = [ "--replSet" "overleaf" ];
      volumes = [
        "/home/jpolo/overleaf/mongo_data:/data/db"
        "/home/jpolo/overleaf/mongo_init:/docker-entrypoint-initdb.d"
      ];
      environment = {
        MONGO_INITDB_DATABASE = "sharelatex";
      };
      extraOptions = [
        "--add-host=mongo:127.0.0.1"
      ];
    };

    overleaf-redis = {
      image = "docker.io/redis:7-alpine";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      volumes = [
        "/home/jpolo/overleaf/redis_data:/data"
      ];
    };

    overleaf-sharelatex = {
      image = "docker.io/sharelatex/sharelatex:with-texlive-full";
      autoStart = true;
      extraOptions = [ "--restart=always" "--stop-timeout=60" ];
      dependsOn = [ "overleaf-mongo" "overleaf-redis" ];
      ports = [ "127.0.0.1:8081:80" ];
      volumes = [
        "/home/jpolo/overleaf/sharelatex_data:/var/lib/overleaf"
      ];
      environment = {
        OVERLEAF_APP_NAME = "Overleaf Community Edition";
        OVERLEAF_SITE_URL = "https://overleaf.javierpolo.com";
        OVERLEAF_MONGO_URL = "mongodb://overleaf-mongo/sharelatex";
        OVERLEAF_REDIS_HOST = "overleaf-redis";
        REDIS_HOST = "overleaf-redis";
        ENABLED_LINKED_FILE_TYPES = "project_file,project_output_file";
        ENABLE_CONVERSIONS = "true";
        EMAIL_CONFIRMATION_DISABLED = "true";
      };
    };

    # =========================================================================
    # OPEN WEBUI — ChatGPT-like interface for Ollama
    #
    # Uses your existing Ollama on 127.0.0.1:11434.
    # Port 3002 was freed when Hoarder moved to 3001.
    # Access at: http://apollo.<tailnet>/chat
    # =========================================================================
    open-webui = {
      image = "ghcr.io/open-webui/open-webui:main";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "127.0.0.1:3002:8080" ];
      volumes = [
        "/var/lib/open-webui:/app/backend/data"
      ];
      environment = {
        OLLAMA_BASE_URL = "http://host.containers.internal:11434";
        WEBUI_AUTH = "false";  # no login needed behind Authentik/Tailscale
        WEBUI_NAME = "apollo-ai";
      };
    };

    # =========================================================================
    # CO-CREATION FRAMEWORK — Custom app (build from Dockerfile)
    #
    # Since this uses a custom Dockerfile build, we reference the built image.
    # Build it once with: podman build -t co-creation-framework:latest .
    # =========================================================================
    # co-creation-framework = {
    #   image = "localhost/co-creation-framework:latest";
    #   autoStart = true;
    #   extraOptions = [ "--restart=always" ];
    #   ports = [ "127.0.0.1:3002:3000" ];  # 3002 avoids Grafana (3000) and Hoarder (3001)
    #   environment = { NODE_ENV = "production"; };
    # };

    # =========================================================================
    # ANYTYPE — Self-hosted sync backend
    #
    # This is a complex multi-container pod. The full docker-compose has
    # ~12 containers (mongo, redis, minio, coordinator, filenode, 3 nodes,
    # consensusnode, 2 config generators).
    #
    # For a clean migration, keep Anytype in a dedicated podman pod
    # that preserves the internal Docker networking.
    #
    # TODO: Create the pod first: podman pod create --name anytype
    # Then each container uses --pod=anytype
    # =========================================================================
    # anytype-generateconfig-anyconf = {
    #   image = "localhost/anytype-generateconfig-anyconf:latest";
    #   autoStart = true;
    #   extraOptions = [ "--pod=anytype" ];
    #   volumes = [ "/home/jpolo/anytype/any-sync-dockercompose:/code:Z" ];
    # };
    #
    # anytype-mongo = {
    #   image = "docker.io/mongo:7.0.2";
    #   autoStart = true;
    #   extraOptions = [ "--pod=anytype" ];
    #   cmd = [ "--replSet" "any-sync" "--port" "27001" ];
    #   volumes = [ "${das1}/anytype/mongo:/data/db:Z" ];
    #   ports = [ "127.0.0.1:27001:27001" ];
    # };
    #
    # # ... remaining anytype containers follow the same pattern

    # =========================================================================
    # PENPOT — Design & Prototyping (DISABLED by default)
    #
    # Stopped in the original setup. Uncomment to enable.
    # =========================================================================
    # penpot-frontend = {
    #   image = "docker.io/penpotapp/frontend:latest";
    #   autoStart = false;
    #   ports = [ "127.0.0.1:10001:8080" ];
    #   volumes = [ "/var/lib/penpot/assets:/opt/data/assets" ];
    # };
    #
    # penpot-backend = {
    #   image = "docker.io/penpotapp/backend:latest";
    #   autoStart = false;
    #   ports = [ "127.0.0.1:6060:6060" ];
    #   volumes = [ "/var/lib/penpot/assets:/opt/data/assets" ];
    #   environment = {
    #     PENPOT_DATABASE_URI = "postgresql://penpot:___SECRET_MANAGED___@host.containers.internal:5432/penpot";
    #     PENPOT_REDIS_URI = "redis://host.containers.internal:6379/4";
    #   };
    # };
    #
    # penpot-exporter = {
    #   image = "docker.io/penpotapp/exporter:latest";
    #   autoStart = false;
    # };

    # =========================================================================
    # PI-HOLE — DNS Ad Blocking (DISABLED by default)
    #
    # Was stopped in original setup. NixOS has a native module if needed:
    # services.pihole.enable = true;
    # =========================================================================
  };
}
