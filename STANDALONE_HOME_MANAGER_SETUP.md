# Standalone Home-Manager Setup

## What Changed

**REMOVED** home-manager as NixOS module (the source of all problems!)

**ADDED** standalone home-manager configuration in `/home-manager-standalone/`

## Why This Is Better

✅ **Independent** - Home-manager doesn't rely on NixOS rebuild  
✅ **User-level** - You control it, not root  
✅ **No systemd service** - No mysterious activation failures  
✅ **Easier debugging** - Clear error messages  
✅ **Faster rebuilds** - Only rebuild what you need  

## Setup Instructions

### Step 1: Rebuild NixOS (without home-manager module)

```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

This should now work! The system no longer tries to activate home-manager.

### Step 2: Set up standalone home-manager (as user jpolo)

```bash
# Switch to user jpolo
su - jpolo

# Copy the home-manager config to your home directory
mkdir -p ~/.config/home-manager
cp /etc/nixos/home-manager-standalone/flake.nix ~/.config/home-manager/

# Initialize and activate
cd ~/.config/home-manager
nix run home-manager/master -- switch --flake .
```

### Step 3: Future updates

As user jpolo:

```bash
# Update home-manager config
vim ~/.config/home-manager/flake.nix

# Apply changes
home-manager switch --flake ~/.config/home-manager
```

## Adding More Programs

Edit `~/.config/home-manager/flake.nix` and add to the `modules` list:

```nix
# Firefox
programs.firefox.enable = true;

# Kitty
programs.kitty = {
  enable = true;
  font.name = "JetBrainsMono Nerd Font";
  font.size = 11;
};

# Neovim
programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;
};

# Add packages
home.packages = with pkgs; [
  firefox
  kitty
  vscode
  # ... more packages
];
```

## System vs Home-Manager

**NixOS manages** (in `/etc/nixos`):
- System services
- Kernel
- Boot loader
- System-wide packages
- Users and groups

**Home-Manager manages** (in `~/.config/home-manager`):
- User dotfiles
- User programs
- Shell configuration
- User services

## Benefits

1. **System rebuild doesn't affect home-manager** - They're independent
2. **No sudo needed for user config** - Just `home-manager switch`
3. **Faster iterations** - Change dotfiles without system rebuild
4. **Clear separation** - System vs user configuration
5. **Actually works** - No mysterious activation failures!

## Next Steps

1. Build NixOS: `sudo nixos-rebuild switch --flake /etc/nixos#ares`
2. Set up home-manager as user: Follow Step 2 above
3. Customize: Edit `~/.config/home-manager/flake.nix`
4. Apply: `home-manager switch --flake ~/.config/home-manager`

This is how many NixOS users actually run their systems!
