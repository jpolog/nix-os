{ pkgs }:

{
  # Python development environment
  python = import ./python.nix { inherit pkgs; };
  
  # Node.js development environment
  node = import ./node.nix { inherit pkgs; };
  
  # Rust development environment
  rust = import ./rust.nix { inherit pkgs; };
  
  # Go development environment
  go = import ./go.nix { inherit pkgs; };
}

