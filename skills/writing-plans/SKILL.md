---
name: writing-plans
description: Use when writing or reviewing implementation plans — format reference for DAG roadmaps, step files, and task structure
---

# Writing Plans — Format Reference

## Overview

Implementation plans tell an engineer which files to touch, what each task must achieve, and what the tests must assert. DRY. YAGNI. TDD. Frequent commits.

Assume the implementer is a skilled developer who knows almost nothing about the codebase or problem domain, and who doesn't know good test design very well.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## The Plan Does Not Restate The TDD Loop

`superpowers:executing-plans` already runs Red → Green → Commit for **every** task, unconditionally. It writes the failing test, runs it, verifies the failure, implements, re-runs, and commits, without being told to.

So the plan must NOT spell out "write the failing test / run it / implement / run it / commit" per task. That is five checkboxes and ~40 lines restating a loop the executor supplies for free — and then the plan reviewer reviews the restatement. It is the single largest source of plan bloat.

**One block per task.** State what the task achieves, which files it touches, and what the test must assert. Let the executor run the ritual.

## What Code To Include

Include code only where a competent implementer could get it *wrong* from a one-line description:

- **Include:** exact signatures and contracts, non-obvious algorithms, specific constants or formulas, anything with a subtle correctness condition, anything where the wrong-but-plausible version would pass a naive test.
- **Omit:** boilerplate, obvious CRUD, imports, standard error handling, test scaffolding, anything the description already determines.

"Add a `--verbose` flag that prints each file as it's processed" needs no code block. "The ceiling must come from the measured value, not the config value" does — that's exactly where a plausible wrong implementation hides.

A plan that contains the whole implementation is not a plan; it is the implementation, written twice, in a file where nothing type-checks it.

## Plan Structure: DAG Roadmap + Self-Contained Step Files

### When to split

- **Default to a single plan file.** Most features fit in one step — prefer this unless there's a real reason to split.
- **Only split into DAG roadmap + step files** when there are genuinely independent work streams that benefit from parallel execution in separate worktrees, OR when the plan is large enough (many commits across distinct subsystems) that a single file would be unwieldy.
- Do not inflate commit counts or invent parallelism to justify splitting. Fewer steps is always better.

### Roadmap file

`docs/plans/YYYY-MM-DD-<feature>-roadmap.md` — the DAG of steps with explicit dependency and parallelism markers:

```markdown
# Feature X — Roadmap

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement each step below.

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]
**Design doc:** [Path to design doc]

---

## DAG

Step 1: Foundation (data models, shared types)
Step 2a: API layer           [parallel, depends: 1]
Step 2b: Background workers  [parallel, depends: 1]
Step 2c: UI components       [parallel, depends: 1]
Step 3: Integration tests    [sequential, depends: 2a, 2b, 2c]

## Steps

| Step | File | Purpose | Commits |
|------|------|---------|---------|
| 1 | `YYYY-MM-DD-<feature>-step-1.md` | Foundation | 3 |
| 2a | `YYYY-MM-DD-<feature>-step-2a.md` | API layer | 2 |
| ... | ... | ... | ... |
```

Sequential steps must be merged to main before their dependents can begin. Parallel steps can run simultaneously in separate Claude sessions, each in its own git worktree. Parallelism is user-managed — each session runs one step at a time independently.

**Branch rule:** Parallel steps MUST have separate branch names (e.g. `feat/auth-api`, `feat/auth-ui`). You cannot parallelize work on the same branch. Each parallel step merges independently to main.

Do NOT also create the combined single file — the roadmap + step files are the plan.

### Step files

Each step file is a fully self-contained mini-plan. A fresh Claude session can execute it without any other context. Each includes:

- **Header:** Goal, context (how this fits the overall feature), branch name, execution instruction (`superpowers:executing-plans`), merge instruction (`superpowers:finishing-a-development-branch`)
- **Task list:** One block per task — exact file paths, what the test must assert, and code only where it's non-obvious
- **Format/lint command:** The project-specific formatter to run after each edit (e.g., `ruff format <file> && ruff check --fix <file>`)

### Single-file plan format

The default for nearly all work. With one block per task, a single file comfortably holds 8-10 commits — split only when the sequencing constraints in "When to split" actually apply.

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Design doc:** [Path to design doc]

---
```

## Task Structure

One checkbox per task. `executing-plans` handles red/green/commit inside it.

````markdown
- [ ] **Task N: [what this task achieves]**

  **Files:** create `exact/path/to/file.py`, modify `exact/path/to/existing.py`, test `tests/path/test_file.py`

  **Test asserts:** `parse_config()` raises `ConfigError` on a missing `arm` key,
  and returns the measured ceiling — not the configured one — when both are present.

  **Non-obvious:** the ceiling comes from `run.measured_phi`; using `config.phi`
  here passes a naive test and is wrong.

  **Commit:** `feat: parse arm config from measured run`
````

Reach for a code block only when the **Non-obvious** line can't carry it — a
signature that must match exactly, a formula, a specific constant.

For a task with genuinely nothing subtle in it, three lines is a complete task:

````markdown
- [ ] **Task 4: add `--verbose` flag printing each file as it's processed**

  **Files:** modify `src/cli.py`, test `tests/test_cli.py`
  **Test asserts:** with `--verbose`, each input path appears in stdout; without it, none do.
  **Commit:** `feat: add --verbose flag`
````

## Remember
- Exact file paths — but **paths only, never line numbers.** `src/cli.py`, not `src/cli.py:123-145`. Line numbers go stale before the plan is executed and cost review rounds to maintain.
- Code only where it's non-obvious. The plan is not a second copy of the implementation.
- Don't restate the TDD loop — `executing-plans` runs it for every task.
- **The plan should be shorter than the diff it produces.** If it isn't, cut.
- DRY, YAGNI, TDD, frequent commits
