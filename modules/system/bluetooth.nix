{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.system.bluetooth;
in
{
  options.modules.system.bluetooth = {
    enable = mkEnableOption "Bluetooth";
  };

  config = mkIf cfg.enable {
    # Bluetooth support
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    # Bluez service
    services.blueman.enable = true;

    # Bluetooth packages
    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
      blueman
    ];
  };
}
