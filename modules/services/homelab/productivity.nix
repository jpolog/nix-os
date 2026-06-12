{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Productivity Services
#
# Native NixOS:   Immich, Vaultwarden, Syncthing
# OCI containers: Paperless-ngx, Nextcloud AIO, Mealie, Firefly III,
#                 Audiobookshelf, Calibre, Calibre-Web, Stirling-PDF,
#                 Actual Budget, Hoarder, Dawarich
###############################################################################
let
  das1 = "/mnt/das1";
in
{
  # ===========================================================================
  # IMMICH — Photo & Video Library (native NixOS module)
  # ===========================================================================
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2283;
    mediaLocation = "${das1}/immich";
    accelerationDevices = [ "/dev/dri/renderD128" ];

    settings = {
      server.externalDomain = "http://apollo:2283";
      newVersionCheck.enabled = false;
    };

    database = {
      createDB = false;
      host = "/run/postgresql";
      name = "immich";
      user = "immich";
    };

    redis = {
      host = "127.0.0.1";
      port = 6379;
      dbIndex = 0;
    };
  };

  # ===========================================================================
  # VAULTWARDEN — Password Manager (native NixOS module)
  # ===========================================================================
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      DOMAIN = "https://apollo.hippo-pentatonic.ts.net";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = false;
      DATABASE_URL = "postgresql:///vaultwarden?host=/run/postgresql";
    };
  };

  # ===========================================================================
  # SYNCTHING — File Synchronization (native NixOS module)
  # ===========================================================================
  services.syncthing = {
    enable = true;
    user = "jpolo";
    group = "users";
    dataDir = "/home/jpolo/.syncthing-data";
    configDir = "/home/jpolo/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
    settings = {
      devices = {};
      folders = {
        "obsidian" = {
          path = "${das1}/obsidian";
        };
      };
    };
  };

  # ===========================================================================
  # OCI Containers — Productivity apps
  # ===========================================================================
  virtualisation.oci-containers.containers = {

    # PAPERLESS-NGX — Document Management
    paperless-webserver = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      dependsOn = [ "paperless-gotenberg" "paperless-tika" ];
      ports = [ "14000:8000" ];
      volumes = [
        "${das1}/paperless-ngx/data:/usr/src/paperless/data"
        "${das1}/paperless-ngx/media:/usr/src/paperless/media"
        "/home/jpolo/paperless-ngx/export:/usr/src/paperless/export"
        "/home/jpolo/paperless-ngx/consume:/usr/src/paperless/consume"
      ];
      environment = {
        PAPERLESS_REDIS = "redis://host.containers.internal:6379/1";
        PAPERLESS_DBHOST = "host.containers.internal";
        PAPERLESS_DBPORT = "5432";
        PAPERLESS_DBNAME = "paperless";
        PAPERLESS_DBUSER = "paperless";
        PAPERLESS_DBPASS = "___SECRET_MANAGED___";
        PAPERLESS_TIKA_ENABLED = "1";
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://paperless-gotenberg:3000";
        PAPERLESS_TIKA_ENDPOINT = "http://paperless-tika:9998";
        PAPERLESS_TIME_ZONE = "Europe/Madrid";
      };
    };

    paperless-gotenberg = {
      image = "docker.io/gotenberg/gotenberg:8.22";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      entrypoint = "gotenberg";
      cmd = [
        "--chromium-disable-javascript=true"
        "--chromium-allow-list=file:///tmp/.*"
      ];
    };

    paperless-tika = {
      image = "docker.io/apache/tika:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
    };

    # NEXTCLOUD AIO — File sync & collaboration
    nextcloud-aio = {
      image = "docker.io/nextcloud/all-in-one:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" "--init" ];
      ports = [ "7777:8080" ];
      environment = {
        APACHE_PORT = "11000";
        APACHE_IP_BINDING = "127.0.0.1";
        SKIP_DOMAIN_VALIDATION = "true";
        NEXTCLOUD_DATADIR = "${das1}/nextcloud_data";
      };
      volumes = [
        "/var/lib/containers/config/nextcloud-aio:/mnt/docker-aio-config"
        "/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
    };

    # MEALIE — Recipe Manager
    mealie = {
      image = "ghcr.io/mealie-recipes/mealie:v3.1.2";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "9925:9000" ];
      volumes = [
        "${das1}/mealie/mealie-data:/app/data"
      ];
      environment = {
        DB_ENGINE = "postgres";
        POSTGRES_SERVER = "host.containers.internal";
        POSTGRES_PORT = "5432";
        POSTGRES_DB = "mealie";
        POSTGRES_USER = "mealie";
        POSTGRES_PASSWORD = "___SECRET_MANAGED___";
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Madrid";
        BASE_URL = "http://apollo:9925";
        ALLOW_SIGNUP = "false";
      };
    };

    # FIREFLY III — Personal Finance Manager
    firefly-iii = {
      image = "docker.io/fireflyiii/core:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "8280:8080" ];
      volumes = [
        "/var/lib/firefly/upload:/var/www/html/storage/upload"
      ];
      environment = {
        DB_CONNECTION = "mysql";
        DB_HOST = "host.containers.internal";
        DB_PORT = "3306";
        DB_DATABASE = "firefly_iii";
        DB_USERNAME = "firefly";
        DB_PASSWORD = "___SECRET_MANAGED___";
        APP_ENV = "local";
        APP_KEY = "___SECRET_MANAGED___";
        STATIC_CRON_TOKEN = "___SECRET_MANAGED___";
        TZ = "Europe/Madrid";
      };
    };

    firefly-cron = {
      image = "docker.io/alpine:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      environment = {
        STATIC_CRON_TOKEN = "___SECRET_MANAGED___";
        TZ = "Europe/Madrid";
      };
      entrypoint = "sh";
      cmd = [
        "-c"
        "apk add tzdata curl && ln -fs /usr/share/zoneinfo/$$TZ /etc/localtime && echo \"0 3 * * * wget -qO- http://firefly-iii:8080/api/v1/cron/$$STATIC_CRON_TOKEN;echo\" | crontab - && crond -f -L /dev/stdout"
      ];
    };

    # AUDIOBOOKSHELF — Audiobook & Podcast Server
    audiobookshelf = {
      image = "ghcr.io/advplyr/audiobookshelf:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "13378:80" ];
      environment = { TZ = "Europe/Madrid"; };
      volumes = [
        "${das1}/books_and_podcasts/books/audiobooks:/audiobooks"
        "/mnt/elements/books/podcasts:/podcasts"
        "/mnt/elements/books/ebooks:/ebooks"
        "/var/lib/audiobookshelf/config:/config"
        "/var/lib/audiobookshelf/metadata:/metadata"
      ];
    };

    # CALIBRE — E-book Manager (KasmVNC GUI)
    calibre = {
      image = "lscr.io/linuxserver/calibre:latest";
      autoStart = true;
      extraOptions = [
        "--restart=always"
        "--security-opt=seccomp:unconfined"
        "--shm-size=1gb"
      ];
      ports = [
        "16080:8080"
        "16081:8081"
      ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Madrid";
      };
      volumes = [
        "/var/lib/calibre/config:/config"
        "/var/lib/calibre/database:/database"
        "${das1}/books_and_podcasts/books/ebooks:/books"
      ];
    };

    # CALIBRE-WEB — E-book Web Interface
    calibre-web = {
      image = "lscr.io/linuxserver/calibre-web:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      dependsOn = [ "calibre" ];
      ports = [ "16083:8083" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Madrid";
      };
      volumes = [
        "/var/lib/calibre-web/config:/config"
        "/var/lib/calibre/database:/database"
        "${das1}/books_and_podcasts/books/ebooks:/books"
      ];
    };

    # STIRLING PDF — PDF manipulation toolkit
    stirling-pdf = {
      image = "docker.io/stirlingpdf/stirling-pdf:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "5005:8080" ];
      environment = {
        DOCKER_ENABLE_SECURITY = "true";
        LANGS = "en_GB";
      };
      volumes = [
        "/var/lib/stirling-pdf/trainingData:/usr/share/tessdata"
        "/var/lib/stirling-pdf/configs:/configs"
      ];
    };

    # ACTUAL BUDGET — Personal Budgeting
    actual-budget = {
      image = "docker.io/actualbudget/actual-server:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "5006:5006" ];
      volumes = [
        "${das1}/actual-data:/data"
      ];
    };

    # HOARDER — Bookmark Manager with AI
    hoarder = {
      image = "ghcr.io/hoarder-app/hoarder:release";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      dependsOn = [ "hoarder-meilisearch" ];
      ports = [ "3001:3000" ];
      volumes = [
        "${das1}/hoarder/data:/data"
      ];
      environment = {
        MEILI_ADDR = "http://hoarder-meilisearch:7700";
        BROWSER_WEB_URL = "http://hoarder-chrome:9222";
        DATA_DIR = "/data";
        OPENAI_API_KEY = "___SECRET_MANAGED___";
      };
    };

    hoarder-chrome = {
      image = "gcr.io/zenika-hub/alpine-chrome:123";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      cmd = [
        "--no-sandbox"
        "--disable-gpu"
        "--disable-dev-shm-usage"
        "--remote-debugging-address=127.0.0.1"
        "--remote-debugging-port=9222"
        "--hide-scrollbars"
      ];
    };

    hoarder-meilisearch = {
      image = "docker.io/getmeili/meilisearch:v1.11.1";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      environment = {
        MEILI_NO_ANALYTICS = "true";
      };
      volumes = [
        "${das1}/hoarder/meilisearch:/meili_data"
      ];
    };

    # DAWARICH — Location History Tracker
    dawarich = {
      image = "docker.io/freikin/dawarich:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      dependsOn = [ "dawarich-sidekiq" ];
      ports = [ "6006:3000" ];
      entrypoint = "web-entrypoint.sh";
      cmd = [ "bin/rails" "server" "-p" "3000" "-b" "::" ];
      volumes = [
        "${das1}/dawarich/public:/var/app/public"
        "${das1}/dawarich/storage:/var/app/storage"
      ];
      environment = {
        RAILS_ENV = "production";
        REDIS_URL = "redis://host.containers.internal:6379/2";
        DATABASE_HOST = "host.containers.internal";
        DATABASE_USERNAME = "dawarich";
        DATABASE_PASSWORD = "___SECRET_MANAGED___";
        DATABASE_NAME = "dawarich";
        MIN_MINUTES_SPENT_IN_CITY = "60";
        APPLICATION_HOSTS = "apollo";
        TIME_ZONE = "Europe/Madrid";
        APPLICATION_PROTOCOL = "http";
        DISTANCE_UNIT = "km";
        SELF_HOSTED = "true";
        ENABLE_TELEMETRY = "false";
      };
    };

    dawarich-sidekiq = {
      image = "docker.io/freikin/dawarich:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      entrypoint = "sidekiq-entrypoint.sh";
      cmd = [ "sidekiq" ];
      volumes = [
        "${das1}/dawarich/public:/var/app/public"
        "${das1}/dawarich/storage:/var/app/storage"
      ];
      environment = {
        RAILS_ENV = "production";
        REDIS_URL = "redis://host.containers.internal:6379/2";
        DATABASE_HOST = "host.containers.internal";
        DATABASE_USERNAME = "dawarich";
        DATABASE_PASSWORD = "___SECRET_MANAGED___";
        DATABASE_NAME = "dawarich";
        APPLICATION_HOSTS = "apollo";
        BACKGROUND_PROCESSING_CONCURRENCY = "10";
        APPLICATION_PROTOCOL = "http";
        DISTANCE_UNIT = "km";
        SELF_HOSTED = "true";
        ENABLE_TELEMETRY = "false";
      };
    };
  };
}