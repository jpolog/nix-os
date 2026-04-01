{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  # Create power profile scripts with proper dependencies
  powerScripts = pkgs.stdenv.mkDerivation {
    name = "power-profile-scripts";

    src = ../../scripts/power;

    buildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin

      # Copy scripts and wrap them with proper PATH
      for script in balanced.sh balanced-eco.sh performance.sh performance-plus.sh eco.sh; do
        name=''${script%.sh}
        cp ${../../scripts/power}/$script $out/bin/power-$name
        chmod +x $out/bin/power-$name
        
        # Wrap script to ensure PATH includes tlp and systemd
        wrapProgram $out/bin/power-$name \
          --prefix PATH : ${lib.makeBinPath [ pkgs.tlp pkgs.systemd pkgs.coreutils ]}
      done
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

    # Ensure TLP is managed
    services.tlp.enable = true;
    
    # Enable thinkfan but we'll override its service to use writable config
    services.thinkfan.enable = true;

    # Define directories for writable configs
    systemd.tmpfiles.rules = [
      "d /etc/tlp.d 0755 root root -"
      "d /var/lib/thinkfan 0755 root root -"
    ];

    # Copy thinkfan YAML profile configs to /etc
    environment.etc."power-profiles/thinkfan-eco.yaml".source =
      ../../scripts/power/thinkfan-eco.yaml;
    environment.etc."power-profiles/thinkfan-balanced.yaml".source =
      ../../scripts/power/thinkfan-balanced.yaml;
    environment.etc."power-profiles/thinkfan-balanced-eco.yaml".source =
      ../../scripts/power/thinkfan-balanced-eco.yaml;
    environment.etc."power-profiles/thinkfan-performance.yaml".source =
      ../../scripts/power/thinkfan-performance.yaml;
    environment.etc."power-profiles/thinkfan-performance-plus.yaml".source =
      ../../scripts/power/thinkfan-performance-plus.yaml;

    # Override thinkfan service to use writable config
    systemd.services.thinkfan = {
      serviceConfig = {
        Type = lib.mkForce "simple"; # Changed from forking since we use -n
        PIDFile = lib.mkForce null; # Remove PIDFile since we're not forking
        ExecStart = lib.mkForce [
          "" # Clear existing ExecStart
          "${pkgs.thinkfan}/bin/thinkfan -n -c /var/lib/thinkfan/active.yaml"
        ];
      };
      preStart = lib.mkForce ''
        # Initialize with eco profile if no active config exists
        if [ ! -f /var/lib/thinkfan/active.yaml ]; then
          cp /etc/power-profiles/thinkfan-eco.yaml /var/lib/thinkfan/active.yaml
        fi
      '';
    };
  };
}
