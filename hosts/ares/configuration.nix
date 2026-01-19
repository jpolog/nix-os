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
      "libvirtd"        # VM management (when virtualization enabled)
      "kvm"             # KVM access (when virtualization enabled)
    ];
    shell = pkgs.zsh;
  };

  # ============================================================================
  # Home Manager Integration
  # ============================================================================

  # Ensure profile directory exists before home-manager service starts
  systemd.tmpfiles.rules = [
    "d /nix/var/nix/profiles/per-user/jpolo 0755 jpolo users -"
  ];
  
  systemd.services."home-manager-jpolo" = {
    wants = [ "systemd-tmpfiles-setup.service" ];
    after = [ "systemd-tmpfiles-setup.service" ];
  };

  # Home Manager user configuration
  home-manager.users.jpolo = { ... }: {
    imports = [ ../../home/users/jpolo.nix ];
    
    # Ares-specific: Full development workstation
    home.profiles = {
      base.enable = true;
      desktop.enable = true;
      
      # Enable development with shells
      development = {
        enable = true;
        devShells = {
          enable = true;              # Enable dev shells
          enableLaunchers = true;      # Enable launcher scripts
          enableDirenvTemplates = true; # Enable direnv templates
        };
        editors = {
          vscode.enable = true;
          neovim.enable = true;
        };
      };
      
      personal.enable = true;
      creative.enable = true;
    };
  };


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
  
  environment.systemPackages = with pkgs; [
    # Essential editors
    vim
    nano  # Included by default but explicit is better
    
    # Network tools
    wget
    curl
    
    # Version control
    git
    
    # System monitoring
    htop
    btop
    
    # System information
    neofetch
    pciutils   # lspci
    usbutils   # lsusb
    lshw       # Hardware lister
    dmidecode  # DMI table decoder
  ];

  # ============================================================================
  # Programs
  # ============================================================================
  
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}

