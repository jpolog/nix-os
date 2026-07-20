#!/usr/bin/env bash
# Setup script for Nix shell

# Enter the Nix shell
echo "Entering Nix shell..."
nix develop

# Create a virtual environment
echo "Creating virtual environment..."
python -m venv .venv

# Activate the virtual environment and install dependencies
echo "Activating virtual environment and installing dependencies..."
source .venv/bin/activate
pip install -e '.[all]'

echo "Setup complete!"
