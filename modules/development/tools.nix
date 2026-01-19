{ config, pkgs, ... }:

{
  # Development tools and utilities
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gh  # GitHub CLI
    lazygit
    tig
    git-crypt  # Encrypted files in git
    gitleaks  # Secret scanner
    pre-commit  # Git hooks framework
    
    # Database tools
    sqlite
    postgresql
    redis
    dbeaver-bin  # Universal database tool
    
    # API testing
    postman
    insomnia
    httpie  # Better curl
    
    # Build tools
    gnumake
    cmake
    meson
    ninja
    bazel
    
    # Debugging
    gdb
    lldb
    valgrind
    rr  # Record and replay
    
    # Performance profiling
    hyperfine  # Benchmarking
    flamegraph
    heaptrack  # Memory profiler
    perf-tools
    
    # Network tools
    curl
    wget
    httpie
    netcat
    nmap
    mtr
    wireshark
    tcpdump
    
    # Container tools (additional)
    kubectl
    k9s
    helm
    kind  # Kubernetes in Docker
    ctop  # Container top
    
    # Cloud CLIs
    awscli2
    google-cloud-sdk
    azure-cli
    terraform
    terragrunt
    ansible
    
    # Text processing
    jq
    yq-go
    fx  # JSON viewer
    dasel  # JSON/YAML/TOML/XML query
    miller  # CSV/TSV processing
    
    # Documentation
    mdbook
    graphviz
    plantuml
    
    # Monitoring
    btop
    iftop
    bandwhich  # Network bandwidth monitor
    procs  # Better ps
    
    # File sync
    rsync
    rclone
    syncthing
    
    # Benchmarking
    wrk  # HTTP benchmarking
    
    # Terminal multiplexing
    tmux
    screen
    
    # Better CLI tools
    tealdeer  # tldr client
    trash-cli  # Safe rm
    tokei  # Code statistics
    
    # Code quality
    shellcheck  # Shell script analysis
    yamllint
    
    # File tools
    file
    tree
    ncdu  # Disk usage analyzer
    duf  # Better df
    dust  # Better du
    
    # Security tools
    age  # Encryption tool
    sops  # Secrets management
    
    # Hex editors
    hexyl
    
    # Binary analysis
    binutils
    radare2
  ];

  # Enable system-wide command-not-found using nix-index
  programs.command-not-found.enable = false;  # Disable default
  
  # Git configuration (global)
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
    };
  };
}
