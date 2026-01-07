{ config, pkgs, ... }:

{
  # CUPS printing service
  services.printing = {
    enable = true;
    drivers = with pkgs; [ 
      gutenprint 
      gutenprintBin 
      hplip 
      epson-escpr 
      brlaser 
    ];
  };

  # Scanner support
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  # Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
