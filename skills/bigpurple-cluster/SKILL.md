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
- Shared Slurm aliases live in `~/.bashrc` and use `$CLUSTER_LOG_DIR` (set by each project's `env-setup.sh`). Canonical snippet: `slurm-aliases.bash` (sibling file in this skill folder) — paste/append into `~/.bashrc` on the cluster. Run `qh` in-shell for the live reference.
- **Bash only** — no zsh-isms like `${$(cmd)##pattern}`. Split into a temp variable.

## Job Submission

### Two project conventions

Projects converge on one of two submission patterns:

1. **Header-based** (preferred): each script declares its own resource needs in a parseable `# CLUSTER:` comment block at the top of the file. `cluster/submit.sh` parses the header, applies CLI overrides, and falls back to family defaults from `cluster/defaults.sh` + `cluster/partitions.env`. Supports partition aliases (`any-gpu`, `a100`, `l40s`, `v100`, `h100`, `cpu`) so scripts can spread across the cluster without listing every partition by name. Canonical reference: `deep_embeddings_eval` (post-2026-05-26).
2. **Profile-based** (legacy): `cluster/submit.sh <script.py> --profile <name>` where profile files in `cluster/profiles/*.sh` hardcode partition/time/mem/gpus. Simple but conservative — typically pins everything to the lab partition. Still found in older projects that haven't migrated.

Use header-based for new work. When in doubt, check whether the project has `cluster/defaults.sh` (header-based) or `cluster/profiles/` (profile-based).

### Batch (header-based)

```bash
cluster/submit.sh <script.py> [-- script_args...]
```

The script must declare its needs in a header block (above the imports, after the docstring):

```python
# CLUSTER: partition=any-gpu   # alias or literal partition list
# CLUSTER: time=02:00:00       # required
# CLUSTER: gpus=1              # required (0 for CPU jobs)
# CLUSTER: cpus=8              # optional; default 8 GPU / 16 CPU
# CLUSTER: mem=64G             # optional; default 64G GPU / 32G CPU
# CLUSTER: exclude=cn-0058     # optional; merged with GLOBAL_EXCLUDES
# CLUSTER: reservation=NAME    # optional; needed for superpod / h100
```

CLI flags override the header per-submission: `--name`, `--time`, `--mem`, `--gpus`, `--cpus`, `--partition`, `--exclude`, `--reservation`, `--dry-run`.

Partition aliases (in headers and `--partition`):

| Alias | Expands to | Use case |
|-------|-----------|----------|
| `any-gpu` | A100 + L40S + V100 partitions | Default for GPU jobs — wide pool, queue jumps |
| `a100`    | A100 partitions only          | Need 40–80 GB GPU memory |
| `l40s`    | L40S partitions only          | The misnamed `cpu_*` partitions are actually L40S |
| `v100`    | V100 partitions only          | Smaller / older jobs |
| `h100`    | `superpod`                    | Reservation-only |
| `cpu`     | `data_mover` + `fn_*`         | Non-GPU work |

`submit.sh` generates a timestamped `.sbatch` in the logs dir with git provenance, sources `env-setup.sh`, runs via `uv run python` (or `Rscript` for `.R` files). The local off-cluster smoke test is `bash cluster/test_submit.sh`.

### Batch (profile-based, legacy)

```bash
cluster/submit.sh <script.py> --profile <profile> [-- script_args...]
```

Same overrides as above except no `--partition` aliases — partition is fixed by the profile file.

### Interactive

```bash
# Header-based projects:
cluster/interactive.sh [--partition <alias>] [--gpus N] [--time HH:MM:SS] [--bash | --python | --ipython]

# Legacy:
cluster/interactive.sh [--profile <profile>] [--ipython | --python]
```

For header-based, `--partition cpu` implies `--gpus 0` when `--gpus` is not specified (Slurm rejects GPU `--gres` on CPU-only partitions).

### Shared Aliases (from ~/.bashrc)

Canonical source: `slurm-aliases.bash` in this skill folder — copy into `~/.bashrc` on BigPurple. To update: edit that file, then `pbcopy < .../slurm-aliases.bash` and replace the block in `~/.bashrc`. The cluster shell's `qh` prints the live reference.

Families: queue views (`qq`, `qom`, `qop`, `qo`, `qow`), log viewers operating on `$CLUSTER_LOG_DIR` (`ql`, `qe`, `qc`, `qr`), diagnosis (`qwhy`, `qh`). Log viewers take an optional job-ID/substring arg and default to the most recent `.out`. `qr` shows real sacct state (COMPLETED / FAILED / CANCELLED / TIMEOUT / OUT_OF_MEMORY / NODE_FAIL / …) with color.

## Broken Nodes and GPU Diagnostics

### Excluded nodes

In header-based projects, `cluster/defaults.sh` exposes `GLOBAL_EXCLUDES` (defaults to `gh12-1,gh12-2,a100-8003`). The exclude list emitted to sbatch is `GLOBAL_EXCLUDES` ∪ header `exclude=` ∪ CLI `--exclude`, deduped.

In profile-based projects, the per-profile exclude list lives in `cluster/profiles/*.sh`.

- `gh12-1`, `gh12-2` — special GPUs, not suitable for standard workloads.
- `a100-8003` — broken NVIDIA fabric manager, CUDA hangs on init (recurring).

### Triage workflow for GPU failures

1. Find the node: `sacct -j <jobid> --format=NodeList`
2. Get an interactive shell on a GPU node and run the diagnose script:
   ```bash
   cluster/interactive.sh --partition any-gpu --gpus 1 --time 00:05:00 --bash
   # inside the shell:
   cluster/diagnose_gpu.sh
   ```
   (checks `/dev/nvidia*`, `nvidia-smi`, `cuInit()`)
3. If broken, add to `GLOBAL_EXCLUDES` in `cluster/defaults.sh` (or the profile's exclude list, for legacy projects)
4. Check if resolved later: `scontrol show node <node>` (look for idle/mixed vs drained)

## Cluster Nodes

See `PARTITIONS.md` (sibling file in this skill folder) for a snapshot of authorized partitions with hardware specs, generated by `cluster/discover_partitions.sh` on a project that runs it. Re-run that script in any project's `cluster/` dir to refresh — the cluster topology occasionally changes (new nodes added, partitions renamed).

### Partition layout (grouped by GPU type)

| Group | Partitions | Hardware |
|-------|-----------|----------|
| A100 (lab) | `oermannlab` | 8× A100, 96 CPUs, ~934 GB RAM (3 a100-8xxx nodes + cn-0058 + 2 excluded gh12) |
| A100 (shared) | `a100_dev` (4h), `a100_short` (3d), `a100_long` (28d) | 4× A100, 48 CPUs, ~468 GB RAM (~53 nodes total) |
| L40S | `gl40s_dev/short/long`, `cpu_dev/short/medium/long` | 4× L40S, 384 CPUs, 512–1410 GB RAM |
| V100 (4-GPU) | `gpu4_dev/short/medium/long` | 4× V100, 40 CPUs, 320 GB RAM |
| V100 (8-GPU) | `gpu8_short/medium/long` | 8× V100, 40 CPUs, 692–720 GB RAM |
| H100 | `superpod` | 8× H100, 224 CPUs, 2011 GB RAM (16 nodes) |
| CPU-only | `fn_short/medium/long`, `data_mover` | 40 CPUs, 320–1440 GB RAM (no GPUs) |

### Critical gotchas

- **`cpu_*` partitions have L40S GPUs**, not CPU-only — the name is historical. CPU-only work goes to `fn_*` (fat memory) or `data_mover`.
- **`superpod` requires an HPC-manager-granted Slurm reservation** — submit with `--reservation=<NAME>`. Do not include in default "any GPU" partition lists.
- **`a100-8003`** — fabric manager broken, recurring. Exclude globally.
- **`gh12-1`, `gh12-2`** — special GPUs, not for standard workloads. Exclude globally.
- **Slurm gates partitions by `--time` automatically**: a multi-partition list like `a100_dev,a100_short,a100_long` with `--time=12:00:00` silently drops `a100_dev` (4h max). Use this to your advantage — wide partition lists with a tight `--time` cost nothing.

## Common Gotchas

- **`((var++))` under `set -e`**: returns 1 when var starts at 0, causing the script to exit. Use `var=$((var + 1))`.
- **Long-running scripts**: must have checkpoint/resume and `--overwrite` flag. Slurm wall time limits mean jobs get killed.
- **Memory scaling**: avoid per-thread copies of large arrays. Think about memory at scale from the start.
- **`module load gcc`**: needed in `~/.bashrc` for compiled extensions.
