---
name: nixify
description: Analyze a project's language, build system, and dependencies, then generate a flake.nix devShell and .envrc so the project is immediately ready for NixOS development with direnv.
globs:
  - "**/*"
alwaysApply: false
---

# Nixify — Generate Nix Flakes for Any Project

## Purpose

When invoked, this skill analyzes the current project directory and generates a `flake.nix` (with an appropriate dev shell) and `.envrc` so that, after `direnv allow`, the project is fully configured for NixOS development and execution.

## Prerequisites

Before generating anything, verify these conditions. If any fail, report them as blockers:

1. `nix` is installed and flakes + nix-command are enabled (`nix flake --help` succeeds).
2. `direnv` is installed (`direnv version` succeeds).
3. The project is a git repository or the user is willing to `git init` (flakes require git).

If the project is not a git repo, offer to initialize one (`git init && git add -A`). Flakes will not see untracked files.

## Workflow

### Step 1 — Analyze the project

Probe the project to determine its type. Check in this order (first match wins for primary language; record all detected secondary languages):

#### Detection heuristics

| Signal files / dirs | Language / ecosystem | Key version indicators |
|---|---|---|
| `Cargo.toml` / `Cargo.lock` | Rust | `rust-version` in Cargo.toml; `edition` |
| `pyproject.toml` / `setup.py` / `setup.cfg` / `requirements.txt` / `Pipfile` | Python | `python-requires` or `requires-python`; `pyproject.toml` `[project] requires-python` |
| `package.json` / `pnpm-lock.yaml` / `yarn.lock` / `bun.lockb` / `.npmrc` | Node.js | `engines` field; `packageManager` in package.json |
| `go.mod` / `go.sum` | Go | `go` directive in go.mod |
| `*.sln` / `*.csproj` | C# / .NET | `TargetFramework` in csproj |
| `pom.xml` / `build.gradle` / `build.gradle.kts` | Java / Kotlin | `sourceCompatibility` / `targetCompatibility` / Kotlin version |
| `mix.exs` / `mix.lock` | Elixir | `elixir` version in mix.exs |
| `Gemfile` / `Gemfile.lock` | Ruby | `ruby` version in Gemfile or `.ruby-version` |
| `Makefile` / `CMakeLists.txt` / `meson.build` / `configure.ac` | C / C++ | Compiler flags, C standard |
| `flake.nix` already exists | Nix | — |
| `shell.nix` already exists | Nix (legacy) | — |

Read the version indicators. Extract exact or minimum versions when available; fall back to sensible defaults.

Also detect:

- **Package manager**: cargo, poetry, pip, npm, yarn, pnpm, bun, go modules, maven, gradle, mix, bundler, etc.
- **Linter / formatter config**: `.prettierrc`, `rustfmt.toml`, `ruff.toml`, `.flake8`, `.eslintrc*`, etc.
- **Test runner**: cargo test, pytest, jest/vitest, go test, etc.
- **Docker/OCI**: `Dockerfile`, `docker-compose.yml` — note but do NOT containerize the dev shell.
- **CI config**: `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` — useful for understanding test/lint commands.

If `flake.nix` or `shell.nix` already exists, ask the user whether to overwrite or update. Never silently replace existing nix files.

### Step 2 — Choose the flake strategy

Based on the primary language and project complexity, select a strategy:

#### Strategy A — Simple dev shell (default)

Use for: single-language projects, or projects where you just need tooling available in `$PATH`.

Structure: `flake-parts`-based flake with `devShells` using `mkShell`.

This is the **recommended default**. Only escalate to Strategy B or C if the project truly needs it.

#### Strategy B — Build + dev shell (Rust with crane)

Use for: Rust projects that benefit from cached incremental builds via crane.

Requires: `crane` input + `rust-overlay` (or fenix) for toolchain.

#### Strategy C — Build + dev shell (Python with poetry2nix)

Use for: Python projects using poetry that want reproducible virtualenvs.

Requires: `poetry2nix` input.

#### Strategy D — Multi-language / monorepo

Use for: projects with 2+ primary languages that need separate shells.

Structure: named devShells per language, plus a `default` that composes them.

### Step 3 — Generate flake.nix

Produce a `flake.nix` following the template structure appropriate for the chosen strategy.

#### Universal rules

