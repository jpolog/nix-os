#!/usr/bin/env bash
set -euo pipefail

# Home Manager Standalone Setup Script for jpolo user
# This script sets up the standalone home-manager configuration

echo "==================================================================="
echo "Home Manager Standalone Setup for Hyprland"
echo "==================================================================="

# Check if running as jpolo user
if [ "$USER" != "jpolo" ]; then
    echo "ERROR: This script must be run as the 'jpolo' user"
    exit 1
fi

# Create config directory
echo "Creating ~/.config/home-manager directory..."
mkdir -p ~/.config/home-manager

# Copy configuration files
echo "Copying configuration files..."
cp -v /etc/nixos/home-manager-standalone/flake.nix ~/.config/home-manager/
cp -v /etc/nixos/home-manager-standalone/home.nix ~/.config/home-manager/
cp -v /etc/nixos/home-manager-standalone/hyprland.nix ~/.config/home-manager/

# Create Pictures directories for Hyprland
echo "Creating Pictures directories..."
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Pictures/Screenshots

# Download a default wallpaper if none exists
if [ ! -f ~/Pictures/Wallpapers/default.jpg ]; then
    echo "Downloading default wallpaper..."
    curl -L -o ~/Pictures/Wallpapers/default.jpg \
        "https://w.wallhaven.cc/full/pk/wallhaven-pkz3ml.jpg" || \
        echo "Warning: Could not download wallpaper. You'll need to add one manually."
fi

echo ""
echo "==================================================================="
echo "Setup complete! Next steps:"
echo "==================================================================="
echo ""
echo "1. Initialize and switch to the home-manager configuration:"
echo "   cd ~/.config/home-manager"
echo "   nix run home-manager/master -- switch --flake .#jpolo"
echo ""
echo "2. Future updates can be done with:"
echo "   home-manager switch --flake ~/.config/home-manager#jpolo"
echo ""
echo "3. After switching, log out and log back into Hyprland"
echo ""
echo "==================================================================="
