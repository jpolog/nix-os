# 1. Update arguments to accept osConfig (with a default of null for safety)
{
  pkgs,
  lib,
  osConfig ? null,
  ...
}:

let
  mkUser = (import ./lib.nix { inherit lib; }).mkUser;
in
mkUser {
  username = "jpolo";
  fullName = "Javier Polo Gambin";
  email = "javier.polog@outlook.com";

  profiles = {
    desktop = {
      enable = true;
    };

    cli.enable = true;
    development = {
      enable = true;
      editors.vscode.enable = false;
      ai.tools.claude-code.enable = true;
    };
    creative = {
      enable = true;
      video.enable = false;
    };

    power-user = {
      enable = true;
      productivity.enable = true;
      cli-utils.enable = true;
      torrenting.enable = true;
      upscayl.enable = true;
    };

    work = {
      enable = true;
      communication = {
        slack = true;
        teams = true;
        zoom = true;
      };
      vpn.enable = true;
    };

    research = {
      enable = true;
      latex.enable = true;
      tools.enable = true;
      diagrams.enable = true;
    };

    personal = {
      enable = true;
      media = {
        enable = true;
        spotify = false;
        plexamp = true;
        plex = true;
        vlc = false;
        mpv = true;
      };
      office = {
        enable = true;
        onlyoffice = false;
        libreoffice = true;
        okular = true;
        koreader = true;
      };
      productivity = {
        enable = true;
        bitwarden = true;
        syncthing = true;
      };
      tools = {
        enable = true;
        image-editing = true;
        screenshot = true;
        video-tools = false;
      };
      communication.enable = true;
    };
  };

  extraConfig = { config, ... }: {

    imports = [

      ../shell

      ../services

    ];

    # Explicitly enable desktop profile and set environment

    home.profiles.desktop.enable = true;

    home.profiles.desktop.environment = "hyprland";

    home.profiles.desktop.browsers = {
      firefox = true;
      chromium = false;
    };

    home.firefox.vimNavigation.enable = true;

    home.file = {
      "Documents/important/.keep".text = "";
      "Documents/books/.keep".text = "";
      "Documents/scans/.keep".text = "";
      "Documents/work/.keep".text = "";
    };

    programs.web-apps.apps.outlook = true;

    programs.firefox = {
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "dgx-spark" = {
          hostname = "155.54.180.23";
          port = 25004;
          user = "javierpg";
          identityFile = "~/.ssh/id_um";
          identitiesOnly = true;
          forwardX11 = true;
        };
        "um-machine" = {
          hostname = "155.54.180.23";
          port = 25002;
          user = "javierpg";
          identityFile = "~/.ssh/id_um";
          identitiesOnly = true;
        };
        "apollo" = {
          user = "jpolo";
        };
        "jureca" = {
          hostname = "jureca.fz-juelich.de";
          user = "pologambn1";
          identityFile = "~/.ssh/cispa";
        };
        "aws-public" = {
          hostname = "13.222.23.109";
          user = "ec2-user";
          identityFile = "~/.ssh/WebserverKey-PUBLIC-Prac2.pem";
        };
      };
    };
  };
}
