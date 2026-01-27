{ config, lib, ... }:

{
  # ============================================================================
  # eduroam WiFi Configuration for University
  # ============================================================================

  # Enable eduroam module
  networking.eduroam = {
    enable = true;

    networks = {
      # Your university's eduroam network
      university-eduroam = {
        ssid = "eduroam";

        # Your eduroam identity (format: username@institution.domain)
        # Example: jpolo@university.edu
        # Replace with your actual identity
        identity = "javier.polog@um.es"; # CHANGE THIS to your actual eduroam username

        # Password is managed by SOPS (secrets management)
        passwordFile = config.sops.secrets.eduroam_password.path;

        # Optional: Configure certificate validation for enhanced security
        # Uncomment and modify if your university provides specific requirements:

        # Domain match for certificate validation (prevents MITM attacks)
        # Get this from your university's IT department
        # domain = "radius.university.edu";

        # Phase 2 authentication method
        # Common options: "MSCHAPV2" (most common), "PAP", "GTC"
        phase2Auth = "MSCHAPV2";

        # Anonymous identity for outer authentication (privacy protection)
        anonymousIdentity = "anonymous@um.es"; # CHANGE THIS to match your domain

        # CA Certificate (optional, but recommended for security)
        # If your university provides a CA cert, download it and reference it here:
        # caCertificate = /path/to/university-ca-cert.pem;
      };
    };
  };

  # SOPS secret configuration for eduroam password
  sops.secrets.eduroam_password = {
    # Use the default secrets file
    sopsFile = ../../secrets/secrets.yaml;

    # NetworkManager needs to read this secret at runtime
    # Set appropriate ownership
    owner = "root";
    group = "networkmanager";
    mode = "0440";
  };
}
