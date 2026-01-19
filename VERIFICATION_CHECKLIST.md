# Verification Checklist

After uploading to remote server and rebuilding, verify everything works:

## Pre-Rebuild Checks

```bash
# Check flake syntax
cd /etc/nixos
nix flake check

# Show what will be built
sudo nixos-rebuild dry-build --flake /etc/nixos#ares
```

## Rebuild

```bash
# Rebuild system with new configuration
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

Expected output:
- Building system
- Activating home-manager for jpolo
- Starting/restarting services

## Post-Rebuild Verification

### 1. Home Manager Integration

```bash
# Check home-manager service
systemctl --user status home-manager-jpolo.service

# Should show: active (exited)
```

### 2. System Packages (Base Profile)

```bash
# Check base tools installed
which vim       # Should find /run/current-system/sw/bin/vim
which git       # Should find git
which eza       # Should find eza
which bat       # Should find bat
which ripgrep   # Should find rg
which htop      # Should find htop
```

### 3. Desktop Packages (Desktop Profile)

```bash
# Check desktop apps installed
which firefox   # Should find firefox
which kitty     # Should find kitty
which hyprctl   # Should find hyprctl
which waybar    # Should find waybar
which grimblast # Should find grimblast
```

### 4. Development Packages (Development Profile)

```bash
# Check dev tools installed
which python3   # Should find python 3.12
which node      # Should find node 22
which docker    # Should find docker
which gh        # Should find gh (GitHub CLI)
which lazygit   # Should find lazygit
```

### 5. Home Manager Configs

```bash
# Check generated configs exist
ls ~/.config/hypr/hyprland.conf
ls ~/.config/waybar/config
ls ~/.config/kitty/kitty.conf
ls ~/.config/mako/

# Check XDG directories created
ls ~/Pictures/Wallpapers/
ls ~/Pictures/Screenshots/
ls ~/Documents/
```

### 6. Shell Configuration

```bash
# Check zsh is default shell
echo $SHELL  # Should be /run/current-system/sw/bin/zsh

# Check environment variables
echo $EDITOR   # Should be nvim
echo $TERMINAL # Should be kitty
echo $BROWSER  # Should be firefox

# Check aliases work
alias ls       # Should show: ls='eza'
alias cat      # Should show: cat='bat'
```

### 7. Git Configuration

```bash
# Check git config
git config --global user.name   # Should be: Javier Polo Gambin
git config --global user.email  # Should be: javier.polog@outlook.com
git config --global init.defaultBranch  # Should be: main

# Check git aliases
git config --global alias.st    # Should be: status
git config --global alias.lg    # Should be: log --graph --oneline...
```

### 8. Starship Prompt

```bash
# Start new zsh session
zsh

# Should see starship prompt with:
# - Current directory
# - Git branch (if in git repo)
# - ➜ character
```

### 9. Hyprland Configuration

```bash
# After logging into Hyprland
hyprctl version
hyprctl clients
hyprctl monitors

# Test keybindings:
# SUPER+Return → Should open kitty
# SUPER+R → Should open walker
# SUPER+B → Should open firefox
```

### 10. Services

```bash
# Check user services running
systemctl --user status waybar
systemctl --user status mako
systemctl --user status hypridle
systemctl --user status swayosd

# All should be active/running
```

### 11. Dev Shell Launchers

```bash
# Check launcher scripts exist
ls -la ~/.local/bin/dev-python
ls -la ~/.local/bin/dev-node
ls -la ~/.local/bin/dev-rust
ls -la ~/.local/bin/dev-go

# Test one
dev-python
# Should launch Python dev shell
```

### 12. Direnv

```bash
# Check direnv installed
which direnv

# Check nix-direnv
direnv version

# Check templates
ls ~/.config/direnv/templates/
```

## Profile Toggle Tests

### Test 1: Disable Desktop

Edit `/etc/nixos/hosts/ares/configuration.nix`:
```nix
profiles.desktop.enable = false;
```

Rebuild and verify:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
which firefox  # Should NOT find firefox
```

Re-enable for next tests.

### Test 2: Enable Rust

Edit `/etc/nixos/hosts/ares/configuration.nix`:
```nix
profiles.development.languages.rust.enable = true;
```

Rebuild and verify:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
which rustc    # Should find rustc
which cargo    # Should find cargo
```

### Test 3: Home Profile Toggle

Edit `/etc/nixos/home/users/jpolo.nix`:
```nix
home.profiles.development.enable = false;
```

Rebuild and verify:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
ls ~/.local/bin/dev-python  # Should NOT exist
```

Re-enable for normal use.

## Troubleshooting

### Issue: home-manager service failed

```bash
# Check logs
journalctl --user -u home-manager-jpolo.service

# Common issues:
# - Syntax error in home config
# - Missing inputs
# - Conflicting options
```

### Issue: Packages not found

```bash
# Check if profile is enabled
sudo nixos-rebuild switch --flake /etc/nixos#ares --show-trace

# Verify in configuration:
# - System profile enabled in hosts/ares/configuration.nix
# - Package listed in modules/profiles/*.nix
```

### Issue: Configs not applied

```bash
# Check if home profile is enabled
# Verify in home/users/jpolo.nix

# Force rebuild home-manager
sudo nixos-rebuild switch --flake /etc/nixos#ares --recreate-lock-file
```

### Issue: Hyprland not starting

```bash
# Check Hyprland logs
cat ~/.hyprland.log

# Check if system has Hyprland enabled
# Should be in modules/desktop/hyprland.nix
```

## Success Criteria

All checks should pass:
- [x] Home-manager service active
- [x] All base packages installed
- [x] All desktop packages installed
- [x] All dev packages installed
- [x] Configs generated in ~/.config/
- [x] Shell configured with aliases
- [x] Git configured correctly
- [x] Starship prompt working
- [x] Hyprland working
- [x] All services running
- [x] Dev launchers working
- [x] Profiles toggle correctly

If all pass: **Configuration is working perfectly!** ✅

If any fail: Check the specific section in this guide for troubleshooting.

## Final Verification

```bash
# This command shows the entire system configuration
nix-store --query --requisites /run/current-system | wc -l
# Should show ~1000+ packages (full NixOS system)

# This shows home-manager generation
home-manager generations
# Should show your generations

# This shows what's in your profile
nix-env --query
# Should show packages installed in user profile
```

## Rollback (If Needed)

```bash
# Rollback system
sudo nixos-rebuild switch --rollback

# Rollback home-manager
home-manager generations
home-manager switch --generation <number>
```

## Success! 🎉

If everything checks out, your NixOS configuration is:
- ✅ Properly structured
- ✅ Following best practices
- ✅ Fully modular
- ✅ Ready for production use

Congratulations! Your NixOS is now perfectly configured! 🚀
