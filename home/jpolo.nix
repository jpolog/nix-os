{ config, pkgs, inputs, ... }:

{
  imports = [
    ./programs
    ./services
    ./shell
    ./hyprland
  ];

  home = {
    username = "jpolo";
    homeDirectory = "/home/jpolo";
    stateVersion = "24.11";

    # User packages
    packages = with pkgs; [
      # Browsers
      firefox
      chromium
      
      # Development
      vscode
      vscodium  # Open source VSCode
      
      # Communication
      discord
      telegram-desktop
      slack
      zoom-us
      
      # Media
      mpv
      vlc
      spotify
      spotifywm  # Spotify with window manager support
      
      # Graphics
      gimp
      inkscape
      krita
      
      # Utilities
      kitty
      alacritty
      ranger
      yazi  # Modern file manager
      fzf
      ripgrep
      fd
      eza
      bat
      delta
      zoxide
      
      # System monitoring
      btop
      nvtop
      bandwhich
      
      # Archive tools
      unzip
      zip
      p7zip
      unrar
      atool  # Universal archive tool
      
      # Documents
      libreoffice-fresh
      okular  # PDF viewer
      zathura  # Minimal PDF viewer
      obsidian  # Note taking
      
      # Clipboard
      cliphist
      wl-clipboard
      
      # Color picker
      hyprpicker
      
      # Brightness control
      brightnessctl
      
      # Walker dependencies
      walker
      
      # Screenshots
      grim
      slurp
      swappy
      
      # Password manager
      bitwarden
      keepassxc
      
      # Network
      networkmanagerapplet
      
      # Audio control
      pavucontrol
      pwvucontrol  # PipeWire volume control
      
      # Image viewers
      imv
      feh
      
      # Video editing
      kdenlive
      
      # Screen recording
      obs-studio
      wf-recorder
      
      # Cloud storage
      rclone
      syncthing
      
      # Torrent
      transmission-gtk
      
      # E-book
      calibre
      
      # Calculator
      qalculate-gtk
      
      # System info
      neofetch
      fastfetch
      
      # Fun
      cmatrix
      pipes
      cbonsai
      
      # Productivity
      timewarrior
      taskwarrior
      taskwarrior-tui
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "kitty";
      BROWSER = "firefox";
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # XDG user directories
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Javier Polo Gambin";
    userEmail = "javier.polog@outlook.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
    };
  };
}
