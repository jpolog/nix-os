# Multi-language / Monorepo Template

For projects with multiple primary languages (e.g., a Python backend + Node.js frontend).

```nix
{
  description = "Development environment for <PROJECT>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells = {
          # Default composes all language shells
          default = pkgs.mkShell {
            inputsFrom = [
              config.devShells.python
              config.devShells.node
            ];
            shellHook = ''
              echo "🦇 <PROJECT> dev shell (all) activated"
            '';
          };

          # Individual language shells for focused work
          python = pkgs.mkShell {
            packages = with pkgs; [
              python312
              python312.pkgs.pip
              python312.pkgs.virtualenv
              ruff
            ];
            shellHook = ''
              echo "  Python sub-shell active"
            '';
          };

          node = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_22
              nodePackages.pnpm
              nodePackages.typescript
              nodePackages.typescript-language-server
            ];
            shellHook = ''
              echo "  Node.js sub-shell active"
            '';
          };
        };

        formatter = pkgs.nixfmt-classic;
      };
    };
}
```

### Entering a specific sub-shell

```bash
# Enter the full shell (all languages)
nix develop

# Enter a specific sub-shell
nix develop .#python
nix develop .#node

# With direnv, the default shell activates automatically
# To use a sub-shell with direnv, change .envrc:
#   use flake .#python
```

### Three-language monorepo (Python + Rust + Node)

```nix
devShells = {
  default = pkgs.mkShell {
    inputsFrom = [
      config.devShells.python
      config.devShells.rust
      config.devShells.node
    ];
    shellHook = ''
      echo "🦇 <PROJECT> dev shell (all) activated"
    '';
  };

  python = pkgs.mkShell {
    packages = with pkgs; [ python312 python312.pkgs.pip ruff ];
    shellHook = '' echo "  Python sub-shell active" '';
  };

  rust = pkgs.mkShell {
    packages = with pkgs; [ rustc cargo rust-analyzer clippy pkg-config openssl.dev ];
    shellHook = '' echo "  Rust sub-shell active" '';
  };

  node = pkgs.mkShell {
    packages = with pkgs; [ nodejs_22 nodePackages.pnpm ];
    shellHook = '' echo "  Node.js sub-shell active" '';
  };
};
```