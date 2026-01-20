{ config, pkgs, inputs, lib, ... }:

with lib;

{
  config = mkIf (config.home.profiles.desktop.enable && config.home.profiles.desktop.environment == "hyprland") {
    # Hyprsunset - Blue light filter for Hyprland
    home.packages = [ 
      inputs.hyprsunset.packages.${pkgs.stdenv.hostPlatform.system}.hyprsunset 
    ];

    # Hyprsunset service
    systemd.user.services.hyprsunset = {
      Unit = {
        Description = "Hyprsunset - Blue light filter";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      
      Service = {
        ExecStart = "${inputs.hyprsunset.packages.${pkgs.stdenv.hostPlatform.system}.hyprsunset}/bin/hyprsunset -t 4500";
        Restart = "on-failure";
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
