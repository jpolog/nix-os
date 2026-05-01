# Rust Templates

## Simple Rust dev shell

For Rust projects that only need tooling in PATH (no cached incremental builds).

```nix
{
  description = "Development environment for <PROJECT>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          rustToolchain = pkgs.rust-bin.stable.latest.default;
        in
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              rustToolchain
              rust-analyzer
              rustfmt
              clippy
              pkg-config
              openssl.dev
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

## Rust with crane (cached builds)

For Rust projects that want `nix build` support with cached incremental compilation.

```nix
{
  description = "Build and dev environment for <PROJECT>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane = {
      url = "github:ipetkov/crane";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          craneLib = inputs.crane.lib.${system};
          rustToolchain = pkgs.rust-bin.stable.latest.default;
          craneLib' = craneLib.overrideToolchain rustToolchain;

          src = craneLib'.path ./.;

          commonArgs = {
            strictDeps = true;
            buildInputs = with pkgs; [
              openssl
            ];
            nativeBuildInputs = with pkgs; [
              pkg-config
            ];
          };

          cargoArtifacts = craneLib'.buildDepsOnly commonArgs;

          myProject = craneLib'.buildPackage (commonArgs // {
            inherit cargoArtifacts src;
          });
        in
        {
          packages.default = myProject;

          checks = {
            inherit myProject;
            myProject-clippy = craneLib'.cargoClippy (commonArgs // {
              inherit cargoArtifacts src;
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            });
            myProject-test = craneLib'.cargoTest (commonArgs // {
              inherit cargoArtifacts src;
            });
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ myProject ];

            packages = with pkgs; [
              rustToolchain
              rust-analyzer
              rustfmt
              clippy
              pkg-config
              openssl.dev
            ];

            shellHook = ''
              echo "🦇 <PROJECT> dev shell (crane) activated"
            '';
          };

          formatter = pkgs.nixfmt-classic;
        };
    };
}
```

### When to use crane vs simple

- **Simple**: You just need `cargo build`, `cargo test`, `cargo run` in the shell. You don't need `nix build` to produce a binary.
- **Crane**: You want `nix build` to produce a cached binary, or you want `nix flake check` to run clippy/test checks, or you have a CI pipeline that benefits from dependency caching.

### Notes

- Always use `rust-overlay` for the toolchain — never `rustup` inside a nix shell on NixOS.
- Add `openssl.dev` and `pkg-config` to both `buildInputs`/`nativeBuildInputs` (crane) and `packages` (dev shell) — most Rust projects need TLS.
- If using `sqlx`, add `sqlite.dev` or `postgresql.dev` as needed.
- If using `systemd` crates, add `systemd.dev` and `libseccomp.dev`.