{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.home.profiles.power-user;
in
{
  options.home.profiles.power-user = {
    enable = mkEnableOption "advanced power user tools";

    # Categories
    network.enable = mkEnableOption "network analysis tools (Wireshark, etc)" // {
      default = true;
    };
    system.enable = mkEnableOption "system monitoring and disk tools" // {
      default = true;
    };
    dev-gui.enable = mkEnableOption "development GUI tools (Insomnia, Hex Editors)" // {
      default = true;
    };
    productivity.enable = mkEnableOption "power productivity tools (Obsidian, CLI tools)" // {
      default = true;
    };
    cli-utils.enable = mkEnableOption "CLI power utilities (jq, ffmpeg, strace)" // {
      default = true;
    };
    torrenting.enable = mkEnableOption "torrenting tools (qBittorrent)" // {
      default = true;
    };
    upscayl.enable = mkEnableOption "AI image upscaler" // {
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      # Network Analysis
      (optionals cfg.network.enable [
        wireshark
        nmap
        socat
        mtr
        bandwhich
        gping
        dog
      ])
      ++

        # System & Disk
        (optionals cfg.system.enable [
          qdirstat
          kdePackages.filelight
          gparted
          cpu-x
          btop
          virt-manager
          kmonad
          krusader

          # CLI System Tools
          strace
          ltrace
          lsof
          iotop
          iftop
          sysstat
          duf
          dust
          gdu
          plocate
        ])
      ++

        # CLI Utilities
        (optionals cfg.cli-utils.enable [
          jq
          yq-go
          miller
          fx
          ripgrep
          fd
          eza
          bat
          tealdeer
          ffmpeg
          imagemagick
          p7zip
          unzip
          zip
          hyperfine
          parallel
          yt-dlp
        ])
      ++

        # Development GUIs
        (optionals cfg.dev-gui.enable [
          imhex
          insomnia
        ])
      ++

        # Power Productivity (Moved from personal)
        (optionals cfg.productivity.enable [
          obsidian
          timewarrior
          taskwarrior3
          taskwarrior-tui
          rclone
          calibre
        ])
      ++

        # Torrenting (Swapped Transmission for qBittorrent)
        (optionals cfg.torrenting.enable [
          qbittorrent
        ])
      ++

        # AI Image Upscaling
        (optionals cfg.upscayl.enable [
          upscayl
        ]);

    # Declarative Obsidian Vault Configuration
    xdg.configFile."obsidian/obsidian.json".text = builtins.toJSON {
      vaults = {
        "knowledge-base" = {
          path = "/home/jpolo/Vault/Knowledge Base";
          ts = 1737742000000;
          open = true;
        };
      };
    };

    # Force Dark Mode in the vault via activation script (keeps file writable)
    home.activation.obsidianDarkMode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      APPEARANCE_FILE="/home/jpolo/Vault/Knowledge Base/.obsidian/appearance.json"
      if [ -f "$APPEARANCE_FILE" ]; then
        # Use jq to merge the theme setting into existing config
        ${pkgs.jq}/bin/jq '.theme = "obsidian"' "$APPEARANCE_FILE" > "$APPEARANCE_FILE.tmp" && mv "$APPEARANCE_FILE.tmp" "$APPEARANCE_FILE"
      else
        mkdir -p "$(dirname "$APPEARANCE_FILE")"
        echo '{"theme":"obsidian"}' > "$APPEARANCE_FILE"
      fi
      chown jpolo:users "$APPEARANCE_FILE" || true
    '';
  };
}
