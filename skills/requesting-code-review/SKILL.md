---
name: requesting-code-review
description: Use when completing ad-hoc work outside a structured plan, or when stuck and wanting a fresh perspective
---

# Requesting Code Review

Dispatch a superpowers:branch-reviewer subagent to catch issues before they cascade. The reviewer gets the branch diff for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** One review per branch, at the point where fresh eyes are worth the most.

## When to Use

Use this for **ad-hoc work** — tasks done outside a structured plan. For plan-driven work, `superpowers:finishing-a-development-branch` already handles the pre-merge review.

**Good times to request review:**
- After completing a feature or significant change
- When stuck (fresh perspective helps)
- Before refactoring (baseline check)
- After fixing a complex bug

**Dispatch the reviewer once per branch.** Don't re-dispatch after acting on the feedback — the reviewer will find new things to say about code it has already passed, and those later rounds cost more than they catch. Re-running the tests is how you verify the fixes.

## How to Request

**1. Determine the base branch** (e.g. `main` or `master`) — just the name, no need to capture a SHA. Avoid `BASE_SHA=$(git merge-base ...)`: command substitution and shell variables can't be matched against the permission allowlist, so they prompt for approval. The three-dot range below computes the merge-base internally.

**2. Dispatch branch-reviewer subagent:**

```
Agent:
  subagent_type: superpowers:branch-reviewer
  description: "Review ad-hoc work on <branch-name>"
  prompt: |
    Review this feature branch for merge readiness.

    Branch: <branch-name>
    Base: <base-branch>
    Commits: <N> commits

    Run these commands to get the changes (literal three-dot range,
    never a captured SHA):
      git diff --stat <base-branch>...HEAD
      git diff <base-branch>...HEAD

    Report everything that passes your cost test, ranked most severe
    first, with no numeric cap — I do the filtering on this end.
    Returning none is a normal and successful outcome.
```

**3. Filter before acting.** The reviewer no longer caps itself, so apply the cost test to what came back: for each non-critical finding, ask how it would surface if it shipped and what fixing it would cost then. Act on the critical ones and on at most **3** non-critical ones; drop the rest without mentioning them.

Filtering here rather than in the reviewer means detection is uncapped while what you act on stays bounded. Be aware of the tradeoff: you wrote this code, so you are the anchored party — when a finding is borderline, that bias runs toward dismissing it.

**4. Act on feedback:**
- Fix Critical issues before merging — those are the ones that block
- Decide case by case on Important issues. They're worth your attention, not your obedience; skipping one is a legitimate call
- Push back if the reviewer is wrong (with reasoning)

## Example

```
[Just completed a verification feature on branch fix/verify-index]

You: Let me request code review before merging.

[Dispatch superpowers:branch-reviewer subagent]
  Branch: fix/verify-index
  Base: main
  Prompt: Review this feature branch...
    git diff --stat main...HEAD
    git diff main...HEAD

[Subagent returns]:
  Summary: Adds verifyIndex() and repairIndex() with 4 issue types.
  Findings:
    [BUG-1] repairIndex() writes the new index before fsyncing the
            journal, so a crash mid-repair leaves an index that points
            at entries the journal never recorded (critical)
  Verdict: FIX BEFORE MERGE

You: [Reorder the fsync, commit, re-run tests]
[Proceed to merge via finishing-a-development-branch — no second review]
```

Note what isn't in that report: no naming nits, no magic numbers, no "consider adding progress indicators." One real bug and nothing else is a good review, not a thin one.

## Red Flags

**Never:**
- Ignore Critical issues
- Argue with valid technical feedback
- Re-dispatch the reviewer on a branch it has already reviewed

**If reviewer is wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

## Integration

**For ad-hoc work:** Use this skill, then `superpowers:finishing-a-development-branch` to merge.

**For plan-driven work:** `superpowers:finishing-a-development-branch` handles the pre-merge branch review. You typically don't need this skill.
