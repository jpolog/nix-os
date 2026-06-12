{ ... }:

{
  imports = [
    ./databases.nix
    ./media.nix
    ./productivity.nix
    ./monitoring.nix
    ./development.nix
    ./networking.nix
    ./backup.nix
    ./hardening.nix
    ./storage.nix
  ];
}