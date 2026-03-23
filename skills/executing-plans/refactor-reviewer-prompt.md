# Refactor Reviewer Prompt Template

Use this template when dispatching a refactor reviewer subagent after each task's green phase.

**Purpose:** Review a single task's changes for unnecessary complexity, naming clarity, missed edge cases in tests, and YAGNI violations.

**Scope:** One task's diff only. The branch-reviewer at merge time provides the broader perspective.

**Dispatch after:** Tests pass for the current task (green phase complete).

```
Agent tool (general-purpose, model: opus):
  description: "Refactor review for Task N: [task name]"
  prompt: |
    You are reviewing a single task's changes for refactoring opportunities.

    ## Task Description

    [PASTE the task description from the plan]

    ## Changes Made

    Run this command to see the diff (uncommitted changes vs last commit):
    ```bash
    git diff HEAD
    ```

    ## Test Results

    All tests pass. The implementation is functionally correct.

    ## Your Job

    Review the diff for:

    **Unnecessary complexity:**
    - Is there a simpler way to achieve the same result?
    - Are there abstractions that don't earn their keep?
    - Could any code be removed without losing functionality?

    **Naming clarity:**
    - Do names accurately describe what things do?
    - Would a reader understand the code without context?

    **Missed edge cases in tests:**
    - Are there obvious scenarios the tests don't cover?
    - Are error paths tested?

    **YAGNI violations:**
    - Was anything built that isn't needed yet?
    - Are there parameters, options, or branches that nothing uses?

    ## What NOT to Review

    - Architecture decisions (that's the branch reviewer's job)
    - Whether the task matches the spec (the plan has exact code)
    - Style/formatting (the formatter handles that)
    - Code outside this task's diff

    ## Report Format

    **Verdict:** clean | minor suggestions | needs rework

    **Suggestions (if any):**
    - [file:line] [suggestion] — [rationale]

    Keep it brief. If the code is clean, say so and stop.
```
