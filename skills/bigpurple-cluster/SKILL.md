---
name: bigpurple-cluster
description: Use when working on any project that runs on NYU's BigPurple Slurm cluster — job submission, GPU debugging, env setup, scratch vs data paths, node exclusions, GPFS quirks, or cluster shell configuration
---

# BigPurple Cluster

Reference for NYU's BigPurple HPC cluster. Project-specific variables and paths belong in each project's CLAUDE.md — this skill covers cross-project patterns and gotchas.

## File System Layout

| Path | Purpose | Notes |
|------|---------|-------|
| `/data/` | Shared read-only datasets | Slower writes, fine for reads |
| `/gpfs/scratch/$USER/` | Per-user derived data | 10TB quota, faster writes |
| `/project_data/` | Shared between users | For cross-user collaboration |

- **Never write derived data to `/data/`** — all outputs go to scratch.
- `/gpfs/scratch` is faster than `/data` for writes, comparable for reads.

## Project Environment Convention

Each project has a `cluster/env-setup.sh` that is idempotent (safe to re-source). It:
1. Adds `~/.local/bin` to PATH (for `uv`)
2. Exports project-specific env vars with a short prefix (`DEE_`, `LER_`, etc.)
3. Creates scratch directories
4. Conditionally runs `uv sync` (only when `uv.lock` is newer than a stamp file)
5. Sets `export CLUSTER_LOG_DIR=<project-logs-dir>` for shared aliases
6. Defines project-specific aliases (e.g. `dee-pull`, `ler-pull`)

**Naming convention**: each project picks a short prefix. Standard variables:
- `<PREFIX>_ROOT` — project root on BigPurple
- `<PREFIX>_DATA` — raw input data (often read-only)
- `<PREFIX>_SCRATCH` — all derived data on `/gpfs/scratch`
- `<PREFIX>_LOGS` — Slurm job logs (`$<PREFIX>_SCRATCH/logs`)

Each project also has a shell alias in `~/.bashrc` (e.g. `dee`, `ler`) that cd's into the project and sources `env-setup.sh`.

## UV and Python on GPFS

- `UV_LINK_MODE=copy` — **required** because GPFS doesn't support hardlinks across mount points. Without this, `uv sync` fails silently or creates broken venvs.
- `UV_CACHE_DIR` should point to scratch (not home) to avoid filling home quota.
- Conditional sync: `env-setup.sh` only re-runs `uv sync` when `uv.lock` is newer than a stamp file (`$<PREFIX>_SCRATCH/.uv-synced`), so re-sourcing is cheap.
- Git dependencies (like `eegarray`, `eegzoo`): update with `uv lock --upgrade-package <pkg> && uv sync`, not `git pull` of a local clone.

## Shell Configuration

- Login shell is `/bin/bash`.
- User-level modifications (aliases, env vars, PATH) go in `~/.bashrc`.
- `~/.bash_profile` must source `~/.bashrc` for login shells (SSH sessions) to pick them up.
- Shared Slurm aliases (`qq`, `ql`, `qe`, `qr`) live in `~/.bashrc` and use `$CLUSTER_LOG_DIR` (set by each project's `env-setup.sh`).
- **Bash only** — no zsh-isms like `${$(cmd)##pattern}`. Split into a temp variable.

## Job Submission

### Profiles

| Profile | Partition | GPUs | CPUs | RAM | Wall time | Use case |
|---------|-----------|------|------|-----|-----------|----------|
| `cpu` | oermannlab | 0 | 16 | 128G | 4h | Preprocessing, evaluation |
| `gpu1` | oermannlab | 1 | 8 | 64G | 12h | Embedding extraction, probes |
| `gpu2` | oermannlab | 2 | 16 | 128G | 12h | Multi-GPU jobs |
| `gpu8` | oermannlab | 8 | 64 | 512G | 24h | Full-node jobs |
| `superpod` | superpod | 1 (80GB) | 8 | 80G | 12h | Very large models |

Default is `gpu1`. Use `--profile cpu` for non-GPU work.

### Batch

```bash
cluster/submit.sh <script.py> --profile <profile> [-- script_args...]
```

Generates a timestamped `.sbatch` in the logs dir with git provenance, sources `env-setup.sh`, runs via `uv run python`. Supports overrides: `--time`, `--mem`, `--gpus`, `--cpus`, `--partition`, `--dry-run`.

### Interactive

```bash
cluster/interactive.sh [--profile <profile>] [--ipython] [--python]
```

### Shared Aliases (from ~/.bashrc)

- `qq` — compact `squeue` for your jobs
- `ql [pattern]` — tail stdout of most recent job log
- `qe [pattern]` — same as `ql` (stderr merged into `.out`)
- `qr` — 10 most recent jobs with STATE and DURATION columns

## Broken Nodes and GPU Diagnostics

### Excluded nodes

All GPU profiles exclude `gh12-1`, `gh12-2` (special GPUs, not suitable for standard workloads).

`a100-8003` is excluded from `gpu1` (broken NVIDIA fabric manager — CUDA hangs on init).

### Triage workflow for GPU failures

1. Find the node: `sacct -j <jobid> --format=NodeList`
2. Run `cluster/diagnose_gpu.sh` on the node (checks `/dev/nvidia*`, `nvidia-smi`, `cuInit()`)
3. If broken, add to the profile's exclude list
4. Check if resolved later: `scontrol show node <node>` (look for idle/mixed vs drained)

## Cluster Nodes

| Partition | Nodes | GPUs | Notes |
|-----------|-------|------|-------|
| oermannlab | a100-8001 to a100-8003, cn-0058 | 8x A100 + 1TB RAM each | a100-8003 currently broken |
| oermannlab | gh12-1, gh12-2 | Special GPUs | Excluded — not for standard workloads |
| superpod | sp-0001 to sp-0016 | 80GB VRAM | For very large models |
| (general) | gn/gpu nodes | V100s | |

## Common Gotchas

- **`((var++))` under `set -e`**: returns 1 when var starts at 0, causing the script to exit. Use `var=$((var + 1))`.
- **Long-running scripts**: must have checkpoint/resume and `--overwrite` flag. Slurm wall time limits mean jobs get killed.
- **Memory scaling**: avoid per-thread copies of large arrays. Think about memory at scale from the start.
- **`module load gcc`**: needed in `~/.bashrc` for compiled extensions.
