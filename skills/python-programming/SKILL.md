---
name: python-programming
description: General guidelines and defaults for Python programming. Use when working in Python projects.
---

## Defaults
- Language: Python 3.12+
- Package/env manager: **uv** (always). Use `pyproject.toml`; keep deps minimal.
- Style: **pythonic**, small modules, clear names, typed where it helps (pyright-friendly).
- Codebases should be **simple, readable, and easily expandable**.
- Lint/format: ruff (format + lint) — always env-local, never global
- **Dev tools** (`ruff`, `pytest`) go in `[dependency-groups].dev` so plain `uv sync` installs them. Invoke via `uv run ruff` / `uv run pytest` (never system-installed versions).
- If a project uses `[project.optional-dependencies]` instead, document the setup command in CLAUDE.md (e.g. `uv sync --extra dev`) — plain `uv sync` won't install them.
- Designed to scale: single GPU → **DDP** without rewrites; CPU parallelism where useful.
- Prefer "thin scripts, real code in `src/`"
  - For packages, scripts in /script. For projects, scripts numbered (01-.., 02-...) in root

## Initial Project Setup
- Always add pyright config to `pyproject.toml` during initial setup, not after Pyright errors appear:
```toml
[tool.pyright]
venvPath = "."
venv = ".venv"
```

## Training/Runtime Requirements
- **Fail early**: validate config, paths, dataset sample, shapes/dtypes, device, and a single forward/backward before full training.
- **Checkpoint by default**: resume-friendly. Save intermediary steps to file
- Deterministic option (with caveats) + explicit seeding.
- Log clearly: structured logs to file + rich console output.

## Style
- Avoid deduplication of code; use abstractions and re-usability
- Reduce dependencies, if only one functionality from a library is needed: try to re-implement it
- List/dictionary/tuple comprehension > for loops
- Use generators if it reduces the amount of data in memory

## Console
- Use **rich** for:
  - progress bars
  - pretty tables for config/device summary
  - readable logging (no spam; key metrics only)
  - Long running task should show that they're running and not hanging

## Parallelism Preferences
- Data: PyTorch DataLoader tuned (pin_memory on GPU, persistent_workers, configurable workers).
- Streaming-friendly datasets (IterableDataset when appropriate).
- GPU: AMP optional; support gradient accumulation; DDP-safe logging/checkpointing (rank 0 only).
- Efficient use of RAM, on-file intermediary saves, parquet sinks
- Data structures: zarr arrays with chunking, parquet files, polars

## What to Avoid
- Over-engineering, heavy frameworks, hidden state, global singletons
- Giant config systems; prefer a small typed config
