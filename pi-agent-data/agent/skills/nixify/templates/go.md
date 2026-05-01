# Go Templates

## Simple Go dev shell

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
            go
            gopls
            gotools
            golangci-lint
            gosec
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

### Go with build support

If the project needs `nix build` to produce a Go binary:

```nix
perSystem = { config, self', inputs', pkgs, system, ... }:
  let
    myProject = pkgs.buildGoModule {
      pname = "<PROJECT>";
      version = "0.1.0";
      src = self;
      vendorHash = ""; # Set after first build attempt; nix will tell you the correct hash
    };
  in
  {
    packages.default = myProject;

    devShells.default = pkgs.mkShell {
      inputsFrom = [ myProject ];
      packages = with pkgs; [
        gopls
        gotools
        golangci-lint
      ];
      shellHook = ''
        echo "🦇 <PROJECT> dev shell (go build) activated"
      '';
    };

    formatter = pkgs.nixfmt-classic;
  };
```

### CGO dependencies

If the Go project uses CGO (check for `import "C"` or `cgo` in go files), add:

```nix
packages = with pkgs; [
  gcc
  pkg-config
  # Add C libraries as needed, e.g.:
  # sqlite.dev
  # postgresql.dev
];
```

And set:

```nix
CGO_ENABLED = "1";
```