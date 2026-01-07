# Secrets Management

This configuration uses **sops-nix** for declarative, encrypted secrets management.

## Overview

Secrets are:
- ✅ Encrypted in git
- ✅ Declaratively managed in Nix
- ✅ Automatically decrypted at boot
- ✅ Portable across machines
- ✅ Version controlled safely

## Quick Setup

### 1. Generate Age Key (Per Machine)

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
age-keygen -y ~/.config/sops/age/keys.txt  # Get public key
```

### 2. Configure .sops.yaml

Add your public key to `.sops.yaml`:

```yaml
keys:
  - &ares age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
    - age:
      - *ares
```

### 3. Create Secrets

```bash
# Create/edit encrypted secrets
sops secrets/secrets.yaml
```

See `secrets.yaml.example` for examples.

### 4. Use in Configuration

```nix
# Declare secret
sops.secrets.example = {
  sopsFile = ./secrets/secrets.yaml;
};

# Use secret file path
someService.passwordFile = config.sops.secrets.example.path;
```

## Common Examples

### User Password
```nix
sops.secrets.jpolo_password.neededForUsers = true;
users.users.jpolo.hashedPasswordFile = 
  config.sops.secrets.jpolo_password.path;
```

### SSH Key
```nix
sops.secrets.ssh_private_key = {
  owner = "jpolo";
  path = "/home/jpolo/.ssh/id_ed25519";
  mode = "0600";
};
```

### WiFi Password
```nix
sops.secrets.wifi_password = { };
networking.wireless.networks."SSID".pskFile = 
  config.sops.secrets.wifi_password.path;
```

## Multi-Machine

Add new machine's public key to `.sops.yaml`, then:

```bash
sops updatekeys secrets/secrets.yaml
```

All secrets now work on the new machine!

## Security

- ✅ Private keys stay on machines (never in git)
- ✅ Encrypted secrets safe to commit
- ✅ Different keys per machine possible
- ✅ Fully declarative and reproducible

See full documentation in `docs/` for advanced usage.
