# Workflow Cleanup — Design Spec

## Goal

Reduce redundancy, clarify roles, fix confusing handoffs, and properly scope project-level vs. general-level content across the superpowers plugin's skill and agent workflow.

## Context

The brainstorming → planning → execution → finishing workflow has accumulated overlapping review layers, duplicated content across skills and agents, unclear handoffs, and personality-specific content baked into general-purpose skills. This cleanup addresses 10 identified issues without changing the fundamental workflow structure.

## Changes

### 1. Review Layer Consolidation

**Per-task refactor review → optional**

In `executing-plans`, change the Refactor phase from mandatory to optional. Trigger it when:
- The implementation deviated significantly from the plan
- The task was complex enough to warrant a second look

The branch-reviewer at merge time catches the same issues (complexity, naming, YAGNI) with better whole-branch context. For plan-driven development where tasks have complete code, per-task review adds latency without proportional value.

**Unify reviewer agents**

Delete `agents/code-reviewer.md`. The `branch-reviewer` agent covers the same concerns with a sharper, more focused prompt. Update `requesting-code-review` to dispatch `branch-reviewer` instead.

Delete `skills/requesting-code-review/code-reviewer.md` (the template file) — the branch-reviewer's own prompt is sufficient.

Scope `requesting-code-review` description to ad-hoc work: "Use when completing ad-hoc work outside a structured plan, or when stuck and wanting a fresh perspective." This eliminates confusion with `finishing-a-development-branch`, which already handles the standard pre-merge review.

### 2. Deduplicate writing-plans and code-planner

**writing-plans → pure format spec**

Remove from `skills/writing-plans/SKILL.md`:
- "Scope Check" section (code-planner Phase 1 does this)
- "File Structure" section (code-planner Phase 3 covers this)
- "Plan Review Loop" section (code-planner Phase 6 owns this process)
- "Execution Handoff" section (code-planner Phase 7 owns this)

Keep:
- Overview (what a plan is)
- When to split (4-commit threshold)
- DAG roadmap format + step file format + single-file format
- Task structure template
- Bite-sized granularity guidance
- "Remember" checklist

**code-planner → sole authority on process**

Remove the inline plan-document-reviewer prompt from `agents/code-planner.md` Phase 6. Replace with a reference to the canonical source: `skills/writing-plans/plan-document-reviewer-prompt.md`.

### 3. Parallel Execution Guidance

Add a "Parallel Steps" section to `executing-plans` explaining:
- Parallel steps from a DAG roadmap are user-managed
- Each parallel step runs in a separate Claude session with its own worktree
- This skill handles one step at a time — parallelism comes from running multiple sessions
- Each step file is self-contained; no shared state between parallel sessions

Add a brief note to the writing-plans roadmap format template explaining this user-managed model.

### 4. Fix Worktree Setup Handoff

In `executing-plans`, make worktree setup the explicit first action in Step 1 (not just a footnote in "Integration"):
- Before loading the plan, check if you're in a worktree
- If not, trigger `superpowers:using-git-worktrees` to set one up
- Then load and review the plan

In code-planner Phase 7 (Execution Handoff), mention that execution starts with worktree setup.

### 5. Fix Default Spec Path

In `brainstorming`, change the default spec location from `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` to `docs/specs/YYYY-MM-DD-<topic>-design.md`. The `superpowers/` segment is specific to this repo and doesn't make sense when the plugin is installed in other projects.

### 6. Consolidate Worktree Cleanup

Make `using-git-worktrees` the single canonical source for the cleanup order and `git -C` convention.

In `finishing-a-development-branch`:
- Keep the `git -C` commands inline in the merge flow (Steps 7/8) since they're part of the procedural steps
- Remove the standalone Step 9 "Cleanup Worktree and Branch" explanation section that duplicates `using-git-worktrees`
- Add a cross-reference: "Cleanup order per superpowers:using-git-worktrees"

### 7. Remove Deprecated Skill Aliases

Delete the following deprecated redirect skills:
- `superpowers:execute-plan`
- `superpowers:write-plan`
- `superpowers:brainstorm`

These waste context window tokens on every conversation. The renamed skills have been in place long enough.

### 8. Tone Down receiving-code-review

**Keep (technical core — general-purpose):**
- The Response Pattern (read → understand → verify → evaluate → respond → implement)
- Handling unclear feedback (clarify all items before implementing any)
- Source-specific handling (human partner vs. external reviewers)
- YAGNI check for "professional" features
- Implementation order
- When to push back (and how)
- Common mistakes table

**Remove (personality-specific):**
- "NEVER say 'You're absolutely right!'" and all forbidden response phrases
- "ANY gratitude expression" prohibition
- "Strange things are afoot at the Circle K" signal phrase
- "your human partner's rule:" framing throughout
- The "Acknowledging Correct Feedback" section with its exhaustive forbidden/allowed lists
- "Gracefully Correcting Your Pushback" section (too prescriptive about social dynamics)

**Replace with toned-down general guidance:**
- "Be direct — acknowledge correct feedback briefly and move to action, don't be performative"
- "Focus on technical substance over social niceties"

### 9. Clean "your human partner" Phrasing

In `systematic-debugging`:
- Rename "your human partner's Signals You're Doing It Wrong" to "Signals You're On The Wrong Track" or similar
- Remove "your human partner" prefix from watch-for items — make them general signals

In `verification-before-completion`:
- Remove "your human partner said 'I don't believe you'" anecdote (too personal)
- Remove "Violates: 'Honesty is a core value. If you lie, you'll be replaced.'" (personal threat framing)
- Keep the principle (verification is about integrity) but frame it generally

## Files Changed

| File | Action |
|------|--------|
| `skills/executing-plans/SKILL.md` | Refactor review optional, add parallel steps section, fix worktree handoff |
| `skills/requesting-code-review/SKILL.md` | Use branch-reviewer, scope to ad-hoc |
| `skills/requesting-code-review/code-reviewer.md` | Delete |
| `agents/code-reviewer.md` | Delete |
| `agents/code-planner.md` | Remove inline plan-reviewer prompt, add worktree mention in handoff |
| `skills/writing-plans/SKILL.md` | Strip to pure format spec |
| `skills/brainstorming/SKILL.md` | Change default spec path |
| `skills/using-git-worktrees/SKILL.md` | No changes (already canonical) |
| `skills/finishing-a-development-branch/SKILL.md` | Remove standalone cleanup section, add cross-reference |
| `skills/receiving-code-review/SKILL.md` | Tone down personality, keep technical core |
| `skills/systematic-debugging/SKILL.md` | Clean "your human partner" phrasing |
| `skills/verification-before-completion/SKILL.md` | Clean personal anecdotes |
| Deprecated skill aliases (3 files) | Delete |

## Parallelization

All work is sequential — too many files overlap between logical groups for meaningful parallelization. Single branch, sequential commits.

## Testing

These are documentation/process changes to skill files. Verify by:
- Reading each changed file for internal consistency
- Checking cross-references still resolve
- Confirming no orphaned references to deleted files (code-reviewer agent, code-reviewer.md template)
