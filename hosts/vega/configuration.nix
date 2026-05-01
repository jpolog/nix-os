{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    # Only import headless/system modules
    ../../modules/system/power-profiles.nix
    ../../modules/system/security.nix
    ../../modules/system/ssh.nix
    ../../modules/system/network.nix
    ../../modules/system/optimization.nix
  ];

  # ============================================================================
  # System Identity
  # ============================================================================
  networking.hostName = "vega";
  system.stateVersion = "25.11"; # DO NOT CHANGE

  # ============================================================================
  # Headless Compute Configuration (Vega 56 / ROCm)
  # ============================================================================
  
  # AMD GPU Support for Compute (Vega 56 / GFX900)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd # OpenCL for ROCm
      amdvlk              # Alternative Vulkan driver
      libva               # Video acceleration
    ];
  };

  # Environment variables for ROCm / Compute workloads
  environment.sessionVariables = {
    # Vega 56 (GFX900) compatibility
    HSA_OVERRIDE_GFX_VERSION = "9.0.0";
    # Force GPU to high performance mode
    ROC_ENABLE_PRE_VEGA = "0"; 
  };

  # ============================================================================
  # Disk & Space Management (120GB SSD)
  # ============================================================================
  
  # Aggressive Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  # Disable documentation to save space
  documentation.enable = false;
  documentation.nixos.enable = false;
  documentation.man.enable = false;

  # ============================================================================
  # Performance Tuning
  # ============================================================================
  
  # Performance CPU Governor for Compute
  powerManagement.cpuFreqGovernor = lib.mkForce "performance";
  
  # Enable ZRAM to help with large jobs (32GB swap in RAM)
  zramSwap = {
    enable = true;
    memoryPercent = 50; 
  };

  # ============================================================================
  # Remote Access (SSH Only)
  # ============================================================================
  
  services.openssh.enable = true;
  # Enable Avahi for mDNS (find as vega.local)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # ============================================================================
  # System Profiles (Headless)
  # ============================================================================
  
  profiles.base.enable = true;
  profiles.development.enable = true;
  profiles.desktop.enable = false; # NO GUI
  
  # Configure development for jobs
  profiles.development.languages = {
    python.enable = true; # AI/ML jobs
    rust.enable = true;
    go.enable = true;
    cpp.enable = true;
  };

  profiles.development.tools = {
    docker.enable = true;
    ai.enable = true;
  };

  # ============================================================================
  # Users
  # ============================================================================
  
  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin (Headless)";
    extraGroups = [ "wheel" "video" "render" "docker" "networkmanager" ];
    shell = pkgs.zsh;
    # Ensure you can SSH from your laptop (ares)
    # Add your public key here later or via sops
  };

  # ============================================================================
  # Home Manager - User Configuration
  # ============================================================================
  
  home-manager.users.jpolo = { ... }: {
    imports = [ ../../home/users/jpolo.nix ];
    # Override jpolo's default desktop environment to ensure it's headless
    home.profiles.desktop.enable = lib.mkForce false;
    
    # Configure Ollama for GPU compute on Vega 56
    services.ollama-service = {
      enable = true;
      acceleration = "rocm";
    };

    # Enable task queuing service
    services.pueue = {
      enable = true;
      settings = {
        shared = {
          use_unix_socket = true;
        };
        daemon = {
          default_parallel_tasks = 1; # Sequential by default (like a queue)
          callback = ''
            ssh jpolo@ares.local "source ~/.zshrc && vega-notify 'Task {{ id }}: {{ command }}' '{{ result }}'"
          '';
        };
      };
    };
  };

  # ============================================================================
  # Networking
  # ============================================================================
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 11434 ]; # SSH and Ollama
}
