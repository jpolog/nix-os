#!/usr/bin/env bash

# Balanced Power Profile
# - Default, well-rounded profile
# - Good balance between performance and power saving
# - Standard fan curve

set -e

echo "Setting Balanced power profile..."

# TLP Configuration - Set to balanced mode
echo 'CPU_SCALING_GOVERNOR_ON_AC="schedutil"' | sudo tee /etc/tlp.d/01-balanced.conf > /dev/null
echo 'CPU_SCALING_GOVERNOR_ON_BAT="schedutil"' | sudo tee -a /etc/tlp.d/01-balanced.conf > /dev/null
echo 'CPU_ENERGY_PERF_POLICY_ON_AC="balance_performance"' | sudo tee -a /etc/tlp.d/01-balanced.conf > /dev/null
echo 'CPU_ENERGY_PERF_POLICY_ON_BAT="balance_power"' | sudo tee -a /etc/tlp.d/01-balanced.conf > /dev/null

# AMD CPU Boost - Enable on AC, disable on battery
echo 'CPU_BOOST_ON_AC=1' | sudo tee -a /etc/tlp.d/01-balanced.conf > /dev/null
echo 'CPU_BOOST_ON_BAT=0' | sudo tee -a /etc/tlp.d/01-balanced.conf > /dev/null

# Apply TLP settings
sudo tlp start

# Enable AMD CPU boost (for AC power)
if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
    echo "1" | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
fi

# Thinkfan Configuration - Use balanced curve
sudo cp /etc/power-profiles/thinkfan-balanced.conf /etc/thinkfan.conf
sudo systemctl restart thinkfan

echo "✓ Balanced power profile activated."
echo "  - CPU Governor: schedutil"
echo "  - Energy Policy: balance_performance (AC) / balance_power (BAT)"
echo "  - CPU Boost: Enabled (AC) / Disabled (BAT)"
echo "  - Fan Curve: Balanced"

