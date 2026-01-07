# Home Manager Implementation Guide

**Status**: ✅ New Architecture Created  
**Date**: January 2026

---

## 🎯 What Was Implemented

### New Directory Structure

```
home/
├── profiles/              # ✅ NEW: Home Manager profiles (like NixOS profiles)
│   ├── default.nix       # Import all HM profiles
│   ├── base.nix          # Essential tools for all users
│   ├── desktop.nix       # Desktop applications
│   ├── development.nix   # Development tools
│   ├── creative.nix      # Creative apps (GIMP, Blender, etc.)
│   └── personal.nix      # Personal apps (Discord, Spotify, etc.)
├── users/                 # ✅ NEW: User definitions
│   ├── default.nix       # User factory & exports
│   └── shared.nix        # Shared config for all users
├── programs/              # ✅ EXISTING: Portable program configs
│   └── ... (git, firefox, neovim, etc.)
├── shell/                 # ✅ EXISTING: Shell configurations
├── services/              # ✅ EXISTING: User services
├── hyprland/              # ✅ EXISTING: Hyprland config
└── jpolo.nix             # ⚠️ DEPRECATED: Old monolithic config
```

---

## 📋 Files Created

### 1. Home Manager Profiles (5 files)

**`home/profiles/base.nix`** - Essential tools
- Modern CLI tools (eza, bat, ripgrep, fd)
- System monitoring (btop, htop)
- Archive tools
- XDG directories
- Session variables

**`home/profiles/desktop.nix`** - Desktop applications
- Browsers (Firefox, Chromium)
- Terminals (Kitty, Alacritty)
- File managers (Ranger, Yazi)
- Document/Image viewers
- Desktop utilities (clipboard, screenshots, brightness)
- Office suite, password managers

**`home/profiles/development.nix`** - Development tools
- Git, GitHub CLI, lazygit
- Terminal tools (tmux, zoxide, fzf)
- Text processing (jq, yq)
- Optional VS Code
- Neovim (default enabled)

**`home/profiles/creative.nix`** - Creative tools
- Graphics: GIMP, Inkscape, Krita
- Video: Kdenlive, OBS, wf-recorder
- Audio: Audacity

**`home/profiles/personal.nix`** - Personal apps
- Communication: Discord, Slack, Telegram, Zoom
- Media: Spotify, VLC, MPV
- Productivity: Taskwarrior, Timewarrior, rclone, syncthing

### 2. User System (2 files)

**`home/users/default.nix`** - User factory
- `mkUser` helper function
- User definitions (jpolo, workuser, admin examples)
- Per-user profile selections
- `forHost` helper for multi-machine
- Export mechanism for flake

**`home/users/shared.nix`** - Shared configuration
- Common programs (direnv, nix-index)
- Common packages
- Universal session variables

---

## 🔄 How To Use

### Option 1: Direct Import (Simple)

```nix
# flake.nix
{
  home-manager.users = (import ./home/users).all;
  # This gives you: { jpolo = {...}; workuser = {...}; admin = {...}; }
}
```

### Option 2: Selective Import (Recommended)

```nix
# flake.nix
let
  users = import ./home/users;
in {
  # Laptop: Only jpolo
  ares = {
    home-manager.users.jpolo = users.jpolo;
  };
  
  # Workstation: jpolo + workuser
  workstation = {
    home-manager.users = {
      jpolo = users.jpolo;
      workuser = users.workuser;
    };
  };
  
  # Server: Only admin
  server = {
    home-manager.users.admin = users.admin;
  };
}
```

### Option 3: Per-Host Helper (Advanced)

```nix
# flake.nix
let
  users = import ./home/users;
in {
  ares = {
    home-manager.users = users.forHost "ares";
    # Returns only users configured for this host
  };
}
```

---

## 👤 Adding a New User

### Step 1: Define User in `home/users/default.nix`

```nix
# Add to the exports
{
  jpolo = mkUser { ... };
  
  # NEW USER
  alice = mkUser {
    username = "alice";
    fullName = "Alice Smith";
    email = "alice@example.com";
    
    profiles = {
      desktop.enable = true;
      development = {
        enable = true;
        editors.vscode.enable = false;  # Neovim only
      };
      personal = {
        enable = true;
        media.enable = false;  # No media apps
      };
    };
  };
}
```

### Step 2: Add to Flake

```nix
# flake.nix
{
  home-manager.users = {
    jpolo = users.jpolo;
    alice = users.alice;  # ✅ New user!
  };
}
```

### Step 3: Create System User

```nix
# hosts/ares/configuration.nix
users.users.alice = {
  isNormalUser = true;
  description = "Alice Smith";
  extraGroups = [ "wheel" "networkmanager" ];
  shell = pkgs.zsh;
};
```

### Step 4: Deploy

```bash
sudo nixos-rebuild switch --flake .#ares
```

Done! Alice now has her own home-manager configuration.

---

## 🎛️ Profile Options

### Base Profile

Always enabled for all users.

```nix
home.profiles.base.enable = true;  # Default
```

### Desktop Profile

```nix
home.profiles.desktop.enable = true;
```

Includes: Firefox, Chromium, Kitty, LibreOffice, Obsidian, etc.

### Development Profile

```nix
home.profiles.development = {
  enable = true;
  editors = {
    vscode.enable = true;   # Add VS Code
    neovim.enable = true;   # Default: true
  };
};
```

Includes: Git, lazygit, tmux, zoxide, fzf, jq, etc.

### Creative Profile

