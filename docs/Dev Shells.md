---
tags: [development, shells, reference]
---

# Dev Shells

Reproducible, flake-based development environments defined in `dev-shells/`. Each shell pins its toolchain via [[Flake Inputs|nixpkgs]], so every project gets the same versions regardless of what's installed system-wide.

## Default Shell

`dev-shells/default.nix` aggregates all named shells into a single attribute set consumed by the flake's `devShells` output. There is no bare "default" shell with common tools — every shell is language-specific.

| Attribute | File | Description |
|-----------|------|-------------|
| `python` | `dev-shells/python.nix` | Python 3.12 ecosystem |
| `node` | `dev-shells/node.nix` | Node.js 22 ecosystem |
| `rust` | `dev-shells/rust.nix` | Rust toolchain |
| `go` | `dev-shells/go.nix` | Go toolchain |

## Python

```bash
nix develop /etc/nixos#python
```

**Packages:**

| Category | Packages |
|----------|----------|
| Interpreter | `python312` |
| Package management | `pip`, `virtualenv`, `setuptools`, `wheel` |
| Interactive shells | `ipython`, `jupyter` |
| Data science | `numpy`, `pandas`, `matplotlib`, `scikit-learn` |
| Linting & formatting | `ruff`, `black`, `isort` |
| Type checking & LSP | `pyright`, `python-lsp-server` |
| Neovim integration | `pynvim` |

**Environment variables:**

- `PIP_PREFIX` — set to `$(pwd)/_build/pip_packages` to prevent writes to `/nix/store`
- `PYTHONPATH_EXTRA` — includes the local pip packages path

The shell hook prints version info and a quick-start guide.

## Node.js

```bash
nix develop /etc/nixos#node
```

**Packages:**

| Category | Packages |
|----------|----------|
| Runtime | `nodejs_22` |
| Package managers | `npm`, `yarn`, `pnpm` |
| TypeScript | `typescript`, `typescript-language-server` |
| Linting & formatting | `eslint`, `prettier` |
| Build tools | `webpack-cli`, `vite` |

## Rust

```bash
nix develop /etc/nixos#rust
```

**Packages:**

| Category | Packages |
|----------|----------|
| Toolchain | `rustc`, `cargo`, `rustfmt`, `clippy` |
| LSP & tooling | `rust-analyzer`, `cargo-watch`, `cargo-edit`, `cargo-outdated` |
| Extras | `bacon` (background code checker) |

**Environment variables:**

- `RUST_BACKTRACE = "1"` — always on

## Go

```bash
nix develop /etc/nixos#go
```

**Packages:**

| Category | Packages |
|----------|----------|
| Toolchain | `go` |
| LSP & tools | `gopls`, `gotools`, `go-tools` |
| Extras | `gomodifytags`, `gotests`, `impl`, `delve` (debugger) |

**Environment variables:**

- `CGO_ENABLED = "1"`

## How to Use

### Ad-hoc shell

```bash
nix develop /etc/nixos#python    # Python
nix develop /etc/nixos#node      # Node.js
nix develop /etc/nixos#rust      # Rust
nix develop /etc/nixos#go        # Go
```

### Launcher scripts

The `home.profiles.development` profile creates convenience scripts at `~/.local/bin/`:

| Script | Equivalent |
|--------|------------|
| `dev-python` | `nix develop /etc/nixos#python` |
| `dev-node` | `nix develop /etc/nixos#node` |
| `dev-rust` | `nix develop /etc/nixos#rust` |
| `dev-go` | `nix develop /etc/nixos#go` |

```bash
dev-python   # enter Python shell
dev-node     # enter Node.js shell
dev-rust     # enter Rust shell
dev-go       # enter Go shell
```

These are enabled by default when [[Home Profiles|development profile]] is active (`devShells.enableLaunchers = true`).

## Direnv Integration

When `devShells.enableDirenvTemplates = true` (default in the development profile), templates are installed at `~/.config/direnv/templates/`:

| Template | Flake output |
|----------|-------------|
| `python.envrc` | `use flake /etc/nixos#python` |
| `node.envrc` | `use flake /etc/nixos#node` |
| `rust.envrc` | `use flake /etc/nixos#rust` |
| `go.envrc` | `use flake /etc/nixos#go` |

To activate a shell per-project:

```bash
cd myproject
cp ~/.config/direnv/templates/python.envrc .envrc
direnv allow
```

Direnv + nix-direnv are configured system-wide (see [[System Modules]]) and per-user via [[Home Profiles]]. The integration creates persistent GC roots so environments aren't garbage-collected mid-session.

## Adding a New Shell

1. Create `dev-shells/<name>.nix`:

   ```nix
   { pkgs }:

   pkgs.mkShell {
     name = "<name>-dev";

     buildInputs = with pkgs; [
       # packages here
     ];

     shellHook = ''
       echo "<Name> Development Environment"
     '';
   };
   ```

2. Register it in `dev-shells/default.nix`:

   ```nix
   <name> = import ./<name>.nix { inherit pkgs; };
   ```

3. Add a launcher script in `home/profiles/development.nix` (optional, mirrors the existing `dev-python`/`dev-node` pattern).

4. Add a direnv template in `home/profiles/development.nix` (optional, mirrors the existing template pattern).

5. Rebuild or `direnv allow` to pick up the new shell.

## Cross-References

- [[Home Profiles]] — development profile enables launchers + direnv templates
- [[Flake Inputs]] — nixpkgs and nix-direnv inputs that pin shell versions
- [[AI Agent Reference]] — the nixify skill can scaffold project-level dev shells