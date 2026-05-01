{ config, pkgs, lib, ... }:

{
  # Install tools to manage and analyze snapshots
  environment.systemPackages = with pkgs; [
    btrbk       # The backup/snapshot tool
    compsize    # See actual disk usage (snapshots share blocks)
    snapper     # (Optional) You can still use the CLI for quick lookups if preferred
  ];

  # Mount the physical Btrfs root to manage subvolumes easily
  # UUID for /dev/mapper/cryptroot: 119a5314-824a-4f0b-b101-72345142a797
  fileSystems."/mnt/btrfs-root" = {
    device = "/dev/disk/by-uuid/119a5314-824a-4f0b-b101-72345142a797";
    fsType = "btrfs";
    options = [ "subvolid=5" "noatime" "compress=zstd" ];
  };

  # Configure btrbk - Advanced, declarative Btrfs snapshots
  services.btrbk = {
    instances.local = {
      # Schedule: Run once a day at 2:00 AM
      onCalendar = "02:00";
      
      settings = {
        # Retention policy: Keep it simple but deep
        snapshot_preserve_min = "2d";
        snapshot_preserve = "14d 4w"; # Keep 14 dailies and 4 weeklies

        # Snapshot locations
        snapshot_dir = "btrbk_snapshots";
        
        # We define the subvolumes to snapshot
        volume."/mnt/btrfs-root" = {
          # Snapshot @ (root) - Good for recovering /var or other non-Nix state
          subvolume = "@";
          
          # Snapshot @home (user data) - MOST CRITICAL
          subvolume = "@home";
          
          # We can exclude @nix since it's fully reproducible from config
          # subvolume = "@nix";
        };
      };
    };
  };

  # Create the snapshot directory if it doesn't exist
  systemd.tmpfiles.rules = [
    "d /mnt/btrfs-root/btrbk_snapshots 0700 root root -"
  ];
}
