#!/usr/bin/env bash

# Performance Power Profile
# - High-performance profile
# - Less focus on power saving
# - More aggressive fan curve

set -e

echo "Setting Performance power profile..."

# TLP Configuration - Set to performance mode
echo 'CPU_SCALING_GOVERNOR_ON_AC="performance"' | sudo tee /etc/tlp.d/01-performance.conf > /dev/null
echo 'CPU_SCALING_GOVERNOR_ON_BAT="schedutil"' | sudo tee -a /etc/tlp.d/01-performance.conf > /dev/null
echo 'CPU_ENERGY_PERF_POLICY_ON_AC="performance"' | sudo tee -a /etc/tlp.d/01-performance.conf > /dev/null
echo 'CPU_ENERGY_PERF_POLICY_ON_BAT="balance_performance"' | sudo tee -a /etc/tlp.d/01-performance.conf > /dev/null

# AMD CPU Boost - Always enabled
echo 'CPU_BOOST_ON_AC=1' | sudo tee -a /etc/tlp.d/01-performance.conf > /dev/null
echo 'CPU_BOOST_ON_BAT=1' | sudo tee -a /etc/tlp.d/01-performance.conf > /dev/null

# Apply TLP settings
sudo tlp start

# Enable AMD CPU boost
if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
    echo "1" | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
fi

# Thinkfan Configuration - Use performance curve
sudo cp /etc/power-profiles/thinkfan-performance.conf /etc/thinkfan.conf
sudo systemctl restart thinkfan

echo "✓ Performance power profile activated."
echo "  - CPU Governor: performance (AC) / schedutil (BAT)"
echo "  - Energy Policy: performance (AC) / balance_performance (BAT)"
echo "  - CPU Boost: Always Enabled"
echo "  - Fan Curve: Aggressive"

