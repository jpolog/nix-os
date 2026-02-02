{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.eduroam;
in
{
  options.networking.eduroam = {
    enable = mkEnableOption "eduroam WiFi configuration";

    networks = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          ssid = mkOption {
            type = types.str;
            default = "eduroam";
            description = "SSID of the eduroam network";
          };

          identity = mkOption {
            type = types.str;
            description = "Your eduroam identity (usually username@institution.domain)";
          };

          passwordFile = mkOption {
            type = types.path;
            description = "Path to file containing the password (managed by SOPS)";
          };

          # Advanced WPA-Enterprise settings
          domain = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Domain match for certificate validation (e.g., radius.university.edu)";
          };

          caCertificate = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to CA certificate file for server validation";
          };

          phase2Auth = mkOption {
            type = types.str;
            default = "MSCHAPV2";
            description = "Phase 2 authentication method (MSCHAPV2, PAP, GTC, etc.)";
          };

          anonymousIdentity = mkOption {
            type = types.str;
            default = "anonymous";
            description = "Anonymous identity for outer authentication";
          };
        };
      });
      default = {};
      description = "eduroam network configurations";
    };
  };

  config = mkIf cfg.enable {
    # Ensure NetworkManager is enabled
    networking.networkmanager.enable = true;

    # Create NetworkManager connection files for each eduroam network
    environment.etc = lib.mapAttrs' (name: netCfg:
      nameValuePair "NetworkManager/system-connections/${name}.nmconnection" {
        mode = "0600";
        text = ''
          [connection]
          id=${name}
          uuid=${let hash = builtins.hashString "sha256" name; in "${builtins.substring 0 8 hash}-${builtins.substring 8 4 hash}-${builtins.substring 12 4 hash}-${builtins.substring 16 4 hash}-${builtins.substring 20 12 hash}"}
          type=wifi
          permissions=

          [wifi]
          mode=infrastructure
          ssid=${netCfg.ssid}

          [wifi-security]
          auth-alg=open
          key-mgmt=wpa-eap

          [802-1x]
          eap=peap;
          identity=${netCfg.identity}
          phase2-auth=${lib.toLower netCfg.phase2Auth}
          password-flags=0
          anonymous-identity=${netCfg.anonymousIdentity}
          ${optionalString (netCfg.domain != null) "domain-suffix-match=${netCfg.domain}"}
          ${optionalString (netCfg.caCertificate != null) "ca-cert=${netCfg.caCertificate}"}

          [ipv4]
          method=auto

          [ipv6]
          addr-gen-mode=stable-privacy
          method=auto

          [proxy]
        '';
      }
    ) cfg.networks;

    # Systemd service to inject passwords once NetworkManager is up
    systemd.services.eduroam-password-injector = {
      description = "Inject eduroam passwords into NetworkManager";
      after = [ "NetworkManager.service" ];
      wants = [ "NetworkManager.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.networkmanager ];
      
      script = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: netCfg: ''
          if [ -f "${netCfg.passwordFile}" ]; then
            # Wait for NM to be ready
            for i in {1..30}; do
              if nmcli general status >/dev/null 2>&1; then break; fi
              sleep 1
            done

            password=$(cat "${netCfg.passwordFile}")
            nmcli connection modify "${name}" 802-1x.password "$password"
            
            # Attempt to connect immediately
            nmcli connection up "${name}" --wait 2 2>/dev/null || true
          fi
        '') cfg.networks
      );
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };

    # System packages needed for certificate management
    environment.systemPackages = with pkgs; [
      networkmanager
      networkmanagerapplet
    ];
  };
}
