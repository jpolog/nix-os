{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Monitoring Services
#
# Native NixOS:   Prometheus, Grafana, Loki, Promtail, Uptime Kuma,
#                 node-exporter, postgres/redis/nginx exporters
# OCI containers: cAdvisor, Scrutiny, Homepage, Gotify, Portainer
###############################################################################
let
  tailscaleIp = "100.114.69.83";
in
{
  # ---------------------------------------------------------------------------
  # PROMETHEUS — Metrics Collection & Storage
  # ---------------------------------------------------------------------------
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";

    retentionTime = "168h";
    globalConfig = {
      scrape_interval = "30s";
      evaluation_interval = "30s";
    };

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{ targets = ["127.0.0.1:9090"]; }];
      }
      {
        job_name = "node";
        static_configs = [{ targets = ["127.0.0.1:9100"]; }];
      }
      {
        job_name = "cadvisor";
        static_configs = [{ targets = ["127.0.0.1:9200"]; }];
      }
      {
        job_name = "postgres";
        static_configs = [{ targets = ["127.0.0.1:9187"]; }];
      }
      {
        job_name = "redis";
        static_configs = [{ targets = ["127.0.0.1:9121"]; }];
      }
      {
        job_name = "nginx";
        static_configs = [{ targets = ["127.0.0.1:9113"]; }];
      }
    ];

    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "systemd"
          "processes"
          "filesystem"
          "loadavg"
          "meminfo"
        ];
      };
    };

    rules = [
      ''
        groups:
        - name: system
          rules:
          - alert: HighMemoryUsage
            expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
            for: 10m
            annotations:
              summary: "High memory usage (> 90%)"
          - alert: HighDiskUsage
            expr: (1 - (node_filesystem_avail_bytes{mountpoint="/mnt/das1"} / node_filesystem_size_bytes{mountpoint="/mnt/das1"})) * 100 > 95
            for: 10m
            annotations:
              summary: "DAS1 disk usage > 95%"
      ''
    ];
  };

  # ---------------------------------------------------------------------------
  # GRAFANA — Dashboards
  # ---------------------------------------------------------------------------
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "apollo.hippo-pentatonic.ts.net";
        root_url = "%(protocol)s://%(domain)s/grafana";
        serve_from_sub_path = true;
      };
      security = {
        admin_user = "admin";
        admin_password = "___CHANGE_AFTER_FIRST_LOGIN___";
        secret_key = "___CHANGE_AFTER_FIRST_LOGIN___";
      };
      "auth.anonymous".enabled = false;
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
        }
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # LOKI — Log aggregation
  # ---------------------------------------------------------------------------
  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 3100;
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
        };
        chunk_idle_period = "5m";
        chunk_retain_period = "30s";
        max_transfer_retries = 0;
      };

      schema_config.configs = [{
        from = "2024-01-01";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }];

      storage_config = {
        tsdb_shipper.active_index_directory = "/var/lib/loki/tsdb-index";
        tsdb_shipper.cache_location = "/var/lib/loki/tsdb-cache";
        filesystem.directory = "/var/lib/loki/chunks";
      };

      limits_config = {
        retention_period = "168h";
        max_entries_limit_per_query = 5000;
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
        compaction_interval = "10m";
        retention_enabled = true;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # PROMTAIL — Ships logs to Loki
  # ---------------------------------------------------------------------------
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };

      clients = [{
        url = "http://127.0.0.1:3100/loki/api/v1/push";
      }];

      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "apollo";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "hostname";
            }
          ];
        }
        {
          job_name = "containers";
          static_configs = [{
            targets = [ "localhost" ];
            labels = {
              job = "containers";
              host = "apollo";
              __path__ = "/var/lib/containers/storage/overlay-containers/*/userdata/ctr.log";
            };
          }];
        }
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # UPTIME KUMA — Service reachability monitoring & status page
  # ---------------------------------------------------------------------------
  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "3006";
    };
  };

  # ---------------------------------------------------------------------------
  # NGINX EXPORTER — for prometheus to scrape nginx metrics
  # ---------------------------------------------------------------------------
  services.prometheus.exporters.nginx = {
    enable = true;
    port = 9113;
  };

  services.nginx.statusPage = true;

  # ---------------------------------------------------------------------------
  # OCI Containers — Monitoring
  # ---------------------------------------------------------------------------
  virtualisation.oci-containers.containers = {

    # CADVISOR — Container metrics
    cadvisor = {
      image = "gcr.io/cadvisor/cadvisor:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" "--privileged" "--device=/dev/kmsg" ];
      ports = [ "9200:8080" ];
      volumes = [
        "/:/rootfs:ro"
        "/var/run:/var/run:rw"
        "/sys:/sys:ro"
        "/var/lib/docker/:/var/lib/docker:ro"
        "/dev/disk/:/dev/disk:ro"
      ];
    };

    # SCRUTINY — HDD SMART Monitoring
    scrutiny = {
      image = "ghcr.io/analogj/scrutiny:master-omnibus";
      autoStart = true;
      extraOptions = [
        "--restart=always"
        "--cap-add=SYS_RAWIO"
        "--device=/dev/sda"
        "--device=/dev/sdb"
        "--device=/dev/sdc"
        "--device=/dev/sdd"
      ];
      ports = [
        "1121:8080"
        "8086:8086"
      ];
      volumes = [
        "/run/udev:/run/udev:ro"
        "/var/lib/scrutiny/config:/opt/scrutiny/config"
        "/var/lib/scrutiny/influxdb:/opt/scrutiny/influxdb"
      ];
    };

    # HOMEPAGE — Dashboard
    homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "10000:3000" ];
      environment = {
        HOMEPAGE_ALLOWED_HOSTS = "apollo:10000,apollo.hippo-pentatonic.ts.net:80";
      };
      volumes = [
        "/var/lib/homepage/config:/app/config"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
    };

    # GOTIFY — Push Notification Server
    gotify = {
      image = "docker.io/gotify/server:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "10200:80" ];
      environment = {
        GOTIFY_DEFAULTUSER_NAME = "admin";
        GOTIFY_DEFAULTUSER_PASS = "___SECRET_MANAGED___";
      };
      volumes = [
        "/var/lib/gotify/data:/app/data"
      ];
    };

    # PORTAINER — Docker/Podman management UI
    portainer = {
      image = "docker.io/portainer/portainer-ce:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "9000:9000" ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "/var/lib/portainer:/data"
        "/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
    };
  };
}