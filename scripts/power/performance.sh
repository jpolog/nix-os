#!/usr/bin/env bash

# Performance Power Profile
# - High-performance profile
# - Always applies performance settings when selected
# - Works on both AC and battery

set -e

echo "Setting Performance power profile..."

# TLP Configuration - Performance mode on AC, high performance on battery
sudo bash -c 'cat > /etc/tlp.d/01-profile.conf << EOFperformance.conf << EOF
CPU_SCALING_GOVERNOR_ON_AC="performance"
CPU_SCALING_GOVERNOR_ON_BAT="performance"
CPU_ENERGY_PERF_POLICY_ON_AC="performance"
CPU_ENERGY_PERF_POLICY_ON_BAT="performance"
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=1
EOF

EOF'

# Apply TLP settings
sudo tlp start

# FORCE apply settings IMMEDIATELY regardless of AC/battery state
# This ensures the profile is active RIGHT NOW, not just after next power event

# Force CPU governor to performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && echo "performance" | sudo tee "$cpu" > /dev/null
done

# Force energy performance policy to performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [ -f "$cpu" ] && echo "performance" | sudo tee "$cpu" > /dev/null
done

# Enable AMD CPU boost
if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
    echo "1" | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
fi

# Set CPU frequency scaling limits to maximum
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
    if [ -f "$cpu" ]; then
        MAX_FREQ=$(cat "$(dirname "$cpu")/cpuinfo_max_freq")
        echo "$MAX_FREQ" | sudo tee "$cpu" > /dev/null
    fi
done

# Thinkfan Configuration - Use performance curve
if [ -f /etc/power-profiles/thinkfan-performance.conf ]; then
    sudo cp /etc/power-profiles/thinkfan-performance.conf /etc/thinkfan.conf
    sudo systemctl restart thinkfan
fi

echo "✓ Performance power profile activated."
echo "  - CPU Governor: performance (ACTIVE NOW)"
echo "  - Energy Policy: performance (ACTIVE NOW)"
echo "  - CPU Boost: Enabled (ACTIVE NOW)"
echo "  - Fan Curve: Aggressive"
echo ""
echo "This profile is now active regardless of AC/battery state!"
