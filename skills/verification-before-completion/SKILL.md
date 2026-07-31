---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs, or when about to break working code on purpose to check whether the tests catch it - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- About to `git checkout --` or `git restore` a file that still has uncommitted work in it
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ compiler |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "I'll put it back right after" | Revert discards to HEAD. Uncommitted means there is no "back" |
| "The mutation was caught, tests are fine" | Only if the mutation ran. Control run, or it proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Commit → Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
❌ Reverting anything while the fix is still uncommitted (see below)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Breaking Code On Purpose

Reverting a fix to watch a regression test fail, deleting a call to see whether any test notices, flipping a boundary to probe the suite — these all end in "put it back," and that step is where the evidence gets destroyed instead of collected.

**`git checkout -- <file>` is not an undo.** It makes the file match HEAD, discarding every uncommitted change in it — including the work you are verifying — along with the mutation. Silently. Every run after that tests code nobody wrote, and the numbers still look plausible.

```
COMMIT BEFORE YOU BREAK ANYTHING
```

- **Clean tree first.** `git status --porcelain` must be empty before the first break and after the last. Not empty? Commit. A WIP commit on a feature branch costs nothing and can be amended or squashed later.
- **Backing the file up instead is not a substitute.** It leaves the only copy of your work outside version control, one bad path away from gone. Commit, then break.
- **Don't edit anything else mid-loop.** A fix applied between two breaks dies at the next restore. Note it, finish the loop, then fix — or commit it before continuing.
- **Control run after every restore.** Re-run the suite un-mutated and confirm it returns to the baseline counts you recorded before the first break. This is the one check that catches both ways the loop lies to you: a restore that took your work with it, and a run that never executed the mutated code at all.

That second one is easy to miss: a "caught" verdict is evidence only if the mutated code actually ran, and stale build or bytecode caches routinely fake one. (Python: a same-size edit in the same timestamp-second reuses `__pycache__`; `-B` doesn't help — it stops the cache being written, not read.)

## Why This Matters

Verification failures have real consequences:
- Undefined functions shipped — would crash at runtime
- Missing requirements shipped — incomplete features
- Time wasted on false completion, redirect, rework
- Trust broken when claims don't match reality

Verification is about integrity. Claims without evidence are not efficiency — they are dishonesty.

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