```nix
home.profiles.creative = {
  enable = true;
  graphics.enable = true;  # GIMP, Inkscape, Krita
  video.enable = true;     # Kdenlive, OBS
  audio.enable = false;    # No audio tools
};
```

### Personal Profile

```nix
home.profiles.personal = {
  enable = true;
  communication.enable = true;  # Discord, Slack, etc.
  media.enable = true;          # Spotify, VLC, MPV
  productivity.enable = true;   # Taskwarrior, etc.
};
```

---

## 🔀 Migration from Old Config

### Current Config (jpolo.nix)

```nix
# home/jpolo.nix - 182 lines, everything mixed
{
  home.username = "jpolo";
  home.packages = [ firefox discord vscode gimp ... ];  # 50+ packages
  programs.git.userName = "Javier Polo Gambin";
}
```

### New Config (with profiles)

```nix
# home/users/default.nix - User definition only
jpolo = mkUser {
  username = "jpolo";
  fullName = "Javier Polo Gambin";
  email = "javier.polog@outlook.com";
  
  # Select profiles instead of listing packages
  profiles = {
    desktop.enable = true;
    development.enable = true;
    creative.enable = true;
    personal.enable = true;
  };
};
```

**Result**: User config reduced from 182 lines to ~20 lines!

### Migration Steps

1. **Identify packages** in current `jpolo.nix`
2. **Map to profiles**:
   - `firefox`, `kitty` → desktop profile
   - `vscode`, `git` → development profile
   - `gimp`, `inkscape` → creative profile
   - `discord`, `spotify` → personal profile
3. **Update flake.nix** to use `users.jpolo`
4. **Test**: `nixos-rebuild build --flake .#ares`
5. **Deploy**: `nixos-rebuild switch --flake .#ares`

---

## 📊 Comparison

| Aspect | Old (jpolo.nix) | New (profiles) |
|--------|----------------|----------------|
| **Lines of code** | 182 | 20 |
| **User definitions** | Hard-coded | Abstract |
| **Reusability** | ❌ Low | ✅ High |
| **Multi-user** | ❌ Hard | ✅ Easy |
| **Portability** | ⚠️ Medium | ✅ High |
| **Modularity** | ❌ Monolithic | ✅ Profile-based |
| **Maintainability** | ⚠️ Medium | ✅ High |

---

## 🏢 Example Use Cases

### Use Case 1: Personal Laptop (ares)

```nix
# One user, full setup
home-manager.users.jpolo = users.jpolo;
```

**Result**: Full desktop + development + personal apps

### Use Case 2: Workstation (Multi-User)

```nix
# Two users, different profiles
home-manager.users = {
  jpolo = users.jpolo;      # Full setup
  workuser = users.workuser; # Minimal, work-focused
};
```

**Result**: 
- jpolo: All profiles enabled
- workuser: Only development + communication

### Use Case 3: Server (Headless)

```nix
# One admin user, no GUI
home-manager.users.admin = users.admin;
```

**Result**: Only base + development profiles, no desktop/personal

### Use Case 4: Same User, Different Machines

```nix
# ares (laptop) - Selective
jpolo = mkUser {
  profiles = {
    development.editors.vscode.enable = false;  # Neovim only
    creative.video.enable = false;  # No video editing
  };
};

# workstation (desktop) - Full
jpolo = mkUser {
  profiles = {
    development.editors.vscode.enable = true;   # ✅ VS Code
    creative.video.enable = true;   # ✅ Video editing
  };
};
```

**Result**: Same user, different capabilities per machine

---

## 🔧 Customization

### Override Profile Defaults

```nix
# In user definition
jpolo = mkUser {
  profiles = {
    personal = {
      enable = true;
      media.enable = false;  # Disable media apps for this user
    };
  };
};
```

### Add User-Specific Packages

```nix
jpolo = mkUser {
  extraConfig = {
    home.packages = with pkgs; [
      # User-specific packages not in any profile
      some-special-tool
    ];
  };
};
```

### Import User-Specific Modules

```nix
jpolo = mkUser {
  extraConfig = {
    imports = [
      ../shell     # ZSH configuration
      ../services  # User services
    ];
  };
};
```

---

## 📁 Full Example Configuration

```nix
# flake.nix
{
  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations.ares = nixpkgs.lib.nixosSystem {
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users = let
              homeUsers = import ./home/users;
            in {
              # Import jpolo user configuration
              jpolo = homeUsers.jpolo;
            };
          };
        }
        ./hosts/ares/configuration.nix
      ];
    };
  };
}

# hosts/ares/configuration.nix
{
  users.users.jpolo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
}

# home/users/default.nix defines jpolo with profiles
# Profiles automatically install packages based on selections
```

---

## ✅ Benefits Summary

1. **Portable** ✅
   - Move user to different machine
   - Copy user definition, works everywhere

2. **Multi-User** ✅
   - Add users in minutes
   - Each user independent

3. **Modular** ✅
   - Mix and match profiles
   - Toggle features per user

4. **Maintainable** ✅
   - DRY principle
   - Clear separation of concerns

5. **Type-Safe** ✅
   - NixOS options system
   - Catch errors at build time

---

## 🚀 Next Steps

1. **Review** created files in `home/profiles/` and `home/users/`
2. **Update** `flake.nix` to use new user system
3. **Test** with current user (jpolo)
4. **Migrate** packages from old `jpolo.nix` to profiles
5. **Add** second user to demonstrate multi-user capability
6. **Document** your specific user/profile combinations

---

**Status**: Architecture ready for implementation! 🎉
