{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.services.kmonad;
in
{
  options.modules.services.kmonad = {
    enable = mkEnableOption "KMonad keyboard configuration service";
    
    keyboards = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          device = mkOption {
            type = types.path;
            description = "Path to the input device file.";
          };
          config = mkOption {
            type = types.lines;
            description = "KMonad configuration (.kbd) content.";
          };
        };
      });
      default = {};
      description = "Map of keyboard names to their KMonad configurations.";
    };
  };

  config = mkIf cfg.enable {
    # NixOS standard module for KMonad
    services.kmonad = {
      enable = true;
      keyboards = mapAttrs (name: kb: {
        inherit (kb) device config;
      }) cfg.keyboards;
    };
  };
}
