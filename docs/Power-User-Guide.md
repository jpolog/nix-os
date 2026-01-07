# Power User Guide

Advanced tools, configurations, and workflows for power users.

## Philosophy

This configuration includes:
- **200+ Tools** - Best-in-class CLI utilities
- **No Bloatware** - Every tool serves a purpose
- **Keyboard-Driven** - Minimize mouse usage
- **Highly Customizable** - Declarative configuration
- **Performance-Focused** - Optimized for speed

## Enhanced Shell Features

### Advanced Functions

Over 40 custom shell functions:

```bash
# Directory Navigation
z <partial-name>     # Smart jump to frequently used directories
mkcd <dir>           # Create and enter directory
d                    # Show directory stack
1-9                  # Jump to directory in stack

# File Operations
x <archive>          # Extract any archive type
bak <file>           # Backup file with timestamp
optimg <images>      # Optimize PNG/JPEG images
largest [dir]        # Find largest files

# System Analysis
sysinfo              # Quick system stats
memtop               # Top memory consumers
cputop               # Top CPU consumers
port <number>        # Find process using port
stats                # Comprehensive system stats

# Development
serve [port]         # Quick HTTP server (default: 8000)
json                 # Pretty print JSON
bench <cmd>          # Benchmark command with hyperfine
gclone <url>         # Clone and cd into repo

# Utilities
genpass [length]     # Generate secure password
calc <expression>    # Quick calculator
wttr [city]          # Weather forecast
cheat <topic>        # Cheat sheets from cheat.sh
n                    # Daily note
todo [task]          # Quick todo management
```

### FZF Enhanced

Every operation with FZF integration:

```bash
fe                   # Find and edit file
fcd                  # Find and cd to directory
fh                   # Search command history
fk                   # Kill process interactively
fgl                  # Git log browser
gwt                  # Git worktree with FZF
ts                   # Tmux session switcher
```

## Power User Tools

### System Analysis

```bash
# Comprehensive system analysis
sys-analyze          # Quick analysis
sys-analyze --full   # Full diagnostics

# Performance profiling
perf-profile <command>  # Profile with perf and flamegraph

# System monitoring
btm                  # Bottom (modern htop)
zenith               # Another modern monitor
glances              # Cross-platform monitor
```

### Network Tools

```bash
# Network monitoring
bandwhich            # Bandwidth usage by process
nethogs              # Per-process network usage
iftop                # Network traffic
mtr <host>           # Network diagnostics

# Network analysis
termshark            # TUI for Wireshark
rustscan             # Fast port scanner
dog <domain>         # Modern dig
gping <host>         # Ping with graph

# HTTP tools
httpie <url>         # User-friendly HTTP client
xh <url>             # HTTPie in Rust
curlie <url>         # Curl with colors
```

### File Management

```bash
# Terminal file managers
ranger               # Feature-rich
nnn                  # Blazing fast
lf                   # Simple and fast
vifm                 # Vi-style

# Disk analysis
ncdu                 # Interactive disk usage
gdu                  # Fast disk usage
dust                 # Visual disk usage
duf                  # Modern df
```

### Text Processing

```bash
# JSON
jq                   # JSON processor
fx                   # JSON viewer
jless                # JSON pager

# YAML
yq                   # YAML processor
dasel                # Query JSON/YAML/XML

# CSV
xsv                  # CSV toolkit
miller               # CSV/JSON processor

# Grep alternatives
rg <pattern>         # Ripgrep (faster grep)
ast-grep             # AST-based search
semgrep              # Semantic search
```

### Git Power Tools

```bash
# Enhanced git workflow
git-recent           # Browse and switch recent branches
git-absorb           # Automatic commit fixup
gita                 # Manage multiple repos

# Git visualization
lazygit              # Terminal UI for git
tig                  # Text-mode interface

# GitHub integration
gh                   # GitHub CLI
gh-dash              # GitHub dashboard
```

### Container Tools

```bash
# Docker
lazydocker           # Docker TUI
dive <image>         # Explore Docker images
ctop                 # Container monitoring
docker-mon           # Custom monitoring script

# Kubernetes
k9s                  # Kubernetes TUI
stern <pod>          # Multi-pod log tailing
kubectx              # Context switching
kubens               # Namespace switching
```

