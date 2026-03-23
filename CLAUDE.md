# Superpowers — Claude Code Plugin

This repo **is** a Claude Code plugin. It provides skills, agents, hooks, and commands that shape how Claude Code behaves in *other* projects. When working here, you are editing the tool itself, not using it.

This is a fork of [obra/superpowers](https://github.com/obra/superpowers), maintained with local customizations.

## What this repo contains

- `skills/` — Skill definitions (SKILL.md files) that Claude Code loads as slash commands and auto-triggered workflows (brainstorming, TDD, debugging, planning, etc.)
- `agents/` — Subagent definitions (.md files) used by skills to dispatch specialized workers (code-planner, branch-reviewer, worktree-setup, org-roam)
- `hooks/` — Claude Code hooks (session-start) that inject context at conversation start
- `docs/` — Documentation, specs, and platform-specific setup guides
- `tests/` — Integration tests that run real Claude Code sessions in headless mode

## Key files

- `.claude-plugin/plugin.json` — Plugin metadata for Claude Code marketplace
- `gemini-extension.json` + `GEMINI.md` — Gemini CLI extension config
- `hooks/hooks.json` — Hook registration (SessionStart triggers `using-superpowers` skill)

## Naming convention

Skills and agents from this plugin are namespaced with the `superpowers:` prefix. When writing instructions, agent definitions, or skill references, always use the fully qualified name (e.g. `superpowers:brainstorming`, `superpowers:branch-reviewer`, `superpowers:worktree-setup`).

## Common tasks

When the user reports issues like "agents ask for approval for X" or "the skill doesn't trigger when I do Y", they are describing behavior of this plugin when installed in another project. The fix is in the skill/agent/hook files in this repo.

## Testing

Integration tests run real Claude Code sessions and parse `.jsonl` transcripts. See `docs/testing.md` for details.

```bash
cd tests/claude-code
./run-skill-tests.sh
```

Requires `claude` CLI, and `"superpowers@superpowers-dev": true` in `~/.claude/settings.json`.
