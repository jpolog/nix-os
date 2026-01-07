{ config, pkgs, ... }:

{
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
}
