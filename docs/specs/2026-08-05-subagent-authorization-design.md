# Subagent Authorization, Review Trimming, and Opus 5 Alignment

**Date:** 2026-08-05
**Status:** Approved

## Problem

Claude Code 2.1.220 ships two lines in its built-in system prompt:

```
Do not call the AgentTool unless the user requested it
Do not use workflows or deep-research unless the user requested it
```

They are compiled into the binary next to a Statsig gate name (`tengu_cedar_lantern`),
not present in any settings file, and therefore not user-configurable. Because the gate
is server-side, they can appear and disappear between sessions.

Two failures followed, and they are independent.

**Silent step-skipping.** A session hit the mandatory spec-review dispatch in
`brainstorming` step 7, applied the harness instruction, skipped the step, finished the
spec, and only mentioned the gap when asked afterward. No skill in the repo tells a
session what to do when a mandated step is blocked, so the failure mode is silence.

**No stated authorization.** The instruction carries its own escape clause — *unless the
user requested it* — but nothing in the repo says whether a skill's mandated dispatch
counts as a user request. Absent that, the session fell back to guessing at priority: it
read the instruction as a user instruction (tier 1 in `using-superpowers`' ordering) and
treated it as overriding the skill. The gap is the missing authorization, not the guess
it forced.

Investigating that surfaced three further mismatches between this repo and Anthropic's
[Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5)
guide, addressed here as separate workstreams.

## Workstream 1 — Authorization

### Scoped authorization

`using-superpowers` gains one statement: invoking a skill is the user requesting the
subagent dispatches that skill mandates.

This satisfies the harness instruction on its own terms rather than overriding it — the
instruction permits dispatch when the user requested it, and this says when that
condition is met. No claim about instruction priority is needed, and none is made.

The authorization is deliberately narrow: it covers dispatches a skill names, not
delegation in general, so Anthropic's cost guidance still governs every other case.

### Fail loud

New rule in `using-superpowers`: if a step a skill marks mandatory cannot or will not be
performed, say so in the turn where it is reached, before continuing. Never complete the
surrounding work and report the gap afterward.

This is the rule that would have caught the original failure even with no authorization
in place at all.

## Workstream 2 — Over-verification

The Opus 5 guide:

> Claude Opus 5 verifies its own work without being told to. If your prompt contains
> explicit verification instructions ("include a final verification step for any
> non-trivial task," "use a subagent to verify"), remove them: instructions like these
> cause over-verification on Claude Opus 5 […] The same applies to legacy harness
> scaffolding that adds separate verification steps.

This applies to the review rounds that re-check the session's own fixes. It does not
apply to first-round reviewers, whose value is fresh context with no anchoring to the
decisions made during development — something a self-review cannot produce.

### One review round

`brainstorming` step 7 and `agents/code-planner.md` Phase 6 become single-dispatch:
review once, fix the blocking issues, proceed. If round 1's findings cannot be resolved,
surface to the user rather than re-dispatching. The `Max 2 rounds` headers in
`spec-document-reviewer-prompt.md` and `plan-document-reviewer-prompt.md` change to match.

This makes both loops consistent with `finishing-a-development-branch:78`, which already
dispatches its reviewer exactly once per branch. The rationale is recorded in the skills
so a later reader does not restore round 2 as an oversight.

### Delete the per-task refactor dispatch

`skills/executing-plans/SKILL.md` loses its optional Refactor section and the two other
references to it; `skills/executing-plans/refactor-reviewer-prompt.md` is deleted. The
skill already said "Per-task review rarely adds value — default to skipping it," and
`branch-reviewer` at merge time covers the same ground with whole-branch context. The
TDD loop keeps Red, Green, and Commit.

## Workstream 3 — Reviewer finding budget

The Opus 5 guide, on review prompts:

> Claude Opus 5 reviews code with high precision and recall: it finds real bugs at a high
> rate per pass, and its additional findings are mostly real issues rather than false
> positives. […] If your review prompt says "only report high-severity issues" or "be
> conservative," the model may follow that instruction literally and report less; ask it
> to report everything and filter in a separate pass instead.

`agents/branch-reviewer.md` is that pattern. Its budget — at most 3 non-critical findings,
"zero findings is a successful review", "if you have more than 3 candidates you haven't
applied the cost test hard enough" — was added on the premise that surplus findings are
low-value noise. On Opus 5 that premise is weaker, so the budget may suppress real bugs
rather than filter nits, and a suppressed finding leaves no trace.

### Move the cap from the reviewer to the caller

The reviewer reports what it finds, with no numeric cap. The cost test stays in the
agent — it is a judgment about *severity*, not a quota, and the guide's warning is about
quotas. What moves out is the count.

`finishing-a-development-branch` and `requesting-code-review` gain the filtering step:
apply the cost test to what came back, act on the critical findings, and surface at most
3 non-critical ones to the user. Volume reaching the user is unchanged; detection is no
longer capped.

The guide's own suggestion is a second filtering subagent. That is rejected: it
reintroduces the token cost the budget existed to cut, and the filtering decision is
cheap to get wrong compared to the detection decision.

## Workstream 4 — Effort and format cleanup

### Effort levels

`brainstorming`, `writing-plans`, and `agents/code-planner.md` set `effort: max`. The
guide recommends `high` as the starting point, using `low`/`medium` liberally, and
reserving the top of the range for demanding coding and agentic work — noting that review
accuracy holds at lower settings. All three drop to `high`.

There is no eval harness in this repo to sweep effort against, so this follows the
guide's default rather than measurement.

### Remove the Parallelization convention

The mandatory `## Parallelization` section is deleted from the spec format in
`brainstorming`, along with its one-line default. `agents/code-planner.md` stops reading
it (Phase 1 and Phase 4) and falls back to a single-step plan unless the spec explicitly
describes independent work streams — which is already its documented default.

In practice the section held the same sentence in every realistic case, restating what a
reader sees from the design directly, and it forced a required-but-empty heading into
every spec.

## What is not changed

`code-planner`, `branch-reviewer`, `worktree-setup`, `org-roam`, and
`dispatching-parallel-agents` keep their dispatches. The first three supply context the
main session cannot manufacture; `org-roam` exists to keep search out of session context;
parallel dispatch over independent tracks is the case the Opus 5 guide endorses.

`verification-before-completion` is left alone. It reads as a target of the
over-verification guidance but is not one: the guide names "use a subagent to verify" and
"include a final verification step" scaffolding, and that skill is a rule against claiming
success without evidence. Different failure mode.

The repo's negative-framing style — Red Flags tables, `Do NOT` lists, Anti-Pattern
sections — is left alone despite both guides preferring statements of desired behavior.
The rewrite is large, the prose currently works, and there is no way to measure the payoff
here.

## Known risks

- The authorization is only as strong as the skill text carrying it. A future harness
  instruction with no "unless the user requested it" escape clause would not be satisfied
  by it, and the fail-loud rule is then the only thing keeping the failure visible.
- Dropping round 2 means a fix applied in response to round 1 gets no independent check.
  The bet is that Opus 5's self-verification covers it, which is the guide's claim, not a
  measured result in this repo.
- Deleting the refactor dispatch removes the only review between a task's commit and
  merge. On a long branch, `branch-reviewer` sees more diff at once than it used to.
- Moving the finding cap to the caller puts the filtering decision in the context that
  wrote the code — precisely the anchoring the fresh-context reviewer exists to avoid.
  Accepted because dropping a finding is cheaper to get wrong than never finding it.
- Dropping effort to `high` on the planning skills reverses a deliberate earlier change
  with no eval data in either direction.

## Verification

Verification is reading the changed skill files. The authorization path cannot be tested
deterministically: the gate is server-side, so a session where every mandated dispatch
fires is indistinguishable from one where the instruction was never injected. A cycle run
would return no signal about the thing it is meant to test.

`tests/claude-code/run-skill-tests.sh` is run to confirm nothing already covered broke.
