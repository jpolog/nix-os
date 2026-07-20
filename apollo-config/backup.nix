{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Restic Backups (3-2-1 strategy)
#
# Daily snapshots of databases, container configs, and user data.
# Backups go to a local directory on DAS1 and should be replicated
# offsite (rclone to B2/S3) for the 3-2-1 rule.
#
# Before deploying:
#   1. Create the backup repository:
#      restic -r /mnt/das1/backup-restic init
#   2. Encrypt the restic password via sops-nix:
#      sops secrets/restic-password.yaml
#   3. Ensure /mnt/das1 is mounted before backup runs
###############################################################################
let
  backupPaths = [
    "/var/lib/postgresql"       # PostgreSQL data
    "/var/lib/redis"            # Redis RDB dumps
    "/var/lib/mysql"            # MariaDB data
    "/var/lib/containers/config" # OCI container configs
    "/home/jpolo"               # User data (exclude cache via .restic-exclude)
  ];

  resticEnv = {
    RESTIC_REPOSITORY = "/mnt/das1/backup-restic";
    RESTIC_PASSWORD_FILE = config.sops.secrets."restic/password".path;
  };
in
{
  # ---------------------------------------------------------------------------
  # sops-nix secret for restic repository password
  # ---------------------------------------------------------------------------
  sops.secrets."restic/password" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # ---------------------------------------------------------------------------
  # Restic package (available for manual operations)
  # ---------------------------------------------------------------------------
  environment.systemPackages = [ pkgs.restic ];

  # ---------------------------------------------------------------------------
  # Daily backup via systemd timer
  # ---------------------------------------------------------------------------
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
      # Exclude cache and build artifacts
      ExecStart = "${pkgs.restic}/bin/restic backup ${toString backupPaths} --exclude='.cache' --exclude='.npm' --exclude='node_modules' --exclude='.rustup' --exclude='.cargo'";
      # After backup, prune old snapshots
      ExecStartPost = "${pkgs.restic}/bin/restic forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --prune";
      # Verify repository health after prune
      ExecStartPost = "${pkgs.restic}/bin/restic check";
    };
  };

  # Timer: daily at 2 AM
  systemd.timers.restic-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };

  # ---------------------------------------------------------------------------
  # Restic exclude file (optional, create at deployment time)
  # ---------------------------------------------------------------------------
  # Create /home/jpolo/.restic-exclude with patterns to skip:
  #   .cache/
  #   .local/share/Trash/
  #   Downloads/
}
