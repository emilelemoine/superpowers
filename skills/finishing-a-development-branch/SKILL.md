---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to integrate the work - defaults to local merge unless the project CLAUDE.md specifies otherwise
---

# Finishing a Development Branch

## Overview

Guide completion of development work. **Default action is local merge** — no menu, no questions asked.

**Core principle:** Verify tests → Code review → Merge locally → Clean up.

**Override:** If the project-level CLAUDE.md contains explicit instructions about how to finish branches (e.g. "create a PR", "push for review"), follow those instead of the default merge. Only then present options or follow the project's specified workflow.

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

**If tests pass:** check the tree is clean before continuing:

```bash
git status --porcelain
```

Uncommitted work at merge time is worth catching regardless, and it also disables the reviewer's mutation check — that check refuses to touch a tree it can't safely revert. Commit or stash first, then continue to Step 2.

### Step 2: Determine Base Branch

```bash
# List which common base branches exist locally
git branch --list main master
```

Use whichever exists as `<base-branch>` below. If both or neither, ask: "This branch split from main — is that correct?"

### Step 3: Collect Branch Diff

**Avoid command substitution and shell variables here.** A `BASE_SHA=$(git merge-base ...)` capture plus `$BASE_SHA..HEAD` cannot be matched against the permission allowlist — the `$(...)` and `$VAR` are opaque to it, so every such command prompts for approval. Git's three-dot range computes the merge-base internally, so plain literal commands do the same job and stay auto-approvable.

Run each as a **separate** command — no `&&` chaining:

```bash
# What changed (summary) — three-dot = changes since the merge-base with base
git diff --stat <base-branch>...HEAD

# Full diff
git diff <base-branch>...HEAD

# Commits added on this branch — two-dot = commits on HEAD but not base
git log --oneline <base-branch>..HEAD
```

### Step 4: Dispatch Branch Reviewer

Spawn a `superpowers:branch-reviewer` subagent. It gets the diff and reviews with fresh context — no anchoring to the implementation decisions made during development.

**Dispatch the reviewer exactly once per branch.** Do not re-dispatch it after applying fixes. Re-running the test suite (Step 6) is the verification, and a second reviewer pass on a branch it has already seen reliably invents new categories of finding rather than confirming the old ones. Concerns that come up after the fixes are ordinary work — handle them or don't, but they are not another review round.

```
Agent:
  subagent_type: superpowers:branch-reviewer
  prompt: |
    Review this feature branch for merge readiness.

    Branch: <branch-name>
    Base: <base-branch>
    Commits: <N> commits

    Worktree path: <worktree-path>

    Run these commands to get the changes. Use git -C (never cd), and use
    the literal three-dot range (never capture a SHA into a variable —
    command substitution triggers approval prompts):
      git -C <worktree-path> diff --stat <base-branch>...HEAD
      git -C <worktree-path> diff <base-branch>...HEAD

    Report everything that passes your cost test, ranked most severe
    first, with no numeric cap — I do the filtering on this end.
    Returning none is a normal and successful outcome.

    The tree is clean and the full suite passes as of right now, so the
    mutation check is safe to run if this branch qualifies for it. Most
    branches don't; say which way you decided in one line either way.
```

**When it applies, the mutation check is where this review earns its cost.** A suite that passes with a whole function deleted is the failure mode that survives any amount of reading. But it applies to a minority of branches — code whose wrong answer gets *believed* rather than noticed. Code that crashes when it's wrong is already served by running the tests.

### Step 5: Filter, Then Present Findings Interactively

The reviewer no longer caps itself, so filter before you present. Apply the cost test to each non-critical finding — how would it surface if it shipped, and what would fixing it cost then? Present every critical finding and at most **3** non-critical ones; drop the rest silently rather than listing them as deferred.

Be aware of the tradeoff this creates: filtering happens in the session that wrote the code, which is the anchored party. When a finding is borderline, that bias runs toward dismissing it. The reason it's still the right place is that dropping a finding is cheaper to get wrong than never detecting one.

