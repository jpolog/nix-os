{ config, pkgs, ... }:

{
  # Geoclue for location services (needed for night light)
  services.geoclue2.enable = true;
  
  location.provider = "geoclue2";
}
