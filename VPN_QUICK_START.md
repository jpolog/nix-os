# University VPN Quick Start for ares

## ✅ Configuration Complete!

Your NixOS configuration has been updated with university VPN support using strongSwan and NetworkManager.

## 🚀 Quick Setup (4 Steps)

### 1. Verify VPN Gateway Address
```bash
nano hosts/ares/university-vpn.nix
```

**IMPORTANT:** Check line 17 for the gateway address:
- Current: `gateway = "vpn.um.es";`
- Verify this is correct with your university's IT documentation
- Common UM gateways: `vpn.um.es`, `vpnacc.um.es`, `acceso.um.es`

Also verify line 22:
- `username = "javier.polog@um.es";` → Your actual UM email

### 2. Rebuild NixOS
```bash
# Rebuild the system
nh os switch
# OR
sudo nixos-rebuild switch --flake .#ares
```

### 3. Connect to VPN

**Option A: Using NetworkManager Applet (GUI)**
1. Click on the network icon in your taskbar
2. Look for "um-vpn" in the VPN section
3. Click to connect
4. Enter your UM password when prompted

**Option B: Using Command Line**
```bash
# Connect to VPN
nmcli connection up um-vpn

# Check VPN status
nmcli connection show --active | grep vpn

# Disconnect from VPN
nmcli connection down um-vpn
```

### 4. (Optional) Store Password with SOPS

If you don't want to enter the password every time:

```bash
# Edit secrets file
sops secrets/secrets.yaml
```

Add this line:
```yaml
um_vpn_password: "your-actual-password-here"
```

Then uncomment in `hosts/ares/university-vpn.nix`:
- Lines 26-27: `passwordFile = config.sops.secrets.um_vpn_password.path;`
- Lines 48-56: The entire `sops.secrets.um_vpn_password` block

Rebuild:
```bash
nh os switch
```

## 📁 Files Created/Modified

✅ `modules/system/university-vpn.nix` - Reusable VPN module (strongSwan)  
✅ `modules/system/default.nix` - Added VPN import  
✅ `hosts/ares/university-vpn.nix` - Your VPN config  
✅ `hosts/ares/configuration.nix` - Added VPN import  

## 🔧 VPN Management Tools

### NetworkManager Applet (GUI)
- **Hyprland users:** Already available in your taskbar
- **KDE users:** Available in system tray

### Command Line Tools
```bash
# Show all VPN connections
nmcli connection show

# Connect to VPN
nmcli connection up um-vpn

# Disconnect from VPN
nmcli connection down um-vpn

# Show VPN connection details
nmcli connection show um-vpn

# Edit VPN connection (interactive)
nmcli connection edit um-vpn

# Check if VPN is active
ip addr show | grep -A 5 ppp0  # VPN interface
```

## 🔍 Troubleshooting

### VPN Not Connecting?
```bash
# Check NetworkManager logs (watch in real-time)
journalctl -u NetworkManager -f

# Check strongSwan logs
journalctl -u strongswan -f

# Check charon-nm logs while connecting
journalctl -u NetworkManager -f | grep charon

# Restart NetworkManager
sudo systemctl restart NetworkManager

# Restart strongSwan daemon
sudo systemctl restart strongswan
sudo systemctl status strongswan
```

### Debug Authentication Issues
```bash
# Try connecting manually with verbose output
sudo nmcli --ask connection up um-vpn

# Verify password is stored correctly
nmcli connection show um-vpn | grep password

# Check if password injector service ran successfully
systemctl status university-vpn-password-injector

# Check if password file exists and is readable (if using SOPS)
ls -l /run/secrets/um_vpn_password
```

### Wrong Gateway?
Contact your university IT department or check:
- University IT website
- VPN documentation
- Email instructions from IT

### Authentication Failed?
1. Verify your UM email address is correct
2. Verify your password
3. Check if you need to be on campus network first
4. Contact university IT support

### Need Different Encryption?
Edit `hosts/ares/university-vpn.nix` and modify:
```nix
proposal = "aes256-sha256-modp1024";  # IKE proposal
esp = "aes256-sha256";                 # ESP proposal
```

Common alternatives:
- `proposal = "aes128-sha1-modp2048"`
- `esp = "aes128-sha1"`

### Check VPN Connection Status
```bash
# Show active connections
nmcli connection show --active

# Show VPN interface details
ip addr show

# Test connectivity through VPN
ping 8.8.8.8  # Should route through VPN when connected
```

## 💡 Tips

### Auto-Connect on Boot
Edit `hosts/ares/university-vpn.nix` line 29:
```nix
autoConnect = true;  # Automatically connect on boot
```

Then rebuild:
```bash
nh os switch
```

### Split Tunneling
By default, all traffic goes through the VPN. To only route specific traffic:
```bash
# Edit connection
nmcli connection modify um-vpn ipv4.never-default true

# Then manually add routes for university resources
# Example: Route only 155.54.0.0/16 through VPN
sudo ip route add 155.54.0.0/16 via <VPN_GATEWAY>
```

### Multiple VPN Connections
You can add multiple VPN connections by adding more entries in the `connections` attribute:
```nix
connections = {
  um-vpn = { ... };
  um-vpn-alternative = {
    gateway = "vpn2.um.es";
    username = "javier.polog@um.es";
    # ... other settings
  };
};
```

## 📖 Package Details

The configuration installs:
- **strongSwan**: Industry-standard IPsec/IKEv2 VPN
- **strongswanNM**: NetworkManager plugin for strongSwan
- **NetworkManager-l2tp**: Additional VPN protocol support
- **NetworkManager applet**: GUI for VPN management

## 🎓 University IT Information

For Universidad de Murcia specific settings, contact:
- **IT Help Desk**: https://www.um.es/atica
- **Email**: atica@um.es
- **Phone**: +34 868 88 8888 (verify current number)

You may need to verify:
1. VPN gateway address
2. Supported authentication methods
3. Required encryption settings
4. Any additional certificates

## 🔐 Security Best Practices

1. **Use SOPS for passwords**: Don't store passwords in plaintext
2. **Verify certificates**: Use CA certificates when available
3. **Monitor connections**: Regularly check VPN status
4. **Disconnect when not needed**: Don't leave VPN on 24/7
5. **Keep updated**: Run system updates regularly

## 🚨 Important Notes

- **Default behavior**: VPN is DISABLED by default and won't auto-connect
- **Password entry**: You'll be prompted for password each time unless using SOPS
- **NetworkManager**: VPN management is integrated with NetworkManager
- **GUI availability**: NetworkManager applet is already installed via desktop profile

## 📱 Desktop Integration

### Hyprland
- NetworkManager applet is in your waybar
- Click the network icon to manage VPN

### KDE Plasma
- VPN settings in System Settings → Network → Connections
- System tray icon for quick access

## 🔄 Comparison with Ubuntu Instructions

Your NixOS setup is equivalent to the Ubuntu instructions:
- ✅ `strongswan-nm` → strongSwan + strongswanNM packages
- ✅ `libcharon-extra-plugins` → Included in strongSwan enabledPlugins
- ✅ NetworkManager GUI → networkmanagerapplet
- ✅ IPsec/IKEv2 configuration → Configured in university-vpn.nix
- ✅ User authentication → Username/password via SOPS or prompt

**Advantages over Ubuntu:**
- Declarative configuration (version controlled)
- Secure password management with SOPS
- Easy to replicate on other machines
- Rollback capability if something breaks