Present what survives in severity order (critical first):

```
## Code Review — <branch-name>

Verdict: <GOOD TO GO / FIX BEFORE MERGE / NEEDS REWORK>

<Summary paragraph>

<N> findings: <X> critical, <Y> important

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

If the verdict is **GOOD TO GO** with no findings, keep it to two lines:

```
## Code Review — <branch-name>

Verdict: GOOD TO GO — <one-line summary>. Nothing worth fixing before merge.
```

A review that finds nothing is the expected outcome for carefully written work, not a signal that something was missed. Don't pad it out.

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

### Step 7: Merge Locally (Default)

**Unless the project CLAUDE.md specifies a different workflow**, proceed directly with a local merge. Do not present a menu — just merge.

Cleanup worktree first (Step 9), then merge and delete branch:

```bash
# 1. Move CWD out of worktree (separate Bash call — never chain cd && git)
cd <main-repo>
```
```bash
# 2. Remove worktree (Step 9) — CWD is now safely outside
git worktree remove <worktree-path>
```
```bash
# 3. Switch to base branch and pull latest
git checkout <base-branch> && git pull

# 4. Merge feature branch
git merge <feature-branch>

# 5. Verify tests on merged result
<test command>

# 6. If tests pass, delete feature branch
git branch -d <feature-branch>
```

### Step 7-alt: Present Options (only when project CLAUDE.md overrides default)

If the project CLAUDE.md specifies a non-merge workflow, or if you cannot determine the right action from it, present these options:

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 8: Execute Choice (only for Step 7-alt)

#### Option 1: Merge Locally

Same as Step 7 above.

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

Report: "PR created. Worktree preserved at <path> for any follow-up changes."

**Don't cleanup worktree** — the PR may need revisions.

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

If confirmed, cleanup worktree first (Step 9), then delete branch:

```bash
# 1. Move CWD out of worktree (separate Bash call — never chain cd && git)
cd <main-repo>
```
```bash
# 2. Remove worktree (Step 9) — CWD is now safely outside
git worktree remove <worktree-path>
```
```bash
# 3. Delete feature branch
git checkout <base-branch>
git branch -D <feature-branch>
```

### Step 9: Cleanup

**For Options 1 and 4 only:** Clean up worktree and branch (worktree remove first, then branch delete).

**Critical:** Before removing a worktree, CWD must be outside it — otherwise deleting the directory crashes the session. Use a **separate Bash call** to `cd <main-repo>` first — never chain `cd && git` (chained commands trigger permission prompts in worktrees).

**For Options 2 and 3:** Keep worktree.

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

**Presenting options when not needed**
- **Problem:** Asking the user what to do when the default is clear
- **Fix:** Merge locally by default; only present options when project CLAUDE.md overrides

**Skipping code review**
- **Problem:** Merge without a fresh set of eyes on the diff
- **Fix:** Always dispatch branch-reviewer before presenting options

**Reviewing until it runs dry**
- **Problem:** Re-dispatching the reviewer after each round of fixes. Later rounds mostly surface problems the earlier rounds introduced, and each one adds tests and churn out of proportion to what it catches
- **Fix:** One dispatch per branch. The test suite verifies the fixes

**Removing worktree while CWD is inside it**
- **Problem:** `git worktree remove` deletes the directory; if the shell's CWD is inside it, the session crashes
- **Fix:** Use a separate Bash call to `cd <main-repo>` before the remove call — never chain `cd && git` (triggers permission prompts)

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
- Re-dispatch the branch-reviewer on a branch it has already reviewed
- Auto-apply review fixes without user approval
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request

**Always:**
- Verify tests before offering options
- Dispatch branch-reviewer before merging
- Merge locally by default; only present options when project CLAUDE.md overrides
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only

## Integration

**Called by:**
- **executing-plans** — After all tasks complete

**Pairs with:**
- **using-git-worktrees** — Cleans up worktree created by that skill