1. **Use `flake-parts`** as the framework. It is the standard way to compose flakes and keeps things modular.
2. **Pin `nixpkgs`** via flake inputs. Use `nixpkgs-unstable` or `nixpkgs-unstable` as the default unless the user specifies otherwise.
3. **Set `systems`** to `["x86_64-linux"]` unless the user has other platforms — this is a NixOS desktop skill.
4. **Include a formatter**: `nixfmt-classic` or `alejandra` in the dev shell and as `formatter = nixfmt-classic`.
5. **Never hard-code system**: always use `pkgs.stdenv.system` or the flake-parts `config.systems` approach.
6. **Keep it minimal**: only include packages the project actually needs. Do not add speculative tooling.
7. **Set `MYSQL_CONFIG` and `PG_CONFIG` env vars** if mysql/pgsql dev headers are included.
8. **Set `LD_LIBRARY_PATH`** entries only when truly needed (e.g., for native extensions that need `.so` files at runtime in the dev shell).
9. **Add `shellHook`** that prints an informational message about the activated shell and any important env vars.
10. **For Python projects with native deps**, add the relevant `-dev` and `-out` packages so `pkg-config` and linker resolution work.
11. **Set `DYLD_LIBRARY_PATH` on Darwin** is NOT needed (NixOS only). But do NOT set it on Linux either unless there is a specific reason.
12. **Pre-commit hooks**: if the project has linters/formatters configured, add them to the dev shell so they're available. Do NOT add a full pre-commit hook framework unless the project already uses one.

#### Template: Strategy A — Simple dev shell

```nix
{
  description = "Development environment for <PROJECT_NAME>";

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
            # <TOOL_PACKAGES>
          ];

          shellHook = ''
            echo "🦇 <PROJECT_NAME> dev shell activated"
          '';
        };

        formatter = pkgs.nixfmt-classic;
      };
    };
}
```

Fill in `<TOOL_PACKAGES>` based on the detected language(s). Common packages per language:

**Rust**: `rustc`, `cargo`, `rustfmt`, `clippy`, `rust-analyzer`, `pkg-config`, `openssl.dev`
**Python**: `python312`, `python312.pkgs.pip`, `python312.pkgs.virtualenv`, `python312.pkgs.venvShellHook`, (if poetry) `poetry`, (if ruff) `ruff`
**Node.js**: `nodejs_22`, `nodePackages.pnpm` / `nodePackages.yarn` / `nodePackages.npm`, `nodePackages.typescript`, `nodePackages.typescript-language-server`
**Go**: `go`, `gopls`, `gotools`, `golangci-lint`
**C/C++**: `gcc`, `cmake`, `pkg-config`, `clang-tools`, `gdb`
**Java**: `jdk21`, `maven` / `gradle`
**Ruby**: `ruby_3_3`, `bundix`
**Elixir**: `beam.packages.erlang_26.elixir_1_16`, `mix2nix`
**Shell**: `shellcheck`, `shfmt`

#### Template: Strategy B — Rust with crane

```nix
{
  description = "Development environment and build for <PROJECT_NAME>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane.url = "github:ipetkov/crane";
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
            buildInputs = with pkgs; [ openssl ]
              ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ ];
            nativeBuildInputs = with pkgs; [ pkg-config ];
          };

          cargoArtifacts = craneLib'.buildDepsOnly commonArgs;

          <PROJECT_NAME> = craneLib'.buildPackage (commonArgs // {
            inherit cargoArtifacts src;
          });
        in
        {
          packages.default = <PROJECT_NAME>;

          checks = {
            inherit <PROJECT_NAME>;
            <PROJECT_NAME>-clippy = craneLib'.cargoClippy (commonArgs // {
              inherit cargoArtifacts src;
              cargoClippyExtraArgs = "--all-targets -- --deny warnings";
            });
            <PROJECT_NAME>-test = craneLib'.cargoTest (commonArgs // {
              inherit cargoArtifacts src;
            });
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ <PROJECT_NAME> ];

            packages = with pkgs; [
              rustToolchain
              rust-analyzer
              rustfmt
              clippy
              pkg-config
              openssl.dev
            ];

            shellHook = ''
              echo "🦇 <PROJECT_NAME> dev shell (crane) activated"
            '';
          };

          formatter = pkgs.nixfmt-classic;
        };
    };
}
```

Only use this if `Cargo.toml` exists. Replace `<PROJECT_NAME>` with the crate name (the `name` field in `Cargo.toml`, hyphenated).

#### Template: Strategy C — Python with poetry2nix

```nix
{
  description = "Development environment for <PROJECT_NAME>";

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
          packages.default = mkPoetryApplication { projectDir = self; python = python; };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              python
              poetry
              pythonPackages.pip
              pythonPackages.virtualenv
              ruff
            ];

            shellHook = ''
              echo "🦇 <PROJECT_NAME> dev shell (poetry) activated"
              # Poetry venv is created in-project; add to PATH
              export VIRTUAL_ENV=.venv
              export PATH=".venv/bin:$PATH"
            '';
          };

          formatter = pkgs.nixfmt-classic;
        };
    };
}
```

#### Template: Strategy D — Multi-language / monorepo

Produce named devShells per detected language, plus a `default` that composes them. Example for a Python + Node monorepo:

