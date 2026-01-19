{ pkgs }:

pkgs.mkShell {
  name = "rust-dev";
  
  buildInputs = with pkgs; [
    # Rust toolchain
    rustc
    cargo
    rustfmt
    clippy
    
    # LSP and tools
    rust-analyzer
    cargo-watch
    cargo-edit
    cargo-outdated
    
    # Additional helpful tools
    bacon  # Background rust code checker
  ];
  
  shellHook = ''
    echo "🦀 Rust Development Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Rust: $(rustc --version)"
    echo "Cargo: $(cargo --version)"
    echo ""
    echo "Available tools:"
    echo "  • cargo         - Package manager"
    echo "  • rustfmt       - Code formatter"
    echo "  • clippy        - Linter"
    echo "  • rust-analyzer - LSP"
    echo "  • cargo-watch   - Watch for changes"
    echo ""
    echo "Quick start:"
    echo "  cargo new my-project"
    echo "  cargo build"
    echo "  cargo run"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';
  
  # Set Rust backtrace
  RUST_BACKTRACE = "1";
}

