{ config, pkgs, lib, firefox-addons, ... }:

{
  programs.firefox = {
    enable = lib.mkDefault false;
    
    profiles.jpolo = {
      id = 0;
      name = "jpolo";
      isDefault = true;
      
      # Extensions
      extensions.packages = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        bitwarden
        darkreader
        privacy-badger
        decentraleyes
        clearurls
        vimium-c  # Uncomment if you want vim keybindings
      ];
      
      # Search engines
      search = {
        default = "ddg";
        force = true;
        
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          
          "NixOS Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "options"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          
          "Home Manager Options" = {
            urls = [{
              template = "https://mipmip.github.io/home-manager-option-search/";
              params = [
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@hm" ];
          };
          
          "GitHub" = {
            urls = [{
              template = "https://github.com/search";
              params = [
                { name = "q"; value = "{searchTerms}"; }
              ];
            }];
            icon = "https://github.com/favicon.ico";
            definedAliases = [ "@gh" ];
          };
        };
      };
      
      # Settings for privacy and performance
      settings = {
        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        
        # Privacy
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.clearOnShutdown.cookies" = false;
        "privacy.clearOnShutdown.history" = false;
        
        # Disable telemetry
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        
        # UI improvements
        "browser.tabs.warnOnClose" = false;
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.startup.homepage" = "about:home";
        "browser.newtabpage.enabled" = true;
        
        # Downloads
        "browser.download.useDownloadDir" = true;
        "browser.download.dir" = "/home/jpolo/Downloads";
        
        # PDF
        "pdfjs.enabledCache.state" = true;
        
        # Smooth scrolling
        "general.smoothScroll" = true;
        "general.smoothScroll.msdPhysics.enabled" = true;
        
        # Enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        
        # WebGL
        "webgl.disabled" = false;
        
        # DNS over HTTPS (optional)
        # "network.trr.mode" = 2;
        # "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
      };
      
      # User Chrome CSS for better UI
      userChrome = ''
        /* Hide tab bar when only one tab */
        #tabbrowser-tabs {
          visibility: collapse !important;
        }
        #tabbrowser-tabs:has([pinned]) {
          visibility: visible !important;
        }
        #tabbrowser-tabs:has(tab[selected]:not(:only-of-type)) {
          visibility: visible !important;
        }
        
        /* Compact mode improvements */
        :root {
          --toolbarbutton-border-radius: 4px !important;
          --tab-border-radius: 4px !important;
        }
      '';
    };
    
    # Firefox policies
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFormHistory = true;
      DisplayBookmarksToolbar = "always";
      DontCheckDefaultBrowser = true;
      
      # Homepage
      Homepage = {
        StartPage = "homepage";
      };
      
      # Preferences that can't be changed
      Preferences = {
        "browser.contentblocking.category" = "strict";
        "extensions.pocket.enabled" = false;
      };
    };
  };
}
