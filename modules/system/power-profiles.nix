{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  # Create power profile scripts as a package
  powerScripts = pkgs.stdenv.mkDerivation {
    name = "power-profile-scripts";

    src = ../../scripts/power;

    installPhase = ''
      mkdir -p $out/bin

      # Copy and make scripts executable
      cp ${../../scripts/power/balanced.sh} $out/bin/power-balanced
      cp ${../../scripts/power/performance.sh} $out/bin/power-performance
      cp ${../../scripts/power/performance-plus.sh} $out/bin/power-performance-plus
      cp ${../../scripts/power/eco.sh} $out/bin/power-eco

      chmod +x $out/bin/*
    '';
  };
in
{
  options.system.powerProfiles = {
    enable = mkEnableOption "system-wide power profiles";
  };

  config = mkIf config.system.powerProfiles.enable {
    environment.systemPackages = with pkgs; [
      tlp
      thinkfan
      powerScripts # Add the power profile scripts
    ];

    # Ensure TLP and Thinkfan services are managed
    services.tlp.enable = true;
    services.thinkfan.enable = true;

    # Define TLP configuration directory for scripts to modify
    systemd.tmpfiles.rules = [
      "d /etc/tlp.d 0755 root root -"
    ];

    # Copy thinkfan profile configs to /etc
    environment.etc."power-profiles/thinkfan-balanced.conf".source =
      ../../scripts/power/thinkfan-balanced.conf;
    environment.etc."power-profiles/thinkfan-performance.conf".source =
      ../../scripts/power/thinkfan-performance.conf;
    environment.etc."power-profiles/thinkfan-performance-plus.conf".source =
      ../../scripts/power/thinkfan-performance-plus.conf;
    environment.etc."power-profiles/thinkfan-eco.conf".source = ../../scripts/power/thinkfan-eco.conf;

    # Copy initial balanced thinkfan config as default
    environment.etc."thinkfan.conf".source = ../../scripts/power/thinkfan-balanced.conf;
  };
}
