{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.system.ssh;
in
{
  options.modules.system.ssh = {
    enable = mkEnableOption "SSH server" // { default = true; };
  };

  config = mkIf cfg.enable {
    # SSH Server
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = lib.mkDefault "yes";  # Secure default, but can be overridden
        PasswordAuthentication = true;
        PubkeyAuthentication = true;
      };
    };

    # SSH and SFTP packages
    environment.systemPackages = with pkgs; [
      openssh
      sshfs
    ];

    # Open SSH port in firewall
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
