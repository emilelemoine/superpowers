# Parallel Plan Execution

Restructure how plans are organized and executed: replace sequential step-by-step plans with DAG-based plans that maximize parallelism, and merge the two execution skills into one.

## Motivation

Today, plans are structured as sequential steps (step 1, step 2, step 3), each containing 3-4 tasks. Executing them requires manual context clearing between steps. This is slow (sequential execution of independent work) and tedious (the user must babysit the process).

Much of the work in a typical plan is actually parallelizable — the API layer, background workers, and UI don't depend on each other. They share a foundation (data models, types) but once that's in place, they can be built simultaneously in separate terminals.

Additionally, the current system has two execution skills (`executing-plans` and `subagent-driven-development`) that overlap in purpose. The subagent-per-task model was a workaround for context pollution, but with parallel branches in separate sessions, context pollution is already solved.

## Design

### Plan Structure: DAG Roadmap + Self-Contained Step Files

The code-planner produces two types of files:

**Roadmap file** (`docs/plans/YYYY-MM-DD-<feature>-roadmap.md`):

Contains the DAG of steps with explicit dependency and parallelism markers.

```markdown
# Feature X — Roadmap

## DAG

Step 1: Foundation (data models, shared types)
Step 2a: API layer           [parallel, depends: 1]
Step 2b: Background workers  [parallel, depends: 1]
Step 2c: UI components       [parallel, depends: 1]
Step 3: Integration tests    [sequential, depends: 2a, 2b, 2c]
```

Sequential steps must be merged to main before their dependents can begin. Parallel steps can run simultaneously in separate terminals/sessions, each in its own git worktree.

**Step files** (`docs/plans/YYYY-MM-DD-<feature>-step-2a.md`):

Each step file is a fully self-contained mini-plan. A fresh Claude session can execute it without any other context. Each includes:

- **Goal and context:** What this branch achieves and how it fits the overall feature.
- **Branch name and worktree setup instructions.**
- **Task list with complete code:** Exact file paths, complete code to write (not descriptions), exact commands to run with expected output. Same level of detail as today's plans.
- **Format/lint command:** The project-specific formatter to run after each edit (e.g., `ruff format <file> && ruff check --fix <file>`).
- **Execution instruction:** Always `superpowers:executing-plans`.
- **Merge instruction:** Use `superpowers:finishing-a-development-branch` when done.

### Parallelization Identified During Brainstorming

The brainstorming/design phase adds a "Parallelization" section to the design doc. This identifies:

- Which parts of the system are independent work streams.
- What shared foundations must exist before parallel work begins.
- What the interfaces/contracts between streams are.

The code-planner reads this section and translates it into the DAG roadmap. The code-planner does not invent parallelism — it encodes what the design already established.

Example in a design doc:

```markdown
## Parallelization

The data models and shared types are foundational — everything depends on them.
Once those exist, the API layer, background workers, and UI can be built independently.
They communicate through the data models only, no direct coupling.
Integration tests should run after all three are merged.
```

### Merged Execution Skill

`executing-plans` becomes the single execution skill. `subagent-driven-development` is retired.

**Core loop — per task:**

1. **Red:** Write the failing test (from plan). Run formatter. Run test, verify it fails.
2. **Green:** Write the implementation (from plan). Run formatter. Run test, verify it passes.
3. **Refactor:** Dispatch a small review subagent scoped to this task's diff. It reviews for unnecessary complexity, naming clarity, missed edge cases in tests, and YAGNI violations. The main session applies accepted suggestions, runs formatter, re-runs tests to confirm they still pass.
4. **Commit.**

**Subagents are used only for support tasks:**

- **Refactor review** — after each task's green phase, scoped to that task's diff.
- **Research / context gathering** — when the executor needs to understand existing code.
- **Worktree setup** — at the start of a session.
- **Branch review** — at the end, via `finishing-a-development-branch`.

**What this replaces:**

- No implementer subagent — the main session writes the code.
- No per-task spec compliance reviewer — the plan has exact code, so spec compliance is built in.
- No separate code quality reviewer — replaced by the lighter refactor subagent.

### User Workflow

1. Run brainstorming. Design doc is written with a parallelization section.
2. Code-planner produces a DAG roadmap + self-contained step files.
3. Execute sequential foundation steps first (one terminal, one session).
4. After foundation is merged to main, open N terminals for parallel steps.
5. Each terminal: set up worktree, point Claude at the step file, let it execute.
6. Each session merges to main via `finishing-a-development-branch` as it completes.
7. Later sessions rebase if an earlier parallel branch has already merged.
8. Execute any final sequential steps (integration tests, etc.).

### Refactor Reviewer Subagent

A new, lightweight subagent dispatched via the Agent tool. Lives at `skills/executing-plans/refactor-reviewer-prompt.md` (colocated with the skill that uses it, following existing convention).

Receives:

- The task description (from the plan).
- The diff of changes made for this task.
- The test results (passing).

Returns (free-form markdown, same pattern as existing reviewer prompts):

- Refactoring suggestions (if any), each with a rationale.
- Verdict: clean / minor suggestions / needs rework.

Scope is deliberately narrow — one task's changes, not the whole branch. The branch-reviewer at merge time provides the broader perspective.

## Files Changed

**Retired:**
- `skills/subagent-driven-development/SKILL.md`
- `skills/subagent-driven-development/implementer-prompt.md`
- `skills/subagent-driven-development/spec-reviewer-prompt.md`
- `skills/subagent-driven-development/code-quality-reviewer-prompt.md`

**Modified:**
- `skills/writing-plans/SKILL.md` — updated plan format (DAG roadmap, self-contained step files); remove execution strategy decision logic (there is only one execution skill now)
- `skills/executing-plans/SKILL.md` — rewritten with TDD loop + refactor subagent + format step
- `skills/brainstorming/SKILL.md` — adds parallelization section to design doc
- `agents/code-planner.md` — DAG-aware, produces roadmap + self-contained step files; remove Phase 4 execution strategy decision (there is only one execution skill now)
- `skills/finishing-a-development-branch/SKILL.md` — remove stale reference to subagent-driven-development
- `skills/using-git-worktrees/SKILL.md` — remove subagent-driven-development from "Called by" section
- `skills/requesting-code-review/SKILL.md` — remove subagent-driven-development from review triggers; still used by branch-reviewer in finishing-a-development-branch

**Peripheral files (stale reference cleanup):**
- `skills/using-superpowers/references/gemini-tools.md` — remove subagent-driven-development skill reference
- `skills/using-superpowers/references/codex-tools.md` — remove subagent-driven-development skill reference
- `README.md` — update plugin workflow description
- `docs/README.codex.md` — update skill references
- `docs/testing.md` — update to reflect retired skill and new test targets
- `tests/subagent-driven-dev/` — retire or replace integration tests
- `tests/explicit-skill-requests/` — retire or replace SDD trigger tests
- `tests/claude-code/test-subagent-driven-development*.sh` — retire or replace
- `tests/claude-code/run-skill-tests.sh` — update test index
- `tests/claude-code/README.md` — update test documentation
- `CLAUDE.md` (project root) — update testing example to reference new test targets

Historical docs (release notes, old plan files) are intentionally left unchanged — they describe what happened at the time.

**Unchanged:**
- `agents/branch-reviewer.md`
- `agents/worktree-setup.md`
- `skills/test-driven-development/SKILL.md`

**New:**
- `skills/executing-plans/refactor-reviewer-prompt.md` — lightweight refactor reviewer subagent prompt
