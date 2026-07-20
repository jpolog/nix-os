{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit self; }
    {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.python312
              pkgs.python312.pkgs.pip
              pkgs.python312.pkgs.virtualenv
              pkgs.python312.pkgs.venvShellHook
              pkgs.ruff
              pkgs.pkg-config
              pkgs.openssl.dev
              pkgs.git
              pkgs.nixfmt
            ];

            shellHook = ''
              echo "Welcome to the Nix shell for SLR Toolkit!"
              echo "Python version: $(python --version)"
              echo "To setup the virtual environment, run:"
              echo "  python -m venv .venv && source .venv/bin/activate && pip install -e '.[all]'"
            '';

            PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
          };
        };
    };
}
