{ pkgs }:

pkgs.mkShell {
  name = "go-dev";
  
  buildInputs = with pkgs; [
    # Go toolchain
    go
    
    # LSP and tools
    gopls
    gotools
    go-tools
    
    # Additional tools
    gomodifytags
    gotests
    impl
    delve  # Debugger
  ];
  
  shellHook = ''
    echo "🐹 Go Development Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Go: $(go version)"
    echo ""
    echo "Available tools:"
    echo "  • go            - Go compiler"
    echo "  • gopls         - Language server"
    echo "  • gofmt         - Code formatter"
    echo "  • delve         - Debugger"
    echo ""
    echo "Quick start:"
    echo "  go mod init example.com/myproject"
    echo "  go build"
    echo "  go run ."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';
  
  # Go environment
  CGO_ENABLED = "1";
}

