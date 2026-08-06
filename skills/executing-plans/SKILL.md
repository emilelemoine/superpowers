---
name: executing-plans
description: Use when you have a written implementation plan to execute — follows TDD loop for each task
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks using a TDD loop, commit after each task.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 0: Set Up Worktree

Plan execution ALWAYS runs in an isolated worktree — that is the default, not a special case. The only question is whether one already exists.

1. Check if already in a worktree: compare `git rev-parse --git-dir` with `git rev-parse --git-common-dir`. If they **differ**, this checkout is a linked worktree (works for any worktree directory name — `.worktrees/`, `worktrees/`, or a custom path), so you're already isolated; proceed to Step 1.
2. Otherwise you are in the main checkout — **regardless of which branch is checked out** (main, master, or an existing feature branch). Being on a feature branch in the main checkout is NOT isolation; it's exactly the state that needs a worktree. Use `superpowers:using-git-worktrees` to create an isolated workspace before proceeding.

**Do not skip worktree setup just because you're already off `main`.** A leftover feature branch in the main checkout is the most common way the pipeline silently stops isolating work — treat it like any other un-isolated state.

### Step 1: Load and Review Plan

1. Read plan file
2. Review critically — identify any questions or concerns about the plan
3. If concerns: Raise them with the user before starting
4. If no concerns: Create tasks (one per plan task) and proceed

### Step 2: Execute Tasks

For each task, follow this loop. If a task has no testable code (e.g., documentation, configuration, markdown), skip the Red and Green phases — apply the changes, then commit.

#### Red

1. Write the failing test (from plan)
2. Run the project's formatter on the test file
3. Run the test — verify it fails with the expected error

#### Green

1. Write the implementation (from plan)
2. Run the project's formatter on the changed files
3. Run the test — verify it passes

#### Commit

```bash
git add <changed-files>
git commit -m "<conventional-prefix>: <description>"
```

Mark task as completed and move to the next task.

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## Subagent Usage

Subagents are used only for support tasks — the main session writes all code:

- **Research / context gathering** — when you need to understand existing code without polluting your context
- **Worktree setup** — at the start of a session (via superpowers:using-git-worktrees)
- **Branch review** — at the end (via superpowers:finishing-a-development-branch)

## Parallel Steps

When executing a DAG roadmap with parallel steps:
- Parallel steps are user-managed — each runs in a separate Claude session with its own worktree
- This skill handles one step at a time; parallelism comes from running multiple sessions
- Each step file is self-contained; no shared state between parallel sessions
- Sequential steps must be merged to main before their dependents can begin

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails unexpectedly, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- The user updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** — stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Red-Green-Commit for every task
- Run the formatter after every edit
- Don't skip verifications
- Commit after each task
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** — REQUIRED (Step 0): isolate work in a worktree unless already inside one
- **superpowers:writing-plans** — Format reference for implementation plans
- **superpowers:finishing-a-development-branch** — Complete development after all tasks
