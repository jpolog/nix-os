{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

with lib;

let
  # Option to enable vim navigation per user
  enableVimNavigation = config.home.firefox.vimNavigation.enable;
in
{
  options.home.firefox.vimNavigation = {
    enable = mkEnableOption "Tridactyl vim navigation for Firefox";
  };

  config = mkIf config.home.profiles.desktop.enable {
    programs.firefox = {
      enable = true;

      nativeMessagingHosts = optionals enableVimNavigation [ pkgs.tridactyl-native ];

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;

        # Force extensions to stay enabled
        settings = {
          # Prevent Firefox from disabling extensions
          "extensions.autoDisableScopes" = 0;
          "extensions.update.autoUpdateDefault" = false;
          "extensions.update.enabled" = false;

          # Privacy & Security
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "browser.disableResetPrompt" = true;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

          # Performance
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;

          # Vim mode (Tridactyl) compatibility
          "browser.tabs.closeWindowWithLastTab" = false;
        };

        # Power user extensions
        extensions.packages =
          with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
          [
            # Privacy & Security
            ublock-origin
            bitwarden
            privacy-badger

            # Productivity
            tree-style-tab
            multi-account-containers

            # Quality of Life
            darkreader
            refined-github
            sponsorblock
          ]
          ++ optionals enableVimNavigation [
            # Vim Navigation (optional, off by default)
            tridactyl
          ]
          ++ optionals (config.home.profiles.research.enable && config.home.profiles.research.tools.enable) [
            zotero-connector
          ];

        # Force containers and search settings
        containersForce = true;
        search.force = true;
      };
    };

    xdg.configFile."tridactyl/tridactylrc" = mkIf enableVimNavigation {
      text = ''
        " Configure Neovim as editor
        " Using debug wrapper to troubleshoot
        set editorcmd "${config.home.homeDirectory}/.config/tridactyl/debug_editor.sh"

        " Use <C-i> to edit text fields
        bind --mode=insert <C-i> editor
      '';
    };

    # Debug script to capture why kitty/nvim might be failing
    xdg.configFile."tridactyl/debug_editor.sh" = mkIf enableVimNavigation {
      executable = true;
      text = ''
        #!/bin/sh
        LOGfile="/tmp/tridactyl_debug.log"
        exec >> "$LOGfile" 2>&1
        echo "=== Tridactyl Editor Debug Start $(date) ==="
        echo "Args: $@"
        
        FILE_PATH="$1"
        
        echo "Bypassing editor, writing directly to file..."
        echo "TEST_CONTENT_FROM_DEBUG_SCRIPT" > "$FILE_PATH"
        
        echo "--- File Content ---"
        cat "$FILE_PATH"
        echo "--------------------"
        
        echo "=== End ==="
      '';
    };

    # Activation script to ensure the native messaging hosts directory can be linked by Home Manager
    home.activation.fixTridactylNative = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      if [ -d "$HOME/.mozilla/native-messaging-hosts" ] && [ ! -L "$HOME/.mozilla/native-messaging-hosts" ]; then
        verboseEcho "Removing existing native-messaging-hosts directory to allow Home Manager to link it..."
        rm -rf "$HOME/.mozilla/native-messaging-hosts"
      fi
    '';
  };
}
