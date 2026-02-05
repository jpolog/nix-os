{ config, lib, ... }:

{
  # ============================================================================
  # University VPN Configuration (Universidad de Murcia)
  # ============================================================================

  # Enable university VPN module
  networking.universityVPN = {
    enable = true;

    connections = {
      # Universidad de Murcia VPN
      um-vpn = {
        # VPN Gateway - REPLACE with the actual gateway from the instructions
        # Common UM VPN gateways might be: vpn.um.es, vpnacc.um.es, etc.
        # Check your university's IT documentation for the exact address
        gateway = "vpn.um.es"; # TODO: VERIFY this gateway address with your university IT

        # Your university email address (complete)
        # Example: javier.polog@um.es
        username = "javier.polog@um.es"; # CHANGE THIS to your actual UM email

        # Password is managed by SOPS (secrets management)
        # Password will be requested on connection if passwordFile is null
        # Uncomment the line below to use SOPS-managed password:
        # passwordFile = config.sops.secrets.um_vpn_password.path;
        passwordFile = null; # Password will be requested when connecting

        # Auto-connect on boot (disabled by default)
        autoConnect = false; # Set to true if you want automatic connection

        # CA Certificate for server validation (required for HARICA certificate chain)
        # Using the HARICA TLS Root CA 2021 certificate from the certs directory
        certificate = ../../certs/harica-tls-root-2021.pem;

        # IKEv2 encryption settings (Universidad de Murcia defaults)
        # These should work for most universities, but verify with your IT department
        proposal = "aes256-sha256-modp1024"; # IKE proposal
        esp = "aes256-sha256"; # ESP proposal
      };
    };
  };

  # SOPS secret configuration for VPN password (OPTIONAL)
  # Uncomment this section if you want to use SOPS for password management
  # Otherwise, NetworkManager will prompt you for the password when connecting
  
  # sops.secrets.um_vpn_password = {
  #   # Use the default secrets file
  #   sopsFile = ../../secrets/secrets.yaml;
  #
  #   # NetworkManager needs to read this secret at runtime
  #   owner = "root";
  #   group = "networkmanager";
  #   mode = "0440";
  # };
}
