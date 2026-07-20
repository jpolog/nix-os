{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.modules.services.printing;
in
{
  options.modules.services.printing = {
    enable = mkEnableOption "CUPS printing service" // { default = true; };
    includeHplip = mkOption {
      type = types.bool;
      default = true;
      description = "Include HP Linux Imaging and Printing (HPLIP) drivers and tools";
    };
  };

  config = mkIf cfg.enable {
    # CUPS printing service
    services.printing = {
      enable = true;
      drivers = with pkgs; [ 
        gutenprint 
        gutenprintBin 
        epson-escpr 
        brlaser 
      ] ++ (optionals cfg.includeHplip [ hplip ]);
    };

    environment.systemPackages = [ pkgs.system-config-printer ];

    # Scanner support
    hardware.sane = {
      enable = true;
      extraBackends = mkIf cfg.includeHplip [ pkgs.hplipWithPlugin ];
    };

    # Avahi for network printer discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
