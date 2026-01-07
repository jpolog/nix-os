{ config, pkgs, ... }:

{
  # Docker & Podman support
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    
    # Alternative: Use Podman (Docker-compatible)
    # podman = {
    #   enable = true;
    #   dockerCompat = true;
    #   defaultNetwork.settings.dns_enabled = true;
    # };
  };

  # Docker tools
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
    dive  # Docker image explorer
  ];

  # Add user to docker group (configured in user module)
  # users.users.jpolo.extraGroups = [ "docker" ];
}
