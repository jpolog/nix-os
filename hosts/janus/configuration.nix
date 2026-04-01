{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    # Note: System modules are imported via flake.nix sharedModules
  ];

  # ============================================================================
  # System Information
  # ============================================================================

  networking.hostName = "janus";
  system.stateVersion = "25.11"; # DO NOT CHANGE

  # ============================================================================
  # Bootloader
  # ============================================================================

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "quiet"
      "splash"
      "i915.enable_psr=1"  # Panel Self Refresh - saves battery on Intel iGPU
    ];

    # Load i915 early for better boot experience
    initrd.kernelModules = [ "i915" ];
  };

  # ============================================================================
  # Networking
  # ============================================================================

  networking.networkmanager.enable = true;

  # ============================================================================
  # Nix Settings
  # ============================================================================

  nix = {
    package = pkgs.nix;
    settings = {
      substituters = [
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  # ============================================================================
  # Localization
  # ============================================================================

  time.timeZone = "Europe/Madrid";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "es_ES.UTF-8";
      LC_IDENTIFICATION = "es_ES.UTF-8";
      LC_MEASUREMENT = "es_ES.UTF-8";
      LC_MONETARY = "es_ES.UTF-8";
      LC_NAME = "es_ES.UTF-8";
      LC_NUMERIC = "es_ES.UTF-8";
      LC_PAPER = "es_ES.UTF-8";
      LC_TELEPHONE = "es_ES.UTF-8";
      LC_TIME = "es_ES.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
  };

  # ============================================================================
  # System Profiles
  # ============================================================================

  profiles.base.enable = true;    # Essential system packages
  profiles.desktop = {
    enable = true;
    environment = "kde";          # KDE for all users on this machine
  };
  profiles.development.enable = false; # General-use PC, no dev tools

  # ============================================================================
  # Media & Codec Support (CRITICAL)
  # ============================================================================

  # Intel i5 8th gen (Coffee Lake) - Intel UHD 620 iGPU
  hardware.enableRedistributableFirmware = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver  # iHD driver - required for Intel gen 8+ VA-API (H.264, H.265, VP9...)
      libvdpau-va-gl      # VDPAU via VA-API (VLC VDPAU output path)
      libva-utils         # vainfo - useful to verify VA-API is working
    ];
  };

  # Tell VA-API to use the iHD driver (intel-media-driver)
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # Full GStreamer codec stack - enables all formats in KDE apps and VLC
  environment.systemPackages = with pkgs; [
    # GStreamer - complete codec stack
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good   # AAC, MP4, AVI, FLAC, JPEG, PNG, WebM, OGG...
    gst_all_1.gst-plugins-bad    # HLS, DASH, FLAC, MPEG-TS, H.265...
    gst_all_1.gst-plugins-ugly   # H.264, MP3, MPEG-2, AC3, x264...
    gst_all_1.gst-libav          # ffmpeg-backed: almost all remaining formats
    gst_all_1.gst-vaapi          # Hardware-accelerated decode via VA-API

    # FFmpeg with all codecs (used by VLC, mpv, etc.)
    ffmpeg

    # DVD playback support
    libdvdcss    # Encrypted DVD decryption (unfree)
    libdvdread
    libdvdnav

    # Additional codec libraries
    x264
    x265

    # Home Manager CLI
    home-manager
  ];

  # ============================================================================
  # Printing
  # ============================================================================

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    gutenprint          # Wide generic driver support
    hplip               # HP printers
    canon-cups-ufr2     # Canon printers
  ];
  # Enable mDNS for printer auto-discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ============================================================================
  # Power Management
  # ============================================================================

  # Laptop power management via TLP (modules/system/power.nix enables it)
  # Disable power-profiles-daemon since it conflicts with TLP
  services.power-profiles-daemon.enable = lib.mkForce false;

  services.tlp = {
    enable = true;
    settings = {
      # Intel 8th gen - use powersave governor (works well with HWP)
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      # Battery care - prolong lifespan
      START_CHARGE_THRESH_BAT0 = 20;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # ============================================================================
  # Desktop Environment (System Level)
  # ============================================================================

  # KDE is enabled via profiles.desktop above (modules/desktop/kde.nix)
  # SDDM is enabled via the KDE module but we ensure it here for clarity
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";

  # Touchpad / input
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;   # Natural scrolling on for family users
      disableWhileTyping = true;
    };
  };

  # ============================================================================
  # Users
  # ============================================================================

  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin";
    extraGroups = [
      "wheel"          # sudo access
      "networkmanager"
      "video"
      "audio"
      "input"
      "power"
    ];
    shell = pkgs.zsh;
  };

  users.users.elena = {
    isNormalUser = true;
    description = "Elena";
    initialPassword = "elena"; # CHANGE on first login with `passwd`
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
      "input"
    ];
    shell = pkgs.bash;
  };

  users.users.padres = {
    isNormalUser = true;
    description = "Padres";
    initialPassword = "padres"; # CHANGE on first login with `passwd`
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
      "input"
    ];
    shell = pkgs.bash;
  };

  # ============================================================================
  # Home Manager - User Configuration
  # ============================================================================

  # jpolo on janus: admin user with personal/power-user setup, NO dev tools
  home-manager.users.jpolo =
    { lib, ... }:
    {
      imports = [ ../../home/users/jpolo.nix ];

      # Override desktop to KDE
      home.profiles.desktop.environment = lib.mkForce "kde";

      # Disable development-heavy profiles - this is a general-use machine
      home.profiles.development.enable = lib.mkForce false;
      home.profiles.work.enable = lib.mkForce false;
      home.profiles.research.enable = lib.mkForce false;
      home.profiles.master.enable = lib.mkForce false;
      home.profiles.creative.enable = lib.mkForce false;

      # Keep power-user but lighter: no upscayl, keep CLI utils
      home.profiles.power-user = {
        enable = true;
        upscayl.enable = lib.mkForce false;
        torrenting.enable = lib.mkForce false;
      };

      # Disable Ollama service (no ROCm on a general-use PC)
      services.ollama-service.enable = lib.mkForce false;
    };

  home-manager.users.elena =
    { ... }:
    {
      imports = [ ../../home/users/elena.nix ];
    };

  home-manager.users.padres =
    { ... }:
    {
      imports = [ ../../home/users/padres.nix ];
    };

  # ============================================================================
  # System Services
  # ============================================================================

  # Syncthing for jpolo only (personal file sync)
  services.syncthing-jpolo.enable = true;

  # ============================================================================
  # Compatibility
  # ============================================================================

  services.envfs.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    glib
    gtk3
    nss
    nspr
    freetype
    fontconfig
    cairo
    pango
    atk
    gdk-pixbuf
    libxml2
  ];

  # ============================================================================
  # Home Manager State Dirs
  # ============================================================================

  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/jpolo  0755 jpolo  users -"
    "d /home/jpolo/.local/state/home-manager 0755 jpolo  users -"
    "d /home/jpolo/.local/state/home-manager/gcroots 0755 jpolo users -"

    "d /nix/var/nix/profiles/per-user/elena  0755 elena  users -"
    "d /home/elena/.local/state/home-manager 0755 elena  users -"

    "d /nix/var/nix/profiles/per-user/padres 0755 padres users -"
    "d /home/padres/.local/state/home-manager 0755 padres users -"
  ];

  # ============================================================================
  # Programs
  # ============================================================================

  programs.zsh.enable = true;

  # Allow unfree packages (VLC codecs, libdvdcss, etc.)
  nixpkgs.config.allowUnfree = true;

  # ============================================================================
  # Optimizations
  # ============================================================================

  documentation.enable = false;
  documentation.nixos.enable = false;

  zramSwap.enable = true;

  # Allow adding a tag to the generation via environment variable
  system.nixos.tags =
    let
      tag = builtins.getEnv "REBUILD_TAG";
    in
    if tag != "" then [ tag ] else [ ];
}
