#!/usr/bin/env bash

# Performance Plus Power Profile
# - Maximum performance profile
# - Disables power saving features
# - Very aggressive fan curve for optimal cooling under heavy load

set -e

echo "Setting Performance Plus power profile..."

# TLP Configuration - Maximum performance
echo 'CPU_SCALING_GOVERNOR_ON_AC="performance"' | sudo tee /etc/tlp.d/01-performance-plus.conf > /dev/null
echo 'CPU_SCALING_GOVERNOR_ON_BAT="performance"' | sudo tee -a /etc/tlp.d/01-performance-plus.conf > /dev/null
echo 'CPU_ENERGY_PERF_POLICY_ON_AC="performance"' | sudo tee -a /etc/tlp.d/01-performance-plus.conf > /dev/null
echo 'CPU_ENERGY_PERF_POLICY_ON_BAT="performance"' | sudo tee -a /etc/tlp.d/01-performance-plus.conf > /dev/null

# AMD CPU Boost - Always enabled
echo 'CPU_BOOST_ON_AC=1' | sudo tee -a /etc/tlp.d/01-performance-plus.conf > /dev/null
echo 'CPU_BOOST_ON_BAT=1' | sudo tee -a /etc/tlp.d/01-performance-plus.conf > /dev/null

# Disable power saving features
echo 'RUNTIME_PM_ON_AC=on' | sudo tee -a /etc/tlp.d/01-performance-plus.conf > /dev/null
echo 'RUNTIME_PM_ON_BAT=on' | sudo tee -a /etc/tlp.d/01-performance-plus.conf > /dev/null

# Apply TLP settings
sudo tlp start

# Enable AMD CPU boost
if [ -f /sys/devices/system/cpu/cpufreq/boost ]; then
    echo "1" | sudo tee /sys/devices/system/cpu/cpufreq/boost > /dev/null
fi

# Set AMD P-State to performance mode if available
if [ -f /sys/devices/system/cpu/amd_pstate/status ]; then
    echo "performance" | sudo tee /sys/devices/system/cpu/amd_pstate/status > /dev/null 2>&1 || true
fi

# Thinkfan Configuration - Use maximum performance curve
sudo cp /etc/power-profiles/thinkfan-performance-plus.conf /etc/thinkfan.conf
sudo systemctl restart thinkfan

echo "✓ Performance Plus power profile activated."
echo "  - CPU Governor: performance (always)"
echo "  - Energy Policy: performance (always)"
echo "  - CPU Boost: Always Enabled"
echo "  - Power Saving: Disabled"
echo "  - Fan Curve: Very Aggressive"

