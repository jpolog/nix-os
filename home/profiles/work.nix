{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.profiles.work;
in
{
  options.home.profiles.work = {
    enable = mkEnableOption "work applications profile";
    
    communication = {
      enable = mkEnableOption "work communication apps" // { default = true; };
      slack = mkEnableOption "Slack" // { default = cfg.communication.enable; };
      teams = mkEnableOption "Microsoft Teams" // { default = cfg.communication.enable; };
      zoom = mkEnableOption "Zoom" // { default = cfg.communication.enable; };
    };

    vpn = {
      enable = mkEnableOption "work VPN (Cisco AnyConnect)" // { default = cfg.enable; };
      server = mkOption {
        type = types.str;
        default = "cdel.c-lab.ee";
        description = "VPN Server Address";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      # Communication
      (optionals cfg.communication.slack [ slack ]) ++
      (optionals cfg.communication.teams [ teams-for-linux ]) ++
      (optionals cfg.communication.zoom [ zoom-us ]) ++
      # VPN
      (optionals cfg.vpn.enable [ 
        openconnect 
        networkmanager-openconnect 
      ]);

    home.file.".local/bin/setup-citadel-vpn" = mkIf cfg.vpn.enable {
      executable = true;
      text = ''
        #!/bin/sh
        # Check if connection already exists
        if nmcli connection show "Citadel VPN" >/dev/null 2>&1; then
          echo "VPN connection 'Citadel VPN' already exists. Updating settings..."
        else
          echo "Creating 'Citadel VPN' connection for server ${cfg.vpn.server}..."
          # Create the connection using nmcli with openconnect
          nmcli con add type vpn vpn-type openconnect con-name "Citadel VPN" ifname "*" -- \
            vpn.data "gateway=${cfg.vpn.server}, cookie-flags=2, gwcert-srv=1" \
            vpn.secrets ""
        fi

        echo "Configuring split tunneling and DNS for 'Citadel VPN'..."
        
        # 1. Never use as default gateway (Split Tunneling)
        # This ensures your normal internet traffic doesn't go through the VPN
        nmcli connection modify "Citadel VPN" ipv4.never-default yes
        
        # 2. DNS Configuration
        # Set a high priority number (lower priority in systemd-resolved) 
        # so it doesn't override your primary DNS for everything
        nmcli connection modify "Citadel VPN" ipv4.dns-priority 50
        
        # 3. Optional: Add specific routes if the VPN doesn't push them automatically
        # Example: nmcli connection modify "Citadel VPN" +ipv4.routes "10.0.0.0/8"

        echo "VPN 'Citadel VPN' configured successfully."
        echo "Split tunneling is ENABLED: only VPN-specific traffic will go through the tunnel."
        echo "To connect, use the system tray network icon or run: nmcli con up 'Citadel VPN'"
      '';
    };

    xdg.configFile."zoomus.conf" = mkIf cfg.communication.zoom {
      text = ''
        [General]
        enablegpucomputeutilization=true
        enableCefGpu=true
      '';
    };
  };
}
