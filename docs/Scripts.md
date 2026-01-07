# Scripts Documentation

## Overview

This NixOS configuration includes a comprehensive script management system based on DevOps best practices. All scripts are:
- ✅ Self-documenting with metadata
- ✅ Organized by category
- ✅ Searchable and discoverable
- ✅ Installed system-wide via Nix
- ✅ Version-controlled and reproducible

## Script Manager

### scriptctl

The central script management tool provides a modern interface to discover, search, and execute scripts.

```bash
# List all available scripts
scriptctl list

# List scripts by category
scriptctl list system
scriptctl list dev
scriptctl list util

# Search for scripts
scriptctl search backup
scriptctl search docker

# Show detailed information
scriptctl info update-system

# Run a script
scriptctl run update-system

# Interactive selector (requires fzf)
scriptctl interactive

# List all categories
scriptctl categories
```

## Available Scripts

### System Management Scripts

#### update-system
**Category:** system  
**Description:** Update NixOS system and all flake inputs

```bash
# Update flake and rebuild
update-system

# Only update flake.lock, don't rebuild
update-system --no-rebuild
```

Features:
- Updates all flake inputs
- Rebuilds system using `nh`
- Shows generation diff with `nvd`
- Displays what changed

#### cleanup-system
**Category:** system  
**Description:** Clean up old NixOS generations and optimize store

```bash
# Standard cleanup (keep last 5 generations)
cleanup-system

# Aggressive cleanup (keep last 3 generations)
cleanup-system --aggressive
```

Features:
- Removes old system generations
- Runs garbage collection
- Optimizes Nix store
- Shows before/after disk usage

#### check-system
**Category:** system  
**Description:** Check system health and configuration status

```bash
check-system
```

Checks:
- ✓ Nix version
- ✓ Current generation
- ✓ Flake status and uncommitted changes
- ✓ Disk usage with warnings
- ✓ Critical service status
- ✓ Failed systemd units
- ✓ System uptime and info
- ✓ Git repository status

### Development Scripts

#### dev-env
**Category:** dev  
**Description:** Create a new development environment with common tools

```bash
# Create Python environment
dev-env myproject python

# Create Node.js environment
dev-env webapp node

# Create Rust environment
dev-env api rust

# Create Go environment
dev-env service go

# Create Terraform environment
dev-env infra terraform

# Create Docker environment
dev-env containers docker
```

Creates:
- Project directory
- Nix flake with language-specific dependencies
- `.envrc` for direnv
- `.gitignore` with common patterns
- Initial git repository
- Language-specific init files

#### nix-search
**Category:** dev  
**Description:** Search for Nix packages and show installation commands

```bash
# Search for packages
nix-search python
nix-search rust-analyzer
nix-search postgresql
```

Shows:
- Package search results
- Installation options (system-wide, user, temporary)
- Usage examples

#### portctl
**Category:** dev  
**Description:** Port management utility for organized development

```bash
# List all active ports
portctl list
ports  # alias

# Find what's using a port
portctl find 3000
pf 3000  # alias

# Kill process on port
portctl kill 8080
pk 8080  # alias

# Check if port is available
portctl check 5432
pc 5432  # alias

# Get recommended port for service type
portctl recommend frontend
prec backend  # alias

# View port registry
portctl registry

# Search registry
portctl search postgres

# Show ports in range
portctl range 3000-3999
```

Features:
- Standardized port allocation by category
- Conflict detection and resolution
- Service-specific recommendations
- Complete port registry with documentation

See [Port-Management.md](Port-Management.md) for full details.

#### docker-mon
**Category:** dev  
**Description:** Monitor and manage Docker containers

```bash
docker-mon
```

Displays:
- Running containers
- System usage (df)
- Recent events
- Management command suggestions

### Utility Scripts

#### quick-backup
**Category:** util  
**Description:** Quick system backup to external drive or cloud

```bash
# Backup to /mnt/backup
quick-backup

# Backup to cloud storage (requires rclone config)
quick-backup --cloud
```

Backs up:
- Documents
- Projects
- .config
- .ssh
- NixOS configuration

#### sysmon
**Category:** util  
**Description:** Monitor system resources in real-time

```bash
sysmon
```

Launches the best available system monitor:
1. bottom (btm) - modern, feature-rich
2. btop - colorful, interactive
3. htop - classic, reliable
4. top - fallback

