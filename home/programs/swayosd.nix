{ config, pkgs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    # SwayOSD - OSD window for volume and brightness
    home.packages = with pkgs; [
      swayosd
    ];

    # SwayOSD service
    systemd.user.services.swayosd = {
      Unit = {
        Description = "SwayOSD - OSD window for volume and brightness";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      
      Service = {
        ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
        Restart = "on-failure";
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}