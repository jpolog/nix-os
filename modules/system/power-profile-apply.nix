{ config, lib, pkgs, ... }:

with lib;

{
  # Ensure TLP and power scripts apply settings immediately
  # This fixes the issue where power profiles only applied on battery
  
  # Udev rule to reapply power profile on AC plug/unplug
  services.udev.extraRules = ''
    # When AC adapter state changes, reapply the current power profile
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.bash}/bin/bash -c 'if [ -f /etc/tlp.d/01-profile.conf ]; then ${pkgs.systemd}/bin/systemctl restart tlp-reapply.service; fi'"
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.bash}/bin/bash -c 'if [ -f /etc/tlp.d/01-profile.conf ]; then ${pkgs.systemd}/bin/systemctl restart tlp-reapply.service; fi'"
  '';
  
  # Service to reapply power settings when AC state changes
  systemd.services.tlp-reapply = {
    description = "Reapply TLP power profile on AC state change";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.tlp}/bin/tlp start";
    };
  };
  
  # Power profile status script
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "power-status" ''
      echo "═══════════════════════════════════════════════════════════"
      echo "  CURRENT POWER PROFILE STATUS"
      echo "═══════════════════════════════════════════════════════════"
      echo ""
      
      # Check AC state
      if [ -f /sys/class/power_supply/AC/online ]; then
        AC_STATE=$(cat /sys/class/power_supply/AC/online)
        if [ "$AC_STATE" = "1" ]; then
          echo "Power Source: 🔌 AC (Plugged In)"
        else
          echo "Power Source: 🔋 Battery"
        fi
      else
        echo "Power Source: Unknown"
      fi
      
      # Check active profile
      if [ -f /etc/tlp.d/01-profile.conf ]; then
        echo ""
        echo "Active TLP Profile:"
        cat /etc/tlp.d/01-profile.conf | grep -v "^#" | grep -v "^$"
      fi
      
      echo ""
      echo "Current CPU Settings (LIVE):"
      echo "───────────────────────────────────────────────────────────"
      
      # CPU Governor
      GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
      echo "  CPU Governor: $GOVERNOR"
      
      # Energy performance preference
      EPP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "unknown")
      echo "  Energy Policy: $EPP"
      
      # CPU Boost
      if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
        BOOST=$(cat /sys/devices/system/cpu/cpufreq/boost)
        if [ "$BOOST" = "1" ]; then
          echo "  CPU Boost: ✓ Enabled"
        else
          echo "  CPU Boost: ✗ Disabled"
        fi
      fi
      
      # CPU Frequencies
      MIN_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null || echo "0")
      MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo "0")
      CUR_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo "0")
      
      echo "  Min Freq: $((MIN_FREQ / 1000)) MHz"
      echo "  Max Freq: $((MAX_FREQ / 1000)) MHz"
      echo "  Current Freq: $((CUR_FREQ / 1000)) MHz"
      
      echo ""
      echo "Available Power Profiles:"
      echo "  • power-performance-plus  - Maximum performance"
      echo "  • power-performance       - High performance"  
      echo "  • power-balanced          - Balanced (default)"
      echo "  • power-eco               - Maximum power saving"
      echo ""
      echo "═══════════════════════════════════════════════════════════"
    '')
  ];
}
