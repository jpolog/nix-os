{ config, pkgs, inputs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    services.hypridle = {
      enable = true;
      package = inputs.hypridle.packages.${pkgs.stdenv.hostPlatform.system}.hypridle;
      
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = 300;  # 5 minutes
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 600;  # 10 minutes
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 660;  # 11 minutes
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1800;  # 30 minutes
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}