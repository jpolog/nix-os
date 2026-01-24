{ config, pkgs, lib, ... }:

with lib;

{
  # Only enable this if the user has the personal profile enabled (checked via specialArg or assumption)
  # For now, we enable it if the user jpolo exists.
  
  options.services.syncthing-jpolo = {
    enable = mkEnableOption "Syncthing for jpolo";
  };

  config = mkIf config.services.syncthing-jpolo.enable {
    services.syncthing = {
      enable = true;
      user = "jpolo";
      dataDir = "/home/jpolo";    # Default folder for new synced folders
      configDir = "/home/jpolo/.config/syncthing";
      overrideDevices = false;     # Don't delete manually added devices
      overrideFolders = false;     # Don't delete manually added folders

      # Declarative Folders
      settings.folders = {
        "knowledge-base-vault" = {
          path = "/home/jpolo/Vault";
          label = "Knowledge Base";
          id = "knowledge-base-vault";
          ignorePerms = false;
        };
      };
    };
    
    # Open Firewall ports for Syncthing
    networking.firewall = {
      allowedTCPPorts = [ 8384 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
    };
  };
}
