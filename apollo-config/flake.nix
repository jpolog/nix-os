{
  description = "apollo — NixOS home server configuration";

  inputs = {
    # Stable nixpkgs as the primary source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Unstable for packages that need fresher versions (immich, ollama, etc.)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Hardware quirks for Intel N100 Alder Lake-N
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Home Manager for user-level dotfiles
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko for declarative disk partitioning (optional, for future use)
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, disko, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";

      # Overlay to pull specific packages from unstable
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations.apollo = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # Overlay for unstable packages
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ unstableOverlay ];
          })

          # Hardware support for Intel N100
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-gpu-intel

          # Secrets management via sops-nix
          sops-nix.nixosModules.sops

          # Our category modules
          ./default.nix
          ./networking.nix
          ./storage.nix
          ./databases.nix
          ./users.nix
          ./media.nix
          ./productivity.nix
          ./monitoring.nix
          ./development.nix

          # Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # User configs are referenced in users.nix
            };
          }
        ];
      };
    };
}
