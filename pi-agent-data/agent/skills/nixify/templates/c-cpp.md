# C/C++ Templates

## Simple C/C++ dev shell

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
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            gcc
            gdb
            cmake
            pkg-config
            clang-tools  # clangd, clang-format
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

### CMake project with build support

```nix
perSystem = { config, self', inputs', pkgs, system, ... }:
  let
    myProject = pkgs.stdenv.mkDerivation {
      pname = "<PROJECT>";
      version = "0.1.0";
      src = self;
      nativeBuildInputs = with pkgs; [ cmake pkg-config ];
      buildInputs = with pkgs [ ]; # Add deps
    };
  in
  {
    packages.default = myProject;

    devShells.default = pkgs.mkShell {
      inputsFrom = [ myProject ];
      packages = with pkgs; [
        gdb
        clang-tools
      ];
      shellHook = ''
        echo "🦇 <PROJECT> dev shell (cmake build) activated"
      '';
    };

    formatter = pkgs.nixfmt-classic;
  };
```

### Common C/C++ library dependencies

| Library | Nix attribute |
|---|---|
| OpenSSL | `openssl.dev` |
| SQLite | `sqlite.dev` |
| PostgreSQL | `postgresql.dev` |
| MySQL | `mysql.client` `mysql.connector-c` |
| curl | `curl.dev` |
| zlib | `zlib.dev` |
| SDL2 | `SDL2.dev` |
| GTK | `gtk3.dev` |
| Qt | `qt6.qtbase.dev` |