{ config, lib, pkgs, ... }:

###############################################################################
# apollo — systemd Service Hardening
#
# Applies security hardening to OCI container systemd units and native services.
# Run `systemd-analyze security <unit>` to audit individual units.
#
# Hardening levels:
#   - containers: all OCI containers get a baseline hardening preset
#   - native:    service-specific hardening for postgres, nginx, etc.
###############################################################################
let
  # Baseline hardening for OCI containers.
  # Containers need less protection than native services since they're already
  # namespaced by podman, but we still lock down what we can.
  containerHardening = {
    serviceConfig = {
      # Protect system directories
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;

      # Prevent privilege escalation
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      MemoryDenyWriteExecute = true;

      # Restrict kernel access
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;

      # Restrict device access
      ProtectClock = true;
      ProtectHostname = true;

      # Network hardening (containers manage their own network ns)
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
    };
  };

  # Tighter hardening for containers that don't need full system access.
  # Some containers (gluetun: NET_ADMIN, cadvisor: privileged) need overrides.
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

  # Exceptions — containers that need CAPs or devices
  # These get the baseline minus the settings that would break them.
  privilegedContainer = {
    serviceConfig = {
      NoNewPrivileges = true;
      RestrictSUIDSGID = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectClock = true;
      ProtectHostname = true;
      # No ProtectSystem=strict, PrivateTmp, etc. — privileged needs these
    };
  };

in
{
  # ---------------------------------------------------------------------------
  # Apply hardening to all OCI container systemd units
  #
  # Pattern: podman-<container-name>.service is the systemd unit for each
  # container started via virtualisation.oci-containers.
  # ---------------------------------------------------------------------------

  systemd.services = lib.genAttrs [
    # Media stack — standard containers
    "podman-sonarr_en"
    "podman-sonarr_es"
    "podman-radarr_en"
    "podman-radarr_es"
    "podman-lidarr"
    "podman-bazarr"
    "podman-prowlarr"
    "podman-flaresolverr"
    "podman-seerr"
    "podman-seerr_es"
    "podman-threadfin"
    "podman-komga"
    "podman-makemkv"

    # Productivity — standard containers
    "podman-paperless-gotenberg"
    "podman-paperless-tika"
    "podman-mealie"
    "podman-firefly-iii"
    "podman-firefly-cron"
    "podman-audiobookshelf"
    "podman-calibre-web"
    "podman-stirling-pdf"
    "podman-actual-budget"
    "podman-hoarder-meilisearch"
    "podman-dawarich"
    "podman-dawarich-sidekiq"

    # Development — standard containers
    "podman-n8n"
    "podman-mermaid"
    "podman-overleaf-redis"

    # Monitoring — standard containers
    "podman-homepage"
    "podman-gotify"
    "podman-portainer"
  ] (_: tightContainer);

  # Containers needing partial hardening (need some system access)
  systemd.services = lib.genAttrs [
    "podman-paperless-webserver"  # needs to spawn subprocesses
    "podman-nextcloud-aio"         # manages internal containers
    "podman-overleaf-mongo"        # needs fsync, etc.
    "podman-overleaf-sharelatex"   # complex multi-process
    "podman-calibre"               # KasmVNC + GUI needs seccomp
    "podman-hoarder"               # needs chromium for scraping
    "podman-hoarder-chrome"        # chromium needs more access
    "podman-scrutiny"              # needs SYS_RAWIO + devices
    "podman-dispatcharr"           # needs GPU device
  ] (_: containerHardening);

  # Privileged containers — minimal hardening only
  systemd.services = lib.genAttrs [
    "podman-gluetun"       # needs NET_ADMIN + /dev/net/tun
    "podman-qbittorrent"   # shares gluetun netns
    "podman-jackett"       # shares gluetun netns
    "podman-cadvisor"      # needs --privileged + /dev/kmsg
  ] (_: privilegedContainer);

  # ---------------------------------------------------------------------------
  # Native service hardening
  # ---------------------------------------------------------------------------

  # PostgreSQL — already well-isolated; tighten further
  systemd.services.postgresql.serviceConfig = {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
    NoNewPrivileges = true;
    RestrictSUIDSGID = true;
    MemoryDenyWriteExecute = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    # PostgreSQL needs these
    ProtectSystem = "full";  # needs /run/postgresql writable
    ReadWritePaths = [
      "/var/lib/postgresql"
      "/run/postgresql"
    ];
  };

  # Nginx — internet-facing, tighten significantly
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

  # Redis — local only, tighten
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
