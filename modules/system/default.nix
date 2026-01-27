{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./network.nix
    ./eduroam.nix
    ./power.nix
    ./security.nix
    ./ssh.nix
    ./optimization.nix
    ./secrets.nix
    ./scripts.nix
    ./perf-tuning.nix
    #./gaming-isolated.nix
    ./virtualization.nix
    ./port-management.nix
  ];
}
