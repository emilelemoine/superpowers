---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Code review → Present options → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 3: Collect Branch Diff

```bash
BASE_SHA=$(git merge-base HEAD <base-branch>)

# What changed (summary)
git diff --stat $BASE_SHA..HEAD

# Full diff
git diff $BASE_SHA..HEAD

# Commit history on this branch
git log --oneline $BASE_SHA..HEAD
```

### Step 4: Dispatch Branch Reviewer

Spawn a `branch-reviewer` subagent. It gets the diff and reviews with fresh context — no anchoring to the implementation decisions made during development.

```
Agent:
  subagent_type: branch-reviewer
  prompt: |
    Review this feature branch for merge readiness.

    Branch: <branch-name>
    Base: <base-branch> (SHA: <BASE_SHA>)
    Commits: <N> commits

    Run these commands to get the changes:
      git diff --stat <BASE_SHA>..HEAD
      git diff <BASE_SHA>..HEAD

    Review for bugs, design issues, refactoring opportunities, efficiency
    improvements, and code quality. Read surrounding code (callers,
    interfaces, related modules) whenever the diff alone isn't enough
    context to judge.
```

### Step 5: Present Findings Interactively

When the agent returns, present its findings to the user in severity order (critical first):

```
## Code Review — <branch-name>

Verdict: <GOOD TO GO / FIX BEFORE MERGE / NEEDS REWORK>

<Summary paragraph>

<N> findings: <X> critical, <Y> important, <Z> minor

---

**[BUG-1] Title** (critical)
File: path/to/file:lines
What: ...
Why: ...
Fix: ...

→ Apply? [yes / skip / discuss]

**[DESIGN-1] Title** (important)
...
```

If the verdict is **GOOD TO GO** with no critical/important findings, keep it brief:

```
## Code Review — <branch-name>

Verdict: GOOD TO GO

<Summary>. No critical or important issues found.

<list any minor findings briefly>

Ready to proceed to merge options.
```

Never auto-apply fixes — the user drives all decisions.

### Step 6: Apply Approved Fixes

For each finding the user approved:
1. Make the change
2. If multiple fixes touch the same file, apply them together

Commit the fixes:
```bash
git add <changed-files>
git commit -m "Refactor: apply code review improvements

- <one line per fix applied>"
```

Skip this step if nothing was approved.

Re-run the test suite if any fixes were applied:
```bash
npm test / cargo test / pytest / go test ./...
```

If tests fail, fix before continuing. Don't proceed with broken tests.

### Step 7: Present Options

Present exactly these 4 options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 8: Execute Choice

#### Option 1: Merge Locally

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass
git branch -d <feature-branch>
```

Then: Cleanup worktree (Step 9)

#### Option 2: Push and Create PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

Then: Cleanup worktree (Step 9)

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

Then: Cleanup worktree (Step 9)

### Step 9: Cleanup Worktree

**For Options 1, 2, 4:**

Check if in worktree:
```bash
git worktree list | grep $(git branch --show-current)
```

If yes:
```bash
git worktree remove <worktree-path>
```

**For Option 3:** Keep worktree.

## Quick Reference

| Option | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------|------|---------------|----------------|
| 1. Merge locally | ✓ | - | - | ✓ |
| 2. Create PR | - | ✓ | ✓ | - |
| 3. Keep as-is | - | - | ✓ | - |
| 4. Discard | - | - | - | ✓ (force) |

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" → ambiguous
- **Fix:** Present exactly 4 structured options

**Skipping code review**
- **Problem:** Merge without a fresh set of eyes on the diff
- **Fix:** Always dispatch branch-reviewer before presenting options

**Automatic worktree cleanup**
- **Problem:** Remove worktree when might need it (Option 2, 3)
- **Fix:** Only cleanup for Options 1 and 4

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Proceed with failing tests
- Skip the code review step
- Auto-apply review fixes without user approval
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Dispatch branch-reviewer before presenting options
- Present exactly 4 options
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

## Integration

**Called by:**
- **subagent-driven-development** (Step 7) - After all tasks complete
- **executing-plans** (Step 5) - After all batches complete

**Pairs with:**
- **using-git-worktrees** - Cleans up worktree created by that skill
