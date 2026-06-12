{ config, lib, pkgs, ... }:

with lib;

{
  options.profiles.homelab = {
    enable = mkEnableOption "homelab profile (headless server with Podman)";
  };

  config = mkIf config.profiles.homelab.enable {
    # Inherit server basics
    profiles.server.enable = true;
    profiles.server.services.ssh.enable = true;

    # Override: Use Podman instead of Docker
    virtualisation.docker.enable = false;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings = { subnet = "10.88.0.0/16"; };
    };
    virtualisation.oci-containers.backend = "podman";

    # Headless server — no GUI
    services.xserver.enable = false;
    services.displayManager.enable = false;
    environment.noXlibs = mkDefault true;

    # Minimal documentation (save space)
    documentation = mkIf config.profiles.server.optimization.minimal {
      enable = false;
      man.enable = false;
      info.enable = false;
      doc.enable = false;
      nixos.enable = false;
    };

    # N100-specific kernel
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.kernelParams = [ "intel_iommu=off" ];
    boot.initrd.availableKernelModules = [
      "nvme" "xhci_pci" "usb_storage" "uas" "ahci"
    ];
    boot.tmp.cleanOnBoot = true;

    # Intel GPU for Plex/Immich transcoding
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    hardware.enableRedistributableFirmware = true;

    # Systemd OOM killer (16GB RAM)
    systemd.oomd = {
      enable = true;
      extraConfig = {
        DefaultMemoryPressureDurationSec = "20s";
      };
    };

    # Security
    security.unprivilegedUserns.enable = true;
    security.sudo.execWheelOnly = true;

    # sops-nix secrets
    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      age.keyFile = "/home/jpolo/.config/sops/age/keys.txt";
    };

    # Additional server packages for homelab
    environment.systemPackages = with pkgs; [
      # Disk utilities
      hdparm smartmontools

      # Networking
      bind-utils iperf3 netcat-gnu tcpdump

      # File tools
      p7zip unrar rar rsync rclone

      # Terminal
      tmux kitty.terminfo
    ];

    # Nix GC (30 days for server)
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    nix.settings = {
      min-free = 10 * 1024 * 1024 * 1024;   # 10 GiB
      max-free = 200 * 1024 * 1024 * 1024;  # 200 GiB
      builders-use-substitutes = true;
      extra-substituters = [
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Auto-upgrade
    system.autoUpgrade = {
      enable = true;
      flags = [ "--no-update-lock-file" ];
      dates = "05:00";
      randomizedDelaySec = "45min";
      allowReboot = true;
    };

    # Locale
    time.timeZone = "Europe/Madrid";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_TIME = "en_GB.UTF-8";
        LC_MONETARY = "es_ES.UTF-8";
      };
    };

    # Users
    users = {
      defaultUserShell = pkgs.bash;

      users.jpolo = {
        isNormalUser = true;
        uid = 1000;
        description = "Javier Polo";
        extraGroups = [
          "wheel"
          "networkmanager"
          "podman"
          "video"
          "render"
          "dialout"
          "plugdev"
        ];
      };

      users.sergio = {
        isNormalUser = true;
        uid = 1001;
        description = "Sergio";
        extraGroups = [
          "networkmanager"
          "video"
          "render"
        ];
        shell = pkgs.bash;
      };

      groups.podman = { };
    };

    # Home Manager for jpolo (headless profile)
    home-manager.users.jpolo = { ... }: {
      imports = [ ../../home/users/jpolo.nix ];
      home.profiles.desktop.enable = lib.mkForce false;
    };

    # Allow unfree packages (Plex, unrar, etc.)
    nixpkgs.config.allowUnfree = true;
  };
}