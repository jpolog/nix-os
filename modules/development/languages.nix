{ config, pkgs, ... }:

{
  # Programming languages and runtimes
  environment.systemPackages = with pkgs; [
    # Python
    python312
    python312Packages.pip
    python312Packages.virtualenv
    
    # Node.js
    nodejs_22
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    
    # Rust
    rustc
    cargo
    rustfmt
    clippy
    
    # Go
    go
    gotools
    
    # Java (if needed)
    # jdk21
    
    # C/C++
    gcc
    clang
    cmake
    gnumake
    
    # Other
    zig
  ];

  # Language servers (for IDE support)
  environment.systemPackages = with pkgs; [
    # LSP servers
    nil  # Nix
    pyright  # Python
    rust-analyzer  # Rust
    gopls  # Go
    nodePackages.typescript-language-server  # TypeScript
    nodePackages.bash-language-server  # Bash
    lua-language-server  # Lua
    vscode-langservers-extracted  # HTML, CSS, JSON
    
    # Formatters
    alejandra  # Nix
    black  # Python
    prettier  # JS/TS/CSS/HTML
    shfmt  # Shell scripts
    stylua  # Lua
  ];
}
