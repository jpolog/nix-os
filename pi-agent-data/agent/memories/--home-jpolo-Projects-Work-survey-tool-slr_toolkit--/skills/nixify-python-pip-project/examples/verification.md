# Verification Steps

1. **Check the flake**:
   ```bash
   nix flake check
   ```

2. **Enter the Nix shell**:
   ```bash
   nix develop
   ```

3. **Verify Python and tools**:
   ```bash
   nix develop -c python --version
   nix develop -c ruff --version
   ```

4. **Setup the virtual environment**:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -e '.[all]'
   ```