### Cloud & Infrastructure

```bash
# Cloud CLIs
aws                  # AWS CLI
gcloud               # Google Cloud
az                   # Azure
doctl                # DigitalOcean
flyctl               # Fly.io

# Infrastructure as Code
terraform            # HashiCorp Terraform
terragrunt           # Terraform wrapper
pulumi               # Modern IaC
ansible              # Configuration management
```

### Database Tools

```bash
# Interactive CLIs
pgcli                # PostgreSQL with autocomplete
mycli                # MySQL with autocomplete
litecli              # SQLite with autocomplete
usql                 # Universal SQL CLI
```

### Development Tools

```bash
# Code editors
nvim                 # Neovim (LazyVim)
helix                # Modern modal editor
micro                # Simple terminal editor

# LSP servers (pre-configured)
# - nil (Nix)
# - pyright (Python)
# - rust-analyzer (Rust)
# - gopls (Go)
# - typescript-language-server
# - yaml-language-server
# - bash-language-server

# Formatters
alejandra            # Nix formatter
black                # Python formatter
prettier             # JavaScript/TypeScript
rustfmt              # Rust formatter
gofmt                # Go formatter
shfmt                # Shell script formatter

# Linters
shellcheck           # Shell scripts
hadolint             # Dockerfiles
yamllint             # YAML files
```

### Nix Power Tools

```bash
# Enhanced Nix REPL
nix-repl-advanced    # REPL with helpful prelude

# Package search
nix-search <package> # Interactive search with install options

# Development environments
dev-env <name> <type>  # Quick project setup

# Nix utilities
nix-tree             # Visualize dependencies
nix-diff             # Compare derivations
vulnix               # Security scanner
```

### Security & Privacy

```bash
# Encryption
age                  # Modern encryption
gpg                  # PGP encryption

# Password managers
pass                 # Unix password manager
gopass               # Team password manager

# Security scanning
lynis                # Security audit
gitleaks             # Find secrets in git
```

### Productivity

```bash
# Note taking
obsidian             # Knowledge base
logseq               # Knowledge graph

# Time tracking
timewarrior          # Time tracking
watson               # Time tracking CLI

# Task management
taskwarrior          # Todo management
```

### Multimedia

```bash
# Images
imagemagick          # Image manipulation
oxipng               # PNG optimizer
jpegoptim            # JPEG optimizer

# Video
ffmpeg               # Video processing

# Screenshots
flameshot            # Screenshot tool
grim + slurp         # Wayland screenshots
```

### Advanced Terminal

```bash
# Multiplexers
tmux                 # Terminal multiplexer
zellij               # Modern tmux alternative
byobu                # Enhanced tmux

# Terminal emulators
kitty                # GPU-accelerated (default)
alacritty            # Fast alternative
wezterm              # Feature-rich
```

## Performance Optimization

### System Tuning

The configuration includes:
- **BBR TCP** congestion control
- **zram** for compressed swap
- **Optimized I/O schedulers** (NVMe, SSD, HDD)
- **Huge pages** support
- **CPU microcode** updates
- **Firmware updates** (fwupd)

### Monitoring

```bash
# Real-time monitoring
btm                  # Resource monitor
iotop                # I/O monitor
nethogs              # Network monitor

# Statistics
sysstat              # Performance tools (sar, iostat)
dstat                # Versatile stats

# Profiling
perf-profile <cmd>   # Profile and generate flamegraph
hyperfine <cmd>      # Benchmark commands
```

## Keyboard Shortcuts

All tools configured for keyboard-first workflow:

### Hyprland (Vim-style)
- `Super + H/J/K/L` - Navigate windows
- `Super + 1-9` - Switch workspaces
- `Super + Enter` - Terminal
- `Super + R` - Launcher

### Tmux
- `Ctrl+A` - Prefix
- `Ctrl+A H/J/K/L` - Navigate panes
- `Ctrl+A |` - Split horizontal
- `Ctrl+A -` - Split vertical

### Vim/Neovim
- Fully configured LazyVim setup
- 50+ plugins
- LSP for all languages

## Customization

### Adding Tools

All tools are declared in Nix:

```nix
# home/programs/power-user.nix
home.packages = with pkgs; [
  your-tool
];
```

