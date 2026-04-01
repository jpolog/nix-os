#!/usr/bin/env bash

# Balanced Power Profile
# - Default, well-rounded profile
# - Applies immediately regardless of AC/battery state
# - Good balance between performance and efficiency

set -e

if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

PROFILE_FILE="/var/lib/power-profiles/current"
mkdir -p "$(dirname "$PROFILE_FILE")"
echo "balanced" > "$PROFILE_FILE"

echo "Setting Balanced power profile..."

# Check current power state
if [ -f /sys/class/power_supply/AC/online ]; then
    AC_STATE=$(cat /sys/class/power_supply/AC/online)
else
    AC_STATE=0
fi

# TLP Configuration - Balanced for both states
cat > /etc/tlp.d/99-profile.conf << "EOF"
CPU_SCALING_GOVERNOR_ON_AC=powersave
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power
CPU_BOOST_ON_AC=0
CPU_BOOST_ON_BAT=0
EOF

# Apply TLP settings - this will handle everything
tlp start

# Force TLP to reapply settings based on current state
echo "Forcing TLP to apply current power state settings..."
if [ "$AC_STATE" = "1" ]; then
    tlp ac
else
    tlp bat
fi

# Small delay to let TLP apply settings
sleep 1

# Thinkfan Configuration - Switch to balanced curve
if [ -f /etc/power-profiles/thinkfan-balanced.yaml ]; then
    cp /etc/power-profiles/thinkfan-balanced.yaml /var/lib/thinkfan/active.yaml
    systemctl restart thinkfan
fi

# Read back actual applied settings
CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
CURRENT_EPP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "unknown")
CURRENT_BOOST=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "unknown")

echo "✓ Balanced power profile activated."
if [ "$AC_STATE" = "1" ]; then
    echo "  - Power State: AC (Plugged In) - DETECTED"
    echo "  - CPU Governor: $CURRENT_GOV (ACTIVE NOW)"
    echo "  - Energy Policy: $CURRENT_EPP (ACTIVE NOW)"
    echo "  - CPU Boost: $([ "$CURRENT_BOOST" = "1" ] && echo "Enabled" || echo "Disabled") (ACTIVE NOW)"
else
    echo "  - Power State: Battery"
    echo "  - CPU Governor: $CURRENT_GOV (ACTIVE NOW)"
    echo "  - Energy Policy: $CURRENT_EPP (ACTIVE NOW)"
    echo "  - CPU Boost: $([ "$CURRENT_BOOST" = "1" ] && echo "Enabled" || echo "Disabled") (ACTIVE NOW)"
fi
echo "  - Fan Curve: Balanced"
echo ""
echo "Settings are active NOW and will automatically adjust on power state changes!"
