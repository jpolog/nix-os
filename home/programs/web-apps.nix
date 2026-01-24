{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.web-apps;

  # Helper function to create a Chromium web app desktop entry
  createWebApp = { name, genericName, url, icon, categories ? [ "Network" "WebBrowser" ] }: {
    name = name;
    genericName = genericName;
    exec = "${pkgs.chromium}/bin/chromium --app=${url}";
    terminal = false;
    icon = icon;
    type = "Application";
    categories = categories;
    mimeType = [ "text/html" "text/xml" "application/xhtml+xml" ];
  };

in
{
  options.programs.web-apps = {
    enable = mkEnableOption "web applications generator";
    
    apps = {
      # Communication & Mail
      gmail = mkEnableOption "Gmail";
      gcal = mkEnableOption "Google Calendar";
      outlook = mkEnableOption "Outlook Web";
      whatsapp = mkEnableOption "WhatsApp";
      telegram = mkEnableOption "Telegram Web";
      
      # Development & Documentation
      github = mkEnableOption "GitHub";
      gitlab = mkEnableOption "GitLab";
      overleaf = mkEnableOption "Overleaf";
      chatgpt = mkEnableOption "ChatGPT";
      claude = mkEnableOption "Claude AI";
      perplexity = mkEnableOption "Perplexity AI";
      
      # Creative & Design
      figma = mkEnableOption "Figma";
      canva = mkEnableOption "Canva";
      excalidraw = mkEnableOption "Excalidraw";
      
      # Office & Productivity
      notion = mkEnableOption "Notion";
      gdocs = mkEnableOption "Google Docs";
      gdrive = mkEnableOption "Google Drive";
      office365 = mkEnableOption "Microsoft 365";
      
      # Entertainment
      netflix = mkEnableOption "Netflix";
      youtube = mkEnableOption "YouTube";
      spotify = mkEnableOption "Spotify Web";
    };
  };

  config = mkIf cfg.enable {
    # Ensure chromium is available as the runner
    home.packages = [ pkgs.chromium ];

    xdg.desktopEntries = {
      
      # === Communication ===
      gmail = mkIf cfg.apps.gmail (createWebApp {
        name = "Gmail";
        genericName = "Email Client";
        url = "https://mail.google.com";
        icon = "google-gmail";
        categories = [ "Office" "Network" "Email" ];
      });

      gcal = mkIf cfg.apps.gcal (createWebApp {
        name = "Google Calendar";
        genericName = "Calendar";
        url = "https://calendar.google.com";
        icon = "google-agenda";
        categories = [ "Office" "Calendar" ];
      });
      
      outlook = mkIf cfg.apps.outlook (createWebApp {
        name = "Outlook";
        genericName = "Email Client";
        url = "https://outlook.office.com/mail/";
        icon = "microsoft-outlook"; # Requires icon theme support
        categories = [ "Office" "Network" "Email" ];
      });

      whatsapp = mkIf cfg.apps.whatsapp (createWebApp {
        name = "WhatsApp";
        genericName = "Messaging Client";
        url = "https://web.whatsapp.com";
        icon = "whatsapp";
        categories = [ "Network" "InstantMessaging" ];
      });
      
      telegram = mkIf cfg.apps.telegram (createWebApp {
        name = "Telegram";
        genericName = "Messaging Client";
        url = "https://web.telegram.org";
        icon = "telegram";
        categories = [ "Network" "InstantMessaging" ];
      });

      # === Development ===
      github = mkIf cfg.apps.github (createWebApp {
        name = "GitHub";
        genericName = "Code Hosting";
        url = "https://github.com";
        icon = "github";
        categories = [ "Development" ];
      });
      
      gitlab = mkIf cfg.apps.gitlab (createWebApp {
        name = "GitLab";
        genericName = "DevOps Platform";
        url = "https://gitlab.com";
        icon = "gitlab";
        categories = [ "Development" ];
      });

      overleaf = mkIf cfg.apps.overleaf (createWebApp {
        name = "Overleaf";
        genericName = "LaTeX Editor";
        url = "https://www.overleaf.com/project";
        icon = "texstudio"; # Closest generic icon usually available
        categories = [ "Office" "Publishing" "Education" ];
      });
      
      chatgpt = mkIf cfg.apps.chatgpt (createWebApp {
        name = "ChatGPT";
        genericName = "AI Assistant";
        url = "https://chat.openai.com";
        icon = "openai"; # May need custom icon
        categories = [ "Utility" "ArtificialIntelligence" ];
      });
      
      claude = mkIf cfg.apps.claude (createWebApp {
        name = "Claude";
        genericName = "AI Assistant";
        url = "https://claude.ai";
        icon = "anthropic-claude"; # May need custom icon
        categories = [ "Utility" "ArtificialIntelligence" ];
      });

      perplexity = mkIf cfg.apps.perplexity (createWebApp {
        name = "Perplexity";
        genericName = "AI Search Engine";
        url = "https://www.perplexity.ai";
        icon = "perplexity"; # May need custom icon
        categories = [ "Utility" "ArtificialIntelligence" ];
      });

      # === Creative ===
      figma = mkIf cfg.apps.figma (createWebApp {
        name = "Figma";
        genericName = "Design Tool";
        url = "https://www.figma.com";
        icon = "figma";
        categories = [ "Graphics" "2DGraphics" "VectorGraphics" ];
      });
      
      canva = mkIf cfg.apps.canva (createWebApp {
        name = "Canva";
        genericName = "Design Tool";
        url = "https://www.canva.com";
        icon = "canva"; # Requires icon theme
        categories = [ "Graphics" "Publishing" ];
      });
      
      excalidraw = mkIf cfg.apps.excalidraw (createWebApp {
        name = "Excalidraw";
        genericName = "Whiteboard";
        url = "https://excalidraw.com";
        icon = "text-x-generic"; # Generic placeholder
        categories = [ "Graphics" ];
      });

      # === Productivity ===
      notion = mkIf cfg.apps.notion (createWebApp {
        name = "Notion";
        genericName = "Notes & Wiki";
        url = "https://www.notion.so";
        icon = "notion-app";
        categories = [ "Office" ];
      });
      
      gdocs = mkIf cfg.apps.gdocs (createWebApp {
        name = "Google Docs";
        genericName = "Word Processor";
        url = "https://docs.google.com";
        icon = "google-docs";
        categories = [ "Office" "WordProcessor" ];
      });
      
      office365 = mkIf cfg.apps.office365 (createWebApp {
        name = "Microsoft 365";
        genericName = "Office Suite";
        url = "https://www.office.com";
        icon = "microsoft-office";
        categories = [ "Office" ];
      });

      # === Entertainment ===
      youtube = mkIf cfg.apps.youtube (createWebApp {
        name = "YouTube";
        genericName = "Video Player";
        url = "https://www.youtube.com";
        icon = "youtube";
        categories = [ "AudioVideo" "Video" ];
      });
      
      netflix = mkIf cfg.apps.netflix (createWebApp {
        name = "Netflix";
        genericName = "Streaming Service";
        url = "https://www.netflix.com";
        icon = "netflix";
        categories = [ "AudioVideo" "Video" ];
      });
      
      spotify = mkIf cfg.apps.spotify (createWebApp {
        name = "Spotify";
        genericName = "Music Player";
        url = "https://open.spotify.com";
        icon = "spotify-client";
        categories = [ "AudioVideo" "Audio" ];
      });
    };
  };
}
