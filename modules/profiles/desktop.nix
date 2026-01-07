{ config, lib, ... }:

with lib;

{
  options.profiles.desktop = {
    enable = mkEnableOption "desktop environment profile";
  };

  config = mkIf config.profiles.desktop.enable {
    imports = [
      ../desktop
    ];
  };
}
