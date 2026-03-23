# Parallel Plan Execution — Step 3: Peripheral Skill Updates

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Step 3 of 4** | Previous: `2026-03-23-parallel-plan-execution-step-02.md` | Next: `2026-03-23-parallel-plan-execution-step-04.md`

**Goal:** Update brainstorming, finishing-a-development-branch, using-git-worktrees, and requesting-code-review to remove stale subagent-driven-development references and add parallelization section to brainstorming.

**Branch:** `feature/parallel-execution-step-3`

**Merge instruction:** Use superpowers:finishing-a-development-branch when done.

---

## Task 1: Add parallelization section to brainstorming SKILL.md

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

- [ ] **Step 1: Add parallelization guidance to the "After the Design" section**

In `skills/brainstorming/SKILL.md`, find the "After the Design" section. Before the "**Documentation:**" subsection, insert a new subsection about parallelization. Specifically, find:

```
## After the Design

**Documentation:**
```

And replace with:

```
## After the Design

**Parallelization:**

Before writing the spec, identify which parts of the system can be built independently:

- What shared foundations must exist before anything else? (data models, types, interfaces)
- Which work streams are independent once the foundation exists?
- What are the contracts/interfaces between streams?
- What must wait until all streams are complete? (integration tests, final assembly)

Add a "## Parallelization" section to the design doc with these findings. Example:

```markdown
## Parallelization

The data models and shared types are foundational — everything depends on them.
Once those exist, the API layer, background workers, and UI can be built independently.
They communicate through the data models only, no direct coupling.
Integration tests should run after all three are merged.
```

If the project is small enough that everything is sequential, state that explicitly: "All work is sequential — no parallelization opportunities." The code-planner reads this section and translates it into the DAG roadmap.

**Documentation:**
```

- [ ] **Step 2: Verify the change**

Run: `grep -A 5 "Parallelization" skills/brainstorming/SKILL.md | head -10`
Expected: Shows the new "Parallelization" subsection text.

- [ ] **Step 3: Commit**

```bash
git add skills/brainstorming/SKILL.md
git commit -m "feat: add parallelization section guidance to brainstorming skill"
```

---

## Task 2: Remove stale SDD references from peripheral skills

**Files:**
- Modify: `skills/finishing-a-development-branch/SKILL.md`
- Modify: `skills/using-git-worktrees/SKILL.md`
- Modify: `skills/requesting-code-review/SKILL.md`

- [ ] **Step 1: Update finishing-a-development-branch SKILL.md**

In `skills/finishing-a-development-branch/SKILL.md`, find the "Called by" section at the bottom:

```
## Integration

**Called by:**
- **subagent-driven-development** - After all tasks complete
- **executing-plans** - After all tasks complete
```

Replace with:

```
## Integration

**Called by:**
- **executing-plans** — After all tasks complete
```

- [ ] **Step 2: Update using-git-worktrees SKILL.md**

In `skills/using-git-worktrees/SKILL.md`, find the "Called by" section:

```
**Called by:**
- **subagent-driven-development** — REQUIRED before executing any tasks
- **executing-plans** — REQUIRED before executing any tasks
- Any skill needing isolated workspace
```

Replace with:

```
**Called by:**
- **executing-plans** — REQUIRED before executing any tasks
- Any skill needing isolated workspace
```

- [ ] **Step 3: Update requesting-code-review SKILL.md**

In `skills/requesting-code-review/SKILL.md`, find the "When to Request Review" section:

```
**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main
```

Replace with:

```
**Mandatory:**
- After completing major feature
- Before merge to main
```

Also find the "Integration with Workflows" section:

```
## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck
```

Replace with:

```
## Integration with Workflows

**Executing Plans:**
- Refactor review after each task (via refactor-reviewer subagent)
- Branch review before merge (via finishing-a-development-branch)

**Ad-Hoc Development:**
- Review before merge
- Review when stuck
```

- [ ] **Step 4: Verify all three files**

Run: `grep -c "subagent-driven-development" skills/finishing-a-development-branch/SKILL.md skills/using-git-worktrees/SKILL.md skills/requesting-code-review/SKILL.md`
Expected: All three files show 0 matches.

- [ ] **Step 5: Commit**

```bash
git add skills/finishing-a-development-branch/SKILL.md skills/using-git-worktrees/SKILL.md skills/requesting-code-review/SKILL.md
git commit -m "refactor: remove subagent-driven-development references from peripheral skills"
```

---

### Risks & Considerations
- The brainstorming skill file contains nested markdown code blocks (the example parallelization section). Make sure the fencing is correct when inserting.
- The requesting-code-review changes are more substantial than a simple reference removal — the "Integration with Workflows" section is restructured to reflect the new refactor-reviewer pattern.
