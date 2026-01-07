# NixOS Configuration Analysis & Recommendations

**Analysis Date**: January 2026  
**Configuration**: nix-omarchy  
**Goal**: Multi-machine deployment with selective module/package installation

---

## Executive Summary

Your current configuration is **well-structured** but lacks **modularity for multi-machine deployment**. Currently, all packages (including Octave) are installed on **every** machine because modules are unconditionally imported in `sharedModules`.

### ✅ What's Already Good

1. **Flake-based setup** - Modern, reproducible
2. **Modular organization** - Separated by concern (system/desktop/development)
3. **Home Manager integration** - User-level configurations
4. **Secrets management** - sops-nix for encrypted secrets
5. **Multiple input sources** - unstable/stable nixpkgs
6. **Well-documented** - Comprehensive README and docs

### 🔴 Critical Issues

1. **No conditional module loading** - Everything installed everywhere
2. **No option system** - Can't enable/disable features per-host
3. **Hardcoded packages** - No toggles for optional software
4. **User packages mixed with system** - Should separate concerns

---

## Recommended Architecture: Profile-Based System

### Power User Approach: NixOS Options + Profiles

This is the **industry standard** for multi-machine NixOS deployments, used by:
- NixOS official modules
- Large NixOS deployments (enterprise, personal fleets)
- Popular community configurations (Misterio77, hlissner, etc.)

### Directory Structure

```
modules/
├── profiles/           # NEW: Profile system
│   ├── default.nix     # Import all profiles
│   ├── base.nix        # Base system (always enabled)
│   ├── desktop.nix     # Desktop environment
│   ├── development.nix # Development tools (with sub-options)
│   ├── gaming.nix      # Gaming setup
│   └── power-user.nix  # Advanced tools (Octave, etc.)
├── system/             # Low-level system modules
├── desktop/            # Desktop components (Hyprland, etc.)
├── development/        # Development implementation
└── services/           # System services
```

### How It Works

**1. Define Options in Profiles**
```nix
# modules/profiles/power-user.nix
options.profiles.power-user = {
  enable = mkEnableOption "power user packages";
  scientific.octave.enable = mkEnableOption "GNU Octave";
};

config = mkIf config.profiles.power-user.scientific.octave.enable {
  environment.systemPackages = [ pkgs.octave ];
};
```

**2. Enable Selectively in Host Configurations**
```nix
# hosts/ares/configuration.nix (laptop - minimal)
profiles = {
  desktop.enable = true;
  development.enable = true;
  power-user = {
    scientific.octave.enable = false;  # Don't install Octave
  };
};

# hosts/workstation/configuration.nix (desktop - full)
profiles = {
  desktop.enable = true;
  development.enable = true;
  gaming.enable = true;
  power-user = {
    scientific.octave.enable = true;   # Install Octave
  };
};
```

---

## Implementation Roadmap

### Phase 1: Create Profile System (1-2 hours)

I've already created the profile system for you:

✅ `modules/profiles/default.nix` - Profile system entry point  
✅ `modules/profiles/base.nix` - Essential packages (always enabled)  
✅ `modules/profiles/desktop.nix` - Desktop environment toggle  
✅ `modules/profiles/development.nix` - Granular dev tool options  
✅ `modules/profiles/gaming.nix` - Gaming profile toggle  
✅ `modules/profiles/power-user.nix` - Advanced tools with Octave option  

Example configurations:
✅ `hosts/ares/configuration-new-example.nix` - Minimal laptop config  
✅ `hosts/workstation-example.nix` - Full-featured desktop config  

### Phase 2: Refactor Existing Modules (2-3 hours)

**Option A: Gradual Migration (Recommended)**
1. Keep current modules as-is
2. Add profile imports alongside in hosts
3. Gradually move packages from modules to profiles
4. Test on each machine

**Option B: Clean Break**
1. Move all package declarations to profiles
2. Keep modules only for configuration (not packages)
3. Update all host configs at once

### Phase 3: Separate User Packages (1 hour)

Move user-specific packages from `home/jpolo.nix` to dedicated modules:

```
home/
├── profiles/
│   ├── base.nix          # Essential user tools
│   ├── creative.nix      # GIMP, Inkscape, etc.
│   ├── communication.nix # Discord, Slack, etc.
│   └── productivity.nix  # Obsidian, LibreOffice, etc.
└── jpolo.nix            # Just imports and toggles
```

---

## Best Practices Recommendations

### 1. **Separation of Concerns**

**Current**: Modules do both configuration AND package installation  
**Better**: Profiles handle packages, modules handle configuration

```nix
# modules/desktop/hyprland.nix (configuration only)
services.hyprland.enable = true;
programs.hyprland.package = pkgs.hyprland;

# profiles/desktop.nix (packages)
environment.systemPackages = [ pkgs.waybar pkgs.wofi ];
```

### 2. **Default Values**

Use sensible defaults to reduce boilerplate:

```nix
# Good: Enable by default for common tools
python.enable = mkEnableOption "Python" // { default = true; };

# Good: Disable by default for specialized tools
octave.enable = mkEnableOption "Octave";  # defaults to false
```

