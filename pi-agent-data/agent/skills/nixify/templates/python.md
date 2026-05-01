# Python Templates

## Simple Python dev shell

For Python projects that use `requirements.txt`, `setup.py`, or a manual venv.

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

      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          python = pkgs.python312;
          pythonPackages = python.pkgs;
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              python
              pythonPackages.pip
              pythonPackages.virtualenv
              pythonPackages.venvShellHook
              ruff
              pyright
            ];

            shellHook = ''
              echo "🦇 <PROJECT> dev shell activated"
            '';
          };

          formatter = pkgs.nixfmt-classic;
        };
    };
}
```

## Python with poetry2nix

For Python projects using poetry that want a fully reproducible virtualenv managed by nix.

```nix
{
  description = "Development environment for <PROJECT>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (inputs.poetry2nix.lib.mkPoetry2Nix { inherit pkgs; }) mkPoetryEnv mkPoetryApplication;

          python = pkgs.python312;
          pythonPackages = python.pkgs;
        in
        {
          packages.default = mkPoetryApplication {
            projectDir = self;
            python = python;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              python
              poetry
              pythonPackages.pip
              pythonPackages.virtualenv
              ruff
              pyright
            ];

            shellHook = ''
              echo "🦇 <PROJECT> dev shell (poetry) activated"
              export VIRTUAL_ENV=.venv
              export PATH=".venv/bin:$PATH"
            '';
          };

          formatter = pkgs.nixfmt-classic;
        };
    };
}
```

### When to use poetry2nix vs simple

- **Simple**: You use `requirements.txt` or just want a bare Python + pip in the shell. You manage the venv yourself.
- **poetry2nix**: You use `pyproject.toml` + `poetry.lock` and want nix to create a deterministic virtualenv. This gives you `nix build` support and `nix flake check` for the Python package.

### Common native dependency patterns

Many Python packages need C libraries. Add these to `packages` (and `buildInputs` for poetry2nix):

| Python package | Nix packages needed |
|---|---|
| `psycopg2` / `psycopg2-binary` | `postgresql.dev` |
| `mysqlclient` | `mysql.client` `mysql.connector-c` |
| `Pillow` | `libjpeg.dev` `zlib.dev` `libtiff.dev` `libwebp.dev` |
| `cryptography` | `openssl.dev` `pkg-config` |
| `lxml` | `libxml2.dev` `libxslt.dev` |
| `h5py` | `hdf5.dev` |
| `numpy` / `scipy` | `gfortran` `blas` |

For poetry2nix, add these as `buildInputs` / `nativeBuildInputs` in the `mkPoetryApplication` / `mkPoetryEnv` call.

### Python version selection

Use the Python version matching `requires-python` in `pyproject.toml` or `python-requires` in `setup.py`:

| Version | nixpkgs attribute |
|---|---|
| 3.10 | `python310` |
| 3.11 | `python311` |
| 3.12 | `python312` |
| 3.13 | `python313` |