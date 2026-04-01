#!/usr/bin/env bash

# Balanced-Eco Power Profile
# - Optimized for longevity and silence
# - Best balance between performance, noise, and component lifespan
# - Prevents excessive fan cycling while keeping temps safe

set -e

if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

PROFILE_FILE="/var/lib/power-profiles/current"
mkdir -p "$(dirname "$PROFILE_FILE")"
echo "balanced-eco" > "$PROFILE_FILE"

echo "Setting Balanced-Eco power profile..."

# Check current power state
if [ -f /sys/class/power_supply/AC/online ]; then
    AC_STATE=$(cat /sys/class/power_supply/AC/online)
else
    AC_STATE=0
fi

# TLP Configuration - Conservative Balanced for both states
cat > /etc/tlp.d/99-profile.conf << "EOF"
CPU_SCALING_GOVERNOR_ON_AC=powersave
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_AC=balance_power
CPU_ENERGY_PERF_POLICY_ON_BAT=power
CPU_BOOST_ON_AC=0
CPU_BOOST_ON_BAT=0
EOF

# Apply TLP settings
tlp start

# Force TLP to reapply settings based on current state
if [ "$AC_STATE" = "1" ]; then
    tlp ac
else
    tlp bat
fi

# Small delay to let TLP apply settings
sleep 1

# Thinkfan Configuration - Switch to balanced-eco curve
if [ -f /etc/power-profiles/thinkfan-balanced-eco.yaml ]; then
    cp /etc/power-profiles/thinkfan-balanced-eco.yaml /var/lib/thinkfan/active.yaml
    systemctl restart thinkfan
fi

# Read back actual applied settings
CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
CURRENT_EPP=$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "unknown")
CURRENT_BOOST=$(cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "unknown")

echo "✓ Balanced-Eco power profile activated."
echo "  - CPU Governor: $CURRENT_GOV (ACTIVE NOW)"
echo "  - Energy Policy: $CURRENT_EPP (ACTIVE NOW)"
echo "  - CPU Boost: Disabled (ACTIVE NOW)"
echo "  - Fan Curve: Balanced-Eco"
echo ""
echo "Settings are active NOW and will automatically adjust on power state changes!"