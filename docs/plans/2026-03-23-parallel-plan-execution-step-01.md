# Parallel Plan Execution — Step 1: Executing-Plans Rewrite

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Step 1 of 4** | Previous: none | Next: `2026-03-23-parallel-plan-execution-step-02.md`

**Goal:** Create the refactor-reviewer subagent prompt and rewrite the executing-plans skill with the TDD loop + refactor subagent pattern.

**Branch:** `feature/parallel-execution-step-1`

**Merge instruction:** Use superpowers:finishing-a-development-branch when done.

---

## Task 1: Create refactor-reviewer prompt

**Files:**
- Create: `skills/executing-plans/refactor-reviewer-prompt.md`

- [ ] **Step 1: Create the refactor-reviewer prompt file**

Create `skills/executing-plans/refactor-reviewer-prompt.md` with this content:

```markdown
# Refactor Reviewer Prompt Template

Use this template when dispatching a refactor reviewer subagent after each task's green phase.

**Purpose:** Review a single task's changes for unnecessary complexity, naming clarity, missed edge cases in tests, and YAGNI violations.

**Scope:** One task's diff only. The branch-reviewer at merge time provides the broader perspective.

**Dispatch after:** Tests pass for the current task (green phase complete).

` ` `
Agent tool (general-purpose):
  description: "Refactor review for Task N: [task name]"
  prompt: |
    You are reviewing a single task's changes for refactoring opportunities.

    ## Task Description

    [PASTE the task description from the plan]

    ## Changes Made

    Run this command to see the diff:
    ` ` `bash
    git diff [BASE_SHA]..HEAD
    ` ` `

    ## Test Results

    All tests pass. The implementation is functionally correct.

    ## Your Job

    Review the diff for:

    **Unnecessary complexity:**
    - Is there a simpler way to achieve the same result?
    - Are there abstractions that don't earn their keep?
    - Could any code be removed without losing functionality?

    **Naming clarity:**
    - Do names accurately describe what things do?
    - Would a reader understand the code without context?

    **Missed edge cases in tests:**
    - Are there obvious scenarios the tests don't cover?
    - Are error paths tested?

    **YAGNI violations:**
    - Was anything built that isn't needed yet?
    - Are there parameters, options, or branches that nothing uses?

    ## What NOT to Review

    - Architecture decisions (that's the branch reviewer's job)
    - Whether the task matches the spec (the plan has exact code)
    - Style/formatting (the formatter handles that)
    - Code outside this task's diff

    ## Report Format

    **Verdict:** clean | minor suggestions | needs rework

    **Suggestions (if any):**
    - [file:line] [suggestion] — [rationale]

    Keep it brief. If the code is clean, say so and stop.
` ` `
```

Note: The triple backticks above use spaces (` ` `) to avoid breaking the outer markdown fence. When creating the actual file, use real triple backticks (no spaces).

- [ ] **Step 2: Verify the file exists and reads correctly**

Run: `cat skills/executing-plans/refactor-reviewer-prompt.md | head -5`
Expected: First 5 lines of the file showing the title and opening text.

- [ ] **Step 3: Commit**

```bash
git add skills/executing-plans/refactor-reviewer-prompt.md
git commit -m "feat: add refactor-reviewer subagent prompt for executing-plans"
```

---

## Task 2: Rewrite executing-plans SKILL.md

**Files:**
- Modify: `skills/executing-plans/SKILL.md`

- [ ] **Step 1: Replace the entire content of `skills/executing-plans/SKILL.md`**

Replace the full file with:

```markdown
---
name: executing-plans
description: Use when you have a written implementation plan to execute — follows TDD loop with refactor review after each task
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks using a TDD loop with refactor review, commit after each task.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

## The Process

### Step 1: Load and Review Plan

1. Read plan file
2. Review critically — identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create tasks (one per plan task) and proceed

### Step 2: Execute Tasks

For each task, follow this loop:

#### Red

1. Write the failing test (from plan)
2. Run the project's formatter on the test file
3. Run the test — verify it fails with the expected error

#### Green

1. Write the implementation (from plan)
2. Run the project's formatter on the changed files
3. Run the test — verify it passes

#### Refactor

1. Get the diff for this task: `git diff HEAD`
2. Dispatch a refactor reviewer subagent (see `./refactor-reviewer-prompt.md`) scoped to this task's diff
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

- **Refactor review** — after each task's green phase, scoped to that task's diff (see `./refactor-reviewer-prompt.md`)
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
- Red-Green-Refactor for every task
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
```

- [ ] **Step 2: Verify the rewrite reads correctly**

Run: `head -20 skills/executing-plans/SKILL.md`
Expected: YAML frontmatter with updated description, then "# Executing Plans" heading.

- [ ] **Step 3: Commit**

```bash
git add skills/executing-plans/SKILL.md
git commit -m "feat: rewrite executing-plans with TDD loop and refactor reviewer"
```

---

### Risks & Considerations
- The refactor-reviewer prompt uses fenced code blocks nested inside markdown. Make sure triple backticks in the prompt file don't conflict with the outer fencing — use real backticks in the actual file (the plan above uses spaces for display purposes only).
- The executing-plans skill no longer references subagent-driven-development at all. Later steps will clean up other files that still reference it.
