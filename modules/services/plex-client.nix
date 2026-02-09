{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.plex-client;
in
{
  options.services.plex-client = {
    enable = mkEnableOption "Plex Client firewall rules (for downloads/sync/GDM)";
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      # Plex GDM (Network Discovery) ports required for local discovery and downloads/sync
      allowedUDPPorts = [ 
        32410 # GDM network discovery
        32412 # GDM network discovery
        32413 # GDM network discovery
        32414 # GDM network discovery
      ];
    };
  };
}
