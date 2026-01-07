# Documentation Index

Welcome to the **nix-omarchy** documentation!

---

## 🚀 Getting Started (Start Here!)

### For Complete Beginners

1. **[Step-by-Step Build Guide](Step-by-Step-Build-Guide.md)** ⭐ **ABSOLUTE BEGINNERS START HERE**
   - Build the system incrementally from scratch
   - Understand each component before adding the next
   - Test and debug at each phase
   - Complete walkthrough (2-4 hours)

2. **[Quick Start](Quick-Start.md)** - For those with NixOS experience
   - Install and deploy in 15 minutes
   - Basic configuration
   - Fast track to working system

3. **[Installation](Installation.md)** - Detailed installation
   - Hardware-specific guides
   - Post-installation setup
   - Partitioning and boot options

### Understanding the System

4. **[Profile System](Profile-System.md)** ⭐ **ESSENTIAL READING**
   - Understanding profiles (base, desktop, development, server, etc.)
   - How to configure machines
   - Examples for different use cases
   - NixOS profiles (system-level) explained

5. **[Home Manager Guide](HOME-MANAGER-IMPLEMENTATION.md)** ⭐ **USER CONFIGURATION**
   - Home Manager profiles (user-level) explained
   - Multi-user support
   - User abstraction and portability
   - Adding and managing users

6. **[NixOS Basics](NixOS-Basics.md)**
   - Nix language fundamentals
   - Module system
   - Flakes
   - How NixOS works

### For Specific Use Cases

