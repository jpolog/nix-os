{ pkgs, lib, ... }:

let
  mkUser = (import ./lib.nix { inherit lib; }).mkUser;

  # -----------------------------------------------------------------------
  # Shared LibreOffice → familiar Windows name aliases (app-menu entries)
  # -----------------------------------------------------------------------
  libreofficeAliasEntries = {
    "lo-word" = {
      name = "Word";
      genericName = "Procesador de textos";
      exec = "libreoffice --writer %U";
      icon = "libreoffice-writer";
      terminal = false;
      type = "Application";
      categories = [ "Office" "WordProcessor" ];
      mimeType = [
        "application/vnd.oasis.opendocument.text"
        "application/msword"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      ];
    };
    "lo-excel" = {
      name = "Excel";
      genericName = "Hoja de cálculo";
      exec = "libreoffice --calc %U";
      icon = "libreoffice-calc";
      terminal = false;
      type = "Application";
      categories = [ "Office" "Spreadsheet" ];
      mimeType = [
        "application/vnd.oasis.opendocument.spreadsheet"
        "application/vnd.ms-excel"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      ];
    };
    "lo-powerpoint" = {
      name = "PowerPoint";
      genericName = "Presentaciones";
      exec = "libreoffice --impress %U";
      icon = "libreoffice-impress";
      terminal = false;
      type = "Application";
      categories = [ "Office" "Presentation" ];
      mimeType = [
        "application/vnd.oasis.opendocument.presentation"
        "application/vnd.ms-powerpoint"
        "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      ];
    };
  };
in
mkUser {
  username = "rosa";
  fullName = "Rosa";
  email = "";

  profiles = {
    base.enable = true;
    cli.enable = false;

    desktop = {
      enable = true;
      environment = "kde";
      browsers.chrome = true;
      powerUserTools.enable = false;
    };

    development.enable = false;
    creative.enable = false;

    personal = {
      enable = true;
      office = {
        enable = true;
        onlyoffice = false;
        libreoffice = true;
        okular = true;
      };
      media = {
        enable = true;
        spotify = true;
        plexamp = true;
        plex = true;
        vlc = true;
        mpv = false;
      };
      communication = {
        enable = true;
        discord = false;
        telegram = true;
      };
      productivity = {
        enable = true;
        bitwarden = true;
        syncthing = true;
      };
      tools = {
        enable = true;
        image-editing = true;
        screenshot = false;     # KDE Spectacle already installed system-wide
        video-tools = false;
      };
    };
  };

  extraConfig = {
    # ---- Spanish locale ----
    home.sessionVariables = {
      LANG     = "es_ES.UTF-8";
      LANGUAGE = "es_ES:es";
    };

    home.file.".config/plasma-localerc".text = ''
      [Formats]
      LANG=es_ES.UTF-8

      [Translations]
      LANGUAGE=es_ES
    '';

    home.file.".config/kxkbrc".text = ''
      [Layout]
      DisplayNames=,
      LayoutList=es
      Model=pc105
      Use=true
      VariantList=
    '';

    # Activate Papirus icon theme in KDE (Qt/Plasma apps)
    home.file.".config/kdeglobals".text = ''
      [Icons]
      Theme=Papirus
    '';

    # ---- Additional apps ----
    home.packages = with pkgs; [
      kdePackages.kdenlive
      nextcloud-client
      papirus-icon-theme
      hunspellDicts.es_ES
      hunspellDicts.es_MX
    ];

    gtk.iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };

    # ---- Web apps ----
    programs.web-apps = {
      enable = true;
      apps = {
        gmail     = true;
        whatsapp  = true;
        youtube   = true;
        netflix   = true;
        gdrive    = true;
      };
    };

    # ---- LibreOffice → Windows-style app-menu entries ----
    xdg.desktopEntries = libreofficeAliasEntries;

    home.shellAliases = {
      word       = "libreoffice --writer";
      excel      = "libreoffice --calc";
      powerpoint = "libreoffice --impress";
      impress    = "libreoffice --impress";
      paint      = "pinta";
    };
  };
}
