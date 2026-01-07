# Declarative Principles

This configuration follows strict declarative principles. Everything is managed through Nix configuration files.

## What is Declarative Configuration?

**Declarative**: You declare what you want, not how to get it.

```nix
# Declarative: Describe the desired state
users.users.jpolo = {
  isNormalUser = true;
  shell = pkgs.zsh;
};

# NOT imperative: useradd jpolo; chsh -s /bin/zsh jpolo
```

## Core Principles

### ✅ Everything in Nix

All system configuration is in `.nix` files:
- Users and groups
- Packages
- Services
- Configuration files
- Secrets (encrypted)
- Environment variables

### ✅ Reproducible

Same configuration = Same system:
```bash
# Machine 1
sudo nixos-rebuild switch --flake .#ares

# Machine 2 (identical result!)
sudo nixos-rebuild switch --flake .#ares
```

### ✅ Atomic Updates

Changes are applied atomically:
- Either fully succeeds or fully fails
- No half-configured state
- Can rollback instantly

### ✅ Rollback-able

Every build creates a new generation:
```bash
# Rollback to previous
sudo nixos-rebuild --rollback

# Or select at boot (GRUB/systemd-boot menu)
```

## What's Declarative Here?

### System Level
```nix
# hosts/ares/configuration.nix
{
  # Hostname (not set with 'hostnamectl')
  networking.hostName = "ares";
  
  # Timezone (not set with 'timedatectl')
  time.timeZone = "Europe/Madrid";
  
  # Locale (not set in /etc/locale.conf)
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Users (not created with 'useradd')
  users.users.jpolo = {
    isNormalUser = true;
    description = "Javier Polo Gambin";
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };
  
  # Packages (not installed with package manager)
  environment.systemPackages = with pkgs; [
    vim git curl
  ];
  
  # Services (not enabled with 'systemctl enable')
  services.openssh.enable = true;
}
```

### User Level (Home Manager)
```nix
# home/jpolo.nix
{
  # Git config (not set with 'git config')
  programs.git = {
    enable = true;
    userName = "Javier Polo Gambin";
    userEmail = "javier.polog@outlook.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
  
  # Shell config (not set in ~/.zshrc manually)
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "eza -lah";
    };
  };
  
  # Application settings (not set manually)
  programs.kitty = {
    enable = true;
    font.size = 12;
    theme = "Catppuccin-Mocha";
  };
}
```

### Secrets (sops-nix)
```nix
# modules/system/secrets.nix
{
  # SSH key (not copied manually)
  sops.secrets.ssh_private_key = {
    owner = "jpolo";
    path = "/home/jpolo/.ssh/id_ed25519";
    mode = "0600";
  };
  
  # WiFi password (not set in NetworkManager manually)
  sops.secrets.wifi_password = { };
  networking.wireless.networks."SSID".pskFile = 
    config.sops.secrets.wifi_password.path;
  
  # User password (not set with 'passwd')
  sops.secrets.jpolo_password.neededForUsers = true;
  users.users.jpolo.hashedPasswordFile = 
    config.sops.secrets.jpolo_password.path;
}
```

## What's NOT Declarative?

Only 2 things are imperative (by design):

### 1. Hardware Configuration
```bash
# Must be generated per machine
sudo nixos-generate-config --show-hardware-config > hosts/ares/hardware-configuration.nix
```

**Why?** Hardware varies between machines. This file contains:
- Disk partitions and filesystems
- Boot loader configuration
- Hardware-specific kernel modules

### 2. Age Private Key
```bash
# Must be generated on target machine
age-keygen -o ~/.config/sops/age/keys.txt
```

**Why?** Private keys must never be in git or shared. They stay on the machine.

Everything else is fully declarative!

## Anti-Patterns to Avoid

### ❌ Don't: Manual Configuration Files
```bash
# DON'T DO THIS:
vim /etc/ssh/sshd_config
vim ~/.gitconfig
echo "alias ll='ls -la'" >> ~/.zshrc
```

**Instead**: Declare in Nix:
```nix
services.openssh.extraConfig = "...";
programs.git.extraConfig = { ... };
programs.zsh.shellAliases.ll = "ls -la";
```

### ❌ Don't: Manual Package Installation
```bash
# DON'T DO THIS:
nix-env -iA nixpkgs.vim
sudo apt install vim  # Won't work anyway on NixOS!
```

**Instead**: Declare in configuration:
```nix
environment.systemPackages = [ pkgs.vim ];
# or
home.packages = [ pkgs.vim ];
```

