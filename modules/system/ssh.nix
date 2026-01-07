{ config, pkgs, ... }:

{
  # SSH Server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
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
