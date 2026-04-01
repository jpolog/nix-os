{
  config,
  lib,
  pkgs,
  ...
}:

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
  };
}
