# Common Nix Package Names Reference

Quick reference for frequently needed nixpkgs attribute names. Always verify with `nix search <name>` if unsure.

## Language runtimes

| What | nixpkgs attribute |
|---|---|
| Python 3.10 | `python310` |
| Python 3.11 | `python311` |
| Python 3.12 | `python312` |
| Python 3.13 | `python313` |
| Node.js 20 | `nodejs_20` |
| Node.js 22 | `nodejs_22` |
| Bun | `bun` |
| Go | `go` |
| Rust (via overlay) | `rust-bin.stable.latest.default` |
| GCC | `gcc` |
| Clang | `clang` |
| JDK 21 | `jdk21` |
| Elixir | `beam.packages.erlang_27.elixir_1_17` |
| Ruby | `ruby_3_3` |

## Package managers

| What | nixpkgs attribute |
|---|---|
| Poetry | `poetry` |
| pip | `python3XX.pkgs.pip` |
| virtualenv | `python3XX.pkgs.virtualenv` |
| pnpm | `nodePackages.pnpm` |
| yarn | `nodePackages.yarn` |
| npm | (built into nodejs) |
| Maven | `maven` |
| Gradle | `gradle` |
| Bundler | `bundix` |
| Mix2nix | `mix2nix` |

## Linters and formatters

| What | nixpkgs attribute |
|---|---|
| ruff | `ruff` |
| pyright | `pyright` |
| mypy | `python3XX.pkgs.mypy` |
| ESLint | `nodePackages.eslint` |
| Prettier | `nodePackages.prettier` |
| TypeScript | `nodePackages.typescript` |
| golangci-lint | `golangci-lint` |
| clippy | (comes with Rust toolchain) |
| rustfmt | (comes with Rust toolchain) |
| rust-analyzer | `rust-analyzer` |
| nixfmt | `nixfmt-classic` |
| alejandra | `alejandra` |
| shellcheck | `shellcheck` |
| shfmt | `shfmt` |
| clang-format | (comes with `clang-tools`) |

## Build tools

| What | nixpkgs attribute |
|---|---|
| CMake | `cmake` |
| Make | `gnumake` |
| pkg-config | `pkg-config` |
| OpenSSL dev | `openssl.dev` |
| SQLite dev | `sqlite.dev` |
| PostgreSQL dev | `postgresql.dev` |
| MySQL client | `mysql.client` |
| libffi dev | `libffi.dev` |
| zlib dev | `zlib.dev` |

## Debugging

| What | nixpkgs attribute |
|---|---|
| GDB | `gdb` |
| LLDB | `lldb` |
| strace | `strace` |
| ltrace | `ltrace` |
| valgrind | `valgrind` |

## Searching for packages

```bash
# Search by name
nix search nixpkgs <name>

# Search by regex
nix search nixpkgs 'python3.*pip'

# Quick check if a package exists
nix eval nixpkgs#<attr-path>.name
```

## Common overlay patterns

### Rust overlay (add to inputs)

```nix
rust-overlay = {
  url = "github:oxalica/rust-overlay";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then in `perSystem`:

```nix
# The overlay extends pkgs with rust-bin
config = { ... }: {
  nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
};
```

Or access directly:

```nix
rustToolchain = pkgs.rust-bin.stable.latest.default;
```

### Specific Rust version

```nix
rustToolchain = pkgs.rust-bin.stable."1.82.0".default;
```

### Nightly Rust

```nix
rustToolchain = pkgs.rust-bin.nightly.latest.default;
```