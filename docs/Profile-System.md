# Profile System Guide

The nix-omarchy configuration uses a **profile-based system** for managing different types of machines. This allows you to selectively enable features per-host without maintaining separate configurations.

---

## Overview

### What are Profiles?

Profiles are **modular configuration templates** that bundle related packages, services, and settings. Instead of installing everything everywhere, you enable only what each machine needs.

### Available Profiles

1. **`base`** - Essential system tools (always enabled)
2. **`desktop`** - Hyprland desktop environment
3. **`development`** - Development tools and languages
4. **`gaming`** - Steam, Proton, isolated gaming environment
5. **`power-user`** - Advanced tools (scientific computing, creative apps)
6. **`server`** - Headless server configurations (web, database, docker, monitoring)

---

## Profile Architecture

```
modules/profiles/
├── default.nix       # Import all profiles
├── base.nix          # Essential packages (vim, git, htop, etc.)
├── desktop.nix       # Desktop environment toggle
├── development.nix   # Dev tools with granular sub-options
├── gaming.nix        # Gaming setup with isolation
├── power-user.nix    # Advanced tools (Octave, Blender, etc.)
└── server.nix        # Server roles and services
```

Each profile:
- Defines **options** you can toggle
- Conditionally installs **packages**
- Configures **services** when enabled

---

## Machine Types

### Desktop/Laptop

**Purpose**: Development workstation, daily driver  
**Profiles**: `base`, `desktop`, `development`, `power-user`

```nix
profiles = {
  base.enable = true;
  desktop.enable = true;
  development = {
    enable = true;
    languages = {
      python.enable = true;
      nodejs.enable = true;
      rust.enable = false;  # Optional
    };
  };
  power-user = {
    enable = true;
    scientific.octave.enable = false;  # Don't install on laptop
  };
};
```

### Servers (Homelab/Proxmox)

**Purpose**: Web hosting, databases, containers, monitoring  
**Profiles**: `base`, `server`

```nix
profiles = {
  base.enable = true;
  server = {
    enable = true;
    role = "web";  # or "database", "docker", "monitoring"
    services = {
      ssh.enable = true;
      webserver.enable = true;
      docker.enable = true;
    };
  };
};
```

---

## Base Profile

**Always enabled** - Provides essential tools for any NixOS system.

### Included Packages

- **Core**: vim, wget, curl, git
- **Monitoring**: htop, btop, neofetch
- **Hardware**: pciutils, usbutils, lshw

### Configuration

```nix
profiles.base.enable = true;  # Default: true
```

---

## Desktop Profile

Enables **Hyprland** desktop environment with all related tools.

### What's Included

- **Compositor**: Hyprland with plugins
- **Bar**: Waybar with Catppuccin theme
- **Launcher**: Walker
- **Lock Screen**: Hyprlock
- **Idle Manager**: Hypridle
- **Display Manager**: SDDM

### Configuration

```nix
profiles.desktop.enable = true;
```

### When to Disable

- Servers (headless)
- Minimal VMs
- CI/CD runners

---

## Development Profile

Comprehensive development environment with **granular control** over languages and tools.

### Language Support

```nix
profiles.development = {
  enable = true;
  
  languages = {
    python.enable = true;   # Python 3.12, pip, virtualenv, pyright
    nodejs.enable = true;   # Node.js 22, npm, yarn, pnpm
    rust.enable = true;     # rustc, cargo, rust-analyzer
    go.enable = true;       # go, gopls, gotools
    cpp.enable = true;      # gcc, clang, cmake
    java.enable = false;    # JDK 21
    zig.enable = false;     # Zig compiler
  };
  
  tools = {
    docker.enable = true;      # Docker daemon + lazydocker
    cloud.enable = true;       # AWS, GCP, Azure CLIs
    kubernetes.enable = true;  # kubectl, k9s, helm
    databases.enable = true;   # PostgreSQL, Redis, DBeaver
    api.enable = true;         # Postman, Insomnia, httpie
  };
};
```

### Defaults

By default, **Python** and **Node.js** are enabled. All others are opt-in.

### Examples

**Minimal (Python only)**:
```nix
profiles.development = {
  enable = true;
  languages = {
    python.enable = true;
    nodejs.enable = false;  # Disable Node.js
  };
  tools.docker.enable = false;  # No Docker
};
```

**Full Stack Web Developer**:
```nix
profiles.development = {
  enable = true;
  languages = {
    nodejs.enable = true;
    python.enable = true;
  };
  tools = {
    docker.enable = true;
    databases.enable = true;
    api.enable = true;
  };
};
```

**DevOps Engineer**:
```nix
profiles.development = {
  enable = true;
  languages.python.enable = true;
  tools = {
    docker.enable = true;
    cloud.enable = true;
    kubernetes.enable = true;
  };
};
```

---

## Gaming Profile

Isolated gaming environment with **security sandboxing**.

### Features

- **Steam** with Proton-GE
- **GameMode** performance optimization
- **Isolated user** (UID 2000, no sudo)
- **Firejail** sandboxing
- **Controller support**

### Configuration

```nix
profiles.gaming.enable = true;
```

### Security

The gaming profile creates a separate user with:
- No `wheel` group (no sudo)
- No docker access
- Resource limits (8GB RAM, 4 CPU cores)
- Filesystem restrictions

See [Gaming Profile Guide](Gaming-Profile.md) for details.

---

## Power User Profile

Advanced tools for **scientific computing** and **creative work**.

### Scientific Computing

```nix
profiles.power-user = {
  enable = true;
  scientific = {
    enable = true;
    octave.enable = true;   # GNU Octave (MATLAB alternative)
    jupyter.enable = true;  # Jupyter notebooks
  };
};
```

**Packages**: Octave, Jupyter, scientific libraries

### Creative Tools

```nix
profiles.power-user = {
  enable = true;
  creative = {
    enable = true;
    video.enable = true;     # Kdenlive, OBS Studio
    modeling3d.enable = true; # Blender
  };
};
```

**Packages**: GIMP, Inkscape, Krita, Kdenlive, Blender

### Base Power User Tools

When `power-user.enable = true`, you also get:
- **Terminal**: ranger, yazi, fzf, ripgrep
- **Monitoring**: btop, nvtop, bandwhich
- **Network**: nmap, mtr, wireshark
- **Dev**: lazygit, tig, gh

---

## Server Profile

**NEW!** Headless server configurations for homelab/Proxmox deployments.

### Server Roles

The server profile supports different **roles** with pre-configured defaults:

| Role | Use Case | Default Services |
|------|----------|-----------------|
| `general` | Basic server | SSH, monitoring |
| `web` | Web hosting | Nginx, SSL, Docker |
| `database` | Database server | PostgreSQL, Redis |
| `docker` | Container host | Docker, Portainer |
| `storage` | File server | NFS, Samba |
| `monitoring` | Observability | Prometheus, Grafana, Loki |

### Basic Configuration

```nix
profiles.server = {
  enable = true;
  role = "web";  # Choose role
  
  services.ssh.enable = true;
};
```

### Service Options

#### SSH Server

```nix
profiles.server.services.ssh = {
  enable = true;
  passwordAuth = false;  # Key-based auth only (recommended)
  port = 22;
};
```

#### Web Server

```nix
profiles.server.services.webserver = {
  enable = true;
  acme = true;  # Automatic SSL via Let's Encrypt
};
```

#### Docker

```nix
profiles.server.services.docker = {
  enable = true;
  portainer = true;  # Web UI on port 9443
};
```

#### Databases

```nix
profiles.server.services.database = {
  postgresql.enable = true;
  redis.enable = true;
  mysql.enable = false;
};
```

#### Monitoring

```nix
profiles.server.services.monitoring = {
  node-exporter.enable = true;  # Prometheus metrics
  prometheus.enable = true;      # Metrics database
  grafana.enable = true;         # Dashboards
  loki.enable = true;            # Log aggregation
};
```

#### Storage

```nix
profiles.server.services.storage = {
  nfs.enable = true;    # NFS server
  samba.enable = true;  # Samba/SMB shares
};
```

#### Backup

```nix
profiles.server.services.backup = {
  enable = true;
  restic.enable = true;  # Restic backup client
};
```

### Optimization Options

