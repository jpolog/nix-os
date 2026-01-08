{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./network.nix
    ./power.nix
    ./security.nix
    ./ssh.nix
    ./optimization.nix
    ./secrets.nix
    ./scripts.nix
    ./power-user.nix
    #./gaming-isolated.nix
    ./virtualization.nix
    ./port-management.nix
  ];
}
