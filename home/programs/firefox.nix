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
  enableVimNavigation = config.home.firefox.vimNavigation.enable or false;
in
{
  options.home.firefox.vimNavigation = {
    enable = mkEnableOption "Tridactyl vim navigation for Firefox";
  };

  config = mkIf config.home.profiles.desktop.enable {
    programs.firefox = {
      enable = true;

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
          ];

        # Force containers and search settings
        containersForce = true;
        search.force = true;
      };
    };
  };
}