### 3. **Hierarchical Options**

Group related options:

```nix
profiles.development = {
  enable = true;  # Master switch
  languages.python.enable = true;  # Sub-option
  tools.docker.enable = true;      # Sub-option
};
```

### 4. **DRY Principle**

Extract common patterns:

```nix
# BAD: Repetition
environment.systemPackages = [ pkgs.nodejs pkgs.python pkgs.go ];

# GOOD: Conditional lists
environment.systemPackages = with pkgs;
  (optionals config.profiles.development.languages.python.enable [ python ])
  ++ (optionals config.profiles.development.languages.nodejs.enable [ nodejs ]);
```

### 5. **Documentation in Options**

```nix
scientific.octave.enable = mkOption {
  type = types.bool;
  default = false;
  description = ''
    Enable GNU Octave (MATLAB alternative) for numerical computing.
    Includes scientific computing libraries and plotting capabilities.
    Note: Large download (~500MB).
  '';
};
```

---

## Comparison: Current vs. Recommended

### Current Approach

```nix
# flake.nix
sharedModules = [
  ./modules/system      # Everything in here installs everywhere
  ./modules/desktop     # Everything in here installs everywhere
  ./modules/development # Everything in here installs everywhere
];

# hosts/ares/configuration.nix
imports = [ /* all shared modules */ ];
# No way to disable anything!
```

**Problems**:
- ❌ Octave installed on laptop (unused, wasted space)
- ❌ Gaming tools on server (security risk)
- ❌ All languages on all machines (bloat)
- ❌ Can't have different machines with different purposes

### Recommended Approach

```nix
# flake.nix
sharedModules = [
  ./modules/profiles  # Option definitions only
  ./modules/system    # Configuration only
  ./modules/desktop   # Configuration only
];

# hosts/ares/configuration.nix (laptop)
profiles = {
  development.enable = true;
  power-user.scientific.octave.enable = false;  # ✅ No Octave
};

# hosts/workstation/configuration.nix (desktop)
profiles = {
  development.enable = true;
  power-user.scientific.octave.enable = true;   # ✅ Has Octave
};
```

**Benefits**:
- ✅ Explicit control per machine
- ✅ Self-documenting configuration
- ✅ Easy to add new machines
- ✅ Reduced closure size on minimal machines

---

## Migration Strategy

### Step 1: Add Profile System (No Breaking Changes)

```bash
# Profile system is already created in modules/profiles/
# Just add to your flake.nix imports
```

### Step 2: Update One Host as Test

```nix
# hosts/ares/configuration.nix
{
  # Keep old imports
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/desktop
    ../../modules/development
  ];
  
  # Add new profiles (override old)
  profiles = {
    desktop.enable = true;
    development = {
      enable = true;
      languages.python.enable = true;
      languages.rust.enable = false;  # Override!
    };
    power-user.scientific.octave.enable = false;
  };
}
```

### Step 3: Test and Compare

```bash
# Build new config
sudo nixos-rebuild build --flake .#ares

# Compare closure sizes
nix path-info --closure-size /run/current-system
nix path-info --closure-size ./result

# Test the system
sudo nixos-rebuild test --flake .#ares
```

### Step 4: Gradually Migrate Other Hosts

Once satisfied, apply to other machines.

---

## Alternative Approaches (For Reference)

### 1. Home Manager Standalone (Not Recommended for You)

**When to use**: Personal dotfiles across non-NixOS systems  
**Why not for you**: You want system-level control, not just user packages

### 2. Nixus/Colmena/Deploy-rs (Overkill)

**When to use**: 10+ servers, automated deployments  
**Why not for you**: 2-5 machines, manual deployment is fine

### 3. Nix Darwin-style Profiles (macOS approach)

**When to use**: macOS systems  
**Why not for you**: You're on NixOS, use native module system

---

## Advanced Power User Techniques

### 1. **Machine-Specific Home Manager Configs**

```nix
# flake.nix
home-manager.users.jpolo = import (./home + "/${hostname}.nix");

# home/ares.nix (laptop)
{ ... }: {
  home.packages = [ /* minimal packages */ ];
}

# home/workstation.nix (desktop)
{ ... }: {
  home.packages = [ /* all the packages */ ];
}
```

### 2. **Machine Types/Roles**

```nix
# lib/machineTypes.nix
{
  laptop = {
    profiles = {
      development.enable = true;
      gaming.enable = false;
      power-user.enable = false;
    };
  };
  
  workstation = {
    profiles = {
      development.enable = true;
      gaming.enable = true;
      power-user.enable = true;
    };
  };
}

# hosts/ares/configuration.nix
profiles = lib.machineTypes.laptop.profiles;
```

### 3. **Feature Flags**

```nix
# lib/features.nix
features = {
  ml = {  # Machine learning
    packages = [ python pytorch jupyter ];
    services.jupyter.enable = true;
  };
  
  gamedev = {
    packages = [ blender godot ];
  };
};

# hosts/ares/configuration.nix
enabledFeatures = [ "ml" ];  # Not "gamedev"
```

### 4. **Overlay-Based Package Selection**

