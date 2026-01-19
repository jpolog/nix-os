{ config, lib, pkgs, ... }:

{
  # SSH Server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";  # Secure default, but can be overridden
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
}
