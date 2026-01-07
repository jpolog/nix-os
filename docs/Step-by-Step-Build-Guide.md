# Step-by-Step Build Guide

**For**: Complete beginners to NixOS and this configuration  
**Goal**: Build the system incrementally, understanding each component  
**Time**: 2-4 hours for full installation

---

## 📚 Prerequisites

Before starting, you should:
1. Have NixOS installed (minimal installation is fine)
2. Be able to SSH or access a terminal
3. Have basic Linux command-line knowledge
4. Understand what a text editor is (we'll use `vim` or `nano`)

**What you'll learn**:
- NixOS declarative configuration
- Flakes system
- Profile-based architecture
- Home Manager for user configuration
- How to debug and test changes safely

---

## 🎯 Overview: What We're Building

This configuration has **two main layers**:

### Layer 1: NixOS System Configuration (Root-level)
- **Boot**loader, kernel, drivers
- **System services** (networking, audio, Bluetooth)
- **System packages** (available to all users)
- **Desktop environment** (Hyprland)

### Layer 2: Home Manager User Configuration
- **User packages** (installed in user's home)
- **Program configurations** (Firefox, Git, Neovim)
- **Shell setup** (ZSH, aliases, functions)
- **Desktop customization** (Waybar, themes)

We'll build this **step by step**, testing each component before moving to the next.

---

## 📋 Phase 0: Preparation (30 minutes)

### Step 0.1: Backup Current System

```bash
# If you already have a configuration, back it up
sudo cp -r /etc/nixos /etc/nixos.backup.$(date +%Y%m%d)

# Check what's currently installed
nix-env -q
```

### Step 0.2: Clone This Repository

```bash
# Create projects directory
mkdir -p ~/Projects
cd ~/Projects

# Clone the configuration
git clone https://github.com/yourusername/nix-omarchy.git
cd nix-omarchy/nix

# Or if you're working with an existing setup
cd /path/to/nix-omarchy/nix
```

### Step 0.3: Understand the Structure

```bash
# View the directory structure
tree -L 2 -d

# Expected output:
# .
# ├── docs/            # Documentation (you're reading this!)
# ├── home/            # Home Manager configuration
# │   ├── profiles/    # User-level profiles
# │   ├── programs/    # Program configurations
# │   └── users/       # User definitions
# ├── hosts/           # Per-machine configurations
# │   └── ares/        # Example: ThinkPad laptop
# ├── modules/         # NixOS system modules
# │   ├── profiles/    # System-level profiles
# │   ├── system/      # Core system config
# │   ├── desktop/     # Desktop environment
# │   └── development/ # Development tools
# ├── scripts/         # Helper scripts
# └── flake.nix        # Main configuration entry point
```

### Step 0.4: Generate Your Hardware Configuration

```bash
# Generate hardware configuration for your machine
sudo nixos-generate-config --show-hardware-config > /tmp/hardware-configuration.nix

# Review it
cat /tmp/hardware-configuration.nix

# This will be used later
```

---

## 📋 Phase 1: Minimal NixOS Build (30 minutes)

**Goal**: Get a bootable NixOS system with just the essentials.

### Step 1.1: Create Your Host Configuration

```bash
# Create your host directory (replace 'mymachine' with your hostname)
mkdir -p hosts/mymachine

# Copy the hardware configuration
sudo cp /tmp/hardware-configuration.nix hosts/mymachine/
```

### Step 1.2: Create Minimal configuration.nix

```bash
# Create a minimal configuration
cat > hosts/mymachine/configuration.nix << 'EOF'
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # === BASIC SYSTEM SETTINGS ===
  
  # Hostname
  networking.hostName = "mymachine";  # Change this!
  
  # Timezone
  time.timeZone = "Europe/Madrid";  # Change to your timezone
  
  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Networking
  networking.networkmanager.enable = true;
  
  # User account
  users.users.myuser = {  # Change 'myuser' to your username
    isNormalUser = true;
    description = "My User";  # Your name
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";  # CHANGE THIS AFTER FIRST BOOT!
  };
  
  # Enable SSH (optional, useful for remote access)
  services.openssh.enable = true;
  
  # Allow unfree packages (needed for some software)
  nixpkgs.config.allowUnfree = true;
  
  # Essential packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  
  # NixOS version
  system.stateVersion = "24.11";  # Match your NixOS version
}
EOF

# Review the file
cat hosts/mymachine/configuration.nix
```

### Step 1.3: Create Minimal Flake

```bash
# Create a minimal flake.nix
cat > flake.nix << 'EOF'
{
  description = "My NixOS Configuration - Step by Step";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";  # Stable
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      mymachine = nixpkgs.lib.nixosSystem {  # Match your hostname
        system = "x86_64-linux";
        modules = [
          ./hosts/mymachine/configuration.nix
        ];
      };
    };
  };
}
EOF

# Review the flake
cat flake.nix
```

### Step 1.4: Test Build

```bash
# Build the configuration (doesn't activate it yet)
sudo nixos-rebuild build --flake .#mymachine

# If successful, you'll see:
# "building the system configuration..."
# "these X derivations will be built:"
# ...
# A symlink './result' is created

# Check the result
ls -l result
```

**Troubleshooting**:
- **Error: "flake.nix not found"** → Make sure you're in the right directory
- **Error: "experimental feature 'flakes' is not enabled"** → Enable flakes (see below)
- **Build errors** → Read the error message, check syntax in your `.nix` files

**Enable Flakes** (if needed):
```bash
# Edit /etc/nixos/configuration.nix and add:
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Then rebuild:
sudo nixos-rebuild switch

# Now try again
```

### Step 1.5: Test Without Applying

```bash
# Test the configuration in a VM (safe, doesn't change your system)
nixos-rebuild build-vm --flake .#mymachine

# This creates a VM image you can boot for testing
# (Advanced: if you want to test in VM)
```

### Step 1.6: Apply Minimal Configuration

```bash
# Apply the configuration to your system
sudo nixos-rebuild switch --flake .#mymachine

# This will:
# - Install the new configuration
# - Update your bootloader
# - Switch to the new system immediately

# If something goes wrong, you can still boot the old configuration
# from the bootloader menu
```

### Step 1.7: Verify

```bash
# Reboot to test
sudo reboot

# After reboot, verify:
hostname  # Should show 'mymachine'
which vim
which git

# Login with your user
# Password is 'changeme' (change it immediately!)
passwd  # Set a real password
```

**✅ Checkpoint**: You now have a minimal, bootable NixOS system!

---

## 📋 Phase 2: Add Nix Flakes & Base Profile (30 minutes)

**Goal**: Enable flakes properly and add the base system profile.

### Step 2.1: Enable Flakes in Configuration

Edit `hosts/mymachine/configuration.nix`:

```bash
vim hosts/mymachine/configuration.nix

# Add after "nixpkgs.config.allowUnfree":
  # Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;  # Save disk space
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
```

### Step 2.2: Add Base Profile

Edit `hosts/mymachine/configuration.nix`:

```bash
# Change the imports section:
  imports = [
    ./hardware-configuration.nix
    ../../modules/profiles  # Add this line
  ];

# Add after system.stateVersion:
  # Enable base profile
  profiles.base.enable = true;
```

### Step 2.3: Update Flake to Use Unstable

Edit `flake.nix`:

```bash
vim flake.nix

# Change inputs to:
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";  # Latest packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
  };

# Add overlays in outputs (after modules):
        modules = [
          ./hosts/mymachine/configuration.nix
          
          # Add stable packages overlay
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [
              (final: prev: {
                stable = import nixpkgs-stable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              })
            ];
          })
        ];
```

### Step 2.4: Build and Test

```bash
# Update flake inputs
nix flake update

# Build
sudo nixos-rebuild build --flake .#mymachine

# If successful, apply
sudo nixos-rebuild switch --flake .#mymachine

# Verify base profile packages are installed
which eza bat ripgrep fd btop

# Check nix store optimization
nix-store --optimise --dry-run
```

**✅ Checkpoint**: You now have flakes enabled and the base profile active!

---

## 📋 Phase 3: Add Desktop Environment (45 minutes)

**Goal**: Install Hyprland desktop with Waybar, SDDM, and essential desktop tools.

### Step 3.1: Update Flake with Hyprland

Edit `flake.nix`:

```nix
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    
    # Add Hyprland
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, hyprland, ... }@inputs: {
    nixosConfigurations.mymachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };  # Pass inputs to modules
      modules = [
        ./hosts/mymachine/configuration.nix
        # ... rest of modules
      ];
    };
  };
```

### Step 3.2: Enable Desktop Profile

Edit `hosts/mymachine/configuration.nix`:

```nix
{ config, pkgs, inputs, ... }:  # Add 'inputs' here

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/profiles
    ../../modules/desktop  # Add desktop modules
  ];

  # Enable desktop profile
  profiles.base.enable = true;
  profiles.desktop.enable = true;  # Add this

  # ... rest of config
}
```

### Step 3.3: Build Desktop

```bash
# Update flake lock
nix flake update

# Build (this will download a lot of packages)
sudo nixos-rebuild build --flake .#mymachine

# Check what will be installed
nix path-info --closure-size ./result

# If successful (and you have ~10-15GB available), apply
sudo nixos-rebuild switch --flake .#mymachine
```

### Step 3.4: Reboot and Test Desktop

```bash
sudo reboot

# After reboot, you should see SDDM login screen
# Login with your user

# Verify Hyprland is running
echo $XDG_CURRENT_DESKTOP  # Should show 'Hyprland'

# Test Hyprland keybindings
# SUPER + Q = Open terminal
# SUPER + E = Open file manager
# SUPER + R = Open application launcher
```

**Troubleshooting**:
- **Black screen after login** → Check logs: `journalctl -b -u display-manager`
- **Hyprland won't start** → Try: `Hyprland` from TTY (Ctrl+Alt+F2)
- **Missing modules error** → Make sure `modules/desktop` exists

**✅ Checkpoint**: You now have a working Hyprland desktop!

---

## 📋 Phase 4: Add Home Manager (45 minutes)

**Goal**: Add user-level configuration with Home Manager.

### Step 4.1: Add Home Manager Input

Edit `flake.nix`:

```nix
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # ... other inputs ...
    
    # Add Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs: {
    nixosConfigurations.mymachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/mymachine/configuration.nix
        
        # Add Home Manager module
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
          };
        }
        
        # ... overlays ...
      ];
    };
  };
```

### Step 4.2: Create Your User Configuration

```bash
# Option A: Use the pre-made user system (recommended)
# Edit home/users/default.nix and customize 'jpolo' user to your username

# Option B: Create a simple user config from scratch
mkdir -p home/users
cat > home/users/myuser.nix << 'EOF'
{ config, pkgs, ... }:

{
  # Import profiles
  imports = [
    ../profiles
  ];

  # User identity
  home = {
    username = "myuser";  # Change to your username
    homeDirectory = "/home/myuser";
    stateVersion = "24.11";
  };

  # Enable base profile
  home.profiles.base.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
}
EOF
```

### Step 4.3: Link User to Host

Edit `hosts/mymachine/configuration.nix`:

```nix
{
  # ... existing config ...

  # Add at the end (or in the flake):
  home-manager.users.myuser = import ../../home/users/myuser.nix;
}
```

OR in `flake.nix` (cleaner):

```nix
  home-manager.nixosModules.home-manager
  {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      users.myuser = import ./home/users/myuser.nix;  # Add this
    };
  }
```

### Step 4.4: Build with Home Manager

```bash
# Update flake
nix flake update

# Build
sudo nixos-rebuild build --flake .#mymachine

# Apply
sudo nixos-rebuild switch --flake .#mymachine

# Verify home-manager packages
ls ~/.nix-profile/bin/
```

**✅ Checkpoint**: Home Manager is now active for your user!

---

## 📋 Phase 5: Add Development Tools (30 minutes)

**Goal**: Enable development profile with your preferred languages.

### Step 5.1: Enable Development Profile (System-Level)

Edit `hosts/mymachine/configuration.nix`:

```nix
  profiles = {
    base.enable = true;
    desktop.enable = true;
    development = {  # Add this
      enable = true;
      languages = {
        python.enable = true;   # Enable Python
        nodejs.enable = true;   # Enable Node.js
        # rust.enable = true;   # Optional
        # go.enable = true;     # Optional
      };
      tools = {
        docker.enable = true;   # Enable Docker
      };
    };
  };
```

### Step 5.2: Enable Development Profile (User-Level)

Edit `home/users/myuser.nix`:

```nix
  # Enable profiles
  home.profiles = {
    base.enable = true;
    development = {  # Add this
      enable = true;
      editors = {
        vscode.enable = true;  # Optional: VS Code
        neovim.enable = true;   # LazyVim
      };
    };
  };
```

### Step 5.3: Build and Test

```bash
# Build
sudo nixos-rebuild build --flake .#mymachine

# Apply
sudo nixos-rebuild switch --flake .#mymachine

# Verify tools
python --version
node --version
docker --version
nvim --version

# Test development shell
nix develop  # If you have devShells defined
```

**✅ Checkpoint**: Development environment is ready!

---

## 📋 Phase 6: Add Personal Apps (20 minutes)

**Goal**: Install personal applications like Discord, Spotify, etc.

### Step 6.1: Enable Personal Profile

Edit `home/users/myuser.nix`:

```nix
  home.profiles = {
    base.enable = true;
    desktop.enable = true;  # Add if not present
    development.enable = true;
    personal = {  # Add this
      enable = true;
      communication.enable = true;  # Discord, Slack, Telegram
      media.enable = true;           # Spotify, VLC
      productivity.enable = true;    # Taskwarrior, etc.
    };
  };
```

### Step 6.2: Build and Test

```bash
# Build and apply
sudo nixos-rebuild switch --flake .#mymachine

# Verify apps are installed
which discord
which spotify
ls ~/.nix-profile/bin/ | grep -E 'discord|spotify|telegram'
```

**✅ Checkpoint**: Personal apps are installed!

---

## 📋 Phase 7: Optimize and Finalize (20 minutes)

**Goal**: Add optimizations, secrets, and final touches.

### Step 7.1: Add System Optimizations

Edit `hosts/mymachine/configuration.nix`:

```nix
  # Add after nix settings:
  boot.kernel.sysctl = {
    # Better network performance
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # ZRAM (compressed RAM)
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Better font rendering
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };
```

### Step 7.2: Add Scripts

```bash
# Scripts are already included in the repo
# Verify they're accessible
ls scripts/

# Test a script
./scripts/system/update-system
```

### Step 7.3: Set Up Secrets (Optional)

If you need to manage secrets (WiFi passwords, SSH keys, etc.):

```bash
# Install sops
nix-shell -p sops age

# Generate age key
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# Read your public key
cat ~/.config/sops/age/keys.txt | grep "public key:"

# See docs/Secrets-Management.md for full guide
```

### Step 7.4: Final Build

```bash
# Final build with all optimizations
sudo nixos-rebuild build --flake .#mymachine

# Apply
sudo nixos-rebuild switch --flake .#mymachine

# Clean old generations
sudo nix-collect-garbage -d

# Optimize store
nix-store --optimise
```

**✅ Checkpoint**: System is fully optimized!

---

## 📋 Testing & Debugging

### Test Before Applying

```bash
# 1. Build only (doesn't change system)
sudo nixos-rebuild build --flake .#mymachine

# 2. Test (applies temporarily, reverts on reboot)
sudo nixos-rebuild test --flake .#mymachine

# 3. Boot (applies to next boot, current system unchanged)
sudo nixos-rebuild boot --flake .#mymachine

# 4. Switch (applies immediately and to next boot)
sudo nixos-rebuild switch --flake .#mymachine
```

### Debugging Build Errors

```bash
# Show full error trace
sudo nixos-rebuild build --flake .#mymachine --show-trace

# Check syntax
nix flake check

# Evaluate without building
nix eval .#nixosConfigurations.mymachine.config.system.build.toplevel
```

### Rollback if Something Breaks

```bash
# Method 1: From bootloader
# Reboot, select previous generation from menu

# Method 2: From command line
sudo nixos-rebuild --rollback switch

# Method 3: List and switch to specific generation
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nix-env --switch-generation 42 --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

### Common Errors

**"Infinite recursion"**:
```bash
# Usually caused by circular imports
# Check your imports in .nix files
# Use --show-trace to see where
```

**"Attribute X does not exist"**:
```bash
# Typo in option name or missing import
# Check spelling and that module is imported
```

**"Collision between X and Y"**:
```bash
# Same package installed in multiple places
# Check both system and home-manager packages
```

---

## 📋 Next Steps

Now that you have a working system, you can:

1. **Customize Hyprland**
   - See `docs/Desktop-Environment.md`
   - Edit `home/hyprland/hyprland.conf`

2. **Add More Languages**
   - Edit `profiles.development.languages` in your config
   - Rebuild and test

3. **Explore Scripts**
   - See `docs/Scripts.md`
   - Scripts are in `scripts/` directory

4. **Set Up Multiple Machines**
   - Copy `hosts/mymachine` to `hosts/another-machine`
   - Adjust profiles per machine
   - Build with different flake outputs

5. **Deploy Servers**
   - See `docs/Server-Deployment.md`
   - Use server profile for headless machines

6. **Learn More**
   - `docs/Profile-System.md` - Understanding profiles
   - `docs/NixOS-Basics.md` - Learn Nix language
   - `docs/Troubleshooting.md` - Fix common issues

---

## 📝 Summary

You've built your NixOS system in these phases:

1. ✅ **Phase 0**: Prepared environment
2. ✅ **Phase 1**: Minimal bootable system
3. ✅ **Phase 2**: Flakes + base profile
4. ✅ **Phase 3**: Desktop environment (Hyprland)
5. ✅ **Phase 4**: Home Manager for user config
6. ✅ **Phase 5**: Development tools
7. ✅ **Phase 6**: Personal applications
8. ✅ **Phase 7**: Optimizations and finalization

**Key Concepts Learned**:
- Declarative configuration
- NixOS profiles (system-level)
- Home Manager profiles (user-level)
- Flakes system
- Testing before applying
- Rollback on errors

**Configuration Structure**:
```
System (NixOS)
├── Base Profile
├── Desktop Profile
└── Development Profile

User (Home Manager)
├── Base Profile
├── Desktop Profile
├── Development Profile
└── Personal Profile
```

---

## 🎓 Understanding What You Built

### Two-Layer Architecture

**NixOS (System Layer)**:
- Installed in `/nix/store/`
- Available to all users
- Requires `sudo` to modify
- Examples: kernel, drivers, system services

**Home Manager (User Layer)**:
- Installed in `~/.nix-profile/`
- Per-user configuration
- No `sudo` needed
- Examples: user apps, dotfiles, shell config

### Profile System

Think of profiles as **feature bundles**:

```
Want Python? → Enable development.languages.python
Want Discord? → Enable personal.communication
Want Octave? → Enable power-user.scientific.octave
```

### Declarative vs Imperative

**Imperative** (old way):
```bash
sudo apt install firefox
sudo apt install git
# System state is unknown
```

**Declarative** (NixOS way):
```nix
profiles.desktop.enable = true;
# System state is defined in config
# Reproducible anywhere
```

---

## 🆘 Getting Help

- **Documentation**: `docs/` directory
- **Troubleshooting**: `docs/Troubleshooting.md`
- **Community**: NixOS Discourse, Reddit r/NixOS
- **Issues**: GitHub issues in your repository

---

**Congratulations!** You've successfully built a complete NixOS system step by step! 🎉

Each phase can be repeated, modified, or extended as you learn more about NixOS.
