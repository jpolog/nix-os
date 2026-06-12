{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Storage
#
# USB-attached drives with nofail + noatime to prevent boot hangs and
# reduce write wear on spinning rust / flash storage.
#
# NOTE: Replace UUIDs with actual values from `lsblk -o name,uuid,mountpoint`
# on the apollo hardware before deploying.
###############################################################################
{
  # ---------------------------------------------------------------------------
  # USB Drive Mounts
  # ---------------------------------------------------------------------------

  # TerraMaster TDAS 7.3TB — primary media and data storage
  fileSystems."/mnt/das1" = {
    device = "/dev/disk/by-uuid/c70e973a-0741-488b-9183-f60b95a86b0f";
    fsType = "ext4";
    options = [
      "nofail"
      "noatime"
      "defaults"
    ];
  };

  # WD Elements 5.5TB — secondary storage
  fileSystems."/mnt/elements" = {
    device = "/dev/disk/by-uuid/E634934734931A1F";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "noatime"
      "uid=1000"
      "gid=1000"
      "dmask=022"
      "fmask=133"
    ];
  };

  # USB flash 116GB — music storage
  fileSystems."/mnt/music_usb" = {
    device = "/dev/disk/by-uuid/1EB9-4446";
    fsType = "exfat";
    options = [
      "nofail"
      "noatime"
      "uid=1000"
      "gid=1000"
    ];
  };

  # ---------------------------------------------------------------------------
  # Swap — 4GB file
  # ---------------------------------------------------------------------------
  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];

  # ---------------------------------------------------------------------------
  # Persistent Directory Structure (systemd-tmpfiles)
  # ---------------------------------------------------------------------------
  systemd.tmpfiles.rules = let
    d = "d"; z = "0750"; r = "-";
  in [
    # Database data directories
    "${d} /var/lib/postgresql ${z} postgres postgres ${r}"
    "${d} /var/lib/redis       ${z} redis redis       ${r}"
    "${d} /var/lib/mysql        ${z} mysql mysql       ${r}"

    # Native service data directories
    "${d} /var/lib/plex         ${z} plex plex         ${r}"
    "${d} /var/lib/vaultwarden  ${z} vaultwarden vaultwarden ${r}"
    "${d} /var/lib/prometheus   ${z} prometheus prometheus ${r}"
    "${d} /var/lib/grafana      ${z} grafana grafana   ${r}"

    # Container config/storage directories
    "${d} /var/lib/containers/config ${z} root root   ${r}"
    "${d} /var/lib/containers/data   ${z} root root   ${r}"

    # Individual container config directories
    "${d} /var/lib/qbittorrent/config  ${z} root root ${r}"
    "${d} /var/lib/jackett/config      ${z} root root ${r}"
    "${d} /var/lib/sonarr_en/config    ${z} root root ${r}"
    "${d} /var/lib/sonarr_es/config    ${z} root root ${r}"
    "${d} /var/lib/radarr_en/config    ${z} root root ${r}"
    "${d} /var/lib/radarr_es/config    ${z} root root ${r}"
    "${d} /var/lib/lidarr/config       ${z} root root ${r}"
    "${d} /var/lib/bazarr/config       ${z} root root ${r}"
    "${d} /var/lib/prowlarr/config     ${z} root root ${r}"
    "${d} /var/lib/seerr/config        ${z} root root ${r}"
    "${d} /var/lib/seerr_es/config     ${z} root root ${r}"
    "${d} /var/lib/komga               ${z} root root ${r}"
    "${d} /var/lib/threadfin/conf      ${z} root root ${r}"
    "${d} /var/lib/threadfin/temp      ${z} root root ${r}"
    "${d} /var/lib/audiobookshelf/config   ${z} root root ${r}"
    "${d} /var/lib/audiobookshelf/metadata ${z} root root ${r}"
    "${d} /var/lib/calibre/config      ${z} root root ${r}"
    "${d} /var/lib/calibre/database    ${z} root root ${r}"
    "${d} /var/lib/calibre-web/config  ${z} root root ${r}"
    "${d} /var/lib/firefly/upload      ${z} root root ${r}"
    "${d} /var/lib/stirling-pdf/configs    ${z} root root ${r}"
    "${d} /var/lib/stirling-pdf/trainingData ${z} root root ${r}"
    "${d} /var/lib/homepage/config     ${z} root root ${r}"
    "${d} /var/lib/scrutiny            ${z} root root ${r}"
    "${d} /var/lib/makemkv             ${z} root root ${r}"
    "${d} /var/lib/dispatcharr         ${z} root root ${r}"
    "${d} /var/lib/open-webui          ${z} root root ${r}"

    # Media data directories on USB drives
    "${d} /mnt/das1/mediaserver/tvshows         0755 jpolo users ${r}"
    "${d} /mnt/das1/mediaserver/movies          0755 jpolo users ${r}"
    "${d} /mnt/das1/mediaserver/spanish/tvshows 0755 jpolo users ${r}"
    "${d} /mnt/das1/mediaserver/spanish/movies  0755 jpolo users ${r}"
    "${d} /mnt/das1/mediaserver/comics          0755 jpolo users ${r}"
    "${d} /mnt/das1/mediaserver/courses         0755 jpolo users ${r}"
    "${d} /mnt/das1/mediaserver/videos          0755 jpolo users ${r}"
    "${d} /mnt/das1/mediaserver/downloads       0755 jpolo users ${r}"
  ];
}