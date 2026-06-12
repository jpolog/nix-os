{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Restic Backups (3-2-1 strategy)
#
# Daily snapshots of databases, container configs, and user data.
###############################################################################
let
  backupPaths = [
    "/var/lib/postgresql"
    "/var/lib/redis"
    "/var/lib/mysql"
    "/var/lib/containers/config"
    "/home/jpolo"
  ];

  resticEnv = {
    RESTIC_REPOSITORY = "/mnt/das1/backup-restic";
    RESTIC_PASSWORD_FILE = config.sops.secrets."restic/password".path;
  };
in
{
  sops.secrets."restic/password" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  environment.systemPackages = [ pkgs.restic ];

  systemd.services.restic-backup = {
    description = "Restic backup — daily snapshot to DAS1";
    wantedBy = [ "multi-user.target" ];
    requires = [ "mnt-das1.mount" ];
    after = [ "mnt-das1.mount" "postgresql.service" "redis-default.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      EnvironmentFile = pkgs.writeText "restic-env" ''
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${v}") resticEnv)}
      '';
      ExecStart = "${pkgs.restic}/bin/restic backup ${toString backupPaths} --exclude='.cache' --exclude='.npm' --exclude='node_modules' --exclude='.rustup' --exclude='.cargo'";
      ExecStartPost = "${pkgs.restic}/bin/restic forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --prune";
    };
  };

  systemd.timers.restic-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };
}