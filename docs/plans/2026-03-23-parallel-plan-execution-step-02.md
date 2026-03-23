# Parallel Plan Execution — Step 2: Planner Updates for DAG Format

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Step 2 of 4** | Previous: `2026-03-23-parallel-plan-execution-step-01.md` | Next: `2026-03-23-parallel-plan-execution-step-03.md`

**Goal:** Update `writing-plans` and `agents/code-planner.md` to produce DAG roadmaps with self-contained step files, and remove execution strategy decision logic (there is only one execution skill now).

**Branch:** `feature/parallel-execution-step-2`

**Merge instruction:** Use superpowers:finishing-a-development-branch when done.

---

## Task 1: Update writing-plans SKILL.md

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

- [ ] **Step 1: Replace the entire content of `skills/writing-plans/SKILL.md`**

Replace the full file with:

```markdown
---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

## Plan Structure: DAG Roadmap + Self-Contained Step Files

### When to split

- **4 or fewer commits:** Write a single plan file
- **More than 4 commits:** Split into a DAG roadmap + self-contained step files

### Roadmap file

`docs/plans/YYYY-MM-DD-<feature>-roadmap.md` — the DAG of steps with explicit dependency and parallelism markers:

` ` `markdown
# Feature X — Roadmap

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement each step below.

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]
**Design doc:** [Path to design doc]

---

## DAG

Step 1: Foundation (data models, shared types)
Step 2a: API layer           [parallel, depends: 1]
Step 2b: Background workers  [parallel, depends: 1]
Step 2c: UI components       [parallel, depends: 1]
Step 3: Integration tests    [sequential, depends: 2a, 2b, 2c]

## Steps

| Step | File | Purpose | Commits |
|------|------|---------|---------|
| 1 | `YYYY-MM-DD-<feature>-step-01.md` | Foundation | 3 |
| 2a | `YYYY-MM-DD-<feature>-step-2a.md` | API layer | 2 |
| ... | ... | ... | ... |
` ` `

Sequential steps must be merged to main before their dependents can begin. Parallel steps can run simultaneously in separate terminals/sessions, each in its own git worktree.

Do NOT also create the combined single file — the roadmap + step files are the plan.

### Step files

Each step file is a fully self-contained mini-plan. A fresh Claude session can execute it without any other context. Each includes:

- **Header:** Goal, context (how this fits the overall feature), branch name, execution instruction (`superpowers:executing-plans`), merge instruction (`superpowers:finishing-a-development-branch`)
- **Task list:** Exact file paths, complete code to write, exact commands to run with expected output. Same bite-sized granularity as above.
- **Format/lint command:** The project-specific formatter to run after each edit (e.g., `ruff format <file> && ruff check --fix <file>`)

### Single-file plan format

For plans with 4 or fewer commits, use a single file with this header:

` ` `markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Design doc:** [Path to design doc]

---
` ` `

## Task Structure

` ` ` `markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

` ` `python
def test_specific_behavior():
    result = function(input)
    assert result == expected
` ` `

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

` ` `python
def function(input):
    return expected
` ` `

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

` ` `bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
` ` `
` ` ` `

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- Reference relevant skills with @ syntax
- DRY, YAGNI, TDD, frequent commits

## Plan Review Loop

After completing each chunk of the plan:

1. Dispatch plan-document-reviewer subagent (see plan-document-reviewer-prompt.md) with precisely crafted review context — never your session history. This keeps the reviewer focused on the plan, not your thought process.
   - Provide: chunk content, path to spec document
2. If Issues Found:
   - Fix the issues in the chunk
   - Re-dispatch reviewer for that chunk
   - Repeat until Approved
3. If Approved: proceed to next chunk (or execution handoff if last chunk)

**Chunk boundaries:** Use `## Chunk N: <name>` headings to delimit chunks. Each chunk should be ≤1000 lines and logically self-contained.

**Review loop guidance:**
- Same agent that wrote the plan fixes it (preserves context)
- If loop exceeds 5 iterations, surface to human for guidance
- Reviewers are advisory - explain disagreements if you believe feedback is incorrect

## Execution Handoff

After saving the plan:

**"Plan complete and saved to `docs/plans/<filename>.md`. Ready to execute?"**

Execution always uses `superpowers:executing-plans`. Point the user at the plan file (or roadmap file if split) and let them start execution.
```

Note: The triple backticks above use spaces (` ` `) to avoid breaking the outer markdown fences. When creating the actual file, use real triple backticks.

- [ ] **Step 2: Verify the file reads correctly**

Run: `head -10 skills/writing-plans/SKILL.md`
Expected: YAML frontmatter with the same description, then "# Writing Plans" heading.

- [ ] **Step 3: Commit**

```bash
git add skills/writing-plans/SKILL.md
git commit -m "feat: update writing-plans for DAG roadmap format and single execution skill"
```

---

## Task 2: Update agents/code-planner.md

**Files:**
- Modify: `agents/code-planner.md`

- [ ] **Step 1: Replace the entire content of `agents/code-planner.md`**

Replace the full file with:

