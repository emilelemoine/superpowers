# Parallel Plan Execution — Roadmap

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement each step below.

**Goal:** Replace sequential step-by-step plans with DAG-based plans that maximize parallelism, merge the two execution skills into one, and retire subagent-driven-development.

**Architecture:** The code-planner produces DAG roadmaps with self-contained step files. The single execution skill (`executing-plans`) uses a TDD loop with a lightweight refactor-reviewer subagent after each task. Parallelism is achieved by running independent steps in separate terminals/worktrees, not by subagent dispatch.

**Tech Stack:** Markdown skill files, shell test scripts

**Design doc:** `docs/superpowers/specs/2026-03-23-parallel-plan-execution-design.md`

---

## DAG

```
Step 1: Rewrite executing-plans skill + create refactor-reviewer
Step 2: Update planner skills (writing-plans, code-planner) for DAG format      [depends: 1]
Step 3: Update brainstorming + peripheral skills                                 [depends: 2]
Step 4: Retire subagent-driven-development + update docs/tests                   [depends: 3]
```

All steps are sequential — each builds on the previous and must be merged to main before starting the next.

## Steps

| Step | File | Purpose | Commits |
|------|------|---------|---------|
| 1 | `2026-03-23-parallel-plan-execution-step-01.md` | Create refactor-reviewer prompt, rewrite executing-plans SKILL.md | 2 |
| 2 | `2026-03-23-parallel-plan-execution-step-02.md` | Update writing-plans and code-planner for DAG format, single execution skill | 2 |
| 3 | `2026-03-23-parallel-plan-execution-step-03.md` | Update brainstorming, finishing-a-development-branch, using-git-worktrees, requesting-code-review | 2 |
| 4 | `2026-03-23-parallel-plan-execution-step-04.md` | Delete SDD files, update README/CLAUDE.md/docs, update test infrastructure | 2 |
