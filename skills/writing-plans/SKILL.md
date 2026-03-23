---
name: writing-plans
description: Format reference for implementation plans — use superpowers:code-planner to write plans from design docs
---

# Writing Plans — Format Reference

## Overview

Implementation plans document everything an engineer needs to execute a feature: which files to touch, complete code for each task, exact test commands, and bite-sized steps. DRY. YAGNI. TDD. Frequent commits.

Assume the implementer is a skilled developer who knows almost nothing about the codebase or problem domain, and who doesn't know good test design very well.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

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

```markdown
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
| 1 | `YYYY-MM-DD-<feature>-step-1.md` | Foundation | 3 |
| 2a | `YYYY-MM-DD-<feature>-step-2a.md` | API layer | 2 |
| ... | ... | ... | ... |
```

Sequential steps must be merged to main before their dependents can begin. Parallel steps can run simultaneously in separate Claude sessions, each in its own git worktree. Parallelism is user-managed — each session runs one step at a time independently.

Do NOT also create the combined single file — the roadmap + step files are the plan.

### Step files

Each step file is a fully self-contained mini-plan. A fresh Claude session can execute it without any other context. Each includes:

- **Header:** Goal, context (how this fits the overall feature), branch name, execution instruction (`superpowers:executing-plans`), merge instruction (`superpowers:finishing-a-development-branch`)
- **Task list:** Exact file paths, complete code to write, exact commands to run with expected output. Same bite-sized granularity as above.
- **Format/lint command:** The project-specific formatter to run after each edit (e.g., `ruff format <file> && ruff check --fix <file>`)

### Single-file plan format

For plans with 4 or fewer commits, use a single file with this header:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Design doc:** [Path to design doc]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits
