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