```nix
profiles.server.optimization = {
  minimal = true;       # Disable docs, man pages (save space)
  autoUpgrade = false;  # Manual updates (production best practice)
  autoGC = true;        # Auto garbage collection weekly
};
```

### What Server Profile Does

**Disables**:
- ❌ GUI (X11/Wayland)
- ❌ Desktop environment
- ❌ Audio services
- ❌ Printing
- ❌ Avahi/mDNS
- ❌ Power management (sets performance governor)
- ❌ Documentation (if `minimal = true`)

**Enables**:
- ✅ SSH with hardened configuration
- ✅ Fail2ban (SSH brute-force protection)
- ✅ AppArmor security
- ✅ BBR TCP congestion control
- ✅ Server-optimized kernel parameters
- ✅ Firewall with minimal ports
- ✅ Automatic garbage collection
- ✅ Journal size limits (500MB max)

**Includes** (packages):
- Essential: vim, wget, curl, git
- Monitoring: htop, btop, iotop, ncdu
- Network: netcat, nmap, tcpdump, dig, mtr
- Tools: tmux, screen, jq, yq
- Security: age, sops

---

## Example Configurations

### 1. Development Laptop (Minimal)

```nix
# hosts/laptop/configuration.nix
profiles = {
  base.enable = true;
  desktop.enable = true;
  
  development = {
    enable = true;
    languages = {
      python.enable = true;
      nodejs.enable = true;
      # All others disabled by default
    };
    tools = {
      docker.enable = true;
      databases.enable = true;
      # cloud/kubernetes disabled
    };
  };
  
  gaming.enable = false;
  
  power-user = {
    enable = true;
    scientific.enable = false;  # Save space on laptop
    creative.enable = true;
  };
};
```

### 2. Full Workstation

```nix
# hosts/workstation/configuration.nix
profiles = {
  base.enable = true;
  desktop.enable = true;
  
  development = {
    enable = true;
    languages = {
      python.enable = true;
      nodejs.enable = true;
      rust.enable = true;
      go.enable = true;
      cpp.enable = true;
    };
    tools = {
      docker.enable = true;
      cloud.enable = true;
      kubernetes.enable = true;
      databases.enable = true;
      api.enable = true;
    };
  };
  
  gaming.enable = true;
  
  power-user = {
    enable = true;
    scientific = {
      enable = true;
      octave.enable = true;
      jupyter.enable = true;
    };
    creative = {
      enable = true;
      video.enable = true;
      modeling3d.enable = true;
    };
  };
};
```

### 3. Web Server (Homelab)

```nix
# hosts/web-server/configuration.nix
profiles = {
  base.enable = true;
  server = {
    enable = true;
    role = "web";
    
    services = {
      ssh = {
        enable = true;
        passwordAuth = false;
      };
      webserver = {
        enable = true;
        acme = true;
      };
      docker = {
        enable = true;
        portainer = true;
      };
      monitoring.node-exporter.enable = true;
    };
    
    optimization = {
      minimal = true;
      autoUpgrade = false;
      autoGC = true;
    };
  };
};
```

### 4. Database Server

```nix
# hosts/db-server/configuration.nix
profiles = {
  base.enable = true;
  server = {
    enable = true;
    role = "database";
    
    services = {
      ssh.enable = true;
      database = {
        postgresql.enable = true;
        redis.enable = true;
      };
      monitoring.node-exporter.enable = true;
      backup.restic.enable = true;
    };
  };
};
```

### 5. Monitoring Server

```nix
# hosts/monitoring/configuration.nix
profiles = {
  base.enable = true;
  server = {
    enable = true;
    role = "monitoring";
    
    services = {
      ssh.enable = true;
      monitoring = {
        node-exporter.enable = true;
        prometheus.enable = true;
        grafana.enable = true;
        loki.enable = true;
      };
    };
  };
};
```

---

## Homelab Architecture Example

**Proxmox Setup** with multiple NixOS VMs:

