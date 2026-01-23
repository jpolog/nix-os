{ config, pkgs, inputs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    services.hypridle = {
      enable = true;
      package = pkgs.hypridle;
      
      settings = {
        general = {
          lockCmd = "pidof hyprlock || hyprlock";
          beforeSleepCmd = "loginctl lock-session";
          afterSleepCmd = "hyprctl dispatch dpms on";
          ignoreDbusInhibit = false;
        };

        listener = [
          {
            timeout = 300;  # 5 minutes
            onTimeout = "brightnessctl -s set 10";
            onResume = "brightnessctl -r";
          }
          {
            timeout = 600;  # 10 minutes
            onTimeout = "loginctl lock-session";
          }
          {
            timeout = 660;  # 11 minutes
            onTimeout = "hyprctl dispatch dpms off";
            onResume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1800;  # 30 minutes
            onTimeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}