### Custom Functions

Add to `home/shell/power-user-functions.nix`:

```nix
programs.zsh.initExtra = lib.mkAfter ''
  my-function() {
    # Your code here
  }
'';
```

### Aliases

Edit `home/shell/zsh.nix`:

```nix
shellAliases = {
  myalias = "command";
};
```

## Workflows

### Development Workflow

```bash
# 1. Create project
dev-env myproject python

# 2. Navigate
cd myproject
direnv allow

# 3. Code
nvim .

# 4. Test
# Tools automatically available

# 5. Version control
git init
git add .
gcm "Initial commit"
```

### System Administration

```bash
# 1. Check health
check-system

# 2. Analyze issues
sys-analyze --full

# 3. Monitor resources
btm

# 4. Profile performance
perf-profile problem-command
```

### Multi-Repo Management

```bash
# 1. Setup gita
gita add <repos>

# 2. Batch operations
gita pull
gita status
gita commit -am "Update"
```

## Pro Tips

1. **Use zoxide**: After a while, `z proj` jumps to your project directory
2. **FZF everything**: Almost every operation has FZF integration
3. **Tmux/Zellij**: Use multiplexers for persistent sessions
4. **LazyGit**: Visual git interface speeds up workflow
5. **nnn with preview**: File manager with live previews
6. **Clipboard sync**: wl-clipboard syncs between Wayland and terminal
7. **Man pages**: Use `tldr` for quick examples, `man` for full docs
8. **Benchmarking**: Use `hyperfine` before optimizing
9. **Profiling**: Generate flamegraphs with `perf-profile`
10. **Documentation**: `zeal` for offline docs
11. **Port Management**: Use `portctl` for organized development ports

## Port Management

Sophisticated system for managing development ports. See [Port Management Guide](Port-Management.md) for full details.

Quick reference:
```bash
# List active ports
ports             # or: portctl list

# Find what's using a port
pf 3000           # or: portctl find 3000

# Kill process on port
pk 8080           # or: portctl kill 8080

# Get recommended port for service type
prec frontend     # or: portctl recommend frontend

# Check port availability
pc 5432           # or: portctl check 5432

# View port registry
portctl registry
```

Port ranges:
- **3000-3999**: Frontend (React, Vue, Angular, etc.)
- **4000-4999**: Backend APIs (Express, Django, FastAPI, etc.)
- **5000-5999**: Databases (PostgreSQL, Redis, MongoDB, etc.)
- **6000-6999**: Message queues (RabbitMQ, Kafka, etc.)
- **7000-7999**: DevOps tools (Jenkins, Grafana, etc.)
- **8000-8999**: Containers (Docker, K8s dashboards, etc.)
- **9000-9999**: Testing & development servers

## Security Considerations

All power-user tools are:
- ✅ From nixpkgs (verified)
- ✅ Sandboxable with firejail
- ✅ No telemetry/tracking
- ✅ Open source
- ✅ Regularly updated

## Gaming/Testing Profile

Completely isolated profile for untrusted software:

```bash
# Switch to gaming user (login screen)
# Username: gaming

# Or from main user:
sudo -u gaming firejail --private bash
```

Features:
- **No sudo access** - Cannot elevate privileges
- **Isolated home** - Separate /home/gaming
- **Resource limits** - Max 8GB RAM, 4 CPU cores
- **No network** (optional) - Configurable
- **Read-only system** - Cannot modify /nix, /etc
- **Sandboxed** - Firejail + AppArmor
- **Cannot access main user** files

See [Gaming Profile docs](Gaming-Profile.md) for details.

## Learning Resources

- `tldr <command>` - Quick examples
- `man <command>` - Full documentation
- `<command> --help` - Built-in help
- `cheat <topic>` - Community cheat sheets
- Scripts have `--help` flags

## Summary

Power-user setup includes:
- **200+ tools** - Best CLI utilities
- **40+ shell functions** - Productivity boosters
- **100+ aliases** - Common operations
- **Full LSP support** - All languages
- **Performance tuned** - Optimized system
- **Keyboard-driven** - Minimal mouse usage
- **Fully declarative** - Everything in Nix
- **Secure** - Isolated gaming profile

---

**Power through your workflow!** ⚡
