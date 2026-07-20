# OMP Sandbox Wrapper

Two commands are provided:

## `omp` - Standard Mode
Runs Oh My Pi directly on your host. No sandboxing. Full access to your system.

```bash
omp                    # Start in current directory
omp "fix the bug"      # Start with initial prompt
```

## `pp` - Sandbox Mode  
Runs Oh My Pi in a Docker container with your workspace mounted. Files outside the mounted directory are inaccessible.

```bash
pp                           # Sandbox current directory
pp /path/to/project          # Sandbox specific directory
PI_EXTRA_MOUNTS="/home/user/.config:/root/.config" pp   # Add extra mounts
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `PI_SANDBOX_IMAGE` | Docker image to use (default: `oven/bun:alpine`) |
| `PI_EXTRA_MOUNTS` | Comma-separated extra mounts in `host:container` format |
| `ANTHROPIC_API_KEY` | Passed through to container |
| `OPENAI_API_KEY` | Passed through to container |
| `GEMINI_API_KEY` | Passed through to container |
| ... | All other API keys passed through |

### Behavior

1. **Workspace Mount**: The target directory is mounted at `/workspace`
2. **OMP Config**: `~/.omp` is mounted to preserve sessions and config
3. **Session Storage**: Sessions stored in `~/.omp/agent` on host
4. **Isolation**: Container has no access to files outside mounted paths

### Aliases

```nix
home.shellAliases = {
  pi = "omp";          # Quick access to standard mode
  pp = "omp-sandbox";  # Quick access to sandbox mode
};
```

### Rebuild

```bash
sudo nixos-rebuild switch --flake /etc/nixos
```