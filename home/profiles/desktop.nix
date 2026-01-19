{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ../hyprland
  ];

  options.home.profiles.desktop = {
    enable = mkEnableOption "desktop applications profile";
  };

  config = mkIf config.home.profiles.desktop.enable {
    # NO package installation - packages installed by system profile!
    # Only configuration/dotfiles here

    # Desktop-specific session variables
    home.sessionVariables = {
      TERMINAL = mkDefault "kitty";
      BROWSER = mkDefault "firefox";
    };
    
    # Create necessary directories
    home.file."Pictures/Wallpapers/.keep".text = "";
    home.file."Pictures/Screenshots/.keep".text = "";
    
    # XCompose for special characters
    home.file.".XCompose".text = ''
      include "%L"
      <Multi_key> <e> <m> : "📧"
      <Multi_key> <h> <e> <a> <r> <t> : "❤️"
    '';
    
    # Configure Firefox (package installed by system)
    programs.firefox = {
      enable = true;
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
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 11;
      };
      settings = {
        background_opacity = "0.95";
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
    
    # SwayOSD systemd service
    systemd.user.services.swayosd = {
      Unit = {
        Description = "SwayOSD - OSD window for volume and brightness";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
