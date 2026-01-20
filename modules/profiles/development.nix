{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.development;
  
  # Common development tools (formerly tools.nix)
  commonTools = with pkgs; [
    # Version control
    git
    gh  # GitHub CLI
    lazygit
    tig
    git-crypt
    gitleaks
    pre-commit
    
    # Text processing & Data
    jq
    yq-go
    fx
    dasel
    miller
    
    # Build & Debug
    gnumake
    cmake
    meson
    ninja
    bazel
    gdb
    lldb
    valgrind
    rr
    
    # Performance
    hyperfine
    flamegraph
    heaptrack
    
    # Network
    curl
    wget
    httpie
    netcat
    nmap
    mtr
    wireshark
    tcpdump
    
    # File & System
    rsync
    rclone
    syncthing
    fd
    ripgrep
    bat
    eza
    tree
    ncdu
    duf
    dust
    file
    
    # Security
    age
    sops
    
    # Terminal
    tmux
    screen
    tealdeer
    zoxide
    fzf
    
    # Code quality
    shellcheck
    yamllint
    tokei
    
    # Nix tools
    nil
    alejandra
  ];

in
{
  options.profiles.development = {
    enable = mkEnableOption "development environment profile";
    
    languages = {
      python.enable = mkEnableOption "Python development tools" // { default = true; };
      nodejs.enable = mkEnableOption "Node.js development tools" // { default = true; };
      rust.enable = mkEnableOption "Rust development tools";
      go.enable = mkEnableOption "Go development tools";
      cpp.enable = mkEnableOption "C/C++ development tools";
      java.enable = mkEnableOption "Java development tools";
      zig.enable = mkEnableOption "Zig development tools";
      lua.enable = mkEnableOption "Lua development tools";
    };
    
    tools = {
      docker.enable = mkEnableOption "Docker and container tools" // { default = true; };
      cloud.enable = mkEnableOption "Cloud CLI tools (AWS, GCP, Azure)";
      kubernetes.enable = mkEnableOption "Kubernetes tools";
      databases.enable = mkEnableOption "Database tools";
      api.enable = mkEnableOption "API testing tools";
    };
  };

  config = mkIf cfg.enable {
    
    # ==========================================================================
    # Core Development Configuration
    # ==========================================================================
    
    # Direnv (formerly direnv.nix)
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    
    # Git Configuration (global defaults)
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "nvim";
      };
    };

    # Disable default command-not-found
    programs.command-not-found.enable = false;

    # Install common tools
    environment.systemPackages = commonTools ++ 
      # ========================================================================
      # Docker Tools
      # ========================================================================
      (optionals cfg.tools.docker.enable (with pkgs; [
        docker-compose
        lazydocker
        dive
        ctop
      ])) ++
      # ========================================================================
      # Languages
      # ========================================================================
      # Python
      (optionals cfg.languages.python.enable (with pkgs; [
        python312
        python312Packages.pip
        python312Packages.virtualenv
        pyright
        black
      ])) ++
      # Node.js
      (optionals cfg.languages.nodejs.enable (with pkgs; [
        nodejs_22
        nodePackages.npm
        nodePackages.yarn
        nodePackages.pnpm
        nodePackages.typescript-language-server
        prettier
      ])) ++
      # Rust
      (optionals cfg.languages.rust.enable (with pkgs; [
        rustc
        cargo
        rustfmt
        clippy
        rust-analyzer
      ])) ++
      # Go
      (optionals cfg.languages.go.enable (with pkgs; [
        go
        gotools
        gopls
      ])) ++
      # C/C++
      (optionals cfg.languages.cpp.enable (with pkgs; [
        gcc
        clang
        cmake
        gnumake
        gdb
      ])) ++
      # Java
      (optionals cfg.languages.java.enable (with pkgs; [
        jdk21
      ])) ++
      # Zig
      (optionals cfg.languages.zig.enable (with pkgs; [
        zig
      ])) ++
      # Lua
      (optionals cfg.languages.lua.enable (with pkgs; [
        lua-language-server
        stylua
      ])) ++
      # ========================================================================
      # Domain Specific Tools
      # ========================================================================
      # Cloud tools
      (optionals cfg.tools.cloud.enable (with pkgs; [
        awscli2
        google-cloud-sdk
        azure-cli
        terraform
        terragrunt
        ansible
      ])) ++
      # Kubernetes
      (optionals cfg.tools.kubernetes.enable (with pkgs; [
        kubectl
        k9s
        helm
        kind
      ])) ++
      # Databases
      (optionals cfg.tools.databases.enable (with pkgs; [
        sqlite
        postgresql
        redis
        dbeaver-bin
      ])) ++
      # API testing
      (optionals cfg.tools.api.enable (with pkgs; [
        postman
        insomnia
        httpie
      ]));
      
    # ==========================================================================
    # Docker Service Configuration (formerly docker.nix)
    # ==========================================================================
    
    virtualisation.docker = mkIf cfg.tools.docker.enable {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    
    users.groups.docker = mkIf cfg.tools.docker.enable {};
    
    # Environment variables
    environment.sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };
}
