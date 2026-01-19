{ config, pkgs, lib, ... }:

{
  # Power user system enhancements
  
  # Advanced filesystem features (ZFS removed - broken with current kernel)
  boot.supportedFilesystems = [ "btrfs" "ntfs" ];
  
  # Performance profiling and debugging
  environment.systemPackages = with pkgs; [
    # System analysis and debugging
    strace           # Trace system calls
    ltrace           # Trace library calls
    lsof             # List open files
    iotop            # I/O monitoring
    iftop            # Network monitoring
    nethogs          # Per-process network usage
    ngrep            # Network grep
    tcpdump          # Packet analyzer
    
    # Performance analysis
    perf-tools       # Performance analysis tools
    flamegraph       # Visualize profiling data
    sysstat          # System performance tools (sar, iostat)
    # dstat removed from nixpkgs (unmaintained), use sysstat instead
    
    # Advanced process management
    parallel         # Execute jobs in parallel
    watchexec        # Execute commands on file changes
    entr             # Run arbitrary commands when files change
    
    # Disk and filesystem tools
    duf              # Modern df alternative
    dust             # Modern du alternative
    gdu              # Fast disk usage analyzer
    compsize         # Btrfs compression statistics
    
    # Network tools (power user)
    socat            # Multipurpose relay
    mtr              # Network diagnostics
    dog              # Modern dig alternative
    bandwhich        # Terminal bandwidth utilization
    gping            # Ping with a graph
    
    # Text processing power tools
    jq               # JSON processor
    yq-go            # YAML processor
    # xsv removed from nixpkgs, use miller instead
    miller           # CSV/JSON/TSV processor
    fx               # JSON viewer
    
    # Clipboard and terminal tools
    wl-clipboard     # Wayland clipboard (includes xclip-like tools)
    zellij           # Modern terminal multiplexer
    
    # File management
    lf               # Terminal file manager (fast, Go-based)
    
    # Archive tools
    p7zip            # 7z support
    unrar            # RAR support
    unzip            # ZIP support
    zip              # ZIP creation
    
    # Search and indexing (plocate is faster, modern replacement)
    plocate          # Fast file location
    
    # System information
    inxi             # Comprehensive system information
    hwinfo           # Hardware detection
    
    # Kernel and module tools
    kmod             # Kernel module tools
    
    # Security tools
    lynis            # Security auditing
    
    # Benchmarking
    hyperfine        # Command-line benchmarking
    
    # Man page alternatives
    tealdeer         # Fast tldr client (Rust-based)
    
    # Git power tools
    git-absorb       # Automatic git commit fixup
    git-town         # Git workflow tool
    gita             # Manage multiple git repos
    
    # Image tools
    imagemagick      # Image manipulation
    oxipng           # PNG optimizer
    jpegoptim        # JPEG optimizer
    
    # Video tools
    ffmpeg           # Video processing
    
    # Automation
    expect           # Automation tool
    
    # Hex editors
    hexyl            # Modern hex viewer
    
    
    # Shell utilities
    direnv           # Per-directory environments
    any-nix-shell    # Nix shell integration
    
    # Quick calculations
    libqalculate     # Advanced calculator (qalc command)
  ];
  
  # Enable sysstat for performance monitoring
  services.sysstat.enable = true;
  
  # Enable fwupd for firmware updates
  services.fwupd.enable = true;
  
  # Enable smartd for disk monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };
  
  # Locate database
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "hourly";
  };
  
  # Enable thermald for thermal management (Intel)
  # services.thermald.enable = true;
  
  # Better I/O scheduler for SSDs
  services.udev.extraRules = ''
    # Set scheduler for NVMe
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    # Set scheduler for SSDs and eMMC
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # Set scheduler for rotating disks
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
  
  # Advanced kernel parameters for power users
  boot.kernelParams = [
    # Better memory management
    "transparent_hugepage=madvise"
    
    # Security
    "lockdown=confidentiality"
    
    # Performance
    "mitigations=auto"
  ];
  
  # Kernel modules
  boot.kernelModules = [
    "tcp_bbr"        # Better TCP congestion control
    "v4l2loopback"   # Virtual camera
  ];
  
  # Extra kernel modules
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  
  # V4L2 loopback config
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';
  
  # Enable CPU microcode updates
  hardware.cpu.amd.updateMicrocode = true;
  
  # Firmware updates
  hardware.enableAllFirmware = true;
  
  # Power user shell environment
  environment.sessionVariables = {
    # Less options for better paging
    LESS = "-R --mouse --wheel-lines=3";
    
    # Ripgrep config
    RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/config";
  };
  
  # System-wide shell aliases for power users
  environment.shellAliases = {
    # Quick system info
    sysinfo = "inxi -Fxxxz";
    
    # Advanced find
    ff = "find . -type f -name";
    
    # Process management
    pgrep = "pgrep -a";
    
    # Network
    ports = "ss -tulpn";
    
    # Disk usage sorted
    dus = "du -sh * | sort -h";
    
    # Watch with color
    watch = "watch --color";
  };
}