- **Desktop/Laptop Users**: [Desktop Environment](Desktop-Environment.md)
- **Server Admins**: [Server Deployment](Server-Deployment.md)
- **Homelab Enthusiasts**: [Homelab Guide](Homelab-Guide.md)
- **Developers**: [Development Profile](Profile-System.md#development-profile)
- **Gamers**: [Gaming Profile](Gaming-Profile.md)
- **Power Users**: [Power User Guide](Power-User-Guide.md)

---

## 📖 Core Documentation

### Configuration Architecture

- **[Profile System](Profile-System.md)** ⭐
  - **NixOS Profiles** (system-level): 6 profiles for system configuration
  - **Home Manager Profiles** (user-level): 5 profiles for user packages
  - How they work together
  - Granular options for each profile
  - Example configurations
  - Best practices

- **[Home Manager Implementation](HOME-MANAGER-IMPLEMENTATION.md)** ⭐
  - Complete guide to user-level configuration
  - Multi-user support (add users in 3 steps)
  - Portable user configurations
  - Profile-based package selection
  - User abstraction layer
  - See also: [Home Manager Analysis](HOME-MANAGER-ANALYSIS.md) for architecture details

- **[System Configuration](System-Configuration.md)**
  - Audio, Bluetooth, networking
  - Power management
  - Security settings
  - Kernel optimization

- **[Customization](Customization.md)**
  - Colors & themes
  - Keybindings
  - Adding packages
  - Creating custom modules

### Deployment

- **[Server Deployment](Server-Deployment.md)** 🖥️
  - Headless server setup
  - Server roles (web, database, docker, monitoring)
  - Security hardening
  - Proxmox integration
  - Backup strategies

- **[Homelab Guide](Homelab-Guide.md)** 🏠
  - Multi-server architecture
  - Network design
  - Service orchestration
  - Monitoring setup
  - Example infrastructure

### Desktop Environment

- **[Desktop Environment](Desktop-Environment.md)**
  - Hyprland configuration
  - Waybar, SDDM, themes
  - Window management
  - Launcher, notifications

- **[Keybindings](Keybindings.md)**
  - Hyprland shortcuts
  - Terminal bindings
  - VI mode keys
  - Custom functions

---

## 🛠️ Usage Guides

### Daily Operations

- **[Quick Start](Quick-Start.md)**
  - System management commands
  - Development workflows
  - Shell features

- **[Scripts](Scripts.md)**
  - Script system overview
  - update, cleanup, check, backup
  - Development scripts
  - Port management

### Advanced Features

- **[Gaming Profile](Gaming-Profile.md)**
  - Isolated gaming user
  - Steam + Proton setup
  - Security sandboxing
  - GameMode optimization

- **[Power User Guide](Power-User-Guide.md)**
  - Scientific computing (Octave, Jupyter)
  - Creative tools (GIMP, Blender, Kdenlive)
  - Advanced terminal tools
  - Network analysis

- **[Virtualization Guide](Virtualization-Guide.md)**
  - virt-manager setup
  - VM quick reference
  - Docker/Podman
  - Proxmox integration

---

## 🔍 Reference

### Troubleshooting

- **[Troubleshooting](Troubleshooting.md)**
  - Common issues and solutions
  - Boot problems
  - Network issues
  - Display issues
  - Performance problems

### Technical Details

- **[NixOS Basics](NixOS-Basics.md)**
  - Nix language fundamentals
  - Module system
  - Flakes
  - Derivations

- **[Hardware Support](Hardware-Support.md)**
  - ThinkPad T14s Gen 6 AMD
  - Fingerprint reader
  - AMD GPU
  - WiFi/Bluetooth

- **[Port Management](Port-Management.md)**
  - Port allocation system
  - Finding/killing processes
  - Recommended ports
  - Conflict resolution

---

## 📂 By Topic

### 🖥️ Servers & Homelab

- [Server Deployment](Server-Deployment.md) - Deploy headless servers
- [Homelab Guide](Homelab-Guide.md) - Multi-server architecture
- [Profile System: Server Profile](Profile-System.md#server-profile) - Server options

### 💻 Desktop & Development

- [Desktop Environment](Desktop-Environment.md) - Hyprland setup
- [Profile System: Development Profile](Profile-System.md#development-profile) - Dev tools
- [Keybindings](Keybindings.md) - Keyboard shortcuts
- [Scripts](Scripts.md) - Management scripts

### 🎮 Gaming & Media

- [Gaming Profile](Gaming-Profile.md) - Steam, Proton, isolation
- [Power User Guide](Power-User-Guide.md) - Creative tools

### 🔒 Security & Secrets

- [System Configuration: Security](System-Configuration.md) - Security hardening
- [Server Deployment: Security](Server-Deployment.md#security-configuration) - Server security
- Secrets management (sops-nix) - See module documentation

---

## 🎯 Quick Links

### For Beginners

- **[Step-by-Step Build Guide](Step-by-Step-Build-Guide.md)** ⭐ Build incrementally
- [Installation Guide](Installation.md) - Install NixOS
- [NixOS Basics](NixOS-Basics.md) - Learn the fundamentals
- [Profile System](Profile-System.md) - Understand the architecture
- [Troubleshooting](Troubleshooting.md) - Fix common issues

### For Experienced Users

- [Quick Start](Quick-Start.md) - Deploy in 15 minutes
- [Profile System](Profile-System.md) - NixOS profiles reference
- [Home Manager Guide](HOME-MANAGER-IMPLEMENTATION.md) - User configuration
- [Customization](Customization.md) - Make it yours
- [System Configuration](System-Configuration.md) - System modules

### Architecture & Best Practices

- [Profile System](Profile-System.md) - NixOS profiles (system-level)
- [Home Manager Implementation](HOME-MANAGER-IMPLEMENTATION.md) - User profiles
- [Home Manager Analysis](HOME-MANAGER-ANALYSIS.md) - Architecture deep dive
- [Flake Example](FLAKE-EXAMPLE.md) - Improved flake.nix with multi-user
- [Profile Summary](PROFILE-SUMMARY.md) - Quick reference
- [Recommendations](RECOMMENDATIONS.md) - Best practices analysis

### Configuration Examples

- [Minimal Laptop](Profile-System.md#1-development-laptop-minimal)
- [Full Workstation](Profile-System.md#2-full-workstation)
- [Web Server](Profile-System.md#3-web-server-homelab)
- [Database Server](Profile-System.md#4-database-server)
- [Monitoring Server](Profile-System.md#5-monitoring-server)
- [Complete Homelab](Homelab-Guide.md#infrastructure-components)
- [Multi-User Workstation](HOME-MANAGER-IMPLEMENTATION.md#use-case-2-workstation-multi-user)

### Common Tasks

- [Install NixOS from scratch](Step-by-Step-Build-Guide.md)
- [Add a package](Customization.md#adding-packages-declarative)
- [Enable a language](Profile-System.md#language-support)
- [Add a new user](HOME-MANAGER-IMPLEMENTATION.md#adding-a-new-user)
- [Deploy a server](Server-Deployment.md#quick-start)
- [Create a backup](Server-Deployment.md#backup-strategies)
- [Update the system](Quick-Start.md#updating)
- [Troubleshoot issues](Troubleshooting.md)
- [Rollback changes](Step-by-Step-Build-Guide.md#rollback-if-something-breaks)

---

## 📝 Recent Updates

### January 2026

✅ **Step-by-Step Build Guide** - Complete beginner's guide (build incrementally, test each phase)  
✅ **Home Manager Profiles** - User-level profile system with multi-user support  
✅ **User Abstraction Layer** - Portable user configurations across machines  
✅ **Profile System** - Modular configuration with 6 NixOS + 5 Home Manager profiles  
✅ **Server Profile** - Headless server support (web, database, docker, monitoring)  
✅ **Homelab Guide** - Multi-server Proxmox architecture  
✅ **Documentation Overhaul** - Reorganized, expanded, and consolidated guides  

See [CHANGELOG.md](../CHANGELOG.md) for complete history.

---

## 📚 Documentation Structure

### Two-Layer Configuration System

This configuration uses a **two-layer system** for maximum flexibility:

**Layer 1: NixOS System Configuration** (root-level)
- Location: `modules/profiles/`
- Installed system-wide (available to all users)
- Requires `sudo` to modify
- Profiles: base, desktop, development, gaming, power-user, server

**Layer 2: Home Manager User Configuration** (user-level)
- Location: `home/profiles/` and `home/users/`
- Installed per-user (`~/.nix-profile/`)
- No `sudo` required
- Profiles: base, desktop, development, creative, personal

### How They Work Together

```
Example: Installing Python

NixOS Profile (System):
  profiles.development.languages.python.enable = true
  → Installs Python system-wide in /nix/store/
  → All users can use Python

Home Manager Profile (User):
  home.profiles.development.enable = true
  → Installs dev tools (VS Code, etc.) for specific user
  → Only that user has these tools

Result: Python available system-wide, dev tools per-user
```

See [Profile System](Profile-System.md) for NixOS profiles and [Home Manager Guide](HOME-MANAGER-IMPLEMENTATION.md) for user profiles.

---

## 🤝 Contributing

Found an error or want to improve documentation?

1. Edit the markdown files in `docs/`
2. Submit a pull request
3. See [CONTRIBUTING.md](../CONTRIBUTING.md)

---

## 📧 Getting Help

- **Documentation**: You're here! Use the index above
- **Issues**: GitHub issues for bugs/features
- **Community**: NixOS Discourse, Reddit r/NixOS

---

**Happy NixOS-ing!** 🚀

*Last updated: January 2026*
