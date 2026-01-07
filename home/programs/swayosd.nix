{ config, pkgs, ... }:

{
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
}
