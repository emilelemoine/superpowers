# Right-Sizing the Branch Review

**Date:** 2026-07-31
**Status:** Approved

## Problem

Branch reviews run for several rounds, produce dozens of low-value tests, and the
code still fails afterward on an unforeseen bug that takes two seconds to fix.

This is the same structural failure already fixed for the planning phase on
`fix/right-size-planning-phase` — reviewer prompts that can only ever push toward
*more*. It reappeared one phase later. Three files cause it:

**`agents/branch-reviewer.md`**
- The `important` bar is "Real improvement to maintainability, performance, or
  correctness. Worth fixing now while the code is fresh." Almost anything clears it.
- Six categories, all of which produce additions. No finding budget. The only
  counterweight is one bullet buried in Principles.
- Category 6, `Test strength`, lets the reviewer read a test file, judge it thin,
  and request assertions — with no evidence the code is actually unprotected. This
  path is unbounded and is the most plausible source of the low-value tests.
- Surviving mutations carry an `important` floor and force `FIX BEFORE MERGE`
  regardless of stakes.

**`skills/finishing-a-development-branch/SKILL.md`**
- No round cap. Compare `brainstorming`, which caps its spec review at 2 rounds
  with round 2 being verification-only. Nothing here stops the loop.

**`skills/requesting-code-review/SKILL.md`**
- "Review early, review often."
- Red Flags include "Proceed with unfixed Important issues" and "Skip review
  because it's simple", which remove the developer's judgment.
- The worked example shows a missing progress indicator earning `FIX BEFORE MERGE`
  and a magic number as a finding — it teaches severity inflation.

## Design

### Cost test

Applied to every non-critical finding, stated once at the top of the agent:

> If this ships wrong, how does it surface, and what does it cost to fix then?

"Loudly, on first run, in two minutes" means it is not a finding. Review effort is
only worth spending on failures that are **quiet** (wrong answers that get believed)
or **expensive later** (design that becomes load-bearing before anyone notices).

### Evidence rule for tests

**A test finding requires a surviving mutation.** Category 6 `Test strength` is
deleted; no reading-based path to a test finding remains. Since the mutation check
is capped at 3 mutations and gated on load-bearing code, this puts a hard ceiling
of ~2 new tests per review.

### Budget

- Every `critical` finding is reported, uncapped.
- At most **3** non-critical findings total, across all categories.
- Zero findings is a successful review, stated explicitly.
- Prefer findings that remove code to findings that add it.

### Categories and severity

Categories 6 → 5: `BUG`, `MUTATION`, `DESIGN`, `REFACTOR`, `EFFICIENCY`. `QUALITY`
is deleted — magic numbers and naming are exactly what the cost test kills, and
keeping a slot for them invites filling it.

`minor` is deleted. Anything reported becomes a yes/skip/discuss decision, so a
finding not worth a decision is not worth reporting. `important` is redefined to
"will cause a real failure or recurring pain that won't announce itself."

### Mutation check

All safety machinery is unchanged — clean-tree precondition, bytecode clearing,
immediate revert, final clean check. Only the output is capped: 5 → 3 mutations,
survivors reported only when the mutated code is load-bearing, survivors count
against the 3-finding budget, and a survivor alone no longer forces
`FIX BEFORE MERGE`.

### Verdict

`GOOD TO GO` is the default, used whenever there is no critical finding and no
load-bearing survivor. `FIX BEFORE MERGE` requires one of those two.
`NEEDS REWORK` is reserved for a wrong approach, not a patchable one.

### Loop

`finishing-a-development-branch` dispatches the reviewer **exactly once per
branch**. Re-running the test suite after fixes is the verification. Concerns
arising after fixes are ordinary work, not a review round.

## Known risks

- Deleting `minor` may push the reviewer to inflate nits into `important` to report
  them. The 3-finding budget and cost test are the only counterweights.
- The evidence rule means a branch with genuinely no tests gets no test finding
  unless a mutation survives.

## Verification

No automated test covers this — `tests/claude-code/` has no branch-reviewer test.
Verification is running a review on a real branch and observing whether finding
volume drops without real bugs being missed.

## Parallelization

All work is sequential — no parallelization opportunities.
