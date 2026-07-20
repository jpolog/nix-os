{ config, lib, pkgs, ... }:

###############################################################################
# apollo — Users
#
# User accounts, groups, and home-manager integration points.
#
# To add home-manager configs per-user later, create:
#   nixos/home/jpolo.nix  and  nixos/home/sergio.nix
# then import them below via home-manager.users.<name>.
###############################################################################
{
  # ---------------------------------------------------------------------------
  # User Accounts
  # ---------------------------------------------------------------------------
  users = {
    # Default shell for all users
    defaultUserShell = pkgs.bash;

    users = {
      # Primary user — owns all services and data
      jpolo = {
        isNormalUser = true;
        uid = 1000;
        description = "Javier Polo";
        extraGroups = [
          "wheel"         # sudo
          "networkmanager"
          "podman"        # rootless container management
          "video"         # GPU access (Plex transcoding, Immich ML)
          "render"        # GPU rendering nodes
          "dialout"       # serial devices
          "plugdev"       # USB devices
        ];
        openssh.authorizedKeys.keys = [
          # IMPORTANT: Add your SSH public keys here before deploying.
          # You can find them at ~/.ssh/id_ed25519.pub on your client machines.
          # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA..."
        ];
      };

      # Secondary user — minimal, runs gotenberg/pdf services
      sergio = {
        isNormalUser = true;
        uid = 1001;
        description = "Sergio";
        extraGroups = [
          "networkmanager"
          "video"
          "render"
        ];
      };
    };

    # Groups
    groups = {
      podman = { };
    };
  };

  # ---------------------------------------------------------------------------
  # Home Manager Integration
  #
  # Uncomment and populate after creating home-manager modules.
  # Example: create nixos/home/jpolo.nix and import it here.
  # ---------------------------------------------------------------------------
  # home-manager.users.jpolo = import ./home/jpolo.nix;
  # home-manager.users.sergio = import ./home/sergio.nix;
}