### ❌ Don't: Manual User Management
```bash
# DON'T DO THIS:
sudo useradd newuser
sudo usermod -aG wheel newuser
```

**Instead**: Declare in configuration:
```nix
users.users.newuser = {
  isNormalUser = true;
  extraGroups = [ "wheel" ];
};
```

### ❌ Don't: Manual Service Management
```bash
# DON'T DO THIS:
sudo systemctl enable docker
sudo systemctl start docker
```

**Instead**: Declare in configuration:
```nix
virtualisation.docker.enable = true;
```

### ❌ Don't: Storing Secrets in Plain Text
```bash
# DON'T DO THIS:
echo "password123" > /etc/secret.txt
```

**Instead**: Use sops:
```nix
sops.secrets.my_secret = {
  sopsFile = ./secrets/secrets.yaml;
};
```

## Benefits of Declarative Configuration

### 1. Reproducibility
```bash
# Same config = Same system (always)
git clone repo
sudo nixos-rebuild switch --flake .#ares
# Identical system, every time!
```

### 2. Version Control
```bash
# All changes tracked in git
git log
git diff
git revert HEAD
```

### 3. Documentation
```nix
# Configuration IS documentation
users.users.jpolo = {
  # Self-documenting: I can see exactly what's configured
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" ];
};
```

### 4. Testing
```bash
# Test changes without committing
sudo nixos-rebuild test --flake .#ares

# Doesn't affect boot menu
# System reverts on reboot if not switched
```

### 5. Multi-Machine Management
```nix
# Same config, different hosts
nixosConfigurations = {
  ares = { ... };      # ThinkPad
  zeus = { ... };      # Desktop
  hermes = { ... };    # Server
};

# Deploy to any machine
sudo nixos-rebuild switch --flake .#zeus
```

### 6. Easy Rollback
```bash
# Something broke? Rollback instantly!
sudo nixos-rebuild --rollback

# Or select previous generation at boot
```

### 7. Sharing and Collaboration
```bash
# Share your entire system config
git push

# Others can use or learn from it
git clone your-repo
# Study the configuration
```

## How to Stay Declarative

### 1. Before Making Changes
Ask: "Can this be declared in Nix?"

Answer: Almost always YES!

### 2. Workflow
```bash
# 1. Edit .nix files
vim hosts/ares/configuration.nix

# 2. Test (optional)
sudo nixos-rebuild test --flake .#ares

# 3. Apply
sudo nixos-rebuild switch --flake .#ares

# 4. Commit
git add .
git commit -m "Add vim package"
git push
```

### 3. Finding Options
```bash
# Search NixOS options
man configuration.nix

# Search Home Manager options
home-manager option search <term>

# Online
# https://search.nixos.org/options
# https://mipmip.github.io/home-manager-option-search/
```

### 4. When Stuck
If you can't find a declarative way:
1. Search nixpkgs issues/PRs
2. Ask on NixOS discourse
3. Check if it can go in Home Manager
4. Use `environment.etc` or `home.file` as last resort

## Examples

### Configure Firefox
```nix
# Declarative!
programs.firefox = {
  enable = true;
  profiles.default = {
    settings = {
      "browser.startup.homepage" = "https://nixos.org";
      "privacy.trackingprotection.enabled" = true;
    };
  };
};
```

### Configure Vim
```nix
# Declarative!
programs.neovim = {
  enable = true;
  defaultEditor = true;
  plugins = with pkgs.vimPlugins; [
    vim-nix
    telescope-nvim
  ];
  extraConfig = ''
    set number
    set relativenumber
  '';
};
```

### Add Cron Job
```nix
# Declarative!
services.cron = {
  enable = true;
  systemCronJobs = [
    "0 2 * * * root /path/to/backup.sh"
  ];
};
```

### Configure Network
```nix
# Declarative!
networking = {
  hostName = "ares";
  networkmanager.enable = true;
  firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };
};
```

## Summary

**Declarative NixOS means**:
- ✅ Everything in .nix files
- ✅ No manual configuration
- ✅ Fully reproducible
- ✅ Version controlled
- ✅ Self-documenting
- ✅ Easily shared

**NOT**:
- ❌ Manual edits to /etc
- ❌ Running package managers
- ❌ Using systemctl enable/start
- ❌ Editing dotfiles manually

When in doubt: **Put it in a .nix file!**

---

**Remember**: If you can't reproduce it from your git repository, it's not declarative!
