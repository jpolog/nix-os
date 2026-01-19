# Home Manager Activation Fix

## Problem

The `home-manager-jpolo.service` was failing during NixOS activation with:

```
× home-manager-jpolo.service - Home Manager environment for jpolo
     Active: failed (Result: exit-code)
    Process: 32587 ExecStart=/nix/store/...-hm-setup-env ... (code=exited, status=1/FAILURE)
```

## Root Cause

In `flake.nix` line 119, the `flakePath` parameter was being passed as:

```nix
flakePath = self;  # WRONG - 'self' is the entire flake attribute set
```

The `development.nix` profile (line 98-108) uses this parameter to generate dev shell launcher scripts:

```nix
text = ''
  #!/usr/bin/env bash
  echo "🐍 Launching Python development shell..."
  nix develop ${toString effectiveFlakePath}#python
'';
```

When home-manager tried to evaluate `toString effectiveFlakePath` with the flake attribute set instead of a path, it failed during activation.

## Solution

Changed `flake.nix` line 119 to pass the actual flake path as a string:

```nix
flakePath = "/etc/nixos";  # CORRECT - path string
```

This allows the `toString effectiveFlakePath` to work correctly in the launcher scripts.

## Testing

After this fix, run on the remote machine:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#ares
```

The home-manager service should now activate successfully.

## Files Modified

- `flake.nix` (line 119): Changed `flakePath = self;` → `flakePath = "/etc/nixos";`

## Follow-up

If your flake is located elsewhere, update the path accordingly. The path must point to the directory containing `flake.nix`.
