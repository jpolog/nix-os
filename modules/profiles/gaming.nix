{ config, lib, ... }:

with lib;

{
  options.profiles.gaming = {
    enable = mkEnableOption "gaming profile with Steam and isolation";
  };

  config = mkIf config.profiles.gaming.enable {
    imports = [
      ../system/gaming-isolated.nix
    ];
  };
}
