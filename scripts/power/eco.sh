#!/usr/bin/env bash
# Eco Power Profile
# - Prioritizes power saving
# - Reduces performance to minimize heat and fan noise
# - Sets a very conservative fan curve

set -e

# TLP Configuration
sudo tlp start
sudo tlp bat

# Set CPU governor to powersave
sudo tlp-stat -s | grep "CPU_SCALING_GOVERNOR_ON_AC" | sudo tee /etc/tlp.d/01_governor.conf > /dev/null
echo 'CPU_SCALING_GOVERNOR_ON_AC="powersave"' | sudo tee /etc/tlp.d/01_governor.conf > /dev/null
sudo tlp-stat -s | grep "CPU_SCALING_GOVERNOR_ON_BAT" | sudo tee -a /etc/tlp.d/01_governor.conf > /dev/null
echo 'CPU_SCALING_GOVERNOR_ON_BAT="powersave"' | sudo tee -a /etc/tlp.d/01_governor.conf > /dev/null

# Disable Turbo Boost
echo "1" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null

# Apply new TLP settings
sudo tlp start

# Thinkfan Configuration
sudo cp /etc/nixos/scripts/power/thinkfan-eco.conf /etc/thinkfan.conf
sudo systemctl restart thinkfan

echo "Eco power profile activated."

