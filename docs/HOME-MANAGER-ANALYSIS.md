# Home Manager Architecture Analysis

**Date**: January 2026  
**Status**: ⚠️ **NEEDS REFACTORING**

---

## 🔴 Current Issues

### 1. **Hard-coded Single User** ❌

```nix
# flake.nix - Line 127
{
  home-manager.users.jpolo = import ./home/jpolo.nix;
}
```

**Problem**: 
- Username `jpolo` is hard-coded in flake
- Cannot easily add new users
- Cannot reuse configuration for different users
- Not portable across machines with different usernames

### 2. **User-Specific Data in Configuration** ❌

```nix
# home/jpolo.nix - Lines 12-13
home = {
  username = "jpolo";
  homeDirectory = "/home/jpolo";
```

```nix
# home/jpolo.nix - Lines 172-174
programs.git = {
  userName = "Javier Polo Gambin";
  userEmail = "javier.polog@outlook.com";
```

**Problem**:
- Personal identity hard-coded
- Not reusable for other users
- Violates DRY principle

### 3. **No Separation of User-Specific vs Shared Config** ❌

```nix
# home/jpolo.nix contains BOTH:
- Personal packages (discord, spotify, obsidian)
- Universal tools (firefox, git, neovim)
```

**Problem**:
- Cannot distinguish between "I want this" vs "everyone should have this"
- Cannot create user templates
- Difficult to maintain consistency across users

### 4. **Home Manager Mixed with System Packages** ⚠️

Some packages in `home/jpolo.nix`, others in:
- `modules/development/languages.nix` (system-wide)
- `modules/development/tools.nix` (system-wide)
- `home/programs/power-user.nix` (user-level)

**Problem**:
- Unclear where to add packages
- Duplication risk
- Inconsistent access (some packages system-wide, some per-user)

### 5. **No Profile System for Home Manager** ❌

We have `modules/profiles/` for NixOS, but nothing equivalent for Home Manager.

**Problem**:
- Cannot selectively enable home-manager features per user
- All-or-nothing imports in `home/jpolo.nix`

---

## ✅ Best Practices (What It Should Be)

### 1. **User Abstraction Layer**

```nix
# Desired structure:
home/
├── profiles/              # NEW: Home Manager profiles
│   ├── base.nix          # Essential tools for all users
│   ├── desktop.nix       # Desktop apps (firefox, etc.)
│   ├── development.nix   # Dev tools (vscode, etc.)
│   ├── creative.nix      # Creative tools (gimp, etc.)
│   └── personal.nix      # Personal apps (discord, spotify)
├── users/                # NEW: User definitions
│   ├── jpolo.nix         # User-specific config
│   ├── workuser.nix      # Another user example
│   └── shared.nix        # Shared user config
└── programs/             # Program configurations (portable)
    └── ... (git, firefox, etc.)
```

### 2. **Portable User Identity**

```nix
# users/jpolo.nix (NEW)
{ config, lib, ... }:
{
  home.username = "jpolo";  # Only identity here
  
  programs.git = {
    userName = "Javier Polo Gambin";
    userEmail = "javier.polog@outlook.com";
  };
  
  # Enable profiles
  profiles = {
    base.enable = true;
    desktop.enable = true;
    development.enable = true;
    personal.enable = true;
  };
}
```

### 3. **Per-Host User Mapping**

```nix
# flake.nix (IMPROVED)
nixosConfigurations = {
  ares = {
    modules = [
      {
        home-manager.users = {
          jpolo = import ./home/users/jpolo.nix;
          # workuser = import ./home/users/workuser.nix;  # Easy to add!
        };
      }
    ];
  };
  
  workstation = {
    modules = [
      {
        home-manager.users = {
          jpolo = import ./home/users/jpolo.nix;  # Same user, different machine!
        };
      }
    ];
  };
};
```

### 4. **Shared vs User-Specific Packages**

```nix
# System packages (in NixOS profiles) - Available to ALL users
environment.systemPackages = [ vim git curl ];

# Home Manager base profile - Essential for any user
home.packages = [ firefox kitty neovim ];

# Home Manager personal profile - User opts in
home.packages = [ discord spotify obsidian ];
```

---

## 📊 Comparison Matrix

| Aspect | Current | Best Practice |
|--------|---------|--------------|
| **User Abstraction** | Hard-coded `jpolo` | Abstract user configs |
| **Multi-User Support** | ❌ Single user only | ✅ Easy multi-user |
| **Portability** | ❌ Tied to specific user | ✅ Portable configs |
| **User Identity** | ❌ Mixed with config | ✅ Separated identity |
| **Package Organization** | ⚠️ Unclear | ✅ Clear layers |
| **Profile System** | ❌ No HM profiles | ✅ HM profile system |
| **Reusability** | ❌ Low | ✅ High |
| **Maintainability** | ⚠️ Medium | ✅ High |

---

## 🎯 Recommended Architecture

### Layer 1: NixOS System (Per-Host)

