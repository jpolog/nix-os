{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.profiles.work;
in
{
  options.home.profiles.work = {
    enable = mkEnableOption "work applications profile";
    
    communication = {
      enable = mkEnableOption "work communication apps" // { default = true; };
      slack = mkEnableOption "Slack" // { default = cfg.communication.enable; };
      teams = mkEnableOption "Microsoft Teams" // { default = cfg.communication.enable; };
      zoom = mkEnableOption "Zoom" // { default = cfg.communication.enable; };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      # Communication
      (optionals cfg.communication.slack [ slack ]) ++
      (optionals cfg.communication.teams [ teams-for-linux ]) ++
      (optionals cfg.communication.zoom [ zoom-us ]);
  };
}
