{ config, lib, ... }:

with lib;

{
  # Import desktop modules at top level
  imports = [
    ../desktop
  ];

  options.profiles.desktop = {
    enable = mkEnableOption "desktop environment profile";
  };

  config = mkIf config.profiles.desktop.enable {
    # Desktop profile is enabled
    # The actual desktop configuration comes from ../desktop modules
  };
}
