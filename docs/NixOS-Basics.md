---
title: NixOS Basics
tags: [nixos, basics, learning, tutorial]
created: 2026-01-06
related: [[README]], [[Nix-Flakes]], [[Configuration-Tips]]
---

# NixOS Basics

Essential NixOS concepts and commands for this configuration.

## 🎯 Core Concepts

### Declarative Configuration

NixOS is **declarative** - you describe what you want, not how to get there.

**Traditional Linux**:
```bash
sudo apt install firefox
sudo systemctl enable sshd
```

**NixOS**:
```nix
environment.systemPackages = [ pkgs.firefox ];
services.openssh.enable = true;
```

### Reproducibility

Same configuration = Same result, every time.

- Configuration files define entire system
- No hidden state
- Easy to share and replicate

### Atomic Updates

Changes are atomic - either fully applied or not at all.

- No broken intermediate states
- Always bootable
- Easy rollback

### Generations

Every rebuild creates a new "generation".

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback
sudo nixos-rebuild switch --rollback

# Switch to specific generation
sudo nixos-rebuild switch --switch-generation 42
```

## 📦 The Nix Store

### What is `/nix/store`?

Immutable store for all packages and dependencies.

```
/nix/store/
├── abc123-firefox-120.0/
├── def456-glibc-2.38/
├── ghi789-bash-5.2/
└── ...
```

Each package has a unique hash based on its inputs.

### Why Immutable?

- Multiple versions coexist
- Dependencies never conflict
- Atomic updates
- Reproducible builds

## 🔧 Common Commands

### System Management

```bash
# Rebuild and switch
sudo nixos-rebuild switch --flake .#ares

# Build without switching
sudo nixos-rebuild build --flake .#ares

# Test (reverts on reboot)
sudo nixos-rebuild test --flake .#ares

# Boot (switch on next boot)
sudo nixos-rebuild boot --flake .#ares

# Rollback
sudo nixos-rebuild switch --rollback
```

### Package Management

```bash
# Search packages
nix search nixpkgs firefox

# Try package temporarily
nix-shell -p firefox

# Check package info
nix-env -qaP firefox

# List installed (system)
nix-env -q --profile /nix/var/nix/profiles/system
```

### Garbage Collection

```bash
# Delete old generations
sudo nix-collect-garbage -d

# User garbage collection
nix-collect-garbage -d

# Delete generations older than 7 days
sudo nix-collect-garbage --delete-older-than 7d
```

### Store Optimization

```bash
# Optimize store (deduplicate)
nix-store --optimise

# Check what depends on package
nix-store --query --referrers /nix/store/...

# Why is package installed?
nix-store --query --roots /nix/store/...
```

## 📁 Configuration Structure

### System Configuration

```
/etc/nixos/
├── configuration.nix   # Main config
├── hardware-configuration.nix
└── ...
```

**In this setup** (flake-based):
```
~/Projects/nix-omarchy/nix/
├── flake.nix           # Flake definition
├── hosts/ares/
│   ├── configuration.nix
│   └── hardware-configuration.nix
└── modules/
```

### Module System

NixOS uses modules to organize configuration.

**Module structure**:
```nix
{ config, pkgs, ... }:

{
  imports = [ ./other-module.nix ];
  
  options = {
    # Define options
  };
  
  config = {
    # Configuration
  };
}
```

**Simplified** (most common):
```nix
{ config, pkgs, ... }:

{
  # Your configuration
  services.ssh.enable = true;
}
```

## 🎨 Nix Language Basics

### Data Types

```nix
# String
name = "value";

# Integer
port = 8080;

# Boolean
enable = true;

# List
packages = [ pkgs.vim pkgs.git ];

# Attribute set (like dictionary)
user = {
  name = "jpolo";
  uid = 1000;
};
```

### Functions

```nix
# Simple function
double = x: x * 2;

