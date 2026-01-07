{ config, pkgs, inputs, ... }:

{
  # Hyprsunset - Blue light filter for Hyprland
  home.packages = [ 
    inputs.hyprsunset.packages.${pkgs.system}.hyprsunset 
  ];

  # Hyprsunset service
  systemd.user.services.hyprsunset = {
    Unit = {
      Description = "Hyprsunset - Blue light filter";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    
    Service = {
      ExecStart = "${inputs.hyprsunset.packages.${pkgs.system}.hyprsunset}/bin/hyprsunset -t 4500";
      Restart = "on-failure";
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
