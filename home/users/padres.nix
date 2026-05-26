{ pkgs, lib, ... }:

let
  mkUser = (import ./lib.nix { inherit lib; }).mkUser;
in
mkUser {
  username = "padres";
  fullName = "Padres";
  email = "";

  profiles = {
    base.enable = true;      # Core system settings
    cli.enable = false;      # No terminal power tools

    desktop = {
      enable = true;
      environment = "kde";   # User friendly desktop
    };

    development.enable = false;
    creative.enable = false;

    # The "General Use" suite
    personal = {
      enable = true;
      # Enable full categories (sub-options default to true)
      office.enable = true;
      media.enable = true;
      communication.enable = true;
      productivity.enable = true;
      tools.enable = true;        # Image editing, Screenshots
    };
  };

  extraConfig = {
    # ---- Spanish locale: UI language, formats, currency, timezone ----
    home.sessionVariables = {
      LANG     = "es_ES.UTF-8";
      LANGUAGE = "es_ES:es";
      # LC_* categories already set system-wide (Europe/Madrid, Euro, etc.)
    };

    # KDE Plasma regional settings (language + format region)
    home.file.".config/plasma-localerc".text = ''
      [Formats]
      LANG=es_ES.UTF-8

      [Translations]
      LANGUAGE=es_ES
    '';

    # KDE keyboard layout: Spanish
    home.file.".config/kxkbrc".text = ''
      [Layout]
      DisplayNames=,
      LayoutList=es
      Model=pc105
      Use=true
      VariantList=
    '';

    # Spanish spell-check dictionaries (LibreOffice, Okular, Kate…)
    home.packages = with pkgs; [
      hunspellDicts.es_ES
      hunspellDicts.es_MX   # broader Spanish coverage
    ];
  };
}