```
┌─────────────────────────────────────────────────┐
│ Proxmox Host (192.168.1.10)                    │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ web-server (192.168.1.100)              │  │
│  │ - Nginx reverse proxy                    │  │
│  │ - Docker containers                      │  │
│  │ - SSL certificates                       │  │
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ docker-host (192.168.1.101)             │  │
│  │ - Dedicated container runtime            │  │
│  │ - Portainer UI                           │  │
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ database-server (192.168.1.102)         │  │
│  │ - PostgreSQL                             │  │
│  │ - Redis                                  │  │
│  │ - Automated backups                      │  │
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ monitoring-server (192.168.1.103)       │  │
│  │ - Prometheus (metrics)                   │  │
│  │ - Grafana (dashboards)                   │  │
│  │ - Loki (logs)                            │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

Each VM:
- Runs **NixOS** (same flake, different profiles)
- **Declaratively configured** (reproducible)
- **Version controlled** (git)
- **Easy to replicate** (clone config, change hostname)

---

## Migration Guide

### Step 1: Choose Your Machine Type

Identify what type of machine you're configuring:
- Desktop/Laptop
- Workstation
- Server (web, database, docker, monitoring)

### Step 2: Start with Base Profile

```nix
profiles.base.enable = true;
```

### Step 3: Add Required Profiles

For **desktop**:
```nix
profiles.desktop.enable = true;
```

For **development**:
```nix
profiles.development.enable = true;
```

For **server**:
```nix
profiles.server.enable = true;
```

### Step 4: Configure Sub-Options

Enable only what you need:

```nix
profiles.development.languages.python.enable = true;
profiles.development.tools.docker.enable = true;
```

### Step 5: Test

```bash
# Build configuration
sudo nixos-rebuild build --flake .#hostname

# Compare sizes
nix path-info --closure-size ./result

# Test (doesn't persist on reboot)
sudo nixos-rebuild test --flake .#hostname

# Apply permanently
sudo nixos-rebuild switch --flake .#hostname
```

---

## Best Practices

### 1. Start Minimal, Add As Needed

```nix
# Good: Start with minimal, expand later
profiles.development.languages.python.enable = true;

# Avoid: Enabling everything "just in case"
profiles.development.languages.*.enable = true;  # ❌
```

### 2. Use Appropriate Profiles Per Machine

- **Laptop**: Minimal dev tools, no gaming
- **Workstation**: Everything enabled
- **Server**: Only server profile, no desktop

### 3. Document Your Choices

```nix
profiles.power-user.scientific.octave.enable = false;
# ^ Not needed on this laptop, but available on workstation
```

### 4. Separate User vs System Packages

- **System packages** (`environment.systemPackages`): Available to all users
- **User packages** (`home.packages`): Per-user in home-manager

### 5. Use Secrets for Sensitive Data

```nix
# Bad: Hardcoded password
services.grafana.settings.security.admin_password = "admin123";

# Good: Use sops-nix
services.grafana.settings.security.admin_password = "$__file{/run/secrets/grafana-password}";
```

---

## Troubleshooting

### "Option not found" Error

**Problem**: `The option 'profiles.foo' does not exist`

**Solution**: Ensure you've imported the profile system:
```nix
imports = [ ../../modules/profiles ];
```

### Packages Still Installing

**Problem**: Disabled a feature but packages still install

**Solution**: 
1. Check if package is in another module
2. Verify profile is actually disabled
3. Rebuild: `sudo nixos-rebuild switch --flake .#hostname`

### Server Has GUI

**Problem**: Server profile enabled but GUI still present

**Solution**: Make sure you didn't import desktop modules:
```nix
# Don't import these on servers:
# ../../modules/desktop
```

---

## Related Documentation

- [Installation Guide](Installation.md) - Installing NixOS with profiles
- [Server Deployment](Server-Deployment.md) - Detailed server setup
- [Homelab Guide](Homelab-Guide.md) - Proxmox + NixOS architecture
- [Development Profile](Development-Profile.md) - Language-specific setup

---

## Summary

Profiles provide:
- ✅ **Granular control** - Enable only what you need
- ✅ **Disk space savings** - 8-12GB (minimal) vs 15-20GB (full)
- ✅ **Clear configuration** - Self-documenting host configs
- ✅ **Easy replication** - Clone and adjust toggles
- ✅ **Type safety** - NixOS prevents invalid configurations

Use profiles to create **purpose-built machines** from a single, shared configuration repository.
