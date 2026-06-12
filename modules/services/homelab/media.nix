{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Media Services
#
# Plex Media Server (native NixOS)
# Gluetun VPN sidecar + download clients (*arr stack as OCI containers)
###############################################################################
let
  lsioEnv = {
    PUID = "1000";
    PGID = "1000";
    TZ = "Europe/Madrid";
  };

  mediaDir  = "/mnt/das1/mediaserver";
  downloadsDir = "/mnt/elements/mediaserver/downloads";
  musicDir  = "/mnt/music_usb/mediaserver/music";
  installDir = "/var/lib";

  sops.secrets."vpn/user" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };
  sops.secrets."vpn/password" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  sops.templates."gluetun.env" = {
    content = ''
      OPENVPN_USER=${config.sops.placeholder."vpn/user"}
      OPENVPN_PASSWORD=${config.sops.placeholder."vpn/password"}
    '';
    owner = "root";
    group = "root";
    mode = "0400";
  };
in
{
  # ---------------------------------------------------------------------------
  # Plex Media Server — Native NixOS module
  # ---------------------------------------------------------------------------
  services.plex = {
    enable = true;
    dataDir = "/var/lib/plex";
  };

  users.users.plex.extraGroups = [ "users" ];

  systemd.services.plex.serviceConfig = {
    SupplementaryGroups = [ "users" ];
    BindReadOnlyPaths = [
      "${mediaDir}/movies:/data/movies"
      "${mediaDir}/tvshows:/data/tvshows"
      "${mediaDir}/tvrecordings:/data/tvrecordings"
      "${mediaDir}/spanish/movies:/data/spanish_movies"
      "${mediaDir}/spanish/tvshows:/data/spanish_tvshows"
      "${mediaDir}/videos:/data/videos"
      "${mediaDir}/courses:/data/courses"
      "${musicDir}:/data/music"
      "/mnt/das1/books_and_podcasts/books/audiobooks:/data/music_2"
      "${downloadsDir}:/data/downloads"
      "/home/jpolo/epg:/epg"
    ];
  };

  # ---------------------------------------------------------------------------
  # OCI Containers — Media stack
  # ---------------------------------------------------------------------------
  virtualisation.oci-containers.containers = {

    # GLUETUN — VPN sidecar (NordVPN via OpenVPN)
    gluetun = {
      image = "docker.io/qmcgaw/gluetun:v3";
      autoStart = true;
      extraOptions = [
        "--restart=always"
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
        "--health-cmd=curl -sfL http://localhost:8000/v1/openvpn/status || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=3"
        "--health-start-period=60s"
      ];
      environment = {
        VPN_SERVICE_PROVIDER = "nordvpn";
        VPN_TYPE = "openvpn";
        OPENVPN_CIPHERS = "AES-256-GCM";
        SERVER_COUNTRIES = "Spain,Portugal,France";
      };
      environmentFiles = [
        config.sops.templates."gluetun.env".path
      ];
      volumes = [
        "${installDir}/containers/config/gluetun:/config"
      ];
      ports = [
        "8888:8888/tcp"
        "8388:8388/tcp"
        "8388:8388/udp"
        "8080:8080/tcp"
        "9117:9117"
      ];
    };

    # QBITTORRENT — via gluetun VPN
    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:4.6.0";
      autoStart = true;
      dependsOn = [ "gluetun" ];
      extraOptions = [
        "--restart=always"
        "--network=container:gluetun"
      ];
      environment = lsioEnv // {
        WEBUI_PORT = "8080";
      };
      volumes = [
        "${downloadsDir}:/downloads"
        "${installDir}/qbittorrent/config:/config"
      ];
    };

    # JACKETT — via gluetun VPN
    jackett = {
      image = "lscr.io/linuxserver/jackett:latest";
      autoStart = true;
      dependsOn = [ "gluetun" ];
      extraOptions = [
        "--restart=always"
        "--network=container:gluetun"
      ];
      environment = lsioEnv;
      volumes = [
        "${installDir}/jackett/config:/config"
      ];
    };

    # SONARR — TV Shows (English)
    sonarr_en = {
      image = "lscr.io/linuxserver/sonarr:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "8989:8989" ];
      environment = lsioEnv;
      volumes = [
        "${mediaDir}/tvshows:/tv"
        "${downloadsDir}:/downloads"
        "${installDir}/sonarr_en/config:/config"
      ];
    };

    # SONARR — TV Shows (Spanish)
    sonarr_es = {
      image = "lscr.io/linuxserver/sonarr:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "8990:8989" ];
      environment = lsioEnv;
      volumes = [
        "${mediaDir}/spanish/tvshows:/tv"
        "${downloadsDir}:/downloads"
        "${installDir}/sonarr_es/config:/config"
      ];
    };

    # RADARR — Movies (English)
    radarr_en = {
      image = "lscr.io/linuxserver/radarr:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "7878:7878" ];
      environment = lsioEnv;
      volumes = [
        "${mediaDir}/movies:/movies"
        "${downloadsDir}:/downloads"
        "${installDir}/radarr_en/config:/config"
      ];
    };

    # RADARR — Movies (Spanish)
    radarr_es = {
      image = "lscr.io/linuxserver/radarr:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "7879:7878" ];
      environment = lsioEnv;
      volumes = [
        "${mediaDir}/spanish/movies:/movies"
        "${downloadsDir}:/downloads"
        "${installDir}/radarr_es/config:/config"
      ];
    };

    # LIDARR — Music
    lidarr = {
      image = "lscr.io/linuxserver/lidarr:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "8686:8686" ];
      environment = lsioEnv;
      volumes = [
        "${musicDir}:/music"
        "${downloadsDir}:/downloads"
        "${installDir}/lidarr/config:/config"
      ];
    };

    # PROWLARR — Indexer Manager
    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      autoStart = true;
      ports = [ "9696:9696" ];
      environment = lsioEnv // {
        DOTNET_SYSTEM_NET_HTTP_SOCKETSHTTPHANDLER_HTTP2SUPPORT = "false";
      };
      volumes = [
        "${installDir}/prowlarr/config:/config"
      ];
      extraOptions = [
        "--restart=always"
        "--sysctl=net.ipv6.conf.all.disable_ipv6=1"
        "--dns=1.1.1.1"
        "--dns=8.8.8.8"
      ];
    };

    # BAZARR — Subtitles
    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "6767:6767" ];
      environment = lsioEnv;
      volumes = [
        "${mediaDir}/movies:/movies"
        "${mediaDir}/tvshows:/tv"
        "${mediaDir}/spanish/movies:/movies_es"
        "${mediaDir}/spanish/tvshows:/tv_es"
        "${installDir}/bazarr/config:/config"
      ];
    };

    # FLARESOLVERR — Cloudflare bypass for Jackett/Prowlarr
    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "8191:8191" ];
      environment = {
        LOG_LEVEL = "info";
        LOG_HTML = "false";
        CAPTCHA_SOLVER = "none";
        TZ = "Europe/Madrid";
      };
    };

    # SEERR — Media Requests (English)
    seerr = {
      image = "ghcr.io/seerr-team/seerr:latest";
      autoStart = true;
      ports = [ "5055:5055" ];
      environment = {
        LOG_LEVEL = "info";
        TZ = "Europe/Madrid";
        PORT = "5055";
      };
      volumes = [
        "${installDir}/seerr/config:/app/config"
      ];
      extraOptions = [
        "--restart=always"
        "--init"
      ];
    };

    # SEERR — Media Requests (Spanish)
    seerr_es = {
      image = "ghcr.io/seerr-team/seerr:latest";
      autoStart = true;
      ports = [ "5056:5055" ];
      environment = {
        LOG_LEVEL = "info";
        TZ = "Europe/Madrid";
        PORT = "5055";
      };
      volumes = [
        "${installDir}/seerr_es/config:/app/config"
      ];
      extraOptions = [
        "--restart=always"
        "--init"
      ];
    };

    # THREADFIN — IPTV/M3U proxy
    threadfin = {
      image = "docker.io/fyb3roptik/threadfin:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "34400:34400" ];
      volumes = [
        "${installDir}/threadfin/conf:/home/threadfin/conf"
        "${installDir}/threadfin/temp:/tmp/threadfin:rw"
      ];
    };

    # KOMGA — Comic/Manga server
    komga = {
      image = "docker.io/gotson/komga:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "25600:25600" ];
      user = "1000:1000";
      environment = { TZ = "Europe/Madrid"; };
      volumes = [
        "${installDir}/komga:/config"
        "${mediaDir}/comics:/data"
      ];
    };

    # DISPATCHARR — Media automation
    dispatcharr = {
      image = "ghcr.io/dispatcharr/dispatcharr:latest";
      autoStart = true;
      ports = [ "3005:9191" ];
      environment = {
        DISPATCHARR_ENV = "aio";
        REDIS_HOST = "host.containers.internal";
        CELERY_BROKER_URL = "redis://host.containers.internal:6379/5";
        DISPATCHARR_LOG_LEVEL = "info";
      };
      volumes = [
        "${installDir}/dispatcharr:/data"
        "/home/jpolo/epg:/epg"
      ];
      extraOptions = [
        "--restart=always"
        "--device=/dev/dri:/dev/dri"
      ];
    };

    # MAKEMKV — DVD/Blu-ray ripper
    makemkv = {
      image = "docker.io/jlesage/makemkv:latest";
      autoStart = true;
      extraOptions = [ "--restart=always" ];
      ports = [ "5800:5800" ];
      volumes = [
        "${installDir}/makemkv:/config:rw"
        "/mnt/elements/mediaserver:/storage:ro"
        "/mnt/elements/mediaserver/MakeMKV/output:/output:rw"
      ];
    };
  };
}