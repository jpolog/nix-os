# Home Manager Configuration Fixes - Complete Summary

## Issues Found and Fixed

### ❌ Issue 1: Duplicate Module Imports (CRITICAL)
**Problem:** Multiple program modules were imported twice:
- `jpolo.nix` imported `../programs` (which imports ALL program modules)
- `development.nix` RE-imported: `git.nix`, `neovim.nix`, `terminal-tools.nix`
- `desktop.nix` RE-imported: `firefox.nix`, `kitty.nix`, `walker.nix`, `swayosd.nix`

**Impact:** Could cause infinite recursion errors, duplicate option definitions, build failures

**Fix:** ✅ Implemented Option 2 - Conditional Programs
- Removed global import of `../programs` from `jpolo.nix`
- Made each program conditional on its profile's enable option
- Profiles now import only their specific programs

### ❌ Issue 2: Redundant home-manager Settings
**Problem:** home-manager settings defined in TWO places:
- `flake.nix` (lines 115-122) - sharedModules
- `hosts/ares/configuration.nix` (lines 127-135) - duplicate settings

**Impact:** Confusion about which settings apply, potential conflicts

**Fix:** ✅ Removed duplicate settings from `configuration.nix`
- Settings now only in `flake.nix` (single source of truth)
- Kept only tmpfiles and systemd service setup in host config

### ❌ Issue 3: Programs Always Enabled
**Problem:** All program modules had hardcoded `enable = true`
- Programs loaded regardless of profile settings
- No way to conditionally disable features

**Fix:** ✅ Made programs conditional on profile options
- Development programs: conditional on `development.enable`
- Desktop programs: conditional on `desktop.enable`
- Base programs: always available (shell, services)

---

## Final Architecture

### Import Structure:
```
jpolo.nix
├─ services/default.nix       ← Always imported (mako, hyprsunset)
├─ shell/default.nix          ← Always imported (zsh, starship)
└─ profiles/default.nix       ← Profile system
    │
    ├─ base.nix               ← Always enabled (core CLI tools)
    │
    ├─ desktop.nix            ← Conditionally enabled
    │   └─ imports:
    │       ├─ firefox.nix
    │       ├─ kitty.nix
    │       ├─ walker.nix
    │       ├─ swayosd.nix
    │       ├─ xcompose.nix
    │       └─ hyprland/
    │
    ├─ development.nix        ← Conditionally enabled
    │   └─ imports:
    │       ├─ git.nix
    │       ├─ neovim.nix
    │       ├─ terminal-tools.nix
    │       └─ power-user.nix
    │
    ├─ personal.nix           ← Conditionally enabled (packages only)
    └─ creative.nix           ← Conditionally enabled (packages only)
```

### Program Conditional Logic:

#### Home Manager Native Programs (use `programs.*`):
```nix
# git.nix, firefox.nix, kitty.nix, neovim.nix
programs.PROGRAM = {
  enable = lib.mkDefault (config.home.profiles.PROFILE.enable or false);
  # ... configuration ...
};
```

#### Custom Programs (use `home.packages`):
```nix
# walker.nix, swayosd.nix, xcompose.nix, power-user.nix
with lib;
{
  config = mkIf (config.home.profiles.PROFILE.enable or false) {
    home.packages = [ ... ];
    # ... configuration ...
  };
}
```

---

## Configuration Files Modified

### 1. `/home/users/jpolo.nix`
**Changed:**
```diff
  imports = [
-   ../programs      # Removed global import
    ../services
    ../shell
    ../profiles
  ];
```

### 2. `/home/profiles/development.nix`
**Changed:**
```diff
+ # Import development program configurations
+ imports = [
+   ../programs/git.nix
+   ../programs/neovim.nix
+   ../programs/terminal-tools.nix
+   ../programs/power-user.nix
+ ];
```

### 3. `/home/profiles/desktop.nix`
**Changed:**
```diff
+ # Import desktop program configurations
+ imports = [
+   ../programs/firefox.nix
+   ../programs/kitty.nix
+   ../programs/walker.nix
+   ../programs/swayosd.nix
+   ../programs/xcompose.nix
+   ../hyprland
+ ];
```

### 4. `/hosts/ares/configuration.nix`
**Changed:**
```diff
- home-manager = {
-   useGlobalPkgs = true;
-   useUserPackages = true;
-   extraSpecialArgs = {
-     inherit inputs;
-     hostname = "ares";
-   };
- };
```

