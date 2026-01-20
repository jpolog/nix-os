{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Note: System modules are imported via flake.nix sharedModules
    # Only add host-specific modules here
  ];

  # ============================================================================
  # System Information
  # ============================================================================
  
  networking.hostName = "ares";
  networking.hostId = "8425e34f";  # Required for ZFS
  system.stateVersion = "25.11";   # DO NOT CHANGE

  # ============================================================================
  # Bootloader
  # ============================================================================
  
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Kernel parameters for ThinkPad T14s Gen 6 AMD
    kernelParams = [
      "quiet"
      "splash"
      "amd_pstate=active"  # Better AMD P-state driver
    ];

    kernelPackages = pkgs.linuxPackages_latest;
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
  
  profiles.base.enable = true;        # Essential system packages
  profiles.desktop.enable = true;     # Desktop environment (Hyprland, fonts, etc.)
  # profiles.style.enable = true;     # Replaced by themes.active below
  
  # Active Theme
  # themes.active = "thinknix"; # Disabled as Stylix/Themes module removed
  
  profiles.development.enable = true; # Development tools
  profiles.gaming.enable = true;      # Gaming infrastructure (drivers, isolated user)
  
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
  };

  # ============================================================================
  # Users
  # ============================================================================
  
  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin";
    extraGroups = [
      "wheel"           # sudo access
      "networkmanager"  # network management
      "video"           # video devices
      "audio"           # audio devices
      "input"           # input devices
      "power"           # power management
      "docker"          # docker daemon (when development profile enabled)
    ];
    shell = pkgs.zsh;
  };
  
  # ============================================================================
  # Home Manager - User Configuration
  # ============================================================================
  
  home-manager.users = {
    jpolo = import ../../home/users/jpolo.nix;
    gaming = import ../../home/users/gaming.nix;
  };

  # ============================================================================
  # Home Manager Integration - DISABLED (Using standalone instead)
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
  # System Services
  # ============================================================================
  
  # OpenSSH - Configuration inherited from modules/system/ssh.nix
  # Default settings: PermitRootLogin = "no", PasswordAuthentication = true
  # Uncomment to override:
  # services.openssh.settings.PermitRootLogin = "yes";  # Only if needed


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
  ];

  # ============================================================================
  # Programs
  # ============================================================================
  
  programs.zsh.enable = true;

  # Allow unfree packages (system-wide)
  nixpkgs.config.allowUnfree = true;
}