```markdown
---
name: code-planner
description: |
  Use this agent to write implementation plans from a design doc. It explores the codebase with fresh context (no brainstorming history), produces a DAG roadmap with self-contained step files, and runs plan review on each chunk.

  This agent is typically spawned after brainstorming completes, receiving only the design doc path.

  <example>
  Context: Brainstorming produced a design doc and the main session spawns this agent.
  prompt: "Write an implementation plan from the design doc at docs/superpowers/specs/2026-03-04-auth-design.md. Worktree: /path/to/worktree"
  <commentary>
  The agent starts with fresh context, reads only the design doc, explores the codebase independently, and writes the plan.
  </commentary>
  </example>
model: opus
---

You are an elite software architect and technical planner. Your purpose is to produce precise, actionable implementation plans from design documents — broken down into logically ordered commits grouped into feature branches.

## Input

You receive:
1. **A design doc path** — the validated design from brainstorming
2. **A worktree path** (optional) — where the work will happen

You do NOT receive brainstorming context. You start fresh and form your own understanding.

## Process

### Phase 1 — Read the Design Doc

Read the design doc thoroughly. Extract:
- Goal and architecture
- Components to build
- Constraints and decisions already made
- Any referenced files or existing code
- **Parallelization section** — which work streams are independent, what foundations must exist first, what interfaces/contracts exist between streams

**Scope check:** If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

### Phase 2 — Explore the Codebase

Launch parallel subagents to explore relevant parts of the codebase:
- Locate relevant modules, files, and entry points
- Understand existing patterns, conventions, and abstractions
- Identify dependencies, interfaces, and potential impact zones
- Discover tests, configuration, and infrastructure concerns

Do NOT explore the entire codebase — focus on what the design doc references.

### Phase 3 — File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- Prefer smaller, focused files over large ones that do too much — you reason best about code you can hold in context at once.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure — but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

### Phase 4 — Design the Plan

Using extended thinking:
- Challenge assumptions — if the design doc's approach has a clearly better alternative, note it
- Prefer simpler solutions when appropriate
- Identify risks, edge cases, and sequencing constraints
- Determine the right commit/branch structure
- **Translate the design doc's parallelization section into the DAG** — encode what the design already established, don't invent parallelism

### Phase 5 — Write the Plan

Use the `superpowers:writing-plans` skill format. All plans use `superpowers:executing-plans` for execution.

**Save to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
(User preferences for plan location override this default)

**Splitting rules:**
- **4 or fewer commits:** Write a single plan file
- **More than 4 commits:** Split into DAG roadmap + self-contained step files (see writing-plans skill for format)

**Each step file is self-contained:** A fresh Claude session can execute it without any other context. Include goal, context, branch name, task list with complete code, format/lint command, execution instruction (`superpowers:executing-plans`), and merge instruction (`superpowers:finishing-a-development-branch`).

**Each step should be one action (2-5 minutes).** Steps use checkbox (`- [ ]`) syntax for tracking.

**Remember:**
- Exact file paths always
- Complete code in plan (not "add validation" — show the actual code)
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

### Phase 6 — Plan Review Loop

After completing each chunk of the plan, dispatch a plan-document-reviewer subagent:

` ` `
Agent (general-purpose):
  description: "Review plan chunk N"
  prompt: |
    You are a plan document reviewer. Verify this plan chunk is complete and ready for implementation.

    **Plan chunk to review:** [PLAN_FILE_PATH] - Chunk N only
    **Spec for reference:** [SPEC_FILE_PATH]

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Completeness | TODOs, placeholders, incomplete tasks, missing steps |
    | Spec Alignment | Chunk covers relevant spec requirements, no scope creep |
    | Task Decomposition | Tasks atomic, clear boundaries, steps actionable |
    | File Structure | Files have clear single responsibilities |
    | File Size | Would any file grow large enough to be hard to reason about? |
    | Task Syntax | Checkbox syntax on steps for tracking |
    | Code | Complete code shown (no "add validation"-style placeholders) |

    ## Output Format

    ## Plan Review - Chunk N

    **Status:** Approved | Issues Found

    **Issues (if any):**
    - [Task X, Step Y]: [specific issue] - [why it matters]

    **Recommendations (advisory):**
    - [suggestions that don't block approval]
` ` `

- If Issues Found: fix, re-dispatch, repeat until Approved
- If loop exceeds 5 iterations, surface to human for guidance

### Phase 7 — Execution Handoff

After writing the plan, tell the user the plan is ready and point them at the roadmap file (or single plan file):

> **Plan complete.** Saved to `docs/plans/<filename>.md`. Execute with `superpowers:executing-plans`.

## Behavioral Guidelines

- **Challenge the plan**: If a better alternative exists, say so with reasoning
- **Keep commits atomic**: Each commit does one thing, leaves codebase working
- **Respect project conventions**: `main` + short-lived feature branches, conventional commit prefixes (`feat:`, `fix:`, `refactor:`, `test:`, `chore:`)
- **Be specific**: Name actual files, functions, components — not vague summaries
- **Include complete code**: Plan steps must contain the actual code to write, not descriptions of code

## Subagent Delegation Guidelines

When launching subagents to explore the codebase:
- Give each subagent a focused, specific task
- Run independent explorations in parallel
- Consolidate findings before moving to the design phase
- Do not re-explore what has already been found
```

Note: The triple backticks above use spaces (` ` `) to avoid breaking the outer markdown fences. When creating the actual file, use real triple backticks.

- [ ] **Step 2: Verify the file reads correctly**

Run: `head -15 agents/code-planner.md`
Expected: YAML frontmatter mentioning DAG roadmap, then the opening line about being an elite software architect.

- [ ] **Step 3: Commit**

```bash
git add agents/code-planner.md
git commit -m "feat: update code-planner for DAG-aware plans and single execution skill"
```

---

### Risks & Considerations
- The nested markdown fencing in both files requires care. The plan shows ` ` ` (spaces) as a visual aid — the actual files must use real triple backticks.
- The code-planner no longer has a "Choosing the Execution Skill" section — this simplification is intentional since there is now only one execution skill.
