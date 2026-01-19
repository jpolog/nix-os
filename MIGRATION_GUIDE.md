# Migration Guide: Standalone → Integrated Home Manager

## What Changed

You previously had home-manager set up as **standalone**, which required manual copying and activation. Now it's **integrated** into NixOS.

## Before (Standalone)

### Old Process
1. Copy files to `~/.config/home-manager/`
2. Run `nix run home-manager/master -- switch`
3. Manage separately from system

### Problems
- ❌ Two separate rebuild processes
- ❌ System and user configs out of sync
- ❌ Manual steps required
- ❌ Package duplication

## After (Integrated)

### New Process
1. Edit `/etc/nixos/hosts/ares/configuration.nix` or profiles
2. Run `sudo nixos-rebuild switch --flake /etc/nixos#ares`
3. Everything rebuilt together

### Benefits
- ✅ Single rebuild command
- ✅ System and user always in sync
- ✅ No manual steps
- ✅ No package duplication
- ✅ Better modularity

## What Happens on System Rebuild

When you run `sudo nixos-rebuild switch --flake /etc/nixos#ares`:

1. **System level** (modules/profiles/):
   - Installs packages based on enabled profiles
   - Configures system services
   - Sets up Hyprland system-level

2. **Home Manager level** (home/profiles/):
   - Configures installed packages for user jpolo
   - Writes dotfiles to `~/.config/`
   - Sets up systemd user services
   - Configures Hyprland window manager

3. **Result**:
   - User jpolo has fully configured environment
   - Everything declarative and version controlled
   - Reproducible on any NixOS system

## No More Manual Steps!

### Old Way (Standalone)
```bash
# After system rebuild
sudo nixos-rebuild switch

# Then separately for user
su - jpolo
cp /etc/nixos/home-manager-standalone/*.nix ~/.config/home-manager/
nix run home-manager/master -- switch
```

### New Way (Integrated)
```bash
# Just rebuild the system
sudo nixos-rebuild switch --flake /etc/nixos#ares
# That's it! User config is automatically applied
```

## What About ~/.config/home-manager/?

With integrated home-manager:
- ✅ No need for `~/.config/home-manager/`
- ✅ No need to manually copy files
- ✅ No need to run `home-manager switch`

Everything is managed from `/etc/nixos/` and rebuilt with the system.

**You can safely delete** `~/.config/home-manager/` if it exists (after switching to integrated):
```bash
rm -rf ~/.config/home-manager/
```

## Where Configs Live Now

| Old Location | New Location | Purpose |
|-------------|--------------|---------|
| `~/.config/home-manager/home.nix` | `/etc/nixos/home/users/jpolo.nix` | User config |
| `~/.config/home-manager/hyprland.nix` | `/etc/nixos/home/hyprland/*.nix` | Hyprland config |
| `~/.config/home-manager/flake.nix` | `/etc/nixos/flake.nix` | Main flake |

## Verification

After switching to integrated home-manager, verify:

```bash
# Check home-manager is active
systemctl --user status home-manager-jpolo.service

# Check generated configs
ls -la ~/.config/hypr/
ls -la ~/.config/waybar/
ls -la ~/.config/kitty/

# Check user packages
which firefox
which kitty
which hyprctl
```

## Rollback (If Needed)

If you need to rollback to standalone (not recommended):

1. Remove home-manager integration from `/etc/nixos/flake.nix`
2. Comment out `home-manager.users.jpolo` in ares config
3. Use the `home-manager-standalone/` directory again

But you shouldn't need to - integrated is better!

## Key Differences

### Standalone
- Separate flake for home-manager
- Packages installed by home-manager
- Manual rebuild required
- User manages own config

### Integrated (Current)
- Home-manager in system flake
- Packages installed by system
- Automatic rebuild with system
- System manages user config

## Tips

### Still Want to Test Changes?

You can still test home-manager changes without full rebuild:

```bash
# Test specific user config
sudo nixos-rebuild test --flake /etc/nixos#ares

# Or build without switching
sudo nixos-rebuild build --flake /etc/nixos#ares
```

### Edit User Config

User-specific settings go in `/etc/nixos/home/users/jpolo.nix`:

```nix
{
  # Toggle profiles
  home.profiles.desktop.enable = true;
  
  # User-specific git config
  programs.git = {
    userName = "Your Name";
    userEmail = "your@email.com";
  };
  
  # Add user-specific files
  home.file.".custom-config".text = ''
    # Your config
  '';
}
```

## Summary

| Aspect | Standalone | Integrated |
|--------|-----------|-----------|
| Location | `~/.config/home-manager/` | `/etc/nixos/home/` |
| Rebuild | `home-manager switch` | `nixos-rebuild switch` |
| Packages | Home-manager installs | System installs |
| Synced | ❌ No | ✅ Yes |
| Modular | ⚠️ Limited | ✅ Yes |
| Best Practice | ❌ No | ✅ Yes |

## Conclusion

You're now using the **integrated** approach which is:
- More maintainable
- Better organized
- Industry standard
- What most NixOS users do

The `home-manager-standalone/` directory is kept for reference but is no longer needed.

Welcome to proper NixOS configuration! 🎉