## Script Metadata Format

All scripts follow a standard metadata format for automatic documentation:

```bash
#!/usr/bin/env bash
# Category: system|dev|util
# Description: Brief description of what the script does
# Usage: script-name [options]
# Examples:
#   script-name --option1
#   script-name --option2 value

set -euo pipefail

# Script content here
```

## Adding New Scripts

1. **Create the script file:**
   ```bash
   cd ~/Projects/nix-omarchy/nix/scripts/<category>
   vim new-script
   ```

2. **Add metadata header:**
   ```bash
   #!/usr/bin/env bash
   # Category: dev
   # Description: Does something awesome
   # Usage: new-script [args]
   # Examples:
   #   new-script --help
   ```

3. **Make it executable:**
   ```bash
   chmod +x new-script
   ```

4. **Add to scripts.nix:**
   ```nix
   new-script = pkgs.writeShellScriptBin "new-script" (builtins.readFile ../scripts/<category>/new-script);
   ```

5. **Rebuild system:**
   ```bash
   rebuild
   ```

## Best Practices

### Error Handling
Always use `set -euo pipefail` at the start of scripts:
- `-e`: Exit on error
- `-u`: Error on undefined variables
- `-o pipefail`: Catch errors in pipelines

### Color Output
Use consistent colors across scripts:
- `GREEN`: Success messages
- `BLUE`: Info messages
- `YELLOW`: Warnings
- `RED`: Errors
- `CYAN`: Headers
- `MAGENTA`: Categories

### User Feedback
Provide clear feedback:
```bash
echo -e "${BLUE}🔄 Starting operation...${NC}"
# Do work
echo -e "${GREEN}✅ Operation complete!${NC}"
```

### Argument Parsing
Use clear argument handling:
```bash
while [[ $# -gt 0 ]]; do
    case $1 in
        --option)
            OPTION=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done
```

## Integration with Shell

All scripts are automatically available in your shell. Additionally, common operations have aliases:

```bash
# Script shortcuts
alias update='update-system'
alias clean='cleanup-system'
alias check='check-system'
alias backup='quick-backup'
alias monitor='sysmon'
alias scripts='scriptctl list'
```

## FZF Integration

Use scriptctl's interactive mode for a visual interface:

```bash
scriptctl interactive
# or
scriptctl i
```

Features:
- Fuzzy search through all scripts
- Live preview of script documentation
- Execute with confirmation

## Categories

Scripts are organized into logical categories:

- **system**: System administration and maintenance
- **dev**: Development tools and environments
- **util**: General utilities and helpers

Add new categories by creating directories in `scripts/` and following the naming convention.

## Examples

### Daily Workflow

```bash
# Morning: Check system health
check-system

# Update system weekly
update-system

# Before shutdown: Clean up
cleanup-system

# Create new project
dev-env myapp python
cd myapp
direnv allow
```

### Advanced Usage

```bash
# Search for backup-related scripts
scriptctl search backup

# Run with arguments
scriptctl run dev-env webapp node

# Get detailed info
scriptctl info update-system
```

### Automation

Scripts can be called from other scripts or scheduled tasks:

```bash
# In another script
source /etc/profile
update-system --no-rebuild

# In a systemd timer
ExecStart=/run/current-system/sw/bin/cleanup-system
```

## Troubleshooting

### Script not found
- Ensure it's added to `modules/system/scripts.nix`
- Rebuild system: `rebuild`
- Check installation: `which script-name`

### Permission denied
- Scripts from Nix store are automatically executable
- For development, ensure `chmod +x`

### Metadata not showing
- Check comment format: `# Description:` (with space)
- Ensure proper casing
- Verify scriptctl can read the file

## Future Enhancements

Planned improvements:
- [ ] Script dependency checking
- [ ] Automatic testing framework
- [ ] Script versioning and rollback
- [ ] Remote execution capabilities
- [ ] Integration with notification system
- [ ] Performance metrics collection
- [ ] Script usage statistics

## Contributing

When creating new scripts:
1. Follow the metadata format
2. Use color coding consistently
3. Add comprehensive examples
4. Handle errors gracefully
5. Document all options
6. Test thoroughly before adding
7. Consider edge cases

---

**Built with ❤️ for efficient system management**
