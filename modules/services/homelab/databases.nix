{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Databases
#
# Consolidated database services (all native NixOS modules):
#   - PostgreSQL 16 (7 databases on one instance)
#   - Redis (6+ apps on one instance, using DB numbers)
#   - MariaDB (Firefly III)
#
# Secrets are managed via sops-nix.
###############################################################################
let
  dbUsers = [
    { name = "immich";    db = "immich";    secret = config.sops.secrets."postgres/immich_pass"; }
    { name = "paperless"; db = "paperless"; secret = config.sops.secrets."postgres/paperless_pass"; }
    { name = "mealie";    db = "mealie";    secret = config.sops.secrets."postgres/mealie_pass"; }
    { name = "nextcloud"; db = "nextcloud"; secret = config.sops.secrets."postgres/nextcloud_pass"; }
    { name = "dawarich";  db = "dawarich";  secret = config.sops.secrets."postgres/dawarich_pass"; }
    { name = "vaultwarden"; db = "vaultwarden"; secret = config.sops.secrets."postgres/vaultwarden_pass"; }
    { name = "authentik";  db = "authentik";  secret = config.sops.secrets."postgres/authentik_pass"; }
  ];

  setPasswordScript = pkgs.writeScript "postgresql-set-passwords" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail
    export PATH=${pkgs.postgresql_16}/bin:$PATH

    ${lib.concatMapStrings (u: ''
      if [[ -f ${u.secret.path} ]]; then
        echo "Setting password for ${u.name}…"
        PGPASS=$(head -n1 ${u.secret.path})
        psql -U postgres -d template1 -c "ALTER USER \"${u.name}\" PASSWORD '$PGPASS';"
      else
        echo "WARNING: secret file for ${u.name} not found at ${u.secret.path} — skipping"
      fi
    '') dbUsers}
  '';
in
{
  # ---------------------------------------------------------------------------
  # sops-nix secrets — PostgreSQL database passwords
  # ---------------------------------------------------------------------------
  sops.secrets = lib.genAttrs (map (u: "postgres/${u.name}_pass") dbUsers)
    (_: { owner = "postgres"; group = "postgres"; mode = "0400"; });

  # ---------------------------------------------------------------------------
  # PostgreSQL 16 — Consolidated instance
  #
  # Databases: immich, paperless, mealie, nextcloud, dawarich, vaultwarden, authentik
  # Extensions: postgis (dawarich), pgvecto-rs (immich), vectors
  # ---------------------------------------------------------------------------
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    dataDir = "/var/lib/postgresql";

    extensions = (ps: with ps; [
      postis        # for Dawarich (location data)
      pgvecto-rs     # for Immich (vector similarity search)
    ]);

    ensureDatabases = [
      "immich"
      "paperless"
      "mealie"
      "nextcloud"
      "dawarich"
      "vaultwarden"
      "authentik"
    ];

    ensureUsers = map (u: {
      name = u.name;
      ensureDBOwnership = true;
      ensureClauses.login = true;
    }) dbUsers;

    enableTCPIP = true;

    settings = {
      port = 5432;
      listen_addresses = "127.0.0.1";
      max_connections = 100;
      shared_buffers = "256MB";
      effective_cache_size = "4GB";
      work_mem = "16MB";
      maintenance_work_mem = "256MB";
      wal_compression = "on";
      max_wal_size = "2GB";
      logging_collector = "on";
      log_min_duration_statement = "1000";
    };

    initialScript = pkgs.writeText "pg-init.sql" ''
      -- Enable postgis extension on dawarich database
      \c dawarich
      CREATE EXTENSION IF NOT EXISTS postgis;
      CREATE EXTENSION IF NOT EXISTS postgis_topology;

      -- Enable vector extension on immich database
      \c immich
      CREATE EXTENSION IF NOT EXISTS vectors;

      -- Set up pgvecto-rs for immich
      ALTER DATABASE immich SET search_path TO "$user", public, vectors;
    '';

    authentication = pkgs.lib.mkOverride 10 ''
      local all all peer
      host  all all 127.0.0.1/32 scram-sha-256
      host  all all ::1/128 scram-sha-256
    '';
  };

  # Oneshot service to apply passwords from sops-nix secrets at boot
  systemd.services.postgresql-set-passwords = {
    description = "Apply PostgreSQL user passwords from sops-nix secrets";
    wantedBy = [ "multi-user.target" ];
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" "sops-nix.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
      Group = "postgres";
      ExecStart = "${setPasswordScript}";
    };
  };

  # ---------------------------------------------------------------------------
  # Redis — Consolidated instance
  #
  # Apps use different DB numbers (0-15) for logical isolation:
  #   DB 0 → Immich
  #   DB 1 → Paperless-ngx
  #   DB 2 → Dawarich
  #   DB 3 → Overleaf
  #   DB 5 → Dispatcharr
  # ---------------------------------------------------------------------------
  services.redis.servers."default" = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
    databases = 16;

    save = [
      [900 1]
      [300 10]
      [60 10000]
    ];

    maxmemory = "256mb";
    maxmemoryPolicy = "allkeys-lru";
  };

  # ---------------------------------------------------------------------------
  # MariaDB — For Firefly III
  # ---------------------------------------------------------------------------
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    ensureDatabases = [ "firefly_iii" ];
    ensureUsers = [
      {
        name = "firefly";
        ensurePermissions = {
          "firefly_iii.*" = "ALL PRIVILEGES";
        };
      }
    ];

    settings = {
      mysqld = {
        bind-address = "127.0.0.1";
        port = 3306;
        innodb_buffer_pool_size = "256M";
        max_connections = 50;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # PostgreSQL Exporter (for Prometheus metrics)
  # ---------------------------------------------------------------------------
  services.prometheus.exporters.postgres = {
    enable = true;
    port = 9187;
    runAsLocalSuperUser = true;
  };

  # ---------------------------------------------------------------------------
  # Redis Exporter (for Prometheus metrics)
  # ---------------------------------------------------------------------------
  services.prometheus.exporters.redis = {
    enable = true;
    port = 9121;
  };
}