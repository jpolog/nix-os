{ pkgs }:

pkgs.mkShell {
  name = "node-dev";
  
  buildInputs = with pkgs; [
    # Node.js runtime
    nodejs_22
    
    # Package managers
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    
    # TypeScript
    nodePackages.typescript
    nodePackages.typescript-language-server
    
    # Linting and formatting
    nodePackages.eslint
    nodePackages.prettier
    
    # Build tools
    nodePackages.webpack-cli
    vite  # Use standalone package
  ];
  
  shellHook = ''
    echo "🟢 Node.js Development Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Node: $(node --version)"
    echo "npm: $(npm --version)"
    echo "yarn: $(yarn --version)"
    echo "pnpm: $(pnpm --version)"
    echo ""
    echo "Available tools:"
    echo "  • npm/yarn/pnpm - Package managers"
    echo "  • typescript    - TypeScript compiler"
    echo "  • eslint        - Linter"
    echo "  • prettier      - Code formatter"
    echo ""
    echo "Quick start:"
    echo "  npm init"
    echo "  npm install"
    echo "  npm run dev"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';
}

