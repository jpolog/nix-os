{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/desktop
    ../../modules/services
    ../../modules/development
  ];

  # System Information
  networking.hostName = "ares";
  system.stateVersion = "25.11";

  # Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    
    # Kernel parameters for ThinkPad T14s Gen 6
    kernelParams = [ 
      "quiet"
      "splash"
      "amd_pstate=active"
    ];
    
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Nix Settings
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

  # Timezone and Locale
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";
  
  i18n.extraLocaleSettings = {
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

  # Console
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Users
  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin";
    extraGroups = [ 
      "wheel" 
      "networkmanager" 
      "video" 
      "audio" 
      "input" 
      "power"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  # Essential System Packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    btop
    neofetch
    pciutils
    usbutils
    lshw
    dmidecode
  ];

  # ZSH
  programs.zsh.enable = true;
}
