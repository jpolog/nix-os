{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Databases
#
# Consolidated database services (all native NixOS modules):
#   - PostgreSQL 16 (7 databases on one instance)
#   - Redis (6+ apps on one instance, using DB numbers)
#   - MariaDB (Firefly III)
#   - MongoDB (Anytype; Overleaf uses a dedicated container)
#
# This replaces: 5 postgres containers, 6 redis containers,
#                1 mariadb container, 2 mongo containers
#
# Secrets are managed via sops-nix. Before deploying, create a
# .sops.yaml file and encrypt each password:
#   sops secrets/postgres-db-passwords.yaml
###############################################################################
let
  # sops-nix decrypts secrets to /run/secrets/<name> at activation time.
  # Each password file contains one line with the plaintext password.
  # The postgresql-set-passwords oneshot service reads these and
  # applies ALTER USER … PASSWORD statements at boot.
  dbUsers = [
    { name = "immich";    db = "immich";    secret = config.sops.secrets."postgres/immich_pass"; }
    { name = "paperless"; db = "paperless"; secret = config.sops.secrets."postgres/paperless_pass"; }
    { name = "mealie";    db = "mealie";    secret = config.sops.secrets."postgres/mealie_pass"; }
    { name = "nextcloud"; db = "nextcloud"; secret = config.sops.secrets."postgres/nextcloud_pass"; }
    { name = "dawarich";  db = "dawarich";  secret = config.sops.secrets."postgres/dawarich_pass"; }
    { name = "vaultwarden"; db = "vaultwarden"; secret = config.sops.secrets."postgres/vaultwarden_pass"; }
    { name = "authentik";  db = "authentik";  secret = config.sops.secrets."postgres/authentik_pass"; }
  ];

  # Generate ALTER USER statements that read passwords from sops files
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
  # Databases: immich, paperless, mealie, nextcloud, dawarich, vaultwarden
  # Extensions: postgis (dawarich), pgvecto-rs (immich), vectors
  # ---------------------------------------------------------------------------
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    dataDir = "/var/lib/postgresql";

    # Required extensions
    extensions = (ps: with ps; [
      postgis        # for Dawarich (location data)
      pgvecto-rs     # for Immich (vector similarity search)
    ]);

    # Databases to create
    ensureDatabases = [
      "immich"
      "paperless"
      "mealie"
      "nextcloud"
      "dawarich"
      "vaultwarden"
    ];

    # Users for each database (without passwords — applied at runtime)
    ensureUsers = map (u: {
      name = u.name;
      ensureDBOwnership = true;
      ensureClauses.login = true;
    }) dbUsers;

    # Network and performance settings (tuned for 16 GB RAM)
    enableTCPIP = true;
    settings = {
      port = 5432;
      listen_addresses = "127.0.0.1";  # local only
      max_connections = 100;
      shared_buffers = "256MB";        # conservative for 16 GB RAM
      effective_cache_size = "4GB";
      work_mem = "16MB";
      maintenance_work_mem = "256MB";
      wal_compression = "on";
      max_wal_size = "2GB";
      logging_collector = "on";
      log_min_duration_statement = "1000";  # log slow queries >1s
    };

    # Initial SQL to create extensions
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

    # Authentication: peer for local socket, scram-sha-256 for TCP
    # Passwords are set at boot by the postgresql-set-passwords oneshot service
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
  #   DB 4 → Anytype (reserved)
  #   DB 5 → Dispatcharr
  # ---------------------------------------------------------------------------
  services.redis.servers."default" = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";  # local only
    databases = 16;       # 0-15, enough for all apps

    # Persistence: RDB snapshots
    save = [
      [900 1]    # after 15 min if at least 1 key changed
      [300 10]   # after 5 min if at least 10 keys changed
      [60 10000] # after 1 min if at least 10000 keys changed
    ];

    # Memory management (conservative for 16 GB RAM)
    maxmemory = "256mb";
    maxmemoryPolicy = "allkeys-lru";  # evict least recently used
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
  # MongoDB — For Anytype only
  #
  # Overleaf uses its own dedicated mongo container (development.nix)
  # because it requires a specific replica set configuration.
  # ---------------------------------------------------------------------------
  services.mongodb = {
    enable = true;
    package = pkgs.mongodb-ce;

    # Bind to localhost only
    bind_ip = "127.0.0.1";

    # Replica set for Anytype
    replSetName = "anytype";
    initialScript = pkgs.writeText "mongo-init.js" ''
      rs.initiate({
        _id: "anytype",
        members: [{ _id: 0, host: "127.0.0.1:27017" }]
      });
    '';
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
