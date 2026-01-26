{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ../hyprland
    ../kde
    ../programs/walker.nix
    ../programs/swayosd.nix
    ../programs/xcompose.nix
  ];

  options.home.profiles.desktop = {
    enable = mkEnableOption "desktop applications profile";
    
    environment = mkOption {
      type = types.enum [ "hyprland" "kde" ];
      default = "hyprland";
      description = "Desktop environment to configure for the user";
    };
  };

  config = mkIf config.home.profiles.desktop.enable {
    # Applications provided by the Desktop Profile
    home.packages = with pkgs; [
      # Browsers
      firefox
      chromium
      
      # Terminals
      kitty
      alacritty
      
      # File Managers (Modern replacements)
      yazi
      ranger
      
      # Identity
      bitwarden-desktop
      
      # Theming & Utils
      qt6Packages.qt6ct
      gtk3 # Provides gtk-launch
    ] ++ (optionals (config.home.profiles.desktop.environment == "hyprland") [
      # Hyprland specific desktop tools
      kdePackages.dolphin
      zathura
      imv
      feh
      wl-clipboard
      cliphist
      hyprpicker
      grim
      slurp
      grimblast
      swappy
      pwvucontrol
      swayosd
      qalculate-gtk
      walker

      # QuickShare
      rquickshare

    ]);

    # Power-User Directory Structure
    home.file = {
      # Projects hierarchy
      "Projects/Work/.keep".text = "";
      "Projects/Personal/.keep".text = "";
      "Projects/Master/.keep".text = "";
      # Projects/NixOS/.keep".text = "";
      "Projects/Playground/.keep".text = "";
      
      # Knowledge Base (Obsidian Vault)
      "Vault/.keep" = mkIf (config.home.profiles.power-user.enable && config.home.profiles.power-user.productivity.enable) { text = ""; };
      
      # Virtualization and ISOs
      "VMs/ISOs/.keep".text = "";
      "VMs/Disks/.keep".text = "";
      
      # Media & Organization
      "Pictures/Wallpapers/.keep".text = "";
      "Pictures/Screenshots/.keep".text = "";
      "Downloads/Torrents/.keep".text = "";
    };

    # Desktop-specific session variables
    
    # Configure Cursor Theme
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    
    # Configure Firefox (package installed by system)
    programs.firefox = {
      # enable = true; # Handled by programs/firefox.nix
      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;
        
        settings = {
          "browser.startup.homepage" = "about:home";
          "browser.search.defaultenginename" = "DuckDuckGo";
          "privacy.trackingprotection.enabled" = true;
          "dom.security.https_only_mode" = true;
        };
      };
    };
    
    # Configure Kitty (package installed by system)
    programs.kitty = {
      # enable = true; # Handled by programs/kitty.nix
      # Font settings handled by Stylix
      settings = {
        enable_audio_bell = false;
        confirm_os_window_close = 0;
      };
    };
    
    # Configure Neovim (package installed by system)
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    # XDG Portal Configuration (resolve rework warning)
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [
        (if config.home.profiles.desktop.environment == "hyprland"
         then pkgs.xdg-desktop-portal-hyprland
         else pkgs.kdePackages.xdg-desktop-portal-kde)
        pkgs.xdg-desktop-portal-gtk
      ];
    };
    
    # Hyprland specific configurations
    # These modules (walker, swayosd, xcompose) are imported but we can 
    # toggle their internal config or enable based on env if we want.
    # For now, we assume they are safe to have config files present even on KDE,
    # OR we can wrap them in their respective files.
  };
}
