{ config, pkgs, lib, ... }:

{
  imports = [
    ./direnv.nix
    ./docker.nix
    ./languages.nix
    ./tools.nix
  ];
}
