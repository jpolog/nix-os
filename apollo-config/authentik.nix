{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Authentik SSO (Single Sign-On)
#
# Provides unified authentication for all services via nginx forward-auth.
# Once configured, add these lines to any nginx location you want to protect:
#
#   auth_request /outpost.goauthentik.io/auth/nginx;
#   error_page 401 = @goauthentik_proxy_signin;
#
# Access: https://apollo.<tailnet>/auth  (Authentik admin)
#
# Before deploying:
#   1. Add authentik entries to secrets/secrets.yaml:
#      authentik:
#        secret_key: "<50-char-random-string>"
#        db_password: "<secure-password>"
#        bootstrap_password: "<initial-admin-password>"
#   2. Encrypt: sops secrets/secrets.yaml
#   3. After first boot, log into Authentik at /auth as user "akadmin"
#   4. Create OAuth2 providers for each service
#   5. Enable forward-auth on protected nginx locations
###############################################################################
let
  tailscaleIp = "100.114.69.83";
in
{
  # ---------------------------------------------------------------------------
  # sops-nix secrets for Authentik
  # ---------------------------------------------------------------------------
  sops.secrets = {
    "authentik/secret_key" = {
      owner = config.services.authentik.user;
      group = config.services.authentik.group;
      mode = "0400";
    };
    "authentik/db_password" = {
      owner = config.services.authentik.user;
      group = config.services.authentik.group;
      mode = "0400";
    };
    "authentik/bootstrap_password" = {
      owner = config.services.authentik.user;
      group = config.services.authentik.group;
      mode = "0400";
    };
  };

  # ---------------------------------------------------------------------------
  # Authentik native NixOS module
  # ---------------------------------------------------------------------------
  services.authentik = {
    enable = true;

    # Secret key for Django crypto operations (keep this secret!)
    secretKeyFile = config.sops.secrets."authentik/secret_key".path;

    # Database — use the shared PostgreSQL instance
    settings = {
      postgresql = {
        host = "/run/postgresql";  # Unix socket (peer auth, no password)
        port = 5432;
        name = "authentik";
        user = "authentik";
      };

      # Redis — shared instance, DB 6
      redis = {
        host = "127.0.0.1";
        port = 6379;
        db = 6;
      };

      # Email (optional — configure when you have an SMTP server)
      # email = {
      #   host = "smtp.example.com";
      #   port = 587;
      #   username = "___SECRET_MANAGED___";
      #   password = "file:///run/secrets/authentik-email-password";
      #   from = "authentik@javierpolo.com";
      # };

      # Error reporting (disable on home server)
      error_reporting.enabled = false;
    };

    # Bootstrap: first user "akadmin" with password from secrets
    environmentFile = config.sops.secrets."authentik/bootstrap_password".path;
  };

  # ---------------------------------------------------------------------------
  # Nginx integration — forward-auth endpoint
  #
  # This creates the /outpost.goauthentik.io path that services redirect to.
  # To protect a location, add:
  #   auth_request /outpost.goauthentik.io/auth/nginx;
  #   error_page 401 = @goauthentik_proxy_signin;
  # ---------------------------------------------------------------------------
  services.nginx.virtualHosts."apollo" = {
    # These locations are added to the existing apollo virtualHost.
    # They must come BEFORE protected locations due to nginx prefix matching.

    # Authentik proxy — handles SSO redirects and auth checks
    locations."/outpost.goauthentik.io" = {
      proxyPass = "http://127.0.0.1:9000/outpost.goauthentik.io";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        add_header Set-Cookie $auth_cookie;
        auth_request_set $auth_cookie $upstream_http_set_cookie;
      '';
    };

    # Redirect target for unauthenticated requests
    extraConfig = ''
      # @goauthentik_proxy_signin — redirects users to the Authentik login page
      location @goauthentik_proxy_signin {
        return 302 /outpost.goauthentik.io/start?rd=$request_uri;
      }
    '';

    # Authentik admin interface
    locations."/auth" = {
      proxyPass = "http://127.0.0.1:9000";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        client_max_body_size 20m;  # for uploading application icons/logos
      '';
    };
  };

  # ---------------------------------------------------------------------------
  # Protect these specific locations with Authentik forward-auth
  #
  # Uncommenting below adds auth_request to each location.
  # Start with monitoring/admin tools, then expand to all services.
  # ---------------------------------------------------------------------------
  #
  # Example — protect the Portainer and Grafana routes:
  #
  # services.nginx.virtualHosts."apollo".locations."/portainer".extraConfig = ''
  #   auth_request /outpost.goauthentik.io/auth/nginx;
  #   error_page 401 = @goauthentik_proxy_signin;
  # '';
  #
  # services.nginx.virtualHosts."apollo".locations."/grafana".extraConfig = ''
  #   auth_request /outpost.goauthentik.io/auth/nginx;
  #   error_page 401 = @goauthentik_proxy_signin;
  # '';
  #
  # services.nginx.virtualHosts."apollo".locations."/chat".extraConfig = ''
  #   auth_request /outpost.goauthentik.io/auth/nginx;
  #   error_page 401 = @goauthentik_proxy_signin;
  # '';
}
