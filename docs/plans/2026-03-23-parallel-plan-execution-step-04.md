# Parallel Plan Execution — Step 4: Retire SDD + Update Docs/Tests

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement this plan.

**Step 4 of 4** | Previous: `2026-03-23-parallel-plan-execution-step-03.md` | Next: none

**Goal:** Delete subagent-driven-development skill files, update all documentation and test infrastructure to reflect the retirement.

**Branch:** `feature/parallel-execution-step-4`

**Merge instruction:** Use superpowers:finishing-a-development-branch when done.

---

## Task 1: Delete SDD skill files and update docs

**Files:**
- Delete: `skills/subagent-driven-development/SKILL.md`
- Delete: `skills/subagent-driven-development/implementer-prompt.md`
- Delete: `skills/subagent-driven-development/spec-reviewer-prompt.md`
- Delete: `skills/subagent-driven-development/code-quality-reviewer-prompt.md`
- Modify: `skills/using-superpowers/references/gemini-tools.md`
- Modify: `skills/using-superpowers/references/codex-tools.md`
- Modify: `README.md`
- Modify: `docs/README.codex.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Delete the SDD skill directory**

```bash
git rm -r skills/subagent-driven-development/
```

- [ ] **Step 2: Update gemini-tools.md**

In `skills/using-superpowers/references/gemini-tools.md`, find:

```
## No subagent support

Gemini CLI has no equivalent to Claude Code's `Agent` tool. Skills that rely on subagent dispatch (subagent-driven-development, dispatching-parallel-agents) will fall back to single-session execution via executing-plans.
```

Replace with:

```
## No subagent support

Gemini CLI has no equivalent to Claude Code's `Agent` tool. Skills that rely on subagent dispatch (dispatching-parallel-agents) will fall back to single-session execution via executing-plans.
```

- [ ] **Step 3: Update codex-tools.md**

In `skills/using-superpowers/references/codex-tools.md`, find:

```
This enables `spawn_agent`, `wait`, and `close_agent` for skills like dispatching-parallel-agents and subagent-driven-development.
```

Replace with:

```
This enables `spawn_agent`, `wait`, and `close_agent` for skills like dispatching-parallel-agents.
```

- [ ] **Step 4: Update README.md**

In `README.md`, find the workflow step that mentions SDD:

```
4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.
```

Replace with:

```
4. **executing-plans** - Activates with plan. Follows TDD loop (red-green-refactor) for each task with lightweight refactor review after each green phase.
```

Also in the "What's Inside" / "Collaboration" section, find and remove this line:

```
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)
```

- [ ] **Step 5: Update docs/README.codex.md**

In `docs/README.codex.md`, find:

```
4. **For subagent skills** (optional): Skills like `dispatching-parallel-agents` and `subagent-driven-development` require Codex's collab feature. Add to your Codex config:
```

Replace with:

```
4. **For subagent skills** (optional): Skills like `dispatching-parallel-agents` require Codex's collab feature. Add to your Codex config:
```

- [ ] **Step 6: Update CLAUDE.md**

In `CLAUDE.md` (project root), find the testing example:

```
```bash
cd tests/claude-code
./test-subagent-driven-development-integration.sh
```
```

Replace with:

```
```bash
cd tests/claude-code
./run-skill-tests.sh
```
```

- [ ] **Step 7: Verify no stale SDD references remain in modified files**

Run: `grep -r "subagent-driven-development" skills/ agents/ README.md CLAUDE.md docs/README.codex.md`
Expected: No output (zero matches). Historical docs in `docs/` may still reference it and that's fine — they describe what happened at the time.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "chore: retire subagent-driven-development skill and update all references"
```

---

## Task 2: Update test infrastructure

**Files:**
- Modify: `tests/claude-code/run-skill-tests.sh`
- Modify: `tests/claude-code/README.md`
- Modify: `docs/testing.md`

Note: The old test files (`tests/claude-code/test-subagent-driven-development*.sh`, `tests/subagent-driven-dev/`, `tests/explicit-skill-requests/`) are left in place for now. They test a retired skill but don't break anything — they'll simply fail if run. A follow-up can write new integration tests for the updated executing-plans skill. Deleting them wholesale risks losing test patterns and infrastructure that can be adapted.