```nix
# overlays/customPkgs.nix
final: prev: {
  myDevEnv = prev.buildEnv {
    name = "my-dev-env";
    paths = with prev; [
      (if config.profiles.development.languages.python.enable then python312 else null)
      # ... conditional packages
    ];
  };
}
```

### 5. **Inheritance and Composition**

```nix
# profiles/common.nix
{ lib, ... }: {
  profiles.base.enable = true;
  profiles.desktop.enable = true;
}

# hosts/ares/configuration.nix
imports = [ ../../profiles/common.nix ];
profiles.development.enable = true;  # Add to common
```

---

## DevOps Best Practices

### 1. **Declarative Machine Inventory**

```nix
# machines.nix
{
  ares = {
    type = "laptop";
    profiles = ["development" "desktop"];
    features = ["python" "nodejs"];
  };
  
  workstation = {
    type = "desktop";
    profiles = ["development" "desktop" "gaming" "power-user"];
    features = ["all"];
  };
}
```

### 2. **CI/CD Validation**

```bash
# .github/workflows/check.yml
nix flake check  # Verify all configurations build
nix build .#nixosConfigurations.ares.config.system.build.toplevel
```

### 3. **Automated Deployment**

```bash
# scripts/deploy.sh
for host in ares workstation; do
  nixos-rebuild switch --flake .#$host --target-host $host
done
```

### 4. **Rollback Strategy**

```nix
# Keep last 5 generations
nix.gc.automatic = true;
boot.loader.systemd-boot.configurationLimit = 5;
```

---

## Quick Migration Guide

### Option 1: Full Migration (Recommended)

1. **Review created profiles**: Check `modules/profiles/`
2. **Pick a host**: Start with `ares` (your laptop)
3. **Copy example config**: Use `configuration-new-example.nix`
4. **Customize options**: Enable only what you need
5. **Test build**: `sudo nixos-rebuild build --flake .#ares`
6. **Apply**: `sudo nixos-rebuild switch --flake .#ares`
7. **Verify**: Check installed packages, disk usage

### Option 2: Gradual Addition (Safer)

1. **Add profiles alongside**: Keep existing imports
2. **Let profiles override**: Use higher priority
3. **Remove old modules**: One category at a time
4. **Test between each step**: Ensure system works

---

## Expected Benefits

### Disk Space Savings

- **Before**: ~15-20GB closure size (everything installed)
- **After (laptop)**: ~8-12GB (only needed tools)
- **After (workstation)**: ~15-20GB (full installation)

### Maintenance Improvements

- **Clear intent**: Each host config shows exactly what's enabled
- **Easy onboarding**: New machines just toggle options
- **Reduced errors**: Can't accidentally install conflicting packages
- **Faster builds**: Smaller closure = faster evaluation

### Deployment Flexibility

- **Server profiles**: Headless, no desktop, minimal tools
- **Development workstation**: Full stack
- **Laptop**: Portable, battery-optimized, essential only
- **Testing VM**: Isolated, specific features

---

## Additional Resources

### NixOS Module System Docs
- https://nixos.org/manual/nixos/stable/#sec-writing-modules
- https://nixos.wiki/wiki/Module

### Example Configurations
- **Misterio77**: https://github.com/Misterio77/nix-config (multi-machine)
- **hlissner**: https://github.com/hlissner/dotfiles (modular profiles)
- **fufexan**: https://github.com/fufexan/dotfiles (clean profiles)

### Tools
- **nix-diff**: Compare closures between configurations
- **nix-tree**: Visualize dependency trees
- **nixos-option**: Query available options

---

## Conclusion

Your configuration is already **advanced**, but adding the **profile system** will make it **production-grade** and truly multi-machine ready.

### Action Items

1. ✅ **Review created profile files** in `modules/profiles/`
2. ✅ **Server profile added** - 6 server roles with comprehensive options
3. ✅ **Example configurations created** - 4 server examples (web, docker, database, monitoring)
4. ✅ **Documentation updated** - Profile-System.md, Server-Deployment.md, Homelab-Guide.md
5. ⏳ **Test on one machine** using example configs
6. ⏳ **Deploy to homelab** - Proxmox VMs ready to deploy

This approach follows **NixOS best practices** and is used by **power users** and **enterprises** alike. It's the **industry standard** for multi-machine NixOS deployments.

---

## New: Server Profile

The server profile has been added with:
- ✅ 6 server roles (general, web, database, docker, storage, monitoring)
- ✅ Headless configuration (no GUI, minimal overhead)
- ✅ 40+ service options (SSH, Nginx, PostgreSQL, Redis, Docker, Prometheus, Grafana, Loki)
- ✅ Security hardening (Fail2ban, AppArmor, SSH hardening)
- ✅ Auto-optimization (BBR TCP, kernel tuning, garbage collection)
- ✅ Proxmox-ready examples (4 complete server configurations)

See:
- `modules/profiles/server.nix` - Server profile implementation
- `hosts/*-server-example.nix` - Example server configurations
- `docs/Server-Deployment.md` - Deployment guide
- `docs/Homelab-Guide.md` - Multi-server architecture

---

**Questions or need help migrating? Let me know!**
