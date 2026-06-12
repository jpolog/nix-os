{ config, lib, pkgs, ... }:

###############################################################################
# apollo — systemd Service Hardening
#
# Applies security hardening to OCI container systemd units and native services.
###############################################################################
let
  containerHardening = {
    serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectClock = true;
      ProtectHostname = true;
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
    };
  };

  tightContainer = containerHardening // {
    serviceConfig = containerHardening.serviceConfig // {
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];
    };
  };

  privilegedContainer = {
    serviceConfig = {
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectClock = true;
      ProtectHostname = true;
    };
  };

in
{
  # Tight hardening for standard containers
  systemd.services = lib.genAttrs [
    "podman-sonarr_en" "podman-sonarr_es"
    "podman-radarr_en" "podman-radarr_es"
    "podman-lidarr" "podman-bazarr"
    "podman-prowlarr" "podman-flaresolverr"
    "podman-seerr" "podman-seerr_es"
    "podman-threadfin" "podman-komga"
    "podman-makemkv"
    "podman-paperless-gotenberg" "podman-paperless-tika"
    "podman-mealie"
    "podman-firefly-iii" "podman-firefly-cron"
    "podman-audiobookshelf"
    "podman-calibre-web"
    "podman-stirling-pdf"
    "podman-actual-budget"
    "podman-hoarder-meilisearch"
    "podman-dawarich" "podman-dawarich-sidekiq"
    "podman-n8n" "podman-mermaid"
    "podman-overleaf-redis"
    "podman-homepage" "podman-gotify" "podman-portainer"
  ] (_: tightContainer);

  # Partial hardening for containers needing more access
  systemd.services = lib.genAttrs [
    "podman-paperless-webserver"
    "podman-nextcloud-aio"
    "podman-overleaf-mongo"
    "podman-overleaf-sharelatex"
    "podman-calibre"
    "podman-hoarder"
    "podman-hoarder-chrome"
    "podman-scrutiny"
    "podman-dispatcharr"
  ] (_: containerHardening);

  # Minimal hardening for privileged containers
  systemd.services = lib.genAttrs [
    "podman-gluetun"
    "podman-qbittorrent"
    "podman-jackett"
    "podman-cadvisor"
  ] (_: privilegedContainer);

  # Native service hardening
  systemd.services.postgresql.serviceConfig = {
    ProtectSystem = "full";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    RestrictSUIDSGID = true;
    MemoryDenyWriteExecute = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ReadWritePaths = [
      "/var/lib/postgresql"
      "/run/postgresql"
    ];
  };

  systemd.services.nginx.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    RestrictSUIDSGID = true;
    MemoryDenyWriteExecute = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
    SystemCallFilter = [ "@system-service" "~@privileged" ];
  };

  systemd.services.redis-default.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    RestrictSUIDSGID = true;
    MemoryDenyWriteExecute = true;
    ProtectKernelTunables = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" ];
  };
}