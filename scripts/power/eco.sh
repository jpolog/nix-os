#!/usr/bin/env bash

# Eco Power Profile
# - Maximum power saving
# - Reduced performance
# - Quiet fan operation

set -e

if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

PROFILE_FILE="/var/lib/power-profiles/current"
mkdir -p "$(dirname "$PROFILE_FILE")"
echo "eco" > "$PROFILE_FILE"

echo "Setting Eco power profile..."

# TLP Configuration - Eco for both AC and battery
cat > /etc/tlp.d/99-profile.conf << EOF
CPU_SCALING_GOVERNOR_ON_AC="powersave"
CPU_SCALING_GOVERNOR_ON_BAT="powersave"
CPU_ENERGY_PERF_POLICY_ON_AC="power"
CPU_ENERGY_PERF_POLICY_ON_BAT="power"
CPU_BOOST_ON_AC=0
CPU_BOOST_ON_BAT=0
EOF

# Apply TLP settings
tlp start

# FORCE apply settings IMMEDIATELY
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && echo "powersave" | tee "$cpu" > /dev/null
done

for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [ -f "$cpu" ] && echo "power" | tee "$cpu" > /dev/null
done

# Disable AMD CPU boost
if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
    echo "0" | tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
fi

# Thinkfan Configuration - Switch to eco curve
if [ -f /etc/power-profiles/thinkfan-eco.yaml ]; then
    cp /etc/power-profiles/thinkfan-eco.yaml /var/lib/thinkfan/active.yaml
    systemctl restart thinkfan
fi

echo "✓ Eco power profile activated."
echo "  - CPU Governor: powersave (ACTIVE NOW)"
echo "  - Energy Policy: power (ACTIVE NOW)"
echo "  - CPU Boost: Disabled (ACTIVE NOW)"
echo "  - Fan Curve: Conservative"
echo ""
echo "Maximum power saving mode is now active on both AC and battery!"
