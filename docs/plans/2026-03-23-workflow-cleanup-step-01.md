# Workflow Cleanup — Step 1: Review Consolidation and Plan Deduplication

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Goal:** Consolidate review layers (delete code-reviewer, make refactor review optional) and deduplicate writing-plans vs code-planner.

**Context:** This is step 1 of the workflow cleanup. It covers design doc changes 1-2 (review layer consolidation and plan deduplication). Step 2 covers changes 3-9.

**Branch:** `cleanup/review-consolidation`

**Design doc:** `docs/specs/2026-03-23-workflow-cleanup-design.md`

**Format/lint:** N/A (markdown files only)

**After all tasks:** Use superpowers:finishing-a-development-branch to merge.

---

### Task 1: Delete code-reviewer agent and template

**Files:**
- Delete: `agents/code-reviewer.md`
- Delete: `skills/requesting-code-review/code-reviewer.md`

- [ ] **Step 1: Delete the agent file**

```bash
git rm agents/code-reviewer.md
```

- [ ] **Step 2: Delete the template file**

```bash
git rm skills/requesting-code-review/code-reviewer.md
```

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "chore: delete redundant code-reviewer agent and template

branch-reviewer covers the same concerns with a sharper prompt.
requesting-code-review will be updated to use branch-reviewer next."
```

---

### Task 2: Rewrite requesting-code-review to use branch-reviewer

**Files:**
- Modify: `skills/requesting-code-review/SKILL.md`

- [ ] **Step 1: Replace the entire file content**

Replace the full content of `skills/requesting-code-review/SKILL.md` with:

```markdown
---
name: requesting-code-review
description: Use when completing ad-hoc work outside a structured plan, or when stuck and wanting a fresh perspective
---

# Requesting Code Review

Dispatch a superpowers:branch-reviewer subagent to catch issues before they cascade. The reviewer gets the branch diff for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

## When to Use

Use this for **ad-hoc work** — tasks done outside a structured plan. For plan-driven work, `superpowers:finishing-a-development-branch` already handles the pre-merge review.

**Good times to request review:**
- After completing a feature or significant change
- When stuck (fresh perspective helps)
- Before refactoring (baseline check)
- After fixing a complex bug

## How to Request

**1. Determine the base:**

```bash
BASE_SHA=$(git merge-base HEAD main)
```

**2. Dispatch branch-reviewer subagent:**

```
Agent:
  subagent_type: superpowers:branch-reviewer
  description: "Review ad-hoc work on <branch-name>"
  prompt: |
    Review this feature branch for merge readiness.

    Branch: <branch-name>
    Base: main (SHA: <BASE_SHA>)

    Run these commands to get the changes:
      git diff --stat <BASE_SHA>..HEAD
      git diff <BASE_SHA>..HEAD

    Review for bugs, design issues, refactoring opportunities, efficiency
    improvements, and code quality. Read surrounding code (callers,
    interfaces, related modules) whenever the diff alone isn't enough
    context to judge.
```

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed a verification feature on branch fix/verify-index]

You: Let me request code review before merging.

BASE_SHA=$(git merge-base HEAD main)

[Dispatch superpowers:branch-reviewer subagent]
  Branch: fix/verify-index
  Base: main (SHA: a7981ec)
  Prompt: Review this feature branch...
    git diff --stat a7981ec..HEAD
    git diff a7981ec..HEAD

[Subagent returns]:
  Summary: Adds verifyIndex() and repairIndex() with 4 issue types.
  Findings:
    [QUALITY-1] Missing progress indicators (important)
    [QUALITY-2] Magic number for reporting interval (minor)
  Verdict: FIX BEFORE MERGE

You: [Fix progress indicators, commit]
[Proceed to merge via finishing-a-development-branch]
```

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer is wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

## Integration

**For ad-hoc work:** Use this skill, then `superpowers:finishing-a-development-branch` to merge.

**For plan-driven work:** `superpowers:executing-plans` handles per-task refactor review; `superpowers:finishing-a-development-branch` handles the pre-merge branch review. You typically don't need this skill.
```

- [ ] **Step 2: Commit**

```bash
git add skills/requesting-code-review/SKILL.md
git commit -m "refactor: rewrite requesting-code-review to use branch-reviewer

- Scope to ad-hoc work (plan-driven work uses finishing-a-development-branch)
- Replace code-reviewer dispatch with branch-reviewer dispatch
- Simplify example to match branch-reviewer's interface
- Remove template placeholder approach in favor of direct prompt"
```

---

### Task 3: Make refactor review optional in executing-plans

**Files:**
- Modify: `skills/executing-plans/SKILL.md`

- [ ] **Step 1: Replace the Refactor section**

In `skills/executing-plans/SKILL.md`, replace:

```markdown
#### Refactor

1. Get the diff for this task: `git diff HEAD`
2. Dispatch a refactor reviewer subagent (general-purpose Agent tool, model: opus — see `./refactor-reviewer-prompt.md` for the prompt template) scoped to this task's diff
3. If the reviewer returns suggestions:
   - Apply accepted suggestions
   - Run the formatter on changed files
   - Re-run tests to confirm they still pass
4. If the reviewer returns "clean": proceed
```

with:

```markdown
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
```

- [ ] **Step 2: Update the overview line**

In the same file, replace:

```markdown
Load plan, review critically, execute all tasks using a TDD loop with refactor review, commit after each task.
```

with:

```markdown
Load plan, review critically, execute all tasks using a TDD loop, commit after each task.
```

- [ ] **Step 3: Update the description in frontmatter**

Replace:

```markdown
description: Use when you have a written implementation plan to execute — follows TDD loop with refactor review after each task
```

with:

```markdown
description: Use when you have a written implementation plan to execute — follows TDD loop for each task
```

- [ ] **Step 4: Update the Remember section**

Replace:

```markdown
- Red-Green-Refactor for every task
```

with:

```markdown
- Red-Green for every task, Refactor when warranted
```

- [ ] **Step 5: Update the Step 2 intro**

Replace:

```markdown
For each task, follow this loop. If a task has no testable code (e.g., documentation, configuration, markdown), skip the Red and Green phases — apply the changes, dispatch the refactor reviewer on the diff, then commit.
```

with:

```markdown
For each task, follow this loop. If a task has no testable code (e.g., documentation, configuration, markdown), skip the Red and Green phases — apply the changes, then commit. Optionally dispatch the refactor reviewer if the changes were complex.
```

- [ ] **Step 6: Update the Subagent Usage section**

Replace:

```markdown
- **Refactor review** — after each task's green phase, scoped to that task's diff (see `./refactor-reviewer-prompt.md`)
```

with:

```markdown
- **Refactor review** — optionally after a task's green phase, scoped to that task's diff (see `./refactor-reviewer-prompt.md`)
```

- [ ] **Step 7: Commit**

```bash
git add skills/executing-plans/SKILL.md
git commit -m "refactor: make per-task refactor review optional in executing-plans

Per-task refactor review adds latency without proportional value for
plan-driven tasks with complete code. The branch-reviewer at merge
time catches the same issues with better whole-branch context."
```

---

### Task 4: Strip writing-plans to pure format spec

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

- [ ] **Step 1: Replace the entire file content**

Replace the full content of `skills/writing-plans/SKILL.md` with:

```markdown
---
name: writing-plans
description: Format reference for implementation plans — use superpowers:code-planner to write plans from design docs
---

# Writing Plans — Format Reference

## Overview

Implementation plans document everything an engineer needs to execute a feature: which files to touch, complete code for each task, exact test commands, and bite-sized steps. DRY. YAGNI. TDD. Frequent commits.

Assume the implementer is a skilled developer who knows almost nothing about the codebase or problem domain, and who doesn't know good test design very well.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Structure: DAG Roadmap + Self-Contained Step Files

### When to split

- **4 or fewer commits:** Write a single plan file
- **More than 4 commits:** Split into a DAG roadmap + self-contained step files

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

Do NOT also create the combined single file — the roadmap + step files are the plan.

### Step files

Each step file is a fully self-contained mini-plan. A fresh Claude session can execute it without any other context. Each includes:

- **Header:** Goal, context (how this fits the overall feature), branch name, execution instruction (`superpowers:executing-plans`), merge instruction (`superpowers:finishing-a-development-branch`)
- **Task list:** Exact file paths, complete code to write, exact commands to run with expected output. Same bite-sized granularity as above.
- **Format/lint command:** The project-specific formatter to run after each edit (e.g., `ruff format <file> && ruff check --fix <file>`)

### Single-file plan format

For plans with 4 or fewer commits, use a single file with this header:

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

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits
```

- [ ] **Step 2: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "refactor: strip writing-plans to pure format spec

Remove duplicated process content (scope check, file structure,
plan review loop, execution handoff) that belongs in code-planner.
Keep format templates, task structure, granularity guidance, and
the remember checklist."
```

---

### Task 5: Remove inline plan-reviewer prompt from code-planner

**Files:**
- Modify: `agents/code-planner.md`

- [ ] **Step 1: Replace Phase 6 content**

In `agents/code-planner.md`, replace the entire Phase 6 section:

```markdown
### Phase 6 — Plan Review Loop

After completing each chunk of the plan, dispatch a plan-document-reviewer subagent:

```
Agent (general-purpose):
  description: "Review plan chunk N"
  prompt: |
    You are a plan document reviewer. Verify this plan chunk is complete and ready for implementation.

    **Plan chunk to review:** [PLAN_FILE_PATH] - Chunk N only
    **Spec for reference:** [SPEC_FILE_PATH]

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Completeness | TODOs, placeholders, incomplete tasks, missing steps |
    | Spec Alignment | Chunk covers relevant spec requirements, no scope creep |
    | Task Decomposition | Tasks atomic, clear boundaries, steps actionable |
    | File Structure | Files have clear single responsibilities |
    | File Size | Would any file grow large enough to be hard to reason about? |
    | Task Syntax | Checkbox syntax on steps for tracking |
    | Code | Complete code shown (no "add validation"-style placeholders) |

    ## Output Format

    ## Plan Review - Chunk N

    **Status:** Approved | Issues Found

    **Issues (if any):**
    - [Task X, Step Y]: [specific issue] - [why it matters]

    **Recommendations (advisory):**
    - [suggestions that don't block approval]
```

- If Issues Found: fix, re-dispatch, repeat until Approved
- If loop exceeds 5 iterations, surface to human for guidance
```

with:

```markdown
### Phase 6 — Plan Review Loop

After completing each chunk of the plan, dispatch a plan-document-reviewer subagent using the prompt template at `skills/writing-plans/plan-document-reviewer-prompt.md`.

- Provide: the plan chunk file path and the spec file path
- If Issues Found: fix, re-dispatch, repeat until Approved
- If loop exceeds 5 iterations, surface to human for guidance
```

- [ ] **Step 2: Update Phase 7 to mention worktree setup**

In the same file, replace:

```markdown
### Phase 7 — Execution Handoff

After writing the plan, tell the user the plan is ready and point them at the roadmap file (or single plan file):

> **Plan complete.** Saved to `docs/plans/<filename>.md`. Execute with `superpowers:executing-plans`.
```

with:

```markdown
### Phase 7 — Execution Handoff

After writing the plan, tell the user the plan is ready and point them at the roadmap file (or single plan file):

> **Plan complete.** Saved to `docs/plans/<filename>.md`. Execute with `superpowers:executing-plans` (which starts with worktree setup).
```

- [ ] **Step 3: Commit**

```bash
git add agents/code-planner.md
git commit -m "refactor: remove inline plan-reviewer prompt from code-planner

Reference the canonical template at skills/writing-plans/plan-document-reviewer-prompt.md
instead of duplicating the full prompt. Also mention worktree setup in execution handoff."
```

---

### Task 6: Update CLAUDE.md references

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update agents list**

In `CLAUDE.md`, replace:

```markdown
- `agents/` — Subagent definitions (.md files) used by skills to dispatch specialized workers (code-reviewer, code-planner, branch-reviewer, worktree-setup, org-roam)
```

with:

```markdown
- `agents/` — Subagent definitions (.md files) used by skills to dispatch specialized workers (code-planner, branch-reviewer, worktree-setup, org-roam)
```

- [ ] **Step 2: Update naming convention example**

Replace:

```markdown
Skills and agents from this plugin are namespaced with the `superpowers:` prefix. When writing instructions, agent definitions, or skill references, always use the fully qualified name (e.g. `superpowers:brainstorming`, `superpowers:code-reviewer`, `superpowers:worktree-setup`).
```

with:

```markdown
Skills and agents from this plugin are namespaced with the `superpowers:` prefix. When writing instructions, agent definitions, or skill references, always use the fully qualified name (e.g. `superpowers:brainstorming`, `superpowers:branch-reviewer`, `superpowers:worktree-setup`).
```

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "chore: update CLAUDE.md to reflect code-reviewer deletion and command cleanup"
```
