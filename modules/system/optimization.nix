{ config, pkgs, lib, ... }:

{
  # Better Nix daemon settings
  nix.settings = {
    # Optimize store automatically
    auto-optimise-store = true;
    
    # Build settings
    max-jobs = "auto";
    cores = 0;  # Use all available cores
    
    # Sandbox builds for security
    sandbox = true;
    
    # Allow flakes and commands
    experimental-features = [ "nix-command" "flakes" ];
    
    # Trusted users
    trusted-users = [ "root" "@wheel" ];
    
    # Keep outputs and derivations for better caching
    keep-outputs = true;
    keep-derivations = true;
    
    # Warn about dirty git trees
    warn-dirty = false;
    
    # HTTP connections
    http-connections = 50;
    
    # Build users
    build-users-group = "nixbld";
    
    # Substituters and caches
    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  
  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  
  # Automatic store optimization
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
  
  # Better systemd settings
  systemd = {
    # Improve boot time
    services.systemd-udev-settle.enable = false;
    
    # User service limits
    extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultLimitNOFILE=1048576
    '';
    
    user.extraConfig = ''
      DefaultLimitNOFILE=1048576
    '';
  };
  
  # Better boot settings
  boot = {
    # Kernel parameters for performance
    kernelParams = [
      # Better memory management
      "vm.swappiness=10"
      "vm.vfs_cache_pressure=50"
      
      # Disable watchdog (faster boot)
      "nowatchdog"
      "nmi_watchdog=0"
      
      # Quiet boot
      "quiet"
      "splash"
    ];
    
    # Kernel modules
    kernelModules = [ "tcp_bbr" ];
    
    # Sysctl parameters
    kernel.sysctl = {
      # Network optimizations
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_fastopen" = 3;
      
      # File system optimizations
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 512;
      "fs.file-max" = 2097152;
      
      # Virtual memory optimizations
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;
      
      # Kernel optimizations
      "kernel.pid_max" = 4194304;
      "kernel.sysrq" = 1;
    };
    
    # Faster boot with systemd
    tmp.cleanOnBoot = true;
    loader.timeout = 3;
  };
  
  # Better file system settings
  fileSystems = {
    "/".options = [ "noatime" "nodiratime" ];
  };
  
  # Zram swap for better performance
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  
  # Better console settings
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
  };
  
  # Security hardening
  security = {
    # Protect kernel logs
    protectKernelImage = true;
    
    # AppArmor support
    apparmor.enable = true;
    
    # Better sudo settings
    sudo = {
      enable = true;
      execWheelOnly = true;
      extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
        Defaults timestamp_timeout=30
      '';
    };
    
    # PAM settings
    pam.services = {
      login.enableGnomeKeyring = true;
      sudo.sshAgentAuth = true;
    };
  };
  
  # Better programs
  programs = {
    # Better dconf
    dconf.enable = true;
    
    # Enable mtr for network diagnostics
    mtr.enable = true;
    
    # Better gnupg
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };
    
    # nh - Better nixos-rebuild wrapper
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 5 --keep-since 7d";
      };
      flake = "/home/jpolo/Projects/nix-omarchy/nix";
    };
  };
  
  # Install useful system packages
  environment.systemPackages = with pkgs; [
    # Better build output
    nix-output-monitor
    nvd  # Nix version diff
    
    # System info
    inxi
    hwinfo
    
    # Performance monitoring
    sysstat
    iotop
    
    # Process management
    psmisc
    lsof
  ];
}
