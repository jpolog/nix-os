{ config, pkgs, lib, ... }:

{
  # Isolated gaming/testing profile with firejail sandboxing
  
  # Create isolated gaming user
  users.users.gaming = {
    isNormalUser = true;
    description = "Gaming/Testing (Sandboxed)";
    home = "/home/gaming";
    createHome = true;
    # Minimal groups - NO wheel (no sudo), NO docker, NO other privileged groups
    extraGroups = [ "audio" "video" "input" ];
    shell = pkgs.bash;
    
    # Isolated UID range
    uid = 2000;
  };
  
  # All packages for gaming profile
  environment.systemPackages = with pkgs; [
    # Sandboxing tools
    firejail         # Application sandboxing
    bubblewrap       # Low-level sandboxing
    appimage-run     # For AppImage games
    
    # Gaming - Wine/Proton
    lutris
    wine
    winetricks
    wine64
    wineWowPackages.stable
    wineWowPackages.staging
    
    # Performance tools
    gamemode
    mangohud
    gamescope
    
    # Controller support
    antimicrox
    
    # Performance monitoring
    radeontop
    nvtopPackages.full
    mesa-demos
    vulkan-tools
  ];
  
  # Firejail configuration
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      # Sandbox Steam
      steam = {
        executable = "${pkgs.steam}/bin/steam";
        profile = "${pkgs.firejail}/etc/firejail/steam.profile";
        extraArgs = [
          "--private-tmp"
          "--private-dev"
          "--noroot"
          "--net=none"  # No network access
        ];
      };
      
      # Sandbox Firefox for testing
      firefox-testing = {
        executable = "${pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
        extraArgs = [
          "--private"
          "--private-dev"
          "--private-tmp"
          "--noroot"
        ];
      };
      
      # Generic sandbox for unknown executables
      sandbox = {
        executable = "${pkgs.bash}/bin/bash";
        extraArgs = [
          "--noprofile"
          "--private"
          "--private-dev"
          "--private-tmp"
          "--noroot"
          "--caps.drop=all"
          "--seccomp"
          "--nogroups"
          "--net=none"
          "--shell=none"
        ];
      };
    };
  };
  
  # PAM configuration - prevent sudo for gaming user
  security.sudo.extraRules = [
    {
      users = [ "gaming" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" "NOEXEC" ];
        }
      ];
    }
  ];
  
  # Explicitly deny gaming user from sudo group
  security.sudo.extraConfig = ''
    # Deny gaming user completely
    gaming ALL=(ALL:ALL) !ALL
  '';
  
  # AppArmor profiles for additional isolation
  security.apparmor = {
    enable = true;
    packages = [ pkgs.apparmor-profiles ];
  };
  
  # Restrict gaming user further with systemd
  systemd.services."user@2000" = {
    serviceConfig = {
      # Resource limits
      MemoryMax = "8G";
      CPUQuota = "400%";  # 4 cores max
      IOWeight = 100;
      
      # Security restrictions
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      
      # Prevent access to sensitive directories
      InaccessiblePaths = 
        let
          normalUsers = lib.filterAttrs (name: user: user.isNormalUser && name != "gaming") config.users.users;
          userHomes = lib.mapAttrsToList (name: user: user.home) normalUsers;
        in
        [
          "/root"
          "/boot"
          "/etc/nixos"
          "/nix/var/nix"
        ] ++ userHomes;
      
      # Read-only paths
      ReadOnlyPaths = [
        "/nix/store"
        "/etc"
        "/usr"
      ];
    };
  };
  
  # Polkit rules - prevent gaming user from administrative actions
  security.polkit.extraConfig = ''
    // Deny all administrative actions for gaming user
    polkit.addRule(function(action, subject) {
      if (subject.user == "gaming") {
        return polkit.Result.NO;
      }
    });
  '';
  
  # Network isolation for gaming profile
  networking.firewall = {
    enable = true;
    # Block all outbound connections from gaming user (optional)
  };
  
  # Quota for gaming user (prevent filling disk)
  # Note: Requires filesystem quota support
  # fileSystems."/home".options = [ "usrquota" "grpquota" ];
  
  
  # GameMode for performance optimization
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
      };
    };
  };
  
  # Steam configuration with Proton support
  programs.steam = {
    enable = true;
    
    # Enable Proton-GE and other compatibility tools
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    
    # Firewall rules - keep isolated for security
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    
    # Additional packages for Steam
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        # Dependencies for various games
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
        
        # Gamescope for better gaming experience
        gamescope
        mangohud
        
        # 32-bit libraries for older games
        pipewire
      ];
    };
  };
  
  # Hardware acceleration for gaming
  # Note: hardware.opengl has been renamed to hardware.graphics in NixOS 24.11+
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Required for 32-bit games (replaces driSupport32Bit)
    
    extraPackages = with pkgs; [
      # VAAPI (renamed packages in NixOS 24.11+)
      libva-vdpau-driver  # Renamed from vaapiVdpau
      libvdpau-va-gl
      
      # Vulkan (for Proton/DXVK)
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
    ];
    
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };
  
  # Udev rules for controllers
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];
  
  # Enable joystick support
  hardware.xone.enable = true;  # Xbox controllers
  
  # Additional security: Use separate session for gaming
  # Note: services.xserver.displayManager.sessionPackages has been renamed
  services.displayManager.sessionPackages = [
    (pkgs.writeTextFile rec {
      name = "gaming-session";
      destination = "/share/wayland-sessions/gaming.desktop";
      text = ''
        [Desktop Entry]
        Name=Gaming Session (Isolated)
        Comment=Sandboxed gaming environment
        Exec=${pkgs.cage}/bin/cage -s -- ${pkgs.steam}/bin/steam -bigpicture
        Type=Application
      '';
      # Required: declare provided sessions
      passthru.providedSessions = [ "gaming" ];
    })
  ];
}
