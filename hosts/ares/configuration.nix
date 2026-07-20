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
    ./university-vpn.nix
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

  # Docker Services Firewall
  networking.firewall = {
    allowedTCPPorts = [
      12000 # Traefik HTTP
      12001 # Traefik Dashboard
      12010 # Auth Service
      12011 # Pipeline Config Service
      12012 # Artifacts Service
      12013 # LangGraph Orchestrator
      12014 # Webapp
      3000 # Langfuse (observability)
      8081 # Mongo Express (dev profile)
      11434 # Ollama
    ];
    # Use extraCommands instead of trustedInterfaces for wildcards
    # as trustedInterfaces doesn't consistently support br-+ wildcards
    extraCommands = ''
      iptables -A INPUT -i docker0 -j ACCEPT
      iptables -A INPUT -i br-+ -j ACCEPT
      iptables -A FORWARD -i docker0 -j ACCEPT
      iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      iptables -A FORWARD -i br-+ -j ACCEPT
      iptables -A FORWARD -o br-+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    '';
  };

  # Keep Docker in charge of bridge NAT/FORWARD chains for published ports.
  virtualisation.docker.daemon.settings = {
    iptables = true;
    ip6tables = true;
    "ip-forward" = true;
  };

  # Docker bridge/NAT path requires forwarding at kernel level.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = lib.mkDefault 1;
    "net.ipv6.conf.all.forwarding" = lib.mkDefault 1;
  };

  # ============================================================================
  # Nix Settings
  # ============================================================================

  nix = {
    package = pkgs.nix;
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
        "https://nixpkgs-python.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nixpkgs-python.cachix.org-1:hxjI7pINPn9njGHQxRXUwQ+ZxXqO0mZ59x2uTfRc2h0="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
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
  # Virtual Machines
  # ============================================================================

  vms.enable = true;
  vms.windows11.enable = true;

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
  home-manager.users.jpolo =
    { lib, ... }:
    {
      imports = [ ../../home/users/jpolo.nix ];
      home.profiles.desktop.environment = "hyprland";
      services.ollama-service = {
        enable = true;
        acceleration = "rocm";
      };

      # Custom theme and Dolphin configuration for jpolo on ares
      home.file."Pictures/Wallpapers/0-black-moon.jpg".source = ../../modules/themes/assets/wallpapers/0-black-moon.jpg;

      xdg.configFile."quickshell/noctalia/settings.json".text = builtins.toJSON {
        "General" = {
          "scale" = 1.0;
          "backend" = "hyprland";
          "cursorTheme" = "Bibata-Modern-Classic";
        };
        "Wallpaper" = {
          "enabled" = true;
          "directory" = "/home/jpolo/Pictures/Wallpapers";
          "viewMode" = "single";
          "fillMode" = "crop";
        };
        "Theme" = {
          "mode" = "dark";
          "useSystemColors" = false; # Disabled system colors
          "blur" = true;
          "blurOpacity" = 0.9;
          "cornerRadius" = 8;
          "fontFamily" = "JetBrains Mono";
          "fontSize" = 12;
        };
        "colorSchemes" = {
          "schemeType" = "M3-Rainbow";
          "useWallpaperColors" = true;
        };
        "Bar" = { "enabled" = true; "position" = "top"; "height" = 42; };
        "ControlCenter" = { "enabled" = true; "position" = "right"; "width" = 400; };
      };

    };

  # ============================================================================
  # Desktop Environments (System Level)
  # ============================================================================

  services.power-profiles-daemon.enable = lib.mkForce false;

  # Enable TLP for advanced power management
  services.tlp = {
    enable = true;
    settings = {
      # Battery charge thresholds
      START_CHARGE_THRESH_BAT0 = lib.mkForce 70;
      STOP_CHARGE_THRESH_BAT0 = lib.mkForce 80;

      CPU_SCALING_GOVERNOR_ON_AC = lib.mkForce "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = lib.mkForce "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = lib.mkForce "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = lib.mkForce "balance_power";
      CPU_BOOST_ON_AC = lib.mkForce 0;
      CPU_BOOST_ON_BAT = lib.mkForce 0;
      # Disable USB autosuspend for Logitech Unifying Receiver (K850 keyboard)
      USB_DENYLIST = "046d:c52b";
    };
  };

  # Enable thinkfan for intelligent fan control
  services.thinkfan = {
    enable = true;

    # Use working temperature sensors
    # Note: ThinkPad ACPI temp sensors (temp1-3,5-8) are not readable on T14s Gen 6 AMD
    # Only k10temp (AMD CPU) and acpitz (ACPI thermal zone) work reliably
    sensors = [
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "k10temp";
        indices = [ 1 ]; # AMD CPU temperature (Tctl)
      }
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "acpitz";
        indices = [ 1 ]; # ACPI thermal zone
      }
    ];

    # Fan control levels - BALANCED PROFILE (optimized for noise/temps)
    # Format: [fan_level min_temp max_temp]
    # Temperatures in Celsius with proper hysteresis
    levels = [
      [
        0
        0
        42
      ] # Fan off until 42°C - silent operation
      [
        1
        38
        48
      ] # Very quiet - light activity (12°C hysteresis)
      [
        2
        45
        55
      ] # Quiet - moderate load (12°C hysteresis)
      [
        3
        52
        62
      ] # Comfortable - sustained work (12°C hysteresis)
      [
        4
        58
        68
      ] # Active cooling (10°C hysteresis)
      [
        5
        64
        74
      ] # Strong cooling (10°C hysteresis)
      [
        6
        70
        78
      ] # Aggressive cooling (8°C hysteresis)
      [
        7
        75
        32767
      ] # Maximum - emergency only
    ];
  };

  # Enable TTY autologin for jpolo (replaces SDDM)
  services.displayManager.sddm.enable = lib.mkForce false;
  services.getty.autologinUser = "jpolo";

  # Enable touchpad support (libinput)
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = false;
      disableWhileTyping = true;
    };
  };

  # ============================================================================
  # Graphics Support
  # ============================================================================

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva-utils
      libvdpau-va-gl
    ];
  };

  # ============================================================================
  # Gaming — system-level Steam/Proton (jpolo home profile adds wine + utils)
  # ============================================================================

  programs.steam.enable = true; # steam + proton + controller udev rules
  programs.steam.protontricks.enable = true;
  programs.gamemode.enable = true; # gamemoded system daemon

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
  ];

  # AccountsService avatar — SDDM reads icon from /var/lib/AccountsService/
  system.activationScripts.accountsServiceAvatar = lib.stringAfter [ "users" ] ''
    mkdir -p /var/lib/AccountsService/icons /var/lib/AccountsService/users
    ln -sf ${../../home/users/assets/jpolo_profile.jpg} /var/lib/AccountsService/icons/jpolo
    if ! grep -q "^Icon=" /var/lib/AccountsService/users/jpolo 2>/dev/null; then
      printf '[User]\nIcon=/var/lib/AccountsService/icons/jpolo\nSystemAccount=false\n' \
        > /var/lib/AccountsService/users/jpolo
    fi
  '';

  # ============================================================================
  # Compatibility
  # ============================================================================

  # Enable envfs to allowing standard shebangs (#!/bin/bash, /usr/bin/env, etc.)
  # to work transparently by populating /bin and /usr/bin dynamically.
  services.envfs.enable = true;

  # Enable nix-ld for running unpatched dynamic binaries
  # This fixes issues with Obsidian plugins (like Zotero), VS Code extensions, etc.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    # Add other common libs if needed
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
    cairo
    gdk-pixbuf
    libxml2
    libxslt
  ];

  # ============================================================================
  # System Services
  # ============================================================================

  # Disable sleep on lid close for remote access
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Disable HPLIP (HP Device Manager) as requested
  modules.services.printing.includeHplip = false;

  # Enable Syncthing for jpolo
  services.syncthing-jpolo.enable = true;

  # Enable Plex Client firewall rules for downloads/sync
  services.plex-client.enable = true;

  # Enable Sunshine for Remote Streaming
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Udev rule for Moonlight Keyboard Passthrough
  services.udev.extraRules = ''
    KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="Keyboard passthrough", SYMLINK+="input/by-id/moonlight-keyboard"
  '';

  # KMonad Keyboard Configuration
  modules.services.kmonad = {
    enable = true;
    keyboards =
      let
        # Choose layout: "standard" or "miryoku"
        # The selectedLayout variable now controls the *default* behavior.
        # Specific keyboards can override this.
        defaultLayout = "standard";

        mkKmonadConfig =
          devicePath:
          if defaultLayout == "miryoku" then mkMiryokuConfig devicePath else mkStandardConfig devicePath;

        mkStandardConfig = devicePath: ''
          ;; --------------------------------------------------------------------------
          ;; Custom KMonad Configuration for jpolo (v9 - Fixed symbols layer)
          ;;
          ;; 1. Dual-role Caps Lock : Tap = Escape,  Hold = control layer
          ;; 2. Dual-role 'k'       : Tap = k,       Hold = numpad layer
          ;; 3. Dual-role 'l'       : Tap = l,       Hold = Left Alt
          ;; 4. Dual-role ';'       : Tap = ;,       Hold = Left Ctrl
          ;; 5. Dual-role 'a'       : Tap = a,       Hold = Left Ctrl  (mirrors ;)
          ;; 6. Dual-role 's'       : Tap = s,       Hold = Left Alt   (mirrors l)
          ;; 7. Dual-role 'd'       : Tap = d,       Hold = symbols layer (mirrors k)
          ;;
          ;; Symbols layer zones:
          ;;   Left  = Shift+number mirror of numpad (same spatial grid)
          ;;   Right = Bracket/operator grid on uiojklm,.
          ;; --------------------------------------------------------------------------

          (defcfg
            input  (device-file "${devicePath}")
            output (uinput-sink "My KMonad output")
            fallthrough true
            allow-cmd true
          )

          (defsrc
            esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft z    x    c    v    b    n    m    ,    .    /    rsft
            lctl lmet lalt           spc            ralt comp rctl
          )

          (defalias
            ctl_esc       (tap-hold-next-release 200 esc (layer-toggle control))
            k_numpad      (tap-hold-next-release 300 k   (layer-toggle numpad))
            l_alt         (tap-hold-next-release 300 l   lalt)
            semicolon_ctl (tap-hold-next-release 200 ;   lctl)
            a_ctl         (tap-hold-next-release 300 a   lctl)
            s_alt         (tap-hold-next-release 300 s   lalt)
            d_sym         (tap-hold-next-release 300 d   (layer-toggle symbols))
          )

          (deflayer qwerty
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            @ctl_esc @a_ctl @s_alt @d_sym _ _ _ _ @k_numpad @l_alt @semicolon_ctl _ _
            _    _    _    _    _    _    _    _    _    _    _    _
            _    _    _              _              _    _    _
          )

          (deflayer control
            C-esc C-1 C-2 C-3 C-4 C-5 C-6 C-7 C-8 C-9 C-0 C-- C-= C-bspc
            C-tab C-q C-w C-e C-r C-t C-y C-u C-i C-o C-p C-[ C-] C-bksl
            caps  C-a C-s C-d C-f C-g left down up right C-; C-' C-ret
            lsft  C-z C-x C-c C-v C-b C-n C-m C-, C-. C-/ rsft
            lctl  lmet lalt           C-spc          ralt comp rctl
          )

          (deflayer numpad
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    7    8    9    _    _    _    _    _    _    _    _    _
            _    _    4    5    6    _    _    _    k    _    _    _    _
            _    0    1    2    3    _    _    _    _    _    _    _
            _    _    _              _              _    _    _
          )

          (deflayer symbols
            ;; Left side  = Shift+number mirror of numpad (same spatial memory)
            ;; Right side = bracket/operator grid on uiojklm,.
            ;;
            ;;  numpad:   w=7   e=8   r=9       u=[  i=]  o=\  p=~
            ;;  symbols:  w=&   e=*   r=(  t=%  u=[  i=]  o=\  p=~
            ;;
            ;;  numpad:   s=4   d=5   f=6       j=(  k=)  l=|
            ;;  symbols:  s=$   d=XX  f=^       j={  k=}  l=|
            ;;
            ;;  numpad:   z=0   x=1   c=2   v=3     m=_  ,=-  .==
            ;;  symbols:  z=)   x=!   c=@   v=#     m=_  ,=-  .==
            _    _    _    _    _    _    _    _    _    _    _    _    _    _
            _    _    (around lsft 7) (around lsft 8) (around lsft 9) (around lsft 5) _    [    ]    bksl   (around lsft grv) _    _    _
            _    _    (around lsft 4) XX   (around lsft 6) _    _    (around lsft lbrc) (around lsft rbrc) (around lsft bksl) _    _    _
            _    (around lsft 0) (around lsft 1) (around lsft 2) (around lsft 3) _    _    (around lsft -) -    =    _    _
            _    _    _              _              _    _    _
          )
        '';

        mkMiryokuConfig = devicePath: ''
                  ;; Copyright 2021 Manna Harbour
          ;; github.com/manna-harbour/miryoku
                 
                 
                 
                 
                 
          (defcfg
            input (device-file "keyboard")
            output (uinput-sink "Miryoku KMonad output")
            fallthrough false
          )
          (defsrc
            2 3 4 5 6 8 9 0 - =
            q w e r t i o p [ ]
            caps a s d f k l ; ' ent
                          x c v , . /
          )
          (deflayer U_BASE
          q	w	f	p	b	j	l	u	y	'
          (tap-hold-next-release 200 a met)	(tap-hold-next-release 200 r alt)	(tap-hold-next-release 200 s ctl)	(tap-hold-next-release 200 t sft)	g	m	(tap-hold-next-release 200 n sft)	(tap-hold-next-release 200 e ctl)	(tap-hold-next-release 200 i alt)	(tap-hold-next-release 200 o met)
          (tap-hold-next-release 200 z (layer-toggle U_BUTTON))	(tap-hold-next-release 200 x ralt)	c	d	v	k	h	,	(tap-hold-next-release 200 . ralt)	(tap-hold-next-release 200 / (layer-toggle U_BUTTON))
          		(tap-hold-next-release 200 esc (layer-toggle U_MEDIA))	(tap-hold-next-release 200 spc (layer-toggle U_NAV))	(tap-hold-next-release 200 tab (layer-toggle U_MOUSE))	(tap-hold-next-release 200 ent (layer-toggle U_SYM))	(tap-hold-next-release 200 bspc (layer-toggle U_NUM))	(tap-hold-next-release 200 del (layer-toggle U_FUN))
          )
          (deflayer U_EXTRA
          q	w	e	r	t	y	u	i	o	p
          (tap-hold-next-release 200 a met)	(tap-hold-next-release 200 s alt)	(tap-hold-next-release 200 d ctl)	(tap-hold-next-release 200 f sft)	g	h	(tap-hold-next-release 200 j sft)	(tap-hold-next-release 200 k ctl)	(tap-hold-next-release 200 l alt)	(tap-hold-next-release 200 ' met)
          (tap-hold-next-release 200 z (layer-toggle U_BUTTON))	(tap-hold-next-release 200 x ralt)	c	v	b	n	m	,	(tap-hold-next-release 200 . ralt)	(tap-hold-next-release 200 / (layer-toggle U_BUTTON))
          		(tap-hold-next-release 200 esc (layer-toggle U_MEDIA))	(tap-hold-next-release 200 spc (layer-toggle U_NAV))	(tap-hold-next-release 200 tab (layer-toggle U_MOUSE))	(tap-hold-next-release 200 ent (layer-toggle U_SYM))	(tap-hold-next-release 200 bspc (layer-toggle U_NUM))	(tap-hold-next-release 200 del (layer-toggle U_FUN))
          )
          (deflayer U_TAP
          q	w	f	p	b	j	l	u	y	'
          a	r	s	t	g	m	n	e	i	o
          z	x	c	d	v	k	h	,	.	/
          		esc	spc	tab	ent	bspc	del
          )
          (deflayer U_BUTTON
          undo	S-del	C-ins	S-ins	again	again	S-ins	C-ins	S-del	undo
          met	alt	ctl	sft	XX	XX	sft	ctl	alt	met
          undo	S-del	C-ins	S-ins	again	again	S-ins	C-ins	S-del	undo
          		#(kp* kp5)	#(kp/ kp5)	#(kp- kp5)	#(kp- kp5)	#(kp/ kp5)	#(kp* kp5)
          )
          (deflayer U_NAV
          XX	(multi-tap 200 XX (layer-switch U_TAP))	(multi-tap 200 XX (layer-switch U_EXTRA))	(multi-tap 200 XX (layer-switch U_BASE))	XX	again	S-ins	C-ins	S-del	undo
          met	alt	ctl	sft	XX	caps	left	down	up	right
          XX	ralt	(multi-tap 200 XX (layer-switch U_NUM))	(multi-tap 200 XX (layer-switch U_NAV))	XX	ins	home	pgdn	pgup	end
          		XX	XX	XX	ent	bspc	del
          )
          (deflayer U_MOUSE
          XX	(multi-tap 200 XX (layer-switch U_TAP))	(multi-tap 200 XX (layer-switch U_EXTRA))	(multi-tap 200 XX (layer-switch U_BASE))	XX	again	S-ins	C-ins	S-del	undo
          met	alt	ctl	sft	XX	XX	kp4	kp2	kp8	kp6
          XX	ralt	(multi-tap 200 XX (layer-switch U_SYM))	(multi-tap 200 XX (layer-switch U_MOUSE))	XX	XX	XX	XX	XX	XX
          		XX	XX	XX	#(kp- kp5)	#(kp/ kp5)	#(kp* kp5)
          )
          (deflayer U_MEDIA
          XX	(multi-tap 200 XX (layer-switch U_TAP))	(multi-tap 200 XX (layer-switch U_EXTRA))	(multi-tap 200 XX (layer-switch U_BASE))	XX	XX	XX	XX	XX	XX
          met	alt	ctl	sft	XX	XX	previoussong	vold	volu	nextsong
          XX	ralt	(multi-tap 200 XX (layer-switch U_FUN))	(multi-tap 200 XX (layer-switch U_MEDIA))	XX	XX	XX	XX	XX	XX
          		XX	XX	XX	stopcd	playpause	mute
          )
          (deflayer U_NUM
          [	7	8	9	]	XX	(multi-tap 200 XX (layer-switch U_BASE))	(multi-tap 200 XX (layer-switch U_EXTRA))	(multi-tap 200 XX (layer-switch U_TAP))	XX
          ;	4	5	6	=	XX	sft	ctl	alt	met
          `	1	2	3	\	XX	(multi-tap 200 XX (layer-switch U_NUM))	(multi-tap 200 XX (layer-switch U_NAV))	ralt	XX
          		.	0	-	XX	XX	XX
          )
          (deflayer U_SYM
          {	&	*	\\(	}	XX	(multi-tap 200 XX (layer-switch U_BASE))	(multi-tap 200 XX (layer-switch U_EXTRA))	(multi-tap 200 XX (layer-switch U_TAP))	XX
          :	$	%	^	+	XX	sft	ctl	alt	met
          ~	!	@	#	|	XX	(multi-tap 200 XX (layer-switch U_SYM))	(multi-tap 200 XX (layer-switch U_MOUSE))	ralt	XX
          		\\(	\\)	\\_	XX	XX	XX
          )
          (deflayer U_FUN
          f12	f7	f8	f9	sysrq	XX	(multi-tap 200 XX (layer-switch U_BASE))	(multi-tap 200 XX (layer-switch U_EXTRA))	(multi-tap 200 XX (layer-switch U_TAP))	XX
          f11	f4	f5	f6	slck	XX	sft	ctl	alt	met
          f10	f1	f2	f3	pause	XX	(multi-tap 200 XX (layer-switch U_FUN))	(multi-tap 200 XX (layer-switch U_MEDIA))	ralt	XX
          		comp	spc	tab	XX	XX	XX
          )

        '';
      in
      {
        "laptop-keyboard" = {
          device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
          config = mkStandardConfig "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        };
        "usb-keyboard" = {
          device = "/dev/input/by-id/usb-CX_2.4G_Receiver-event-kbd";
          config = mkStandardConfig "/dev/input/by-id/usb-CX_2.4G_Receiver-event-kbd";
        };
        "logitech-keyboard" = {
          device = "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-kbd";
          config = mkStandardConfig "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-kbd";
        };
        "usb-keyboard-cable" = {
          device = "/dev/input/by-id/usb-SEM_USB_Keyboard-event-kbd";
          config = mkStandardConfig "/dev/input/by-id/usb-SEM_USB_Keyboard-event-kbd";
        };
        "moonlight-keyboard" = {
          device = "/dev/input/by-id/moonlight-keyboard";
          config = mkStandardConfig "/dev/input/by-id/moonlight-keyboard";
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

  # Disable documentation to avoid failing documentation builds (like python3.12-doc)
  documentation.enable = false;
  documentation.nixos.enable = false;

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
    brightnessctl
    desktop-file-utils
    shared-mime-info
    wgnord
    (writeShellScriptBin "nordvpn" ''
      set -euo pipefail

      usage() {
        cat <<'EOF'
Usage: nordvpn <command> [args]
  login <token>        Login using NordVPN access token
  connect <country>    Connect to a country (example: spain)
  disconnect           Disconnect VPN
  account              Show account information
  help                 Show this help
EOF
      }

      cmd="''${1:-help}"
      case "$cmd" in
        login)
          token="''${2:-}"
          if [ -z "$token" ]; then
            echo "Missing token. Usage: nordvpn login <token>" >&2
            exit 1
          fi
          exec ${wgnord}/bin/wgnord l "$token"
          ;;
        connect)
          country="''${2:-}"
          if [ -z "$country" ]; then
            echo "Missing country. Usage: nordvpn connect <country>" >&2
            exit 1
          fi
          exec sudo ${wgnord}/bin/wgnord c "$country"
          ;;
        disconnect)
          exec sudo ${wgnord}/bin/wgnord d
          ;;
        account|status)
          exec ${wgnord}/bin/wgnord a
          ;;
        help|-h|--help)
          usage
          ;;
        *)
          echo "Unknown command: $cmd" >&2
          usage
          exit 1
          ;;
      esac
    '')
    (writeShellScriptBin "sunshine-headless-connect" ''
      set -euo pipefail

      export HYPRLAND_INSTANCE_SIGNATURE=$(systemctl --user show-environment | grep '^HYPRLAND_INSTANCE_SIGNATURE=' | cut -d= -f2-)
      export WAYLAND_DISPLAY=$(systemctl --user show-environment | grep '^WAYLAND_DISPLAY=' | cut -d= -f2-)
      
      # 1. Create the headless output
      hyprctl output create headless || true
      
      # Wait briefly to ensure Hyprland creates the monitor
      sleep 1
      
      # 2. Get the name of the new headless monitor (usually HEADLESS-1)
      HEADLESS_MON=$(hyprctl monitors all -j | jq -r '.[] | select(.name | startswith("HEADLESS")) | .name' | head -n 1)
      
      if [ -z "$HEADLESS_MON" ]; then
          echo "Could not find headless monitor." >&2
          exit 1
      fi
      
      # Match the headless monitor resolution to the Moonlight client (e.g. iPad)
      if [ -n "''${SUNSHINE_CLIENT_WIDTH:-}" ] && [ -n "''${SUNSHINE_CLIENT_HEIGHT:-}" ] && [ -n "''${SUNSHINE_CLIENT_FPS:-}" ]; then
          MODE="''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}"
          hyprctl eval "hl.monitor({ output = '$HEADLESS_MON', mode = '$MODE', position = 'auto', scale = 1.5 })"
      fi
      
      # 3. Move all workspaces from eDP-1 to the new headless monitor
      for ws in $(hyprctl workspaces -j | jq -r '.[] | select(.monitor == "eDP-1") | .id'); do
          hyprctl dispatch "hl.dsp.workspace.move({ workspace = $ws, monitor = \"$HEADLESS_MON\" })"
      done
      
      # 4. Disable the physical laptop display
      hyprctl eval "hl.monitor({ output = 'eDP-1', disabled = true })"
    '')
    (writeShellScriptBin "sunshine-headless-disconnect" ''
      set -euo pipefail

      export HYPRLAND_INSTANCE_SIGNATURE=$(systemctl --user show-environment | grep '^HYPRLAND_INSTANCE_SIGNATURE=' | cut -d= -f2-)
      export WAYLAND_DISPLAY=$(systemctl --user show-environment | grep '^WAYLAND_DISPLAY=' | cut -d= -f2-)
      
      # 1. Re-enable the physical laptop display
      hyprctl eval "hl.monitor({ output = 'eDP-1', mode = 'preferred', position = 'auto', scale = 1 })"
      
      sleep 1
      
      # 2. Find the headless monitor
      HEADLESS_MON=$(hyprctl monitors all -j | jq -r '.[] | select(.name | startswith("HEADLESS")) | .name' | head -n 1)
      
      if [ -n "$HEADLESS_MON" ]; then
          # 3. Move all workspaces back to eDP-1
          for ws in $(hyprctl workspaces -j | jq -r ".[] | select(.monitor == \"$HEADLESS_MON\") | .id"); do
              hyprctl dispatch "hl.dsp.workspace.move({ workspace = $ws, monitor = \"eDP-1\" })"
          done
          
          # 4. Remove the headless output
          hyprctl output remove "$HEADLESS_MON" || true
      fi
    '')
  ];

  # ============================================================================
  # Programs
  # ============================================================================

  programs.zsh.enable = true;

  # Allow unfree packages (system-wide)
  nixpkgs.config.allowUnfree = true;

  # Permit insecure packages (required by some applications)
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  # Disable kwallet as requested for a pure Hyprland system
  security.pam.services.login.enableKwallet = false;

  # ============================================================================
  # SSD/NVMe Optimizations
  # ============================================================================

  # BTRFS optimizations to reduce wear and improve performance on NVMe
  fileSystems."/".options = [ "noatime" "compress=zstd" "discard=async" "space_cache=v2" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd" "discard=async" "space_cache=v2" ];
  fileSystems."/nix".options = [ "noatime" "compress=zstd" "discard=async" "space_cache=v2" ];
}