```nix
{
  description = "Development environment for <PROJECT_NAME>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells = {
          default = pkgs.mkShell {
            inputsFrom = [
              config.devShells.python
              config.devShells.node
            ];
            shellHook = ''
              echo "🦇 <PROJECT_NAME> dev shell (all) activated"
            '';
          };

          python = pkgs.mkShell {
            packages = with pkgs; [
              python312
              python312.pkgs.pip
              python312.pkgs.virtualenv
            ];
            shellHook = ''
              echo "  Python shell active"
            '';
          };

          node = pkgs.mkShell {
            packages = with pkgs; [
              nodejs_22
              nodePackages.pnpm
            ];
            shellHook = ''
              echo "  Node.js shell active"
            '';
          };
        };

        formatter = pkgs.nixfmt-classic;
      };
    };
}
```

### Step 4 — Generate .envrc

Always generate `.envrc` alongside `flake.nix`:

```
use flake
```

That is the entire file. `direnv allow` after generation will activate the shell.

If `.envrc` already exists and contains `use flake`, leave it alone. If it exists but does NOT contain `use flake`, ask the user whether to add it or replace.

### Step 5 — Generate .direnvrc (optional, advanced)

Only generate `.direnvrc` if the project has special layout needs that `use flake` alone cannot handle. In most cases, `.envrc` with `use flake` is sufficient.

Common additions for `.envrc`:

- `export DOTNET_CLI_TELEMETRY_OPTOUT=1` for .NET projects
- `export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring` for offline Python
- `export CARGO_HOME=$PWD/.cargo` for Rust projects wanting local cargo cache

Do NOT add these speculatively. Only add if the project's config or known issues require them.

### Step 6 — Initialize git if needed

If the project is not a git repo, initialize one:

```bash
git init
git add -A
```

Flakes require git. Untracked files are invisible to `nix build` / `nix develop`. Warn the user about this.

### Step 7 — Verify

After generating all files, run verification:

1. `nix flake check` — validates the flake schema and any defined checks.
2. If `nix flake check` fails, read the error, fix the flake, and retry. Do not leave the user with a broken flake.
3. `direnv allow` — triggers direnv to pick up the new shell.
4. Report the activated packages by running `direnv status` or inspecting the environment.

If `nix flake check` fails due to missing nixpkgs packages, check that the package name exists in nixpkgs. Use `nix search <name>` to verify. Common pitfalls:
- Package was renamed (e.g., `nodejs` → `nodejs_22`)
- Package is in a different attribute set (e.g., `python312.pkgs.requests`)
- Platform-specific package not available on `x86_64-linux`

### Step 8 — Report

Tell the user:
1. What language(s) were detected
2. What strategy was chosen and why
3. What files were created/modified
4. What packages are available in the dev shell
5. How to enter the shell (`nix develop` or `direnv allow`)
6. Any caveats or manual steps (e.g., "you need to run `poetry install` after entering the shell")

## Common pitfalls

- **Native dependencies**: Python packages with C extensions need `buildInputs` / `nativeBuildInputs` in the dev shell. Check `pyproject.toml` / `setup.py` for C deps.
- **OpenSSL**: Many languages need `openssl` and `pkg-config` in the dev shell for TLS. Add `openssl.dev` to `packages` and `pkg-config` as well.
- **PostgreSQL / MySQL client libs**: If the project uses database drivers, add `postgresql.dev` / `mysql.client` and set `PG_CONFIG` / `MYSQL_CONFIG`.
- **Node native modules**: `node-gyp` needs `python3`, `gcc`, `make`. Add them if `package.json` has `node-gyp` dependencies.
- **Rust on NixOS**: never install Rust via rustup inside a nix shell. Use `rust-overlay` or the nixpkgs `rustPlatform` toolchain.
- **PATH shadowing**: if `shellHook` sets `PATH`, always prepend (not append) so nix packages take precedence: `export PATH="${pkgs.something}/bin:$PATH"`.
- **Flake lock drift**: after generating, run `nix flake update` if the lock file needs refreshing. Otherwise, `nix flake lock` creates one on first use.

## Advanced options

The user may request any of these. Do NOT apply them by default:

- **nix-direnv integration**: already handled by `use flake` in `.envrc` (nix-direnv is assumed since they have direnv on NixOS).
- **pre-commit-hooks**: add `pre-commit-hooks-nix` input and configure hooks if requested.
- **devenv**: if the user prefers `devenv` over raw `flake-parts`, generate a `devenv.nix` and `devenv.yaml` instead. This is a different format — see https://devenv.sh.
- **Dream2Nix**: for complex Node/Python projects that need build packaging, not just dev shells. See https://dream2nix.dev.
- **Overlays / custom packages**: if the project has local nix packages, add them as `overlays` or `packages` in the flake.

## File reference

For language-specific reference templates, see:
- `skill://nixify/templates/rust.md` — Rust (simple and crane)
- `skill://nixify/templates/python.md` — Python (simple and poetry2nix)
- `skill://nixify/templates/node.md` — Node.js
- `skill://nixify/templates/go.md` — Go
- `skill://nixify/templates/c-cpp.md` — C/C++
- `skill://nixify/templates/multi.md` — Multi-language
- `skill://nixify/templates/common-packages.md` — Package name reference