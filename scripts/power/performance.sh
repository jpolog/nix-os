#!/usr/bin/env bash

# Performance Power Profile
# - High-performance profile
# - Always applies performance settings when selected
# - Works on both AC and battery

set -e

if [ "$EUID" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

PROFILE_FILE="/var/lib/power-profiles/current"
mkdir -p "$(dirname "$PROFILE_FILE")"
echo "performance" > "$PROFILE_FILE"

echo "Setting Performance power profile..."

# TLP Configuration - Performance mode on AC, high performance on battery
cat > /etc/tlp.d/99-profile.conf << EOF
CPU_SCALING_GOVERNOR_ON_AC="performance"
CPU_SCALING_GOVERNOR_ON_BAT="performance"
CPU_ENERGY_PERF_POLICY_ON_AC="performance"
CPU_ENERGY_PERF_POLICY_ON_BAT="performance"
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=1
EOF

# Apply TLP settings
tlp start

# FORCE apply settings IMMEDIATELY regardless of AC/battery state
# This ensures the profile is active RIGHT NOW, not just after next power event

# Force CPU governor to performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && echo "performance" | tee "$cpu" > /dev/null
done

# Force energy performance policy to performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [ -f "$cpu" ] && echo "performance" | tee "$cpu" > /dev/null
done

# Enable AMD CPU boost
if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
    echo "1" | tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
fi

# Set CPU frequency scaling limits to maximum
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
    if [ -f "$cpu" ]; then
        MAX_FREQ=$(cat "$(dirname "$cpu")/cpuinfo_max_freq")
        echo "$MAX_FREQ" | tee "$cpu" > /dev/null
    fi
done

# Thinkfan Configuration - Switch to performance curve
if [ -f /etc/power-profiles/thinkfan-performance.yaml ]; then
    cp /etc/power-profiles/thinkfan-performance.yaml /var/lib/thinkfan/active.yaml
    systemctl restart thinkfan
fi

echo "✓ Performance power profile activated."
echo "  - CPU Governor: performance (ACTIVE NOW)"
echo "  - Energy Policy: performance (ACTIVE NOW)"
echo "  - CPU Boost: Enabled (ACTIVE NOW)"
echo "  - Fan Curve: Aggressive"
echo ""
echo "This profile is now active regardless of AC/battery state!"
