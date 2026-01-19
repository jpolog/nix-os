# Quick Reference: Profile System

## Toggle Features

Edit `/etc/nixos/hosts/ares/configuration.nix`:

### Enable/Disable Entire Profiles
```nix
profiles.base.enable = true;          # Always keep this
profiles.desktop.enable = true;       # Desktop environment
profiles.development.enable = true;   # Dev tools
profiles.gaming.enable = false;       # Gaming (not used yet)
profiles.server.enable = false;       # Server mode (not used yet)
```

### Configure Development Tools
```nix
profiles.development.languages = {
  python.enable = true;    # Python 3.12
  nodejs.enable = true;    # Node.js 22
  rust.enable = false;     # Rust toolchain
  go.enable = false;       # Go
  cpp.enable = false;      # C/C++
  java.enable = false;     # Java JDK 21
  zig.enable = false;      # Zig
};

profiles.development.tools = {
  docker.enable = true;        # Docker + compose
  cloud.enable = false;        # AWS, GCP, Azure CLIs
  kubernetes.enable = false;   # kubectl, k9s, helm
  databases.enable = false;    # PostgreSQL, Redis, etc.
  api.enable = false;          # Postman, Insomnia
};
```

### Configure User Profiles

Edit `/etc/nixos/home/users/jpolo.nix`:

```nix
home.profiles.base.enable = true;         # Shell, git config
home.profiles.desktop.enable = true;      # Desktop app configs
home.profiles.development.enable = true;  # Dev tool configs
home.profiles.creative.enable = false;    # Creative apps (future)
home.profiles.personal.enable = false;    # Personal tools (future)
```

## Rebuild

After any changes:
```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

## What Gets Installed

### Base Profile
- Editors: vim, nano
- CLI tools: wget, curl, git, tree, eza, fd, ripgrep, bat
- Monitoring: htop, btop, neofetch
- Archives: unzip, zip, p7zip

### Desktop Profile  
- Browsers: firefox, chromium
- Terminal: kitty, alacritty
- File managers: thunar, ranger, yazi
- Editors: neovim
- Hyprland ecosystem: waybar, mako, grimblast, etc.
- Apps: bitwarden, obsidian, libreoffice

### Development Profile (with Python + Node.js enabled)
- Base: gh, lazygit, tmux, jq, fzf
- Python: python312, pip, virtualenv, pyright, black
- Node.js: nodejs_22, npm, yarn, pnpm, typescript-language-server
- Docker: docker, docker-compose

## Common Customizations

### Add a New Language
```nix
profiles.development.languages.rust.enable = true;
```

### Remove Unused Apps
System level - edit `modules/profiles/desktop.nix` and comment out unwanted packages.

### Change Default Apps
Edit `home/profiles/desktop.nix`:
```nix
home.sessionVariables = {
  TERMINAL = "alacritty";  # Change from kitty
  BROWSER = "chromium";    # Change from firefox
};
```

### Add User-Specific Package
Edit `hosts/ares/configuration.nix`:
```nix
users.users.jpolo.packages = with pkgs; [
  your-special-package
];
```

## File Locations

| Component | Location | Purpose |
|-----------|----------|---------|
| System packages | `modules/profiles/*.nix` | What to install |
| User configs | `home/profiles/*.nix` | How to configure |
| Host config | `hosts/ares/configuration.nix` | Enable profiles |
| User config | `home/users/jpolo.nix` | User settings |
| Hyprland config | `home/hyprland/*.nix` | Window manager |

## Troubleshooting

### Package not found
Make sure it's in the right profile in `modules/profiles/`

### Config not applied
Check if the home profile is enabled in `home/users/jpolo.nix`

### Service not starting
Check systemd: `systemctl --user status service-name`

### Rebuild fails
Read the error - usually a typo or missing package

## Philosophy

**System = What to install**
```nix
environment.systemPackages = [ pkgs.firefox ];
```

**Home Manager = How to configure**
```nix
programs.firefox.profiles.default.settings = { ... };
```

This separation makes configs modular and reusable!
