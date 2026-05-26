{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ollama-service;
in
{
  options.services.ollama-service = {
    enable = mkEnableOption "Ollama AI Model Runner";

    package = mkOption {
      type = types.package;
      default = pkgs.ollama;
      description = "The ollama package to use.";
    };

    acceleration = mkOption {
      type = types.nullOr (
        types.enum [
          "rocm"
          "cuda"
        ]
      );
      default = null;
      description = "Acceleration method (rocm for AMD, cuda for NVIDIA).";
    };

    autoDiscover = {
      enable = mkEnableOption "Automatic Ollama model discovery for omp" // { default = true; };

      interval = mkOption {
        type = types.str;
        default = "30min";
        description = "Systemd timer interval for periodic model discovery (e.g. '5min', '30min', '1h').";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.ollama = {
      Unit = {
        Description = "Ollama Service";
        After = [ "network.target" ];
      };

      Service = {
        ExecStart = "${cfg.package}/bin/ollama serve";
        Environment = lib.flatten [
          # Bind to all interfaces so Docker containers can reach Ollama
          # via host.docker.internal (Linux gateway IP, typically 172.17.0.1).
          "OLLAMA_HOST=0.0.0.0:11434"
          (lib.optionals (cfg.acceleration == "rocm") [
            "HSA_OVERRIDE_GFX_VERSION=11.0.0"
            "ROCR_VISIBLE_DEVICES=0"
          ])
        ];
        Restart = "always";
        RestartSec = 3;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # ── Ollama Model Discovery ─────────────────────────────────────────
    # Periodically polls Ollama /api/tags and writes discovered models
    # to ~/.omp/models.local.json for use by the omp model picker.
    # Also runs on omp launch via the wrapper script for immediate updates.
    systemd.user.services.ollama-discover = mkIf cfg.autoDiscover.enable {
      Unit = {
        Description = "Discover locally available Ollama models";
        After = [ "ollama.service" ];
        Wants = [ "ollama.service" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScriptBin "ollama-discover-timer" ''
          export PATH="${pkgs.curl}/bin:${pkgs.python3}/bin:$PATH"
          exec ollama-discover --url http://localhost:11434
        ''}/bin/ollama-discover-timer";
      };
    };

    systemd.user.timers.ollama-discover = mkIf cfg.autoDiscover.enable {
      Unit = {
        Description = "Periodically discover locally available Ollama models";
      };

      Timer = {
        OnBootSec = "2min";
        OnUnitActiveSec = cfg.autoDiscover.interval;
        AccuracySec = "1min";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}