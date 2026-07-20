# Nixify Python Pip Project

This skill provides a reusable workflow for Nixifying a Python project that uses pip for dependency management.

## Overview
- **Strategy**: Strategy A (Simple dev shell for single-language Python projects).
- **Tools**: flake-parts, Python 3.12, pip, virtualenv, venvShellHook, ruff, pkg-config, openssl.dev, git, nixfmt.
- **Environment Variable**: `PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring` for offline-friendliness.

## Steps
1. Generate `flake.nix` with flake-parts and the required dependencies.
2. Create `.envrc` with `use flake` directive.
3. Enter the Nix shell and create a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -e '.[all]'
   ```
4. Verify the setup with `nix flake check` and `nix develop -c`.

## Verification
- Ensure `nix flake check` passes.
- Confirm Python and other tools are available in the Nix shell using `nix develop -c`.
