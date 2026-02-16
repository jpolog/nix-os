{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.universityVPN;
in
{
  options.networking.universityVPN = {
    enable = mkEnableOption "university VPN configuration using strongSwan";

    connections = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          gateway = mkOption {
            type = types.str;
            description = "VPN gateway address (e.g., vpn.um.es)";
          };

          username = mkOption {
            type = types.str;
            description = "Your university email address (e.g., user@um.es)";
          };

          passwordFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to file containing the password (managed by SOPS). If null, password will be requested on connect.";
          };

          autoConnect = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to automatically connect to this VPN on boot";
          };

          certificate = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to CA certificate file for server validation";
          };

          # IKEv2 specific options
          proposal = mkOption {
            type = types.str;
            default = "aes256-sha256-modp1024";
            description = "IKE proposal encryption settings";
          };

          esp = mkOption {
            type = types.str;
            default = "aes256-sha256";
            description = "ESP proposal encryption settings";
          };

          splitTunnelRoutes = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of CIDR subnets to route through VPN (e.g. ['155.54.0.0/16']). If non-empty, split tunneling is enabled.";
          };

          searchDomains = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of DNS search domains to route to the VPN DNS servers (e.g. ['um.es']). Adds '~' prefix for systemd-resolved.";
          };
        };
      });
      default = {};
      description = "University VPN connection configurations";
    };
  };

  config = mkIf cfg.enable {
    # Add HARICA TLS Root CA 2021 to system certificate store
    # Note: strongSwan has issues reading from NixOS certificate bundles
    # The certificate should be specified directly in the VPN connection config
    security.pki.certificateFiles = [
      ../../certs/harica-tls-root-2021.pem
    ];

    # Ensure NetworkManager is enabled
    networking.networkmanager.enable = true;

    # NetworkManager configuration for strongSwan
    networking.networkmanager.plugins = with pkgs;
      [
        networkmanager-strongswan
      ];

    # Enable strongSwan service (required for VPN functionality)
    services.strongswan = {
      enable = true;
      
      # Enable NetworkManager integration
      enabledPlugins = [
        "gcm"
        "aesni"
        "sha2"
        "nonce"
        "x509"
        "revocation"
        "constraints"
        "pubkey"
        "pkcs1"
        "pkcs7"
        "pkcs8"
        "pkcs12"
        "pgp"
        "dnskey"
        "sshkey"
        "pem"
        "fips-prf"
        "gmp"
        "curve25519"
        "xcbc"
        "cmac"
        "hmac"
        "attr"
        "kernel-netlink"
        "resolve"
        "socket-default"
        "stroke"
        "updown"
        "eap-identity"
        "eap-mschapv2"
        "eap-dynamic"
        "eap-tls"
      ];
    };

    # Required packages for strongSwan with NetworkManager
    environment.systemPackages = with pkgs;
      [
        networkmanager
        networkmanagerapplet
        networkmanager-strongswan  # NetworkManager plugin for strongSwan
        strongswan
      ];

    # Create strongswan.conf and NetworkManager connection files
    environment.etc = {
      # strongswan.conf for charon-nm (NetworkManager plugin)
      "strongswan.conf".text = ''
        charon-nm {
          load = random nonce pubkey pkcs1 pem pkcs8 openssl kernel-netlink socket-default eap-identity eap-mschapv2 eap-md5 eap-gtc eap-tls
        }
      '';
    } // lib.mapAttrs' (name: vpnCfg:
      nameValuePair "NetworkManager/system-connections/${name}.nmconnection" {
        mode = "0600";
        text = ''
          [connection]
          id=${name}
          uuid=${let hash = builtins.hashString "sha256" name; in "${builtins.substring 0 8 hash}-${builtins.substring 8 4 hash}-${builtins.substring 12 4 hash}-${builtins.substring 16 4 hash}-${builtins.substring 20 12 hash}"}
          type=vpn
          autoconnect=${if vpnCfg.autoConnect then "true" else "false"}
          permissions=

          [vpn]
          service-type=org.freedesktop.NetworkManager.strongswan
          address=${vpnCfg.gateway}
          virtual=yes
          user=${vpnCfg.username}
          method=eap
          ${optionalString (vpnCfg.certificate != null) "certificate=${vpnCfg.certificate}"}
          proposal=${vpnCfg.proposal}
          esp=${vpnCfg.esp}
          ike=yes
          encap=no
          ipcomp=no
          rightid=${vpnCfg.gateway}

          [vpn-secrets]
          ${optionalString (vpnCfg.passwordFile != null) "password-flags=0"}
          ${optionalString (vpnCfg.passwordFile == null) "password-flags=1"}

          [ipv4]
          method=auto
          ${if vpnCfg.splitTunnelRoutes != [] then ''
          never-default=true
          ignore-auto-routes=false
          ignore-auto-dns=true
          ${concatStringsSep "\n" (imap1 (i: route: "route${toString i}=${route},0.0.0.0,0") vpnCfg.splitTunnelRoutes)}
          '' else ''
          never-default=false
          dns-priority=50
          ''}

          [ipv6]
          method=disabled

          [proxy]
        '';
      }
    ) cfg.connections;

    # Systemd service to inject passwords once NetworkManager is up
    systemd.services.university-vpn-password-injector = mkIf (any (vpn: vpn.passwordFile != null) (attrValues cfg.connections)) {
      description = "Inject university VPN passwords into NetworkManager";
      after = [ "NetworkManager.service" ];
      wants = [ "NetworkManager.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.networkmanager ];
      
      script = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: vpnCfg: 
          optionalString (vpnCfg.passwordFile != null) ''
            if [ -f "${vpnCfg.passwordFile}" ]; then
              # Wait for NetworkManager to be ready
              for i in {1..30}; do
                if nmcli general status >/dev/null 2>&1; then break; fi
                sleep 1
              done

              password=$(cat "${vpnCfg.passwordFile}")
              nmcli connection modify "${name}" vpn.secrets "password=$password"
              
              ${optionalString vpnCfg.autoConnect ''
                # Attempt to connect if autoConnect is enabled
                nmcli connection up "${name}" --wait 5 2>/dev/null || true
              ''}
            fi
          ''
        ) cfg.connections
      );
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}