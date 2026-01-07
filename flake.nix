{
  description = "NixOS Omarchy Configuration - Multi-machine development setup";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hyprland ecosystem
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    
    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprsunset = {
      url = "github:hyprwm/hyprsunset";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Nix-index for command-not-found
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Better direnv integration
    nix-direnv = {
      url = "github:nix-community/nix-direnv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Firefox addons
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, hyprland, nix-index-database, firefox-addons, sops-nix, ...}@inputs:
    let
      system = "x86_64-linux";
      
      # Create overlays
      overlays = [
        # Stable packages overlay
        (final: prev: {
          stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        })
        
        # Firefox addons
        firefox-addons.overlays.default
        
        # Custom packages
        (final: prev: import ./overlays { inherit prev final; })
      ];
      
      # Shared modules for all hosts
      sharedModules = [
        # System modules
        ./modules/system
        ./modules/desktop
        ./modules/services
        ./modules/development
        
        # Nix-index database
        nix-index-database.nixosModules.nix-index
        { programs.nix-index-database.comma.enable = true; }
        
        # Secrets management
        sops-nix.nixosModules.sops
        
        # Apply overlays
        { nixpkgs.overlays = overlays; }
        
        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs firefox-addons; };
          home-manager.backupFileExtension = "backup";
        }
      ];
      
    in
    {
      # NixOS Configurations
      nixosConfigurations = {
        # ThinkPad T14s Gen 6 AMD - Primary development machine
        ares = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [
            ./hosts/ares/configuration.nix
            ./hosts/ares/hardware-configuration.nix
            {
              home-manager.users.jpolo = import ./home/jpolo.nix;
            }
          ];
        };
      };
      
      # Development shells
      devShells.${system} = let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        # Python development
        python = pkgs.mkShell {
          name = "python-dev";
          buildInputs = with pkgs; [
            python312
            python312Packages.pip
            python312Packages.virtualenv
            python312Packages.ipython
            python312Packages.jupyter
            python312Packages.molten-nvim
            ruff
            pyright
          ];
        };
        
        # Node.js development  
        node = pkgs.mkShell {
          name = "node-dev";
          buildInputs = with pkgs; [
            nodejs_22
            nodePackages.npm
            nodePackages.yarn
            nodePackages.pnpm
            nodePackages.typescript
            nodePackages.typescript-language-server
          ];
        };
        
        # Rust development
        rust = pkgs.mkShell {
          name = "rust-dev";
          buildInputs = with pkgs; [
            rustc
            cargo
            rustfmt
            rust-analyzer
            clippy
          ];
        };
        
        # Go development
        go = pkgs.mkShell {
          name = "go-dev";
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            go-tools
          ];
        };
      };
      
      # Formatter for `nix fmt`
      formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    };
}
