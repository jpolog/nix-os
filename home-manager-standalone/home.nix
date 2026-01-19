{ config, pkgs, inputs, ... }:

{
  # Allow unfree packages in home-manager
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hyprland.nix
  ];

  home.username = "jpolo";
  home.homeDirectory = "/home/jpolo";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # CLI Packages
  home.packages = with pkgs; [
    htop
    btop
    neofetch
    tree
    wget
    curl
    eza
    bat
    ripgrep
    fd
    gh
    lazygit
    unzip
    zip
    p7zip
    
    # Fonts (needed for Hyprland UI)
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
  ];

  # Git
  programs.git = {
    enable = true;
    
    settings = {
      user = {
        name = "Javier Polo Gambin";
        email = "javier.polog@outlook.com";
      };
      
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --graph --oneline --decorate --all";
      };
    };
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ls = "eza";
      cat = "bat";
      ll = "eza -l";
      la = "eza -la";
      tree = "eza --tree";
    };
    
    initContent = ''
      eval "$(starship init zsh)"
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$character";
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
  
  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Tmux
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 50000;
    keyMode = "vi";
    mouse = true;
  };

  # Firefox
  programs.firefox.enable = true;

  # Kitty
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      background_opacity = "0.95";
      enable_audio_bell = false;
    };
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # VSCode
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
  };

  # Bash (fallback)
  programs.bash.enable = true;
}
