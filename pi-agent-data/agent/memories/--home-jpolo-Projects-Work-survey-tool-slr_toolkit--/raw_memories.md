# Raw Memories

## 019ec73c-b809-7000-bedb-bfbff0b65b8c
updated_at: 1781462713
## SLR Toolkit Project Architecture
- Backend: Python FastAPI app (`slr.api`), SQLite database, runs via uvicorn
- Frontend: Vue.js SPA built with Vite, output is static HTML/JS/CSS
- Backend version: slr 1.0.0

## Nix Flake Configuration
- Two flake outputs: `.#backend` (Python package via buildPythonApplication) and `.#frontend` (Node.js build via mkDerivation)
- Frontend build uses npm/nodejs in a mkDerivation, installs to `$out/share/slr-toolkit/`
- Backend build produces a Python env with uvicorn at `bin/uvicorn`
- Nix flake checks pass for both x86_64-linux and aarch64-linux

## NixOS Deployment
- NixOS module at `nix/module.nix` — provides `services.slr-toolkit` options
- Module options: `enable`, `package` (backend), `frontendPackage`, `port` (default 8000), `openFirewall`
- Module manages: systemd unit, nginx vhost, system user, firewall
- Imperative deploy script: `deploy/deploy-nixos.sh`
- Frontend static files deployed to `/var/lib/slr-toolkit/frontend/`
- Systemd service runs uvicorn directly from Nix store path (no venv)
- No pip/npm/venv on target — everything from Nix store

## Backend API Endpoints (FastAPI)
- Models in `slr/models.py` use Pydantic BaseModel for request/response contracts
- Key models: CriteriaIn, RoundIn, QueryIn, GoldSetIn, GoldMemberIn, GoldEvalIn, ConstrainedSimIn, ExploratorySimIn, CombinationSimIn, FieldIn, FieldUpdateIn, FieldValueIn, TagIn, ViewIn, ExclusionCriterionIn, ExclusionUpdateIn, CriterionAnnotateIn, AIReviewIn, AnnotationSubmitIn, DecisionIn
- Service modules: analysis, annotation, combinatorics, exclusion, fields, gold, matching, provenance, registry, reports, simulation, structure
- DB connection: per-request SQLite with autocommit, schema ensured on connect
- Config: `config.DB_DEFAULT` for database path

## Key Design Decisions
- Native NixOS deployment chosen over Docker — leverages Nix store for reproducibility
- Frontend served as static files by nginx, proxied to FastAPI backend
- Two deployment strategies supported: imperative script and declarative NixOS module

## 019ec736-0304-7000-ba3a-d5f1f257fd29
updated_at: 1781459065
Nixify skill workflow completed for slr_toolkit (Python project, requires-python >= 3.10, setuptools build system, pip-based).

Strategy chosen: A — Simple dev shell (single-language Python project, no poetry).

flake.nix structure: uses flake-parts with devShells.default containing:
- packages: python312, python312.pkgs.pip, python312.pkgs.virtualenv, python312.pkgs.venvShellHook, ruff, pkg-config, openssl.dev, git, nixfmt
- env vars: PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring (prevents keyring errors in Nix sandbox/offline)
- shellHook: prints activation message with Python version and setup instructions

.envrc: simple `use flake` directive.

Post-enter workflow: python -m venv .venv && source .venv/bin/activate && pip install -e '.[all]'

Key pattern: for pip-based Python projects, use Strategy A with venvShellHook + virtualenv in the nix dev shell, then create a venv inside the shell for actual dependency installation. openssl.dev included because fastapi/uvicorn dependencies need it.

Verification: nix flake check passed; nix develop -c confirmed Python 3.12.13 and ruff 0.15.16 available. Git dirty warning is expected and benign during initial setup.
