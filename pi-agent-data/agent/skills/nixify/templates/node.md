# Node.js Templates

## Simple Node.js dev shell

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
            nodejs_22
            nodePackages.pnpm  # or nodePackages.yarn / nodePackages.npm
            nodePackages.typescript
            nodePackages.typescript-language-server
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

### Package manager selection

Check `package.json` for `packageManager` field or lock files:

| Lock file | Package manager | Nix package |
|---|---|---|
| `pnpm-lock.yaml` | pnpm | `nodePackages.pnpm` |
| `yarn.lock` | Yarn | `nodePackages.yarn` |
| `bun.lockb` | Bun | `bun` |
| `package-lock.json` | npm | (built into `nodejs`) |

### Node native modules

If the project has native dependencies (node-gyp), add:

```nix
packages = with pkgs; [
  nodejs_22
  python312  # node-gyp needs python
  gcc
  gnumake
  pkg-config
];
```

### Corepack

If the project uses `packageManager` in `package.json`, enable corepack:

```nix
shellHook = ''
  corepack enable
  corepack prepare pnpm@latest --activate  # adjust version
'';
```

### Bun variant

```nix
packages = with pkgs; [
  bun
];
```