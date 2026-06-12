{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Development & Creative Services
#
# Native NixOS:   Ollama
# OCI containers: n8n, Overleaf, Mermaid, Open WebUI
###############################################################################
let
  das1 = "/mnt/das1";
in
{
  # ===========================================================================
  # OLLAMA — Local LLM inference (native NixOS module)
  # ===========================================================================
  services.ollama = {
    enable = true;
    host = "127.0.0.1";
    port = 11434;
    acceleration = null;  # CPU-only for Intel N100
    loadModels = [];
  };

  # ===========================================================================
  # OCI Containers — Development & Creative tools
  # ===========================================================================
  virtualisation.oci-containers.containers = {

    # N8N — Workflow Automation
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

    # MERMAID — Live Diagram Editor
    mermaid = {
      image = "ghcr.io/mermaid-js/mermaid-live-editor:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "127.0.0.1:8080:8080" ];
    };

    # OVERLEAF / SHARELATEX — Collaborative LaTeX Editor
    overleaf-mongo = {
      image = "docker.io/mongo:8.0";
      autoStart = true;
      extraOptions = [
        "--restart=always"
        "--add-host=mongo:127.0.0.1"
      ];
      ports = [ "127.0.0.1:27018:27017" ];
      cmd = [ "--replSet" "overleaf" ];
      volumes = [
        "/home/jpolo/overleaf/mongo_data:/data/db"
        "/home/jpolo/overleaf/mongo_init:/docker-entrypoint-initdb.d"
      ];
      environment = {
        MONGO_INITDB_DATABASE = "sharelatex";
      };
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

    # OPEN WEBUI — ChatGPT-like interface for Ollama
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
        WEBUI_AUTH = "false";
        WEBUI_NAME = "apollo-ai";
      };
    };
  };
}