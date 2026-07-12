# Workflow Cleanup — Step 2: Execution Fixes, Phrasing Cleanup, and Deprecation Removal

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Goal:** Add parallel execution guidance, fix worktree handoff, fix default spec path, consolidate worktree cleanup docs, remove deprecated commands, and clean personality-specific phrasing.

**Context:** This is step 2 of the workflow cleanup. Step 1 (review consolidation and plan deduplication) must be merged first. This step covers design doc changes 3-9.

**Branch:** `cleanup/execution-and-phrasing`

**Design doc:** `docs/specs/2026-03-23-workflow-cleanup-design.md`

**Format/lint:** N/A (markdown files only)

**After all tasks:** Use superpowers:finishing-a-development-branch to merge.

---

### Task 1: Add parallel steps guidance to executing-plans

**Files:**
- Modify: `skills/executing-plans/SKILL.md`

- [ ] **Step 1: Add Parallel Steps section**

In `skills/executing-plans/SKILL.md`, after the "Subagent Usage" section and before "When to Stop and Ask for Help", insert:

```markdown
## Parallel Steps

When executing a DAG roadmap with parallel steps:
- Parallel steps are user-managed — each runs in a separate Claude session with its own worktree
- This skill handles one step at a time; parallelism comes from running multiple sessions
- Each step file is self-contained; no shared state between parallel sessions
- Sequential steps must be merged to main before their dependents can begin
```

- [ ] **Step 2: Commit**

```bash
git add skills/executing-plans/SKILL.md
git commit -m "feat: add parallel steps guidance to executing-plans

Explains the user-managed parallelism model: one step per session,
each in its own worktree, no shared state between sessions."
```

---

### Task 2: Fix worktree setup handoff in executing-plans

**Files:**
- Modify: `skills/executing-plans/SKILL.md`

- [ ] **Step 1: Add Step 0 before Step 1**

In `skills/executing-plans/SKILL.md`, replace:

```markdown
### Step 1: Load and Review Plan

1. Read plan file
2. Review critically — identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create tasks (one per plan task) and proceed
```

with:

```markdown
### Step 0: Set Up Worktree

1. Check if already in a worktree: `git rev-parse --show-toplevel` — if the path contains `.worktrees/`, you're already in one; proceed to Step 1
2. If not in a worktree and not on main/master, you're on a feature branch in the main repo — proceed to Step 1 without worktree setup
3. If on main/master, use `superpowers:using-git-worktrees` to create an isolated workspace before proceeding

### Step 1: Load and Review Plan

1. Read plan file
2. Review critically — identify any questions or concerns about the plan
3. If concerns: Raise them with the user before starting
4. If no concerns: Create tasks (one per plan task) and proceed
```

- [ ] **Step 2: Remove worktree from Integration footnote**

Replace the Integration section at the bottom of the file:

```markdown
## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** — REQUIRED: Set up isolated workspace before starting
- **superpowers:writing-plans** — Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** — Complete development after all tasks
```

with:

```markdown
## Integration

**Required workflow skills:**
- **superpowers:writing-plans** — Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** — Complete development after all tasks
```

- [ ] **Step 3: Commit**

```bash
git add skills/executing-plans/SKILL.md
git commit -m "fix: make worktree setup explicit Step 0 in executing-plans

Worktree setup is now part of the main process flow instead of a
footnote reference. Checks if already in a worktree before creating one."
```

---

### Task 3: Fix default spec path in brainstorming

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

- [ ] **Step 1: Update checklist item 7**

In `skills/brainstorming/SKILL.md`, replace:

```markdown
7. **Write design doc** — save to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and commit
```

with:

```markdown
7. **Write design doc** — save to `docs/specs/YYYY-MM-DD-<topic>-design.md` and commit
```

- [ ] **Step 2: Update Documentation subsection**

In the same file, replace:

```markdown
- Write the validated design (spec) to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
```

with:

```markdown
- Write the validated design (spec) to `docs/specs/YYYY-MM-DD-<topic>-design.md`
```

- [ ] **Step 3: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "fix: change default spec path from docs/superpowers/specs to docs/specs

The superpowers/ segment is specific to this repo and doesn't make
sense when the plugin is installed in other projects."
```

---

### Task 4: Consolidate worktree cleanup in finishing-a-development-branch

**Files:**
- Modify: `skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Remove standalone Step 9**

In `skills/finishing-a-development-branch/SKILL.md`, replace the entire Step 9 section:

```markdown
### Step 9: Cleanup Worktree and Branch

**For Options 1 and 4 only:**

**Cleanup order (always, no exceptions):** `git -C <main-repo> worktree remove <path>` → `git -C <main-repo> branch -d/-D <branch>`. Never delete the branch before removing the worktree.

**Always use `git -C <dir>`** instead of `cd <dir> && git ...` to avoid permission prompts for compound shell commands.

```bash
# 1. Remove the worktree FIRST
git -C <main-repo> worktree remove <worktree-path>

# 2. THEN delete the branch (see Option 1/4 above for the rest)
```

**For Options 2 and 3:** Keep worktree.
```

with:

```markdown
### Step 9: Cleanup

**For Options 1 and 4 only:** Clean up worktree and branch per `superpowers:using-git-worktrees` (worktree remove first, then branch delete, always `git -C`).

**For Options 2 and 3:** Keep worktree.
```

- [ ] **Step 2: Commit**

```bash
git add skills/finishing-a-development-branch/SKILL.md
git commit -m "refactor: consolidate worktree cleanup to cross-reference using-git-worktrees

Remove standalone explanation that duplicated using-git-worktrees.
The inline git -C commands in Steps 7/8 remain as procedural steps."
```

---

### Task 5: Remove deprecated command aliases and update CLAUDE.md

**Files:**
- Delete: `commands/brainstorm.md`
- Delete: `commands/execute-plan.md`
- Delete: `commands/write-plan.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Delete all three command files**

```bash
git rm commands/brainstorm.md commands/execute-plan.md commands/write-plan.md
```

- [ ] **Step 2: Remove commands directory if empty**

```bash
rmdir commands/ 2>/dev/null || true
```

- [ ] **Step 3: Remove the commands line from CLAUDE.md**

In `CLAUDE.md`, delete the line:

```markdown
- `commands/` — Slash command definitions (brainstorm, execute-plan, write-plan)
```

(Delete the entire line, don't replace it.)

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove deprecated command aliases and commands/ directory

These redirect commands (brainstorm, execute-plan, write-plan) waste
context window tokens. The renamed skills have been in place long enough.
Remove commands/ entry from CLAUDE.md since the directory is now empty."
```

---

### Task 6: Tone down receiving-code-review

**Files:**
- Modify: `skills/receiving-code-review/SKILL.md`

- [ ] **Step 1: Replace the entire file content**

Replace the full content of `skills/receiving-code-review/SKILL.md` with:

```markdown
---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing suggestions, especially if feedback seems unclear or technically questionable - requires technical rigor and verification, not blind implementation
---

# Code Review Reception

## Overview

Code review requires technical evaluation, not performative agreement.

**Core principle:** Verify before implementing. Ask before assuming. Technical correctness over social comfort.

## The Response Pattern

```
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

## Tone

Be direct — acknowledge correct feedback briefly and move to action. Focus on technical substance over social niceties.

## Handling Unclear Feedback

```
IF any item is unclear:
  STOP - do not implement anything yet
  ASK for clarification on unclear items

WHY: Items may be related. Partial understanding = wrong implementation.
```

**Example:**
```
Reviewer: "Fix 1-6"
You understand 1,2,3,6. Unclear on 4,5.

WRONG: Implement 1,2,3,6 now, ask about 4,5 later
RIGHT: "I understand items 1,2,3,6. Need clarification on 4 and 5 before proceeding."
```

## Source-Specific Handling

### From the User
- **Trusted** — implement after understanding
- **Still ask** if scope unclear
- **Skip to action** or technical acknowledgment

### From External Reviewers
```
BEFORE implementing:
  1. Check: Technically correct for THIS codebase?
  2. Check: Breaks existing functionality?
  3. Check: Reason for current implementation?
  4. Check: Works on all platforms/versions?
  5. Check: Does reviewer understand full context?

IF suggestion seems wrong:
  Push back with technical reasoning

IF can't easily verify:
  Say so: "I can't verify this without [X]. Should I [investigate/ask/proceed]?"

IF conflicts with the user's prior decisions:
  Stop and discuss with the user first
```

## YAGNI Check for "Professional" Features

```
IF reviewer suggests "implementing properly":
  grep codebase for actual usage

  IF unused: "This endpoint isn't called. Remove it (YAGNI)?"
  IF used: Then implement properly
```

## Implementation Order

```
FOR multi-item feedback:
  1. Clarify anything unclear FIRST
  2. Then implement in this order:
     - Blocking issues (breaks, security)
     - Simple fixes (typos, imports)
     - Complex fixes (refactoring, logic)
  3. Test each fix individually
  4. Verify no regressions
```

## When To Push Back

Push back when:
- Suggestion breaks existing functionality
- Reviewer lacks full context
- Violates YAGNI (unused feature)
- Technically incorrect for this stack
- Legacy/compatibility reasons exist
- Conflicts with the user's architectural decisions

**How to push back:**
- Use technical reasoning, not defensiveness
- Ask specific questions
- Reference working tests/code
- Escalate to the user if architectural

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Performative agreement | State requirement or just act |
| Blind implementation | Verify against codebase first |
| Batch without testing | One at a time, test each |
| Assuming reviewer is right | Check if breaks things |
| Avoiding pushback | Technical correctness > comfort |
| Partial implementation | Clarify all items first |
| Can't verify, proceed anyway | State limitation, ask for direction |

## Real Examples

**Blind Agreement (Bad):**
```
Reviewer: "Remove legacy code"
BAD: "Let me remove that right away..."
```

**Technical Verification (Good):**
```
Reviewer: "Remove legacy code"
GOOD: "Checking... build target is 10.15+, this API needs 13+. Need legacy for backward compat. Current impl has wrong bundle ID - fix it or drop pre-13 support?"
```

**YAGNI (Good):**
```
Reviewer: "Implement proper metrics tracking with database, date filters, CSV export"
GOOD: "Grepped codebase - nothing calls this endpoint. Remove it (YAGNI)? Or is there usage I'm missing?"
```

**Unclear Item (Good):**
```
Reviewer: "Fix items 1-6"
You understand 1,2,3,6. Unclear on 4,5.
GOOD: "Understand 1,2,3,6. Need clarification on 4 and 5 before implementing."
```

## GitHub Thread Replies

When replying to inline review comments on GitHub, reply in the comment thread (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as a top-level PR comment.

## The Bottom Line

**External feedback = suggestions to evaluate, not orders to follow.**

Verify. Question. Then implement.

No performative agreement. Technical rigor always.
```

- [ ] **Step 2: Commit**

```bash
git add skills/receiving-code-review/SKILL.md
git commit -m "refactor: tone down receiving-code-review to general-purpose

Remove personality-specific content (forbidden phrases, signal phrases,
exhaustive allowed/forbidden lists, gratitude prohibition). Keep the
technical core: response pattern, verification, YAGNI, pushback guidance.
Replace 'your human partner' with 'the user' throughout."
```

---

### Task 7: Clean phrasing in systematic-debugging

**Files:**
- Modify: `skills/systematic-debugging/SKILL.md`

- [ ] **Step 1: Rename the signals section**

In `skills/systematic-debugging/SKILL.md`, replace:

```markdown
## your human partner's Signals You're Doing It Wrong

**Watch for these redirections:**
- "Is that not happening?" - You assumed without verifying
- "Will it show us...?" - You should have added evidence gathering
- "Stop guessing" - You're proposing fixes without understanding
- "Ultrathink this" - Question fundamentals, not just symptoms
- "We're stuck?" (frustrated) - Your approach isn't working

**When you see these:** STOP. Return to Phase 1.
```

with:

```markdown
## Signals You're On The Wrong Track

**Watch for these redirections:**
- "Is that not happening?" — You assumed without verifying
- "Will it show us...?" — You should have added evidence gathering
- "Stop guessing" — You're proposing fixes without understanding
- "Ultrathink this" — Question fundamentals, not just symptoms
- "We're stuck?" (frustrated) — Your approach isn't working

**When you see these:** STOP. Return to Phase 1.
```

- [ ] **Step 2: Update Phase 4 step 5 reference**

In the same file, replace:

```markdown
   **Discuss with your human partner before attempting more fixes**
```

with:

```markdown
   **Discuss with the user before attempting more fixes**
```

- [ ] **Step 3: Commit**

```bash
git add skills/systematic-debugging/SKILL.md
git commit -m "refactor: clean 'your human partner' phrasing in systematic-debugging

Rename section to 'Signals You're On The Wrong Track' and replace
personal framing with neutral language."
```

---

### Task 8: Clean phrasing in verification-before-completion

**Files:**
- Modify: `skills/verification-before-completion/SKILL.md`

- [ ] **Step 1: Replace the Why This Matters section**

In `skills/verification-before-completion/SKILL.md`, replace:

```markdown
## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."
```

with:

```markdown
## Why This Matters

Verification failures have real consequences:
- Undefined functions shipped — would crash at runtime
- Missing requirements shipped — incomplete features
- Time wasted on false completion, redirect, rework
- Trust broken when claims don't match reality

Verification is about integrity. Claims without evidence are not efficiency — they are dishonesty.
```

- [ ] **Step 2: Commit**

```bash
git add skills/verification-before-completion/SKILL.md
git commit -m "refactor: clean personal anecdotes from verification-before-completion

Replace personal threat framing with general principle: verification
is about integrity, claims without evidence are dishonesty."
```

---

### Task 9: Clean remaining "your human partner" in executing-plans

**Files:**
- Modify: `skills/executing-plans/SKILL.md`

Note: Task 2 already replaced one instance in Step 1. Verify no others remain after Task 2's changes, and if any do, fix them here.

- [ ] **Step 1: Check for remaining instances**

```bash
grep -n "your human partner" skills/executing-plans/SKILL.md
```

If the grep returns no results, skip to Step 3 (commit is not needed). If it finds matches, proceed to Step 2.

- [ ] **Step 2: Replace any remaining instances**

Replace any remaining `your human partner` with `the user` in `skills/executing-plans/SKILL.md`.

- [ ] **Step 3: Commit (only if changes were made)**

```bash
git add skills/executing-plans/SKILL.md
git commit -m "refactor: replace 'your human partner' with 'the user' in executing-plans"
```
