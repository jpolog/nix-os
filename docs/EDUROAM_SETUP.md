# eduroam WiFi Setup Guide

This guide explains how to configure and use eduroam WiFi on your NixOS system with SOPS-managed credentials.

## Overview

Your NixOS configuration now includes:
- ✅ **eduroam module** (`modules/system/eduroam.nix`) - Reusable NixOS module for eduroam
- ✅ **Host configuration** (`hosts/ares/eduroam.nix`) - eduroam settings for the ares host
- ✅ **SOPS integration** - Secure password management
- ✅ **NetworkManager integration** - Automatic connection management

## Setup Steps

### Step 1: Get Your eduroam Credentials

Contact your university's IT department to obtain:
1. **Username/Identity** (format: `username@institution.domain`)
2. **Password**
3. (Optional) **Domain suffix** for certificate validation
4. (Optional) **CA certificate** for enhanced security

### Step 2: Configure Your Identity

Edit `hosts/ares/eduroam.nix` and update these values:

```nix
identity = "jpolo@university.edu";  # CHANGE to your actual eduroam username
anonymousIdentity = "anonymous@university.edu";  # CHANGE to match your domain
```

**Example:** If your university email is `john.doe@mit.edu`:
- `identity = "john.doe@mit.edu";`
- `anonymousIdentity = "anonymous@mit.edu";`

### Step 3: Add Your Password to SOPS

Your SOPS keys are already configured. Now add the eduroam password:

```bash
# Open the encrypted secrets file
sops secrets/secrets.yaml
```

Add this entry to the file:

```yaml
eduroam_password: "YourActualPasswordHere"
```

**Important:** Replace `YourActualPasswordHere` with your actual eduroam password.

### Step 4: Rebuild Your System

```bash
# Navigate to your NixOS configuration directory
cd /etc/nixos

# Rebuild the system
sudo nixos-rebuild switch --flake .#ares

# OR if you use nh (recommended)
nh os switch
```

### Step 5: Connect to eduroam

The eduroam network should now be configured automatically. You can connect using:

**Command Line:**
```bash
nmcli connection up university-eduroam
```

**GUI (Plasma/GNOME/etc):**
1. Open Network settings
2. Select "university-eduroam" from available networks
3. It should connect automatically

## Advanced Configuration

### Certificate Validation (Recommended)

For enhanced security, configure certificate validation in `hosts/ares/eduroam.nix`:

```nix
networking.eduroam.networks.university-eduroam = {
  # ... existing config ...
  
  # Enable domain suffix matching (prevents MITM attacks)
  domain = "radius.university.edu";  # Get this from your IT department
  
  # Optional: Use specific CA certificate
  caCertificate = /etc/nixos/certs/university-ca.pem;
};
```

### Different Authentication Method

If your university uses a different Phase 2 authentication method:

```nix
phase2Auth = "PAP";  # Options: MSCHAPV2 (default), PAP, GTC, etc.
```

### Multiple eduroam Networks

You can configure multiple eduroam networks (e.g., for different universities):

```nix
networking.eduroam.networks = {
  university-eduroam = {
    ssid = "eduroam";
    identity = "jpolo@university1.edu";
    passwordFile = config.sops.secrets.eduroam_password_uni1.path;
  };
  
  conference-eduroam = {
    ssid = "eduroam";
    identity = "jpolo@university2.edu";
    passwordFile = config.sops.secrets.eduroam_password_uni2.path;
  };
};
```

## Troubleshooting

### Connection Fails

**Check NetworkManager logs:**
```bash
journalctl -u NetworkManager -f
```

**Verify the connection profile:**
```bash
nmcli connection show university-eduroam
```

**Check if password was applied:**
```bash
sudo cat /run/secrets/eduroam_password
```

### Certificate Validation Errors

If you see certificate errors:
1. Contact your IT department for the CA certificate
2. Download it to `/etc/nixos/certs/university-ca.pem`
3. Configure `caCertificate` in `hosts/ares/eduroam.nix`
4. Rebuild your system

### Wrong Username/Password

1. Update `identity` in `hosts/ares/eduroam.nix`
2. Update password in SOPS: `sops secrets/secrets.yaml`
3. Rebuild: `sudo nixos-rebuild switch`
4. Reconnect: `nmcli connection up university-eduroam`

### Delete and Recreate Connection

```bash
# Delete the connection
nmcli connection delete university-eduroam

# Rebuild to recreate
sudo nixos-rebuild switch
```

## Security Best Practices

✅ **Enable certificate validation** with `domain` and `caCertificate`  
✅ **Use anonymous identity** to protect your username during outer authentication  
✅ **Keep password in SOPS** - never commit plaintext passwords  
✅ **Regular updates** - Update your password in SOPS if it changes  

## University-Specific Notes

Different universities may have specific requirements:

### Common Configurations

**MIT eduroam:**
```nix
identity = "username@MIT.EDU";
domain = "radius-1.net.mit.edu";
phase2Auth = "MSCHAPV2";
```

**Stanford eduroam:**
```nix
identity = "username@stanford.edu";
domain = "eduroam.stanford.edu";
phase2Auth = "MSCHAPV2";
```

**Generic Configuration:**
```nix
identity = "username@university.edu";
phase2Auth = "MSCHAPV2";  # Most common
```

Check your university's IT documentation for specific settings.

## Files Modified

- `modules/system/default.nix` - Added eduroam module import
- `modules/system/eduroam.nix` - New reusable eduroam module
- `hosts/ares/configuration.nix` - Added eduroam.nix import
- `hosts/ares/eduroam.nix` - New host-specific eduroam configuration
- `secrets/secrets.yaml` - Added eduroam_password (encrypted)

## References

- [eduroam Official Site](https://eduroam.org/)
- [NetworkManager Documentation](https://networkmanager.dev/)
- [SOPS-nix Documentation](https://github.com/Mic92/sops-nix)
- Your university's eduroam setup guide
