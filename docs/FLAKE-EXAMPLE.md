# Improved flake.nix (Example with Multi-User Home Manager)

```nix
{
  description = "NixOS Omarchy - Portable Multi-User Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # ... other inputs ...
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # Import user definitions
      homeUsers = import ./home/users;
      
      # Shared NixOS modules
      sharedModules = [
        # NixOS profiles (system-level)
        ./modules/profiles
        
        # Home Manager integration
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            backupFileExtension = "backup";
          };
        }
        
        # ... other shared modules ...
      ];
      
    in
    {
      nixosConfigurations = {
        # Personal Laptop (ares) - Single user
        ares = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [
            ./hosts/ares/configuration.nix
            {
              # NixOS profiles (system-level)
              profiles = {
                base.enable = true;
                desktop.enable = true;
                development.enable = true;
                power-user.enable = true;
              };
              
              # Home Manager users (user-level)
              home-manager.users = {
                jpolo = homeUsers.jpolo;
              };
            }
          ];
        };
        
        # Workstation - Multi-user
        workstation = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [
            ./hosts/workstation/configuration.nix
            {
              # NixOS profiles
              profiles = {
                base.enable = true;
                desktop.enable = true;
                development.enable = true;
                gaming.enable = true;
                power-user.enable = true;
              };
              
              # Multiple users
              home-manager.users = {
                jpolo = homeUsers.jpolo;
                workuser = homeUsers.workuser;
              };
            }
          ];
        };
        
        # Web Server - Admin user only, no desktop
        web-server = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = sharedModules ++ [
            ./hosts/web-server/configuration.nix
            {
              # NixOS profiles (server)
              profiles = {
                base.enable = true;
                server = {
                  enable = true;
                  role = "web";
                  services.webserver.enable = true;
                };
              };
              
              # Admin user (no desktop)
              home-manager.users = {
                admin = homeUsers.admin;
              };
            }
          ];
        };
      };
    };
}
```

---

## Key Improvements

### 1. User Abstraction

```nix
# Before
home-manager.users.jpolo = import ./home/jpolo.nix;  # Hard-coded

# After
homeUsers = import ./home/users;  # Import user factory
home-manager.users.jpolo = homeUsers.jpolo;  # Select from factory
```

### 2. Multi-User Support

```nix
# Easy to add multiple users
home-manager.users = {
  jpolo = homeUsers.jpolo;
  workuser = homeUsers.workuser;
  admin = homeUsers.admin;
};
```

### 3. Profile-Based Configuration

```nix
# NixOS profiles (system-level)
profiles.desktop.enable = true;

# Home Manager profiles (user-level)
# Configured in home/users/default.nix per user
homeUsers.jpolo  # Has desktop profile enabled
homeUsers.admin  # Has desktop profile disabled
```

### 4. Per-Host Customization

```nix
# Laptop: Minimal jpolo
ares = {
  home-manager.users.jpolo = homeUsers.jpolo;
};

# Workstation: Full jpolo + extra user
workstation = {
  home-manager.users = {
    jpolo = homeUsers.jpolo;  # Same user, different machine!
    workuser = homeUsers.workuser;
  };
};
```

---

## Usage

1. **Add user** in `home/users/default.nix`
2. **Select user** in flake per-host
3. **Create system user** in host configuration
4. **Deploy**

```bash
sudo nixos-rebuild switch --flake .#ares
```

Done! User gets their configuration automatically.

---

## Benefits

- ✅ **DRY**: Define user once, use anywhere
- ✅ **Portable**: User config works on any machine
- ✅ **Multi-user**: Easy to add/remove users
- ✅ **Modular**: Profile-based selections
- ✅ **Type-safe**: NixOS options system
- ✅ **Maintainable**: Clear structure

---

See `HOME-MANAGER-IMPLEMENTATION.md` for complete guide.
