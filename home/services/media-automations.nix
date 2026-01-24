{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.media-automations;
in
{
  options.services.media-automations = {
    enable = mkEnableOption "media automation services";
    autoPause.enable = mkEnableOption "auto-pause on audio sink removal" // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.autoPause.enable) {
    systemd.user.services.auto-pause = {
      Unit = {
        Description = "Auto-pause media on audio sink removal";
        After = [ "graphical-session.target" "pipewire.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        # running the logic directly to ensure dependencies are met
        ExecStart = pkgs.writeShellScript "auto-pause-service" ''
          export PATH="${lib.makeBinPath [ pkgs.pulseaudio pkgs.gnugrep pkgs.playerctl ]}:$PATH"
          echo "Starting auto-pause monitor..."
          pactl subscribe | grep --line-buffered "Event 'remove' on sink" | while read -r line; do
             echo "Audio sink removed. Pausing all media players..."
             playerctl -a pause
          done
        '';
        Restart = "always";
        RestartSec = "5s";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