- [ ] **Step 1: Update run-skill-tests.sh**

In `tests/claude-code/run-skill-tests.sh`, find the test arrays:

```bash
# List of skill tests to run (fast unit tests)
tests=(
    "test-subagent-driven-development.sh"
)

# Integration tests (slow, full execution)
integration_tests=(
    "test-subagent-driven-development-integration.sh"
)
```

Replace with:

```bash
# List of skill tests to run (fast unit tests)
tests=(
    # TODO: Add executing-plans skill test
)

# Integration tests (slow, full execution)
integration_tests=(
    # TODO: Add executing-plans integration test
)
```

Also find the help text:

```bash
            echo "Tests:"
            echo "  test-subagent-driven-development.sh  Test skill loading and requirements"
            echo ""
            echo "Integration Tests (use --integration):"
            echo "  test-subagent-driven-development-integration.sh  Full workflow execution"
```

Replace with:

```bash
            echo "Tests:"
            echo "  (none yet — executing-plans tests coming soon)"
            echo ""
            echo "Integration Tests (use --integration):"
            echo "  (none yet — executing-plans integration test coming soon)"
```

- [ ] **Step 2: Update tests/claude-code/README.md**

Replace the entire content of `tests/claude-code/README.md` with:

```markdown
# Claude Code Skills Tests

Automated tests for superpowers skills using Claude Code CLI.

## Overview

This test suite verifies that skills are loaded correctly and Claude follows them as expected. Tests invoke Claude Code in headless mode (`claude -p`) and verify the behavior.

## Requirements

- Claude Code CLI installed and in PATH (`claude --version` should work)
- Local superpowers plugin installed (see main README for installation)

## Running Tests

### Run all fast tests (recommended):
```bash
./run-skill-tests.sh
```

### Run integration tests (slow, 10-30 minutes):
```bash
./run-skill-tests.sh --integration
```

### Run specific test:
```bash
./run-skill-tests.sh --test test-name.sh
```

### Run with verbose output:
```bash
./run-skill-tests.sh --verbose
```

### Set custom timeout:
```bash
./run-skill-tests.sh --timeout 1800  # 30 minutes for integration tests
```

## Test Structure

### test-helpers.sh
Common functions for skills testing:
- `run_claude "prompt" [timeout]` - Run Claude with prompt
- `assert_contains output pattern name` - Verify pattern exists
- `assert_not_contains output pattern name` - Verify pattern absent
- `assert_count output pattern count name` - Verify exact count
- `assert_order output pattern_a pattern_b name` - Verify order
- `create_test_project` - Create temp test directory
- `create_test_plan project_dir` - Create sample plan file

### Adding New Tests

1. Create new test file: `test-<skill-name>.sh`
2. Source test-helpers.sh
3. Write tests using `run_claude` and assertions
4. Add to test list in `run-skill-tests.sh`
5. Make executable: `chmod +x test-<skill-name>.sh`

## Legacy Tests

The `test-subagent-driven-development*.sh` files test the retired SDD skill. They are kept as reference for test patterns but are no longer in the active test suite.

## Notes

- Tests verify skill *instructions*, not full execution
- Full workflow tests would be very slow
- Focus on verifying key skill requirements
- Tests should be deterministic
- Avoid testing implementation details
```

- [ ] **Step 3: Update docs/testing.md**

Replace the entire content of `docs/testing.md` with:

```markdown
# Testing Superpowers Skills

This document describes how to test Superpowers skills, particularly integration tests that run actual Claude Code sessions.

## Overview

Testing skills that involve subagents, workflows, and complex interactions requires running actual Claude Code sessions in headless mode and verifying their behavior through session transcripts.

## Test Structure

```
tests/
├── claude-code/
│   ├── test-helpers.sh                    # Shared test utilities
│   ├── run-skill-tests.sh                 # Test runner
│   ├── analyze-token-usage.py             # Token analysis tool
│   └── test-subagent-driven-development-*.sh  # Legacy SDD tests (reference only)
```

## Running Tests

### Integration Tests

Integration tests execute real Claude Code sessions with actual skills:

```bash
cd tests/claude-code
./run-skill-tests.sh --integration
```

**Note:** Integration tests can take 10-30 minutes as they execute real implementation plans.

### Requirements

- Must run from the **superpowers plugin directory** (not from temp directories)
- Claude Code must be installed and available as `claude` command
- Local dev marketplace must be enabled: `"superpowers@superpowers-dev": true` in `~/.claude/settings.json`

## Token Analysis Tool

### Usage

Analyze token usage from any Claude Code session:

```bash
python3 tests/claude-code/analyze-token-usage.py ~/.claude/projects/<project-dir>/<session-id>.jsonl
```

### Finding Session Files

Session transcripts are stored in `~/.claude/projects/` with the working directory path encoded:

```bash
SESSION_DIR="$HOME/.claude/projects/-Users-<user>-<path>"
ls -lt "$SESSION_DIR"/*.jsonl | head -5
```

### What It Shows

- **Main session usage**: Token usage by the coordinator
- **Per-subagent breakdown**: Each subagent invocation with message count, input/output tokens, cache usage, estimated cost
- **Totals**: Overall token usage and cost estimate

## Writing New Integration Tests

### Template

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

# Create test project
TEST_PROJECT=$(create_test_project)
trap "cleanup_test_project $TEST_PROJECT" EXIT

# Set up test files...
cd "$TEST_PROJECT"

# Run Claude with skill
PROMPT="Your test prompt here"
cd "$SCRIPT_DIR/../.." && timeout 1800 claude -p "$PROMPT" \
  --allowed-tools=all \
  --add-dir "$TEST_PROJECT" \
  --permission-mode bypassPermissions \
  2>&1 | tee output.txt

# Find and analyze session
WORKING_DIR_ESCAPED=$(echo "$SCRIPT_DIR/../.." | sed 's/\\//-/g' | sed 's/^-//')
SESSION_DIR="$HOME/.claude/projects/$WORKING_DIR_ESCAPED"
SESSION_FILE=$(find "$SESSION_DIR" -name "*.jsonl" -type f -mmin -60 | sort -r | head -1)

# Verify behavior by parsing session transcript
if grep -q '"name":"Skill".*"skill":"your-skill-name"' "$SESSION_FILE"; then
    echo "[PASS] Skill was invoked"
fi

# Show token analysis
python3 "$SCRIPT_DIR/analyze-token-usage.py" "$SESSION_FILE"
```

### Best Practices

1. **Always cleanup**: Use trap to cleanup temp directories
2. **Parse transcripts**: Don't grep user-facing output — parse the `.jsonl` session file
3. **Grant permissions**: Use `--permission-mode bypassPermissions` and `--add-dir`
4. **Run from plugin dir**: Skills only load when running from the superpowers directory
5. **Show token usage**: Always include token analysis for cost visibility
6. **Test real behavior**: Verify actual files created, tests passing, commits made
```

- [ ] **Step 4: Verify the test runner still works syntactically**

Run: `bash -n tests/claude-code/run-skill-tests.sh`
Expected: No output (syntax is valid).

- [ ] **Step 5: Commit**

```bash
git add tests/claude-code/run-skill-tests.sh tests/claude-code/README.md docs/testing.md
git commit -m "chore: update test infrastructure for executing-plans skill"
```

---

### Risks & Considerations
- Old SDD test files are deliberately kept as reference material rather than deleted. This avoids losing test patterns that can be adapted for the new executing-plans tests.
- The `tests/explicit-skill-requests/` and `tests/subagent-driven-dev/` directories are left untouched. They contain SDD-specific test fixtures. A future task can adapt them for executing-plans integration testing.
- The `git add -A` in Task 1 Step 8 is intentional for the deletion commit — it captures the `git rm -r` plus all the reference cleanup edits in one atomic commit.

### Out of Scope
- Writing new integration tests for the updated executing-plans skill (that's a separate task once the skill is stable)
- Deleting legacy test directories (`tests/subagent-driven-dev/`, `tests/explicit-skill-requests/prompts/subagent-driven-development-please.txt`, etc.)