```
modules/profiles/
├── base.nix              # System-wide essentials
├── desktop.nix           # System desktop config
├── development.nix       # System dev tools
└── server.nix            # Server config
```

**Installed**: System-wide packages (all users have access)

### Layer 2: Home Manager Profiles (Per-User Choice)

```
home/profiles/
├── base.nix              # Essential user tools
├── desktop.nix           # Desktop apps (browser, terminal)
├── development.nix       # Dev apps (vscode, IDE)
├── creative.nix          # Creative apps (gimp, blender)
└── personal.nix          # Personal apps (discord, games)
```

**Installed**: In user's home directory (~/.nix-profile/)

### Layer 3: User Identity (Per-User)

```
home/users/
├── jpolo.nix             # Javier's identity + profile choices
├── workuser.nix          # Work user's identity + profile choices
└── shared.nix            # Common settings for all users
```

**Contains**: User-specific data (name, email, profile selections)

### Layer 4: Program Configs (Shared/Portable)

```
home/programs/
├── git.nix               # Portable git config
├── firefox.nix           # Portable firefox config
├── neovim.nix            # Portable neovim config
└── ... (universal configs that work for anyone)
```

**Contains**: Configuration templates (no user-specific data)

---

## 🔄 Migration Path

### Phase 1: Create Home Manager Profiles

1. Create `home/profiles/` directory
2. Split `home/jpolo.nix` into profiles:
   - `base.nix` - Essential tools (firefox, kitty, neovim)
   - `desktop.nix` - Desktop apps
   - `development.nix` - Dev tools (vscode, etc.)
   - `personal.nix` - Personal apps (discord, spotify)

### Phase 2: Extract User Identity

1. Create `home/users/` directory
2. Move user-specific data from `home/jpolo.nix` to `home/users/jpolo.nix`:
   - Username/homeDirectory
   - Git user name/email
   - Profile selections

### Phase 3: Make Programs Portable

1. Remove hard-coded user data from `home/programs/*.nix`
2. Use `config.home.username` instead of literals
3. Make all program configs reusable

### Phase 4: Update Flake

1. Update `flake.nix` to support multiple users
2. Create helper function for user mapping
3. Test with multiple users

---

## 📝 Example: Improved Structure

### Before (Current)

```nix
# flake.nix
home-manager.users.jpolo = import ./home/jpolo.nix;

# home/jpolo.nix (182 lines, everything mixed)
{
  home.username = "jpolo";
  home.packages = [ firefox discord vscode gimp ... ]; # All 50+ packages
  programs.git.userName = "Javier Polo Gambin";
}
```

### After (Best Practice)

```nix
# flake.nix
let
  users = import ./home/users;  # Import all users
in {
  home-manager.users = users.forHost "ares";  # Returns: { jpolo = {...}; }
}

# home/users/jpolo.nix (20 lines, just identity + choices)
{
  imports = [ ./shared.nix ];
  
  home.username = "jpolo";
  
  programs.git = {
    userName = "Javier Polo Gambin";
    userEmail = "javier.polog@outlook.com";
  };
  
  profiles = {
    base.enable = true;
    desktop.enable = true;
    development.enable = true;
    personal.enable = true;
  };
}

# home/profiles/personal.nix (15 lines, optional apps)
{ config, lib, pkgs, ... }:
{
  options.profiles.personal.enable = lib.mkEnableOption "personal apps";
  
  config = lib.mkIf config.profiles.personal.enable {
    home.packages = with pkgs; [
      discord
      spotify
      obsidian
    ];
  };
}
```

---

## 🎁 Benefits of Refactoring

1. **Multi-User Support** ✅
   - Add new users in minutes
   - Each user chooses their own profiles
   - Shared configs, different identities

2. **Portability** ✅
   - Move user to different machine
   - Copy `users/jpolo.nix` + adjust hostname
   - Everything else works automatically

3. **Consistency** ✅
   - All users get same base tools
   - Optional profiles for specialization
   - No duplication

4. **Maintainability** ✅
   - Clear separation of concerns
   - Easy to find and edit configs
   - Type-safe with options

5. **Flexibility** ✅
   - Mix and match profiles
   - Different users, different profiles
   - Same user, different profiles per machine

---

## 🚀 Implementation Plan

1. ✅ **Analyze** current structure (DONE - this document)
2. ⏳ **Create** `home/profiles/` with option system
3. ⏳ **Create** `home/users/` with user definitions
4. ⏳ **Refactor** `home/programs/` to be portable
5. ⏳ **Update** `flake.nix` for multi-user support
6. ⏳ **Test** with current user (jpolo)
7. ⏳ **Add** second user as proof of concept
8. ⏳ **Document** new architecture

---

## 📚 References

- [NixOS Wiki: Home Manager](https://nixos.wiki/wiki/Home_Manager)
- [Home Manager Manual: Multi-User](https://nix-community.github.io/home-manager/)
- [Misterio77/nix-config](https://github.com/Misterio77/nix-config) - Best practice example

---

**Conclusion**: Current setup works for single user, but violates portability and multi-user best practices. Refactoring recommended.
