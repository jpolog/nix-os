{ pkgs }:

pkgs.mkShell {
  name = "python-dev";
  
  buildInputs = with pkgs; [
    # Python interpreter and core tools
    python312
    python312Packages.pip
    python312Packages.virtualenv
    python312Packages.setuptools
    python312Packages.wheel
    
    # Interactive shells
    python312Packages.ipython
    python312Packages.jupyter
    
    # Data science essentials
    python312Packages.numpy
    python312Packages.pandas
    python312Packages.matplotlib
    python312Packages.scikit-learn
    
    # Neovim integration
    python312Packages.pynvim
    
    # Linting and formatting
    ruff          # Fast Python linter & formatter
    black         # Code formatter
    isort         # Import sorter
    
    # Type checking and LSP
    pyright       # Type checker & LSP
    python312Packages.python-lsp-server
  ];
  
  shellHook = ''
    echo "🐍 Python Development Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Python: $(python --version)"
    echo "pip: $(pip --version | cut -d' ' -f1-2)"
    echo ""
    echo "Available tools:"
    echo "  • ipython      - Interactive Python shell"
    echo "  • jupyter      - Jupyter notebooks"
    echo "  • ruff         - Fast linter & formatter"
    echo "  • black        - Code formatter"
    echo "  • pyright      - Type checker"
    echo ""
    echo "Quick start:"
    echo "  python -m venv .venv"
    echo "  source .venv/bin/activate"
    echo "  pip install -r requirements.txt"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';

  # Environment variables
  # Prevent pip from trying to write to /nix/store
  PIP_PREFIX = "$(pwd)/_build/pip_packages";
  PYTHONPATH_EXTRA = "$(pwd)/_build/pip_packages/${pkgs.python312.sitePackages}";
}

