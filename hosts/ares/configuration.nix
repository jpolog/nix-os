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
    # Only add host-specific modules here
    ../../modules/system/power-profiles.nix
    ./eduroam.nix
  ];

  system.powerProfiles.enable = true;

  # ============================================================================
  # System Information
  # ============================================================================

  networking.hostName = "ares";
  networking.hostId = "8425e34f"; # Required for ZFS
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

    # Kernel parameters for ThinkPad T14s Gen 6 AMD
    kernelParams = [
      "quiet"
      "splash"
      "amd_pstate=active" # Better AMD P-state driver
    ];

    kernelPackages = pkgs.linuxPackages_latest;

    # Load thinkpad_acpi for fan control
    kernelModules = [ "thinkpad_acpi" ];
    extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
    '';
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
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # ============================================================================
  # Console
  # ============================================================================

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ============================================================================
  # System Profiles - Enable based on host purpose
  # ============================================================================

  profiles.base.enable = true; # Essential system packages
  profiles.desktop.enable = true; # Desktop environment (Hyprland, fonts, etc.)
  # profiles.style.enable = true;     # Replaced by themes.active below

  # Active Theme
  # themes.active = "thinknix"; # Disabled as Stylix/Themes module removed

  profiles.development.enable = true; # Development tools
  profiles.gaming.enable = false; # Gaming infrastructure (drivers, isolated user)

  # Configure development tools
  profiles.development.languages = {
    python.enable = true;
    nodejs.enable = true;
    rust.enable = false;
    go.enable = false;
  };

  profiles.development.tools = {
    docker.enable = true;
    cloud.enable = false;
    kubernetes.enable = false;
    ai.enable = true;
  };

  # ============================================================================
  # Users
  # ============================================================================

  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin";
    extraGroups = [
      "wheel" # sudo access
      "networkmanager" # network management
      "video" # video devices
      "audio" # audio devices
      "input" # input devices
      "power" # power management
      "docker" # docker daemon (when development profile enabled)
    ];
    shell = pkgs.zsh;
  };

  users.users.gaming = {
    isNormalUser = true;
    description = "Gaming User";
    initialPassword = "gaming";
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

  home-manager.users.gaming =
    { ... }:
    {
      imports = [ ../../home/users/gaming.nix ];
      home.profiles.desktop.environment = "kde";
    };

  home-manager.users.jpolo =
    { ... }:
    {
      imports = [ ../../home/users/jpolo.nix ];
      home.profiles.desktop.environment = "hyprland";
    };

  # ============================================================================
  # Desktop Environments (System Level)
  # ============================================================================

  # Enable the KDE Plasma 6 Desktop Environment
  services.desktopManager.plasma6.enable = true;
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Enable TLP for advanced power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = lib.mkForce "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = lib.mkForce "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = lib.mkForce "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkForce "balance_power";
      CPU_BOOST_ON_AC = lib.mkForce 1;
      CPU_BOOST_ON_BAT = lib.mkForce 0;
      # Disable USB autosuspend for Logitech Unifying Receiver (K850 keyboard)
      USB_DENYLIST = "046d:c52b";
    };
  };

  # Enable thinkfan for intelligent fan control
  services.thinkfan = {
    enable = true;

    # FIXED: Added indices parameter to specify which temp sensor to read
    # Without indices, thinkfan tries to read the directory itself, causing crashes
    sensors = [
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "thinkpad";
        indices = [ 1 ]; # Read temp1_input from ThinkPad ACPI sensor
      }
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "k10temp";
        indices = [ 1 ]; # Read temp1_input from AMD CPU sensor (Tctl)
      }
    ];

    # Fan control levels optimized for ThinkPad T14s Gen 6 AMD
    # Format: [fan_level min_temp max_temp]
    # Temperatures in Celsius with proper hysteresis (10-13°C overlap)
    levels = [
      [
        0
        0
        48
      ] # Silent when idle between calls
      [
        1
        45
        55
      ] # Very quiet - light browsing (7°C overlap)
      [
        2
        52
        62
      ] # Quiet - Zoom video only (7°C overlap)
      [
        3
        58
        68
      ] # Comfortable - typical workload (10°C overlap)
      [
        4
        64
        74
      ] # Active but not loud - heavy compilation (10°C overlap)
      [
        5
        70
        80
      ] # Audible - sustained heavy load (10°C overlap)
      [
        6
        76
        86
      ] # Loud - full throttle work (10°C overlap)
      [
        7
        82
        32767
      ] # Maximum - short bursts only (12°C overlap)
    ];
  };

  # Ensure SDDM is enabled (you likely have this, but verify)
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # ============================================================================
  # Gaming Hardware Support (Manual)
  # ============================================================================

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-utils
      libvdpau-va-gl
    ];
  };

  programs.gamemode.enable = true;

  # ============================================================================
  # Home Manager Integration -
  # ============================================================================

  # NOTE: Home-manager is now integrated as NixOS module via flake.nix
  # User configuration is defined above in home-manager.users.jpolo
  # Profiles are enabled per-user and toggle specific dotfiles/configs

  # Ensure profile directory exists
  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/jpolo 0755 jpolo users -"
    "d /home/jpolo/.local/state/home-manager 0755 jpolo users -"
    "d /home/jpolo/.local/state/home-manager/gcroots 0755 jpolo users -"

    "d /nix/var/nix/profiles/per-user/gaming 0755 gaming users -"
    "d /home/gaming/.local/state/home-manager 0755 gaming users -"
  ];

  # ============================================================================
  # Compatibility
  # ============================================================================

  # Enable envfs to allowing standard shebangs (#!/bin/bash, /usr/bin/env, etc.)
  # to work transparently by populating /bin and /usr/bin dynamically.
  services.envfs.enable = true;

  # ============================================================================
  # System Services
  # ============================================================================

  # Enable Syncthing for jpolo
  services.syncthing-jpolo.enable = true;

  # KMonad Keyboard Configuration
  modules.services.kmonad = {
    enable = true;
    keyboards =
      let
        mkKmonadConfig = devicePath: ''
          ;; --------------------------------------------------------------------------
          ;; Custom KMonad Configuration for jpolo (v7 - Dual-role 'l' for Alt)
          ;;
          ;; This configuration provides:
          ;; 1. Dual-role Caps Lock: Tap for Escape, Hold for 'control' layer.
          ;; 2. Dual-role 'k' key: Tap for 'k', Hold for 'numpad' layer.
          ;; 3. Dual-role 'l' key: Tap for 'l', Hold for Alt modifier.
          ;; --------------------------------------------------------------------------

          (defcfg
            ;; IMPORTANT: Use your keyboard's device file.
            input  (device-file "${devicePath}")
            output (uinput-sink "My KMonad output")
            fallthrough true
            allow-cmd true
          )

          ;; --------------------------------------------------------------------------
          ;; Source Layout (Your physical keyboard - 61 keys total)
          ;; --------------------------------------------------------------------------

          (defsrc
            ;; Row 1 (14 keys)
            esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            ;; Row 2 (14 keys)
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            ;; Row 3 (14 keys)
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            ;; Row 4 (12 keys)
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            ;; Row 5 (7 keys)
            lctl lmet lalt           spc            ralt comp rctl
          )

          ;; --------------------------------------------------------------------------
          ;; Key Aliases
          ;; --------------------------------------------------------------------------

          (defalias
            ;; Dual-role Caps Lock: Tap for Escape, hold for the 'control' layer.
            ctl_esc (tap-hold-next-release 200 esc (layer-toggle control))

            ;; Dual-role 'k' key: Tap for 'k', hold for the 'numpad' layer.
            k_numpad (tap-hold-next-release 300 k (layer-toggle numpad))

            ;; Dual-role 'l' key: Tap for 'l', hold for Alt.
            l_alt (tap-hold-next-release 300 l lalt)
          )

          ;; --------------------------------------------------------------------------
          ;; Layer Definitions
          ;; --------------------------------------------------------------------------

          (deflayer qwerty
            ;; Default layer inherits from defsrc, swapping in our aliases.
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            @ctl_esc _ _    _    _    _    _    _ @k_numpad @l_alt _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _              _              _    _    _
          )

          (deflayer control
            ;; Active when Caps Lock is held. Matched to the 61-key layout.
            C-esc C-1 C-2 C-3 C-4 C-5 C-6 C-7 C-8 C-9 C-0 C-- C-= C-bspc
            C-tab C-q C-w C-e C-r C-t C-y C-u C-i C-o C-p C-[ C-] C-\
            caps  C-a C-s C-d C-f C-g left down up right C-; C-' C-ret
            lsft  C-z C-x C-c C-v C-b C-n C-m C-, C-. C-/ rsft
            lctl  lmet lalt           C-spc          ralt comp rctl
          )

          (deflayer numpad
            ;; Active when 'k' is held. The 'k' position is a no-op.
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    7    8    9    _    _    _    _    _    _    _    _    _
            _    _    4    5    6    _    _    _    k    _    _    _    _
            _    0    1    2    3    _    _    _    _    _    _    _
            _    _    _              _              _    _    _
          )
        '';
      in
      {
        "laptop-keyboard" = {
          device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
          config = mkKmonadConfig "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        };
        "usb-keyboard" = {
          device = "/dev/input/by-id/usb-CX_2.4G_Receiver-event-kbd";
          config = mkKmonadConfig "/dev/input/by-id/usb-CX_2.4G_Receiver-event-kbd";
        };
        "logitech-keyboard" = {
          device = "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-kbd";
          config = mkKmonadConfig "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-kbd";
        };
      };
  };

  # OpenSSH - Configuration inherited from modules/system/ssh.nix
  # Default settings: PermitRootLogin = "no", PasswordAuthentication = true
  # Uncomment to override:
  # services.openssh.settings.PermitRootLogin = "yes";  # Only if needed

  # Allow adding a tag to the generation via environment variable
  # Usage: REBUILD_TAG="my-tag" nh os switch --impure
  system.nixos.tags =
    let
      tag = builtins.getEnv "REBUILD_TAG";
    in
    if tag != "" then [ tag ] else [ ];

  # ============================================================================
  # System Optimization
  # ============================================================================

  # ZRAM swap for better performance
  zramSwap.enable = true;

  # ============================================================================
  # System Packages
  # ============================================================================

  # NOTE: Most packages are now installed via profiles
  # Only add host-specific overrides here if needed
  environment.systemPackages = with pkgs; [
    # Home Manager CLI (useful for debugging)
    home-manager
    radeontop
    amdgpu_top
  ];

  # ============================================================================
  # Programs
  # ============================================================================

  programs.zsh.enable = true;

  # Allow unfree packages (system-wide)
  nixpkgs.config.allowUnfree = true;
}
