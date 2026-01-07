# Complete Documentation Overview

**Last Updated**: January 2026  
**Total Files**: 31 documentation files (~200KB+)

---

## 📖 Quick Navigation

### 🎯 I Want To...

**...start from scratch (complete beginner)**
→ [Step-by-Step Build Guide](Step-by-Step-Build-Guide.md)

**...install quickly (have NixOS experience)**
→ [Quick Start](Quick-Start.md)

**...understand the system architecture**
→ [Profile System](Profile-System.md) + [Home Manager Guide](HOME-MANAGER-IMPLEMENTATION.md)

**...add a new user**
→ [Home Manager Implementation - Adding Users](HOME-MANAGER-IMPLEMENTATION.md#adding-a-new-user)

**...deploy a server**
→ [Server Deployment](Server-Deployment.md)

**...build a homelab**
→ [Homelab Guide](Homelab-Guide.md)

**...customize my desktop**
→ [Desktop Environment](Desktop-Environment.md) + [Customization](Customization.md)

**...troubleshoot issues**
→ [Troubleshooting](Troubleshooting.md)

---

## 📚 All Documentation Files

### 🚀 Getting Started (Beginners)

| File | Purpose | Time | Audience |
|------|---------|------|----------|
| [Step-by-Step-Build-Guide.md](Step-by-Step-Build-Guide.md) | Build system incrementally, phase by phase | 2-4 hours | Complete beginners |
| [Quick-Start.md](Quick-Start.md) | Fast deployment for experienced users | 15 min | Experienced |
| [Installation.md](Installation.md) | Detailed installation instructions | 1 hour | Beginners |
| [NixOS-Basics.md](NixOS-Basics.md) | Learn NixOS fundamentals | 30 min | All users |

### 🏗️ Architecture & Configuration

| File | Purpose | Key Topics |
|------|---------|------------|
| [Profile-System.md](Profile-System.md) | NixOS system profiles (Layer 1) | 6 profiles, granular options, examples |
| [HOME-MANAGER-IMPLEMENTATION.md](HOME-MANAGER-IMPLEMENTATION.md) | User-level configuration (Layer 2) | 5 profiles, multi-user, portability |
| [HOME-MANAGER-ANALYSIS.md](HOME-MANAGER-ANALYSIS.md) | Architecture analysis & best practices | Issues, solutions, comparisons |
| [FLAKE-EXAMPLE.md](FLAKE-EXAMPLE.md) | Improved multi-user flake.nix | User abstraction, examples |
| [System-Configuration.md](System-Configuration.md) | System modules explained | Audio, network, power, security |
| [Customization.md](Customization.md) | Customize your system | Themes, packages, modules |

### 🖥️ Desktop & Applications

| File | Purpose | Topics |
|------|---------|--------|
| [Desktop-Environment.md](Desktop-Environment.md) | Hyprland desktop setup | Compositor, bar, launcher, themes |
| [Keybindings.md](Keybindings.md) | Keyboard shortcuts | Hyprland, terminal, VI mode |
| [Applications.md](Applications.md) | Installed software guide | What's included, how to use |

### 🛠️ Development & Tools

| File | Purpose | Topics |
|------|---------|--------|
| [Scripts.md](Scripts.md) | System management scripts | update, cleanup, backup, dev-env |
| [Port-Management.md](Port-Management.md) | Port allocation system | Finding processes, portctl |

### 🖥️ Server & Homelab

| File | Purpose | Audience |
|------|---------|----------|
| [Server-Deployment.md](Server-Deployment.md) | Deploy headless servers | Server admins |
| [Homelab-Guide.md](Homelab-Guide.md) | Multi-server architecture | Homelab enthusiasts |
| [Virtualization-Guide.md](Virtualization-Guide.md) | VMs, Docker, Proxmox | DevOps, testing |
| [VM-Quick-Reference.md](VM-Quick-Reference.md) | Quick VM commands | All users |

### 🎮 Specialized Profiles

| File | Purpose | Who Needs This |
|------|---------|----------------|
| [Gaming-Profile.md](Gaming-Profile.md) | Isolated gaming environment | Gamers |
| [Power-User-Guide.md](Power-User-Guide.md) | Advanced tools (scientific, creative) | Power users |

### 📋 Reference & Best Practices

| File | Purpose | Topics |
|------|---------|--------|
| [Profile-Summary.md](PROFILE-SUMMARY.md) | Quick reference for all profiles | Options, defaults, examples |
| [Recommendations.md](RECOMMENDATIONS.md) | Best practices analysis | NixOS patterns, optimizations |
| [Production-Ready.md](Production-Ready.md) | Production deployment checklist | Enterprise use |
| [Declarative-Principles.md](Declarative-Principles.md) | NixOS philosophy | Declarative vs imperative |
| [Project-Overview.md](Project-Overview.md) | Project structure overview | Directory layout |

### 🔧 Troubleshooting & Maintenance

| File | Purpose | When to Use |
|------|---------|-------------|
| [Troubleshooting.md](Troubleshooting.md) | Common issues and solutions | When things break |
| [Hardware-Support.md](Hardware-Support.md) | Hardware-specific guides | ThinkPad, AMD GPU, etc. |

### 📰 Updates & Changes

| File | Purpose | Contents |
|------|---------|----------|
| [Whats-New-PowerUser.md](Whats-New-PowerUser.md) | Power user feature updates | Recent additions |
| [Whats-New-Virtualization.md](Whats-New-Virtualization.md) | Virtualization updates | VM features |

---

## 🎓 Learning Paths

### Path 1: Complete Beginner (2-4 hours)

1. **Read**: [Step-by-Step Build Guide](Step-by-Step-Build-Guide.md)
2. **Follow**: Build system phase by phase
3. **Learn**: [NixOS Basics](NixOS-Basics.md)
4. **Customize**: [Customization](Customization.md)

**Result**: Fully functional NixOS system with understanding of all components

### Path 2: Experienced NixOS User (30 min)

1. **Read**: [Quick Start](Quick-Start.md)
2. **Review**: [Profile System](Profile-System.md)
3. **Check**: [Home Manager Guide](HOME-MANAGER-IMPLEMENTATION.md)
4. **Deploy**: `sudo nixos-rebuild switch --flake .#hostname`

**Result**: System deployed, ready to customize

### Path 3: Server Administrator (1 hour)

1. **Read**: [Server Deployment](Server-Deployment.md)
2. **Choose**: Server role (web, database, docker, monitoring)
3. **Configure**: Enable server profile
4. **Deploy**: To Proxmox or bare metal

**Result**: Production-ready headless server

### Path 4: Homelab Enthusiast (2 hours)

1. **Read**: [Homelab Guide](Homelab-Guide.md)
2. **Plan**: Multi-server architecture
3. **Deploy**: Multiple VMs with different roles
4. **Monitor**: Set up Prometheus + Grafana

**Result**: Complete homelab infrastructure

---

## 📊 Documentation Statistics

### By Category

- **Getting Started**: 4 files (Quick Start, Installation, Step-by-Step, Basics)
- **Architecture**: 6 files (Profiles, Home Manager, Flake, System, Customization)
- **Desktop**: 3 files (Desktop, Keybindings, Applications)
- **Development**: 2 files (Scripts, Port Management)
- **Server/Homelab**: 4 files (Server, Homelab, Virtualization, VM Reference)
- **Specialized**: 2 files (Gaming, Power User)
- **Reference**: 5 files (Summary, Recommendations, Production, Declarative, Overview)
- **Troubleshooting**: 2 files (Troubleshooting, Hardware)
- **Updates**: 2 files (Power User Updates, Virtualization Updates)
- **Index**: 1 file (README)

**Total**: 31 files

### By Difficulty

- **Beginner**: 8 files
- **Intermediate**: 14 files
- **Advanced**: 9 files

### By Time to Read

- **Quick (< 15 min)**: 12 files
- **Medium (15-30 min)**: 11 files
- **Long (30+ min)**: 8 files

---

## 🔄 Two-Layer Architecture Reference

### Layer 1: NixOS System Profiles

**Location**: `modules/profiles/`  
**Scope**: System-wide (all users)  
**Access**: Requires `sudo`

| Profile | Purpose | Key Options |
|---------|---------|-------------|
| base | Essential system tools | Always enabled |
| desktop | Hyprland desktop | enable |
| development | Languages, dev tools | languages.*, tools.* |
| gaming | Steam, GameMode | enable, isolation |
| power-user | Scientific, creative | scientific.*, creative.* |
| server | Headless services | role, services.* |

**Documentation**: [Profile System](Profile-System.md)

### Layer 2: Home Manager Profiles

**Location**: `home/profiles/`, `home/users/`  
**Scope**: Per-user  
**Access**: No `sudo` required

| Profile | Purpose | Key Options |
|---------|---------|-------------|
| base | Essential user tools | enable (default: true) |
| desktop | Desktop applications | enable |
| development | Dev tools, editors | editors.vscode, editors.neovim |
| creative | Graphics, video, audio | graphics, video, audio |
| personal | Communication, media | communication, media, productivity |

**Documentation**: [Home Manager Implementation](HOME-MANAGER-IMPLEMENTATION.md)

---

## 💡 Pro Tips

### Finding What You Need

**Use the search function** in your editor or browser to find specific topics across all documentation.

**Common searches**:
- "add user" → Home Manager Implementation
- "install python" → Profile System, Development profile
- "fix error" → Troubleshooting
- "server setup" → Server Deployment
- "rollback" → Step-by-Step Build Guide

### Quick Reference

Bookmark these for quick access:
- Profile options: [Profile Summary](PROFILE-SUMMARY.md)
- Common tasks: [README Quick Links](README.md#quick-links)
- Troubleshooting: [Troubleshooting Guide](Troubleshooting.md)

### Getting Help

1. Check [Troubleshooting](Troubleshooting.md)
2. Read relevant guide (see navigation above)
3. Search documentation for keywords
4. Ask in NixOS Discourse or Reddit r/NixOS
5. Check NixOS manual: https://nixos.org/manual/

---

## 🔗 External Resources

- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Nix Package Search**: https://search.nixos.org/
- **Home Manager Manual**: https://nix-community.github.io/home-manager/
- **Hyprland Wiki**: https://wiki.hyprland.org/
- **NixOS Discourse**: https://discourse.nixos.org/

---

**Last Updated**: January 2026  
**Maintained by**: Javier Polo Gambin  
**Repository**: github.com/yourusername/nix-omarchy

---

**Need to add documentation?** See [CONTRIBUTING.md](../CONTRIBUTING.md)
