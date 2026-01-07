{ config, pkgs, lib, ... }:

{
  # Advanced power-user home configuration
  
  imports = [
    ./power-user-functions.nix
  ];
  
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
    kubens             # Namespace switching
    stern              # Multi-pod log tailing
    kustomize          # Kubernetes customization
    
    # Infrastructure as Code
    terraform-ls       # Terraform language server
    tflint             # Terraform linter
    terragrunt         # Terraform wrapper
    pulumi             # IaC alternative
    
    # API testing
    httpie             # HTTP client
    curlie             # Curl with colors
    xh                 # HTTPie in Rust
    
    # JSON/YAML tools
    jless              # JSON viewer
    yq-go              # YAML query
    dasel              # Query JSON/YAML/XML
    
    # File synchronization
    rclone             # Sync to cloud
    syncthing          # P2P sync
    
    # Password managers
    pass               # Unix password manager
    gopass             # Team password manager
    
    # Encryption
    age                # Modern encryption
    rage               # Rust age
    
    # Backup tools
    restic             # Encrypted backups
    borg               # Deduplicated backups
    
    # System monitoring
    btop               # Resource monitor
    gotop              # Another monitor
    glances            # Cross-platform monitor
    zenith             # Modern htop
    
    # Process management
    pm2                # Process manager
    
    # Build tools
    just               # Command runner
    make               # GNU make
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
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" ]; })
    
    # Language servers (additional)
    yaml-language-server
    dockerfile-language-server-nodejs
    bash-language-server
    taplo              # TOML language server
    
    # Formatters (additional)
    shfmt              # Shell script formatter
    sqlformat          # SQL formatter
    
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
    poppler_utils      # PDF utilities
    
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
    
    # Torrents
    transmission       # BitTorrent client
    
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
  
  # Zellij configuration (modern tmux)
  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      pane_frames = false;
      simplified_ui = true;
    };
  };
  
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
  
  # Bat configuration (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "catppuccin-mocha";
      pager = "less -FR";
    };
  };
  
  # Bottom configuration (system monitor)
  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        dot_marker = false;
        group_processes = true;
        tree = true;
      };
      colors = {
        theme = "catppuccin";
      };
    };
  };
  
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
    controlMaster = "auto";
    controlPersist = "10m";
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
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
