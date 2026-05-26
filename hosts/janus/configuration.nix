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

  # Keyboard layout at login screen (SDDM) — Spanish for family users
  services.xserver.xkb.layout = "es";

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
    defaultLocale = "es_ES.UTF-8";  # Spanish UI in SDDM and system messages
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

    # Miracast / wireless display (cast screen to smart TVs over Wi-Fi Direct)
    gnome-network-displays
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
      CPU_SCALING_GOVERNOR_ON_AC = lib.mkForce "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = lib.mkForce "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = lib.mkForce "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkForce "balance_power";
      # Battery care - prolong lifespan
      START_CHARGE_THRESH_BAT0 = lib.mkForce 20;
      STOP_CHARGE_THRESH_BAT0 = lib.mkForce 80;
    };
  };

  # ============================================================================
  # Desktop Environment (System Level)
  # ============================================================================

  # KDE is enabled via profiles.desktop above (modules/desktop/kde.nix)
  # SDDM greeter runs in X11 mode (wayland.enable = false, the default) so
  # QML themes render correctly.  The KDE plasma session itself is still Wayland.
  services.displayManager.sddm.enable = true;

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
      "docker"
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

  # Fran is added to the "rosa" group so she can read/manage Rosa's files.
  users.users.fran = {
    isNormalUser = true;
    description = "Fran";
    initialPassword = "fran"; # CHANGE on first login with `passwd`
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
      "input"
      "rosa"   # Access to Rosa's home dir (mode 0750, via tmpfiles rule above)
    ];
    shell = pkgs.bash;
  };

  users.users.rosa = {
    isNormalUser = true;
    description = "Rosa";
    initialPassword = "rosa"; # CHANGE on first login with `passwd`
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

      # janus is a family multimedia PC — keep admin tools, strip dev/hacking tools
      home.profiles.power-user = {
        enable = true;
        network.enable   = lib.mkForce false;  # No wireshark/nmap/socat on family PC
        dev-gui.enable   = lib.mkForce false;  # No imhex/insomnia
        upscayl.enable   = lib.mkForce false;
        torrenting.enable = lib.mkForce false;
        # system.enable stays true → btop, qdirstat, gparted, cpu-x
        # cli-utils.enable stays true → jq, ffmpeg, ripgrep, fd, etc.
        # productivity.enable stays true → obsidian, calibre
      };

      # Disable Ollama service (no ROCm on a general-use PC)
      services.ollama-service.enable = lib.mkForce false;

      # Keyboard: US as default, Spanish as secondary (switch via system tray)
      home.file.".config/kxkbrc".text = ''
        [Layout]
        DisplayNames=,
        LayoutList=us,es
        Model=pc105
        Use=true
        VariantList=,
      '';

      # Install Claude Code independently of the development profile
      programs.ai-tools = {
        enable = true;
        tools.claude-code.enable = true;
      };
    };

  home-manager.users.elena =
    { ... }:
    {
      imports = [ ../../home/users/elena.nix ];
    };

  home-manager.users.fran =
    { ... }:
    {
      imports = [ ../../home/users/fran.nix ];
    };

  home-manager.users.rosa =
    { ... }:
    {
      imports = [ ../../home/users/rosa.nix ];
    };

  # ============================================================================
  # Containers
  # ============================================================================

  virtualisation.docker.enable = true;

  # ============================================================================
  # Screen Sharing & Connectivity
  # ============================================================================

  # KDE Connect: phone integration, remote control, clipboard sync.
  # Also enables casting to some Android/Samsung TVs.
  # Opens firewall ports 1714-1764 TCP+UDP automatically.
  programs.kdeconnect.enable = true;

  # Bluetooth (for wireless keyboards, speakers, headphones, BT TVs)
  modules.system.bluetooth.enable = true;

  # ============================================================================
  # System Services
  # ============================================================================

  # Syncthing for jpolo only (personal file sync)
  services.syncthing-jpolo.enable = true;

  # Plex client firewall rules (GDM network discovery + downloads/sync)
  services.plex-client.enable = true;

  # ============================================================================
  # Spanish Government Certificate Tools
  # ============================================================================

  # ConfiguradorFNMT — configures the FNMT digital certificate in browsers
  # Available to all users system-wide
  programs.configuradorfnmt.enable = true;

  # ============================================================================
  # Flatpak — for apps not in nixpkgs (e.g. official gov binaries)
  # Managed declaratively via nix-flatpak (github:gmodena/nix-flatpak).
  # ============================================================================

  services.flatpak = {
    enable = true;

    # Add Flathub as the package source
    remotes = [
      {
        name     = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    # Packages installed system-wide (available to all users).
    # These are the unmodified official binaries as published by their authors.
    packages = [
      # AutoFirma — Spanish government digital signature app (official build)
      { appId = "es.gob.afirma.autofirma"; origin = "flathub"; }
    ];

    # Don't auto-update on every nixos-rebuild switch;
    # update manually with: flatpak update
    update.onActivation = false;
  };

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

    "d /nix/var/nix/profiles/per-user/fran  0755 fran  users -"
    "d /home/fran/.local/state/home-manager 0755 fran  users -"
    "d /home/fran/.local/state/home-manager/gcroots 0755 fran users -"

    # Rosa's home is group-readable so Fran (member of group "rosa") can manage her files
    "d /home/rosa 0750 rosa rosa -"
    "d /nix/var/nix/profiles/per-user/rosa  0755 rosa  users -"
    "d /home/rosa/.local/state/home-manager 0755 rosa  users -"
    "d /home/rosa/.local/state/home-manager/gcroots 0755 rosa users -"
  ];

  # ============================================================================
  # Programs
  # ============================================================================

  programs.zsh.enable = true;

  # Allow unfree packages (VLC codecs, libdvdcss, etc.)
  nixpkgs.config.allowUnfree = true;

  # ============================================================================
  # SDDM Rotating Wallpaper
  # ============================================================================

  # On every boot, pick a random KDE wallpaper and write it to an SDDM
  # drop-in config before the display manager starts.
  systemd.services.sddm-randomize-wallpaper = {
    description = "Pick a random SDDM login screen wallpaper";
    before = [ "display-manager.service" ];
    wantedBy = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "sddm-randomize-wallpaper" ''
        set -euo pipefail
        WALLPAPER_BASE="/run/current-system/sw/share/wallpapers"
        [ -d "$WALLPAPER_BASE" ] || exit 0

        # Collect one image per wallpaper (highest-res from contents/images/, else screenshot)
        images=()
        while IFS= read -r -d $'\0' dir; do
          img=$(find "$dir/contents/images" -name "*.jpg" -o -name "*.png" 2>/dev/null | sort -V | tail -1)
          [ -z "$img" ] && img=$(find "$dir" -maxdepth 1 -name "screenshot.*" 2>/dev/null | head -1)
          [ -n "$img" ] && images+=("$img")
        done < <(find "$WALLPAPER_BASE" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

        count=''${#images[@]}
        [ "$count" -eq 0 ] && exit 0

        selected="''${images[$((RANDOM % count))]}"
        mkdir -p /etc/sddm.conf.d
        printf '[Theme]\nBackground=%s\n' "$selected" > /etc/sddm.conf.d/99-wallpaper.conf
      '';
    };
  };

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
