# eduroam Quick Start for ares

## ✅ Configuration Complete!

Your NixOS configuration has been updated with eduroam support using SOPS for secure password management.

## 🚀 Quick Setup (3 Steps)

### 1. Edit Your Identity
```bash
nano hosts/ares/eduroam.nix
```

Change these lines (lines 16 & 34):
- `identity = "jpolo@university.edu";` → Your actual eduroam username
- `anonymousIdentity = "anonymous@university.edu";` → Match your domain

### 2. Add Your Password to SOPS
```bash
sops secrets/secrets.yaml
```

Add this line:
```yaml
eduroam_password: "your-actual-password-here"
```

Save and exit (Ctrl+X, Y, Enter)

### 3. Rebuild and Connect
```bash
# Rebuild
nh os switch
# OR
sudo nixos-rebuild switch --flake .#ares

# Connect
nmcli connection up university-eduroam
```

## 📁 Files Created/Modified

✅ `modules/system/eduroam.nix` - Reusable eduroam module  
✅ `modules/system/default.nix` - Added eduroam import  
✅ `hosts/ares/eduroam.nix` - Your eduroam config  
✅ `hosts/ares/configuration.nix` - Added eduroam import  
✅ `docs/EDUROAM_SETUP.md` - Full documentation  

## 🔧 Troubleshooting

**Not connecting?**
```bash
journalctl -u NetworkManager -f  # Check logs
```

**Wrong password?**
```bash
sops secrets/secrets.yaml  # Edit password
nh os switch               # Rebuild
```

**Delete connection:**
```bash
nmcli connection delete university-eduroam
sudo nixos-rebuild switch  # Recreate
```

## 📖 Full Documentation

See `docs/EDUROAM_SETUP.md` for:
- Certificate validation setup
- Multiple network configuration
- University-specific settings
- Advanced troubleshooting

## 🎓 University IT Info Needed

Contact your IT department for:
1. **Username format** (e.g., jpolo@uni.edu)
2. **Password**
3. **Domain suffix** (optional, for cert validation)
4. **CA certificate** (optional, recommended)

## 💡 Tips

- eduroam works at ANY participating university/institution
- Connection is automatic once configured
- Password is encrypted and never stored in plaintext
- Works seamlessly when traveling to conferences/other universities
