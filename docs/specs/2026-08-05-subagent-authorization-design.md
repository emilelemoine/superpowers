# Subagent Authorization and Review Trimming

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
treated it as overriding the skill. The gap is the missing authorization, not the
guess it forced.

Separately, Anthropic's [Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5)
guide argues that part of this repo's review scaffolding is now counterproductive:

> Claude Opus 5 verifies its own work without being told to. If your prompt contains
> explicit verification instructions ("include a final verification step for any
> non-trivial task," "use a subagent to verify"), remove them: instructions like these
> cause over-verification on Claude Opus 5 […] The same applies to legacy harness
> scaffolding that adds separate verification steps.

That applies to the review rounds that re-check the session's own fixes. It does not
apply to the first-round reviewers, whose value is fresh context with no anchoring to
the decisions made during development — something a self-review cannot produce.

## Design

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

Historical references in `docs/plans/` are archives and are left untouched.

## What is not changed

`code-planner`, `branch-reviewer`, `worktree-setup`, `org-roam`, and
`dispatching-parallel-agents` keep their dispatches. The first three supply context the
main session cannot manufacture; `org-roam` exists to keep search out of session context;
parallel dispatch over independent tracks is the case the Opus 5 guide endorses.

## Known risks

- The authorization is only as strong as the skill text carrying it. A future harness
  instruction with no "unless the user requested it" escape clause would not be satisfied
  by it, and the fail-loud rule is then the only thing keeping the failure visible.
- Dropping round 2 means a fix applied in response to round 1 gets no independent check.
  The bet is that Opus 5's self-verification covers it, which is the guide's claim, not a
  measured result in this repo.
- Deleting the refactor dispatch removes the only review between a task's commit and
  merge. On a long branch, `branch-reviewer` sees more diff at once than it used to.

## Verification

Verification is reading the changed skill files. The authorization path cannot be tested
deterministically: the gate is server-side, so a session where every mandated dispatch
fires is indistinguishable from one where the instruction was never injected. A cycle run
would return no signal about the thing it is meant to test.

## Parallelization

All work is sequential — no parallelization opportunities.
