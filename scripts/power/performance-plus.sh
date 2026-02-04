#!/usr/bin/env bash

# Performance Plus Power Profile
# - Maximum performance at all times
# - No power saving features
# - Always applies maximum settings

set -e

echo "Setting Performance Plus power profile..."

# TLP Configuration - Maximum performance on both AC and battery
sudo bash -c 'cat > /etc/tlp.d/01-profile.conf << EOFperformance-plus.conf << EOF
CPU_SCALING_GOVERNOR_ON_AC="performance"
CPU_SCALING_GOVERNOR_ON_BAT="performance"
CPU_ENERGY_PERF_POLICY_ON_AC="performance"
CPU_ENERGY_PERF_POLICY_ON_BAT="performance"
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=1
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=on
EOF

EOF'

# Apply TLP settings
sudo tlp start

# FORCE apply settings IMMEDIATELY
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu" ] && echo "performance" | sudo tee "$cpu" > /dev/null
done

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

# Disable CPU frequency scaling minimum limits
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
    if [ -f "$cpu" ]; then
        MAX_FREQ=$(cat "$(dirname "$cpu")/cpuinfo_max_freq")
        echo "$MAX_FREQ" | sudo tee "$cpu" > /dev/null
    fi
done

# Thinkfan Configuration - Use maximum performance curve
if [ -f /etc/power-profiles/thinkfan-performance-plus.conf ]; then
    sudo cp /etc/power-profiles/thinkfan-performance-plus.conf /etc/thinkfan.conf
    sudo systemctl restart thinkfan
fi

echo "✓ Performance Plus power profile activated."
echo "  - CPU Governor: performance (ACTIVE NOW)"
echo "  - Energy Policy: performance (ACTIVE NOW)"
echo "  - CPU Boost: Always Enabled (ACTIVE NOW)"
echo "  - Min CPU Freq: Maximum (ACTIVE NOW)"
echo "  - Fan Curve: Maximum"
echo ""
echo "Maximum performance mode is now active!"
