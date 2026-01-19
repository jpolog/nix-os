# Home-Manager Configuration - Final Working Solution

## The Problem We Hit

**Error:** `home-manager-jpolo.service` failed to activate

**Root Cause:** Circular dependency / evaluation order issue

When we tried to make programs conditional by reading `config.home.profiles.X.enable`:
```nix
# This DOESN'T WORK in NixOS module system
programs.git.enable = mkDefault (config.home.profiles.development.enable or false);
```

**Why it fails:**
1. Profiles import programs
2. Programs try to read profile options
3. But those options are defined IN the profiles being imported
4. NixOS module system can't resolve this circular reference

## The Solution: NixOS Module Pattern

### Architecture:
```
jpolo.nix
├─ programs/ (ALL programs imported, defaulting to disabled)
├─ services/ (always loaded)
├─ shell/ (always loaded)
└─ profiles/ (define options, enable programs when active)
```

### How It Works:

#### 1. Programs Default to Disabled
```nix
# home/programs/git.nix
programs.git = {
  enable = lib.mkDefault false;  # Disabled by default
  # ... configuration ...
};
```

#### 2. ALL Programs Imported from jpolo.nix
```nix
# home/users/jpolo.nix
imports = [
  ../programs    # Import ALL programs (they're disabled)
  ../services
  ../shell
  ../profiles
];
```

#### 3. Profiles Enable Their Programs
```nix
# home/profiles/development.nix
options.home.profiles.development = {
  enable = mkEnableOption "development tools profile";
};

config = mkIf config.home.profiles.development.enable {
  # Enable the programs this profile needs
  programs.git.enable = true;
  programs.neovim.enable = true;
  
  # Add packages
  home.packages = [ ... ];
};
```

#### 4. User Enables Profiles
```nix
# In host configuration or jpolo.nix
home.profiles = {
  base.enable = true;
  desktop.enable = true;
  development.enable = true;
};
```

### Evaluation Flow:
1. ✅ jpolo.nix imports programs → All programs loaded but DISABLED
2. ✅ jpolo.nix imports profiles → Profile options defined
3. ✅ Profiles check their enable option → If true, enable their programs
4. ✅ Programs that got enabled activate → Configuration applies
5. ✅ Programs that stayed disabled → Ignored by system

### Key Benefits:
- ✅ No circular dependencies
- ✅ No evaluation order issues  
- ✅ Clean separation: programs define configs, profiles enable them
- ✅ Follows NixOS module system patterns

## Files Structure:

### Programs (All default to disabled):
- `/home/programs/git.nix` - `enable = mkDefault false`
- `/home/programs/neovim.nix` - `enable = mkDefault false`
- `/home/programs/firefox.nix` - `enable = mkDefault false`
- `/home/programs/kitty.nix` - `enable = mkDefault false`
- `/home/programs/walker.nix` - packages (loaded when imported)
- `/home/programs/swayosd.nix` - packages (loaded when imported)
- `/home/programs/xcompose.nix` - packages (loaded when imported)
- `/home/programs/power-user.nix` - packages (loaded when imported)

### Profiles (Enable programs):
- `/home/profiles/development.nix`:
  - Enables: git, neovim, terminal-tools
  - Includes: power-user packages
  
- `/home/profiles/desktop.nix`:
  - Enables: firefox, kitty
  - Includes: walker, swayosd, xcompose, hyprland

### User Config:
- `/home/users/jpolo.nix`:
  - Imports: programs, services, shell, profiles
  - Sets: profile enables

## Why This Pattern Works:

### mkDefault Priority System:
```nix
# Program defaults to false
programs.git.enable = mkDefault false;  # Priority 1000

# Profile sets to true (higher priority)
programs.git.enable = true;  # Priority 100 (wins!)
```

The profile's `true` overrides the program's `mkDefault false`.

### No Circular Dependencies:
- Programs DON'T read profile options
- Profiles read their OWN options (defined in same file)
- Profiles WRITE to program options (defined elsewhere)
- Clean unidirectional data flow

## Testing:

### Build:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

### Verify Programs:
```bash
# Should be available (development.enable = true)
which git neovim

# Should be available (desktop.enable = true)  
which firefox kitty
```

### Disable a Profile:
```nix
home.profiles.development.enable = false;
```
Result: git, neovim, etc. won't be in your PATH

## This is the Proper NixOS Way ✅

This pattern is used throughout nixpkgs and by NixOS experts because:
1. Modules define options with defaults
2. Other modules set those options  
3. No circular reads
4. Priority system handles conflicts
5. Clean, maintainable, debuggable

Your configuration now follows this pattern correctly!