### 5. `/home/programs/git.nix`
**Changed:**
```diff
- programs.git = {
-   enable = true;
+ programs.git = {
+   enable = lib.mkDefault (config.home.profiles.development.enable or false);
```

### 6. `/home/programs/neovim.nix`
**Changed:**
```diff
- programs.neovim = {
-   enable = true;
+ programs.neovim = {
+   enable = lib.mkDefault (config.home.profiles.development.enable or false);
```

### 7. `/home/programs/firefox.nix`
**Changed:**
```diff
- programs.firefox = {
-   enable = true;
+ programs.firefox = {
+   enable = lib.mkDefault (config.home.profiles.desktop.enable or false);
```

### 8. `/home/programs/kitty.nix`
**Changed:**
```diff
- programs.kitty = {
-   enable = true;
+ programs.kitty = {
+   enable = lib.mkDefault (config.home.profiles.desktop.enable or false);
```

### 9. `/home/programs/walker.nix`
**Changed:**
```diff
+ with lib;
  {
+   config = mkIf (config.home.profiles.desktop.enable or false) {
      # ... all configuration ...
+   };
  }
```

### 10. `/home/programs/swayosd.nix`
**Changed:**
```diff
+ with lib;
  {
+   config = mkIf (config.home.profiles.desktop.enable or false) {
      # ... all configuration ...
+   };
  }
```

### 11. `/home/programs/xcompose.nix`
**Changed:**
```diff
+ with lib;
  {
+   config = mkIf (config.home.profiles.desktop.enable or false) {
      # ... all configuration ...
+   };
  }
```

### 12. `/home/programs/power-user.nix`
**Changed:**
```diff
+ with lib;
  {
+   config = mkIf (config.home.profiles.development.enable or false) {
      # ... all configuration ...
+   };
  }
```

---

## How To Use

### Enable/Disable Profiles
In `/home/users/jpolo.nix` or directly in host configuration:

```nix
home.profiles = {
  base.enable = true;              # Core tools (always recommended)
  desktop.enable = true;            # GUI apps, Hyprland, browsers
  development.enable = true;        # Dev tools, editors, shells
  personal.enable = true;           # Communication, media apps
  creative.enable = true;           # GIMP, Inkscape, etc.
};
```

### Profile-Specific Options
```nix
home.profiles = {
  development = {
    enable = true;
    devShells.enable = true;
    editors.vscode.enable = true;
    editors.neovim.enable = true;
  };
  
  personal = {
    enable = true;
    communication.enable = true;
    media.enable = true;
    productivity.enable = false;    # Disable specific sub-features
  };
};
```

---

## Benefits of This Architecture

### ✅ Modularity
- Each profile manages its own programs
- Easy to add new profiles or programs
- Clear separation of concerns

### ✅ Flexibility
- Enable/disable entire feature sets with one option
- Mix and match profiles per host
- Override individual program settings

### ✅ No Conflicts
- Each module imported exactly once
- Profiles control when programs load
- No duplicate definitions

### ✅ Best Practices
- Follows NixOS module system patterns
- Uses `mkIf` and `mkDefault` properly
- Clear dependency chain

### ✅ Maintainability
- Easy to understand import structure
- Programs grouped by purpose
- Conditional logic explicit and clear

---

## Testing Your Configuration

### Build the Configuration:
```bash
sudo nixos-rebuild build --flake /etc/nixos#ares
```

### Test Without Switching:
```bash
sudo nixos-rebuild test --flake /etc/nixos#ares
```

### Switch to New Configuration:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

### Home Manager Only:
```bash
home-manager switch --flake /etc/nixos#ares
```

### Verify Programs Load Correctly:
```bash
# Check if firefox is enabled
nix eval --raw /etc/nixos#nixosConfigurations.ares.config.home-manager.users.jpolo.programs.firefox.enable

# List all home packages
home-manager packages
```

---

## Next Steps

1. **Test the configuration** - Build and verify it works
2. **Add more hosts** - Use the same profile system for other machines
3. **Customize profiles** - Add host-specific profile overrides
4. **Create new profiles** - Add gaming, server, or other specialized profiles

---

## Summary

✅ **All home-manager issues fixed**  
✅ **Conditional program loading implemented**  
✅ **No duplicate imports**  
✅ **Following best practices**  
✅ **Modular and maintainable architecture**  

Your NixOS configuration is now properly structured and ready to build!
