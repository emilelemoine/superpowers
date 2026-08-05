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

**Tier ambiguity.** `using-superpowers` states a three-tier priority order — user
instructions, then skills, then default system prompt — but never says which tier a
harness-injected session instruction occupies. It is tier 3. The session read it as
tier 1 and so treated it as overriding the skill.

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

### Tier placement

`using-superpowers` gains an explicit statement that harness-injected session
instructions are tier 3 (default system prompt), not tier 1. Tier 1 remains CLAUDE.md,
GEMINI.md, AGENTS.md, and direct user requests only.

### Scoped authorization

Invoking a skill is the user requesting the subagent dispatches that skill mandates.
The authorization is deliberately narrow: it covers dispatches a skill names, not
delegation in general, so Anthropic's cost guidance still governs every other case.

### Fail loud

New rule in `using-superpowers`: if a step a skill marks mandatory cannot or will not be
performed, say so in the turn where it is reached, before continuing. Never complete the
surrounding work and report the gap afterward.

This is the rule that would have caught the original failure regardless of how the tier
question was resolved.

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

- The authorization is only as strong as the skill text carrying it. If a future harness
  instruction is worded to override skills explicitly, the fail-loud rule is what keeps
  the failure visible instead of silent.
- Dropping round 2 means a fix applied in response to round 1 gets no independent check.
  The bet is that Opus 5's self-verification covers it, which is the guide's claim, not a
  measured result in this repo.
- Deleting the refactor dispatch removes the only review between a task's commit and
  merge. On a long branch, `branch-reviewer` sees more diff at once than it used to.

## Verification

No automated test covers these paths — `tests/claude-code/` has no test for dispatch
authorization or review-round counts. Verification is running a full
brainstorm → plan → implement → finish cycle and observing that each mandated dispatch
fires without being asked for, and that no review runs twice.

## Parallelization

All work is sequential — no parallelization opportunities.