# Function with attribute set argument
mkUser = { name, uid }: {
  users.users.${name} = {
    inherit uid;
    isNormalUser = true;
  };
};
```

### Common Patterns

```nix
# with - bring attributes into scope
with pkgs; [ vim git firefox ]

# inherit - copy variable
let user = "jpolo"; in
{ inherit user; }
# Same as: { user = user; }

# let...in - define local variables
let
  version = "1.0";
  name = "myapp";
in
  "${name}-${version}"
```

## 🔄 Overlays

Modify or add packages to nixpkgs.

```nix
nixpkgs.overlays = [
  (final: prev: {
    # Override package
    mypackage = prev.mypackage.override {
      enable = true;
    };
    
    # Add new package
    customPkg = final.callPackage ./custom-pkg.nix {};
  })
];
```

## 🏗️ Options System

### Using Options

```nix
# Simple option
services.openssh.enable = true;

# Nested options
services.openssh.settings = {
  PermitRootLogin = "no";
  PasswordAuthentication = true;
};
```

### Finding Options

```bash
# Search options
man configuration.nix

# Online
https://search.nixos.org/options
```

### In this config

Use modular structure:
```nix
# modules/system/ssh.nix
{ config, pkgs, ... }:
{
  services.openssh.enable = true;
}
```

## 🎯 Best Practices

### 1. Modular Configuration

Split configuration into logical modules:
```
modules/
├── system/
│   ├── audio.nix
│   ├── network.nix
│   └── ...
└── desktop/
    ├── hyprland.nix
    └── ...
```

### 2. Use Home Manager

User-level configuration separate from system:
```nix
# System: /etc/nixos/
# User: ~/.config/home-manager/
```

### 3. Version Control

```bash
git init
git add .
git commit -m "Initial configuration"
```

### 4. Comment Your Code

```nix
# This enables the SSH daemon
services.openssh.enable = true;
```

### 5. Test Before Deploying

```bash
# Build first
sudo nixos-rebuild build --flake .#ares

# Then switch
sudo nixos-rebuild switch --flake .#ares
```

## 🐛 Debugging

### Check Syntax

```bash
# Check flake
nix flake check

# Evaluate expression
nix-instantiate --eval '<nixpkgs>' -A version
```

### Build Traces

```bash
# Show trace
sudo nixos-rebuild switch --show-trace

# Verbose
sudo nixos-rebuild switch -v
```

### Inspect Derivations

```bash
# Show derivation
nix show-derivation /nix/store/...

# Build log
nix log /nix/store/...
```

## 📚 Learning Resources

### Official Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)

### Community

- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)
- [r/NixOS](https://reddit.com/r/nixos)

### Search Tools

- [search.nixos.org](https://search.nixos.org/) - Packages & options
- [home-manager options](https://nix-community.github.io/home-manager/options.html)

## 🎓 Quick Reference

### File Locations

| Item | Location |
|------|----------|
| System config | `/etc/nixos/` or flake dir |
| Nix store | `/nix/store/` |
| User profile | `~/.nix-profile/` |
| System profile | `/run/current-system/` |
| Generations | `/nix/var/nix/profiles/` |

### Important Options

```nix
# Enable flakes
nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Allow unfree
nixpkgs.config.allowUnfree = true;

# System packages
environment.systemPackages = with pkgs; [ ... ];

# Users
users.users.username = { ... };

# Services
services.servicename.enable = true;
```

## 💡 Tips

1. **Start small**: Make one change at a time
2. **Use search**: search.nixos.org is your friend
3. **Read others' configs**: GitHub has many examples
4. **Don't fear rollback**: You can always go back
5. **Join community**: Discourse and Reddit are helpful

## 📚 Related Documentation

- [[Nix-Flakes]] - Flakes in detail
- [[Home-Manager]] - Home Manager guide
- [[Configuration-Tips]] - Advanced tips
- [[Troubleshooting]] - Fix common issues

---

**Last Updated**: 2026-01-06
