---
name: executing-plans
description: Use when you have a written implementation plan to execute — follows TDD loop for each task
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks using a TDD loop, commit after each task.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan

1. Read plan file
2. Review critically — identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create tasks (one per plan task) and proceed

### Step 2: Execute Tasks

For each task, follow this loop. If a task has no testable code (e.g., documentation, configuration, markdown), skip the Red and Green phases — apply the changes, then commit. Optionally dispatch the refactor reviewer if the changes were complex.

#### Red

1. Write the failing test (from plan)
2. Run the project's formatter on the test file
3. Run the test — verify it fails with the expected error

#### Green

1. Write the implementation (from plan)
2. Run the project's formatter on the changed files
3. Run the test — verify it passes

#### Refactor (optional)

Dispatch a refactor reviewer when:
- The implementation deviated significantly from the plan
- The task was complex enough to warrant a second look

The branch-reviewer at merge time catches the same issues with better whole-branch context. For plan-driven tasks with complete code, per-task review rarely adds value.

**When dispatching:**
1. Get the diff for this task: `git diff HEAD`
2. Dispatch a refactor reviewer subagent (general-purpose Agent tool, model: opus — see `./refactor-reviewer-prompt.md` for the prompt template) scoped to this task's diff
3. If the reviewer returns suggestions:
   - Apply accepted suggestions
   - Run the formatter on changed files
   - Re-run tests to confirm they still pass
4. If the reviewer returns "clean": proceed

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

- **Refactor review** — optionally after a task's green phase, scoped to that task's diff (see `./refactor-reviewer-prompt.md`)
- **Research / context gathering** — when you need to understand existing code without polluting your context
- **Worktree setup** — at the start of a session (via superpowers:using-git-worktrees)
- **Branch review** — at the end (via superpowers:finishing-a-development-branch)

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails unexpectedly, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** — stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Red-Green for every task, Refactor when warranted
- Run the formatter after every edit
- Don't skip verifications
- Commit after each task
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** — REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** — Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** — Complete development after all tasks
