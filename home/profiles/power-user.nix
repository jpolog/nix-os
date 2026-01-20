{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.profiles.power-user;
in
{
  options.home.profiles.power-user = {
    enable = mkEnableOption "advanced power user tools";
    
    # Categories
    network.enable = mkEnableOption "network analysis tools (Wireshark, etc)" // { default = true; };
    system.enable = mkEnableOption "system monitoring and disk tools" // { default = true; };
    dev-gui.enable = mkEnableOption "development GUI tools (Insomnia, Hex Editors)" // { default = true; };
    productivity.enable = mkEnableOption "power productivity tools (Obsidian, CLI tools)" // { default = true; };
    cli-utils.enable = mkEnableOption "CLI power utilities (jq, ffmpeg, strace)" // { default = true; };
    torrenting.enable = mkEnableOption "torrenting tools (qBittorrent)" // { default = true; };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; 
      # Network Analysis
      (optionals cfg.network.enable [
        wireshark
        nmap
        socat
        mtr
        bandwhich
        gping
        dog
      ]) ++
      
      # System & Disk
      (optionals cfg.system.enable [
        qdirstat
        filelight
        gparted
        cpu-x
        hardinfo
        btop
        virt-manager
        krusader
        
        # CLI System Tools
        strace
        ltrace
        lsof
        iotop
        iftop
        sysstat
        duf
        dust
        gdu
        plocate
      ]) ++
      
      # CLI Utilities
      (optionals cfg.cli-utils.enable [
        jq
        yq-go
        miller
        fx
        ripgrep
        fd
        eza
        bat
        tealdeer
        ffmpeg
        imagemagick
        p7zip
        unzip
        zip
        hyperfine
        parallel
      ]) ++
      
      # Development GUIs
      (optionals cfg.dev-gui.enable [
        imhex
        insomnia
      ]) ++
      
      # Power Productivity (Moved from personal)
      (optionals cfg.productivity.enable [
        obsidian
        timewarrior
        taskwarrior3
        taskwarrior-tui
        rclone
        calibre
      ]) ++
      
      # Torrenting (Swapped Transmission for qBittorrent)
      (optionals cfg.torrenting.enable [
        qbittorrent
      ]);
  };
}