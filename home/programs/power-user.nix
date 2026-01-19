{ config, pkgs, lib, ... }:

{
  # Advanced power-user home configuration
  
  # Additional power-user packages
  home.packages = with pkgs; [
    # Terminal emulators (alternatives)
    alacritty
    
    # Code searching
    ast-grep           # AST-based code search
    semgrep            # Semantic grep
    
    # Git enhanced
    gh-dash            # GitHub dashboard
    gh-markdown-preview # Preview markdown
    gitleaks           # Find secrets in git
    git-crypt          # Encrypt files in git
    
    # Network analysis
    termshark          # TUI for Wireshark
    rustscan           # Fast port scanner
    
    # Database tools
    pgcli              # Postgres with autocomplete
    mycli              # MySQL with autocomplete
    litecli            # SQLite with autocomplete
    usql               # Universal SQL CLI
    
    # Container tools
    dive               # Docker image explorer
    ctop               # Container monitoring
    lazydocker         # TUI for Docker
    podman-compose
    
    # Kubernetes tools
    kubectx            # Context switching
    stern              # Multi-pod log tailing
    kustomize          # Kubernetes customization
    
    # Infrastructure as Code
    terraform-ls       # Terraform language server
    tflint             # Terraform linter
    terragrunt         # Terraform wrapper
    pulumi             # IaC alternative
    
    # API testing
    xh                 # HTTPie in Rust (modern HTTP client)
    
    # JSON/YAML tools
    jless              # JSON viewer
    dasel              # Query JSON/YAML/XML
    
    # File synchronization
    rclone             # Sync to cloud
    syncthing          # P2P sync
    
    # Password managers
    pass               # Unix password manager
    gopass             # Team password manager
    
    # Encryption
    age                # Modern encryption tool
    
    # Backup tools
    restic             # Encrypted backups
    
    # System monitoring (btop is the best all-in-one)
    btop               # Resource monitor (best modern option)
    nvtopPackages.amd  # GPU monitoring tool
    
    # Process management
    pm2                # Process manager
    
    # Build tools
    just               # Command runner
    gnumake               # GNU make
    cmake              # CMake
    meson              # Meson build
    ninja              # Ninja build
    
    # Documentation
    zeal               # Offline documentation
    
    # Note taking
    obsidian           # Knowledge base
    logseq             # Knowledge graph
    
    # Time tracking
    timewarrior        # Time tracking
    watson             # Time tracking CLI
    
    # Screenshots and recording
    flameshot          # Screenshot tool
    peek               # GIF recorder
    
    # Color picker
    grim               # Screenshot (Wayland)
    slurp              # Region select (Wayland)
    
    # Clipboard management
    clipman            # Clipboard manager
    
    # Fonts for power users
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    
    # Language servers (additional)
    yaml-language-server
    dockerfile-language-server
    bash-language-server
    taplo              # TOML language server
    
    # Formatters (additional)
    shfmt              # Shell script formatter
    sql-formatter          # SQL formatter
    
    # Linters (additional)
    shellcheck         # Shell script linter
    hadolint           # Dockerfile linter
    yamllint           # YAML linter
    
    # Virtualization
    quickemu           # Quick VM creation
    
    # Terminal multiplexers
    zellij             # Modern tmux
    byobu              # Enhanced tmux
    
    # File managers
    lf                 # Terminal file manager
    vifm               # Vi-style file manager
    
    # Disk tools
    gparted            # Partition editor
    
    # PDF tools
    pdftk              # PDF toolkit
    
    # E-books
    calibre            # E-book management
    
    # Markdown tools
    glow               # Markdown viewer
    mdcat              # Cat for markdown
    
    # Diagram tools
    graphviz           # Graph visualization
    plantuml           # UML diagrams
    
    # Math
    octave             # MATLAB alternative
    
    # Data science
    jupyter            # Notebooks
    
    # 3D modeling
    openscad           # Programmable 3D
    
    # ASCII art
    figlet             # ASCII banners
    toilet             # Colorful ASCII
    
    # Fun/useful
    cowsay             # Talking cow
    fortune            # Random quotes
    lolcat             # Rainbow cat
    cmatrix            # Matrix effect
    
    # System utilities
    pv                 # Pipe viewer
    progress           # Show progress of commands
    
    # Modern alternatives
    sd                 # Better sed
    choose             # Better cut
    
    # Fuzzy finders
    skim               # Fuzzy finder (Rust)
    
    # Terminal file transfer
    croc               # Easy file transfer
    magic-wormhole     # Secure file transfer
    
    # QR codes
    qrencode           # Generate QR codes
    
    # IRC
    weechat            # IRC client
    
    # Email
    neomutt            # Email client
    
    # RSS
    newsboat           # RSS reader
    
    # Music
    ncmpcpp            # Music player
    
    # System call tracer
    sysdig             # System call tracer
  ];
  
  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
      catppuccin
    ];
    extraConfig = ''
      # Better prefix
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix
      
      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %
      
      # Reload config
      bind r source-file ~/.tmux.conf
      
      # Pane navigation with hjkl
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      
      # Enable true color
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };
  
  # Terminal multiplexer is configured in terminal-tools.nix
  
  # Helix editor (modern Vim/Neovim alternative)
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        mouse = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        file-picker = {
          hidden = false;
        };
      };
    };
  };
  
  
  # System monitor (btop) is in packages above
  
  # Ripgrep configuration
  home.file.".config/ripgrep/config".text = ''
    --max-columns=150
    --max-columns-preview
    --smart-case
    --hidden
    --glob=!.git/*
    --glob=!node_modules/*
    --glob=!target/*
    --glob=!.direnv/*
  '';
  
  # Nnn file manager configuration
  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });
    bookmarks = {
      d = "~/Documents";
      D = "~/Downloads";
      p = "~/Projects";
      n = "~/Projects/nix-omarchy/nix";
    };
    plugins = {
      src = "${pkgs.nnn}/share/plugins";
      mappings = {
        p = "preview-tui";
        d = "diffs";
        v = "imgview";
      };
    };
  };
  
  # SSH configuration
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;  # Disable default config to avoid future warnings
    matchBlocks."*" = {
      controlMaster = "auto";
      controlPersist = "10m";
    };
    extraConfig = ''
      AddKeysToAgent yes
      ServerAliveInterval 60
      ServerAliveCountMax 3
      TCPKeepAlive yes
    '';
  };
  
  # GPG configuration
  programs.gpg = {
    enable = true;
    settings = {
      use-agent = true;
      default-key = "your-key-id";
    };
  };
  
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
