{ config, lib, ... }:

with lib;

{
  # Import gaming-isolated module at top level
  imports = [
    ../system/gaming-isolated.nix
  ];

  options.profiles.gaming = {
    enable = mkEnableOption "gaming profile with Steam and isolation";
  };

  config = mkIf config.profiles.gaming.enable {
    # Gaming profile configuration would go here
    # The gaming-isolated.nix module is always imported but can have its own enable options
  };
}
