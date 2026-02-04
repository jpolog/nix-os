{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./network.nix
    ./eduroam.nix
    ./university-vpn.nix
    ./power.nix
    ./power-profile-apply.nix
    ./security.nix
    ./ssh.nix
    ./optimization.nix
    ./secrets.nix
    ./scripts.nix
    ./perf-tuning.nix
    #./gaming-isolated.nix
    # Virtualization is now a separate module in modules/vms
    # ./virtualization.nix
    ./port-management.nix
  ];
}
