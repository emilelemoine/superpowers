# Codex Tool Mapping

Skills use Claude Code tool names. When you encounter these in a skill, use your platform equivalent:

| Skill references | Codex equivalent |
|-----------------|------------------|
| `Agent` tool (dispatch subagent) | `spawn_agent` |
| Multiple `Agent` calls (parallel) | Multiple `spawn_agent` calls |
| Agent returns result | `wait` |
| Agent completes automatically | `close_agent` to free slot |
| `TaskCreate`/`TaskUpdate` (task tracking) | `update_plan` |
| `Skill` tool (invoke a skill) | Skills load natively — just follow the instructions |
| `Read`, `Write`, `Edit` (files) | Use your native file tools |
| `Bash` (run commands) | Use your native shell tools |

## Subagent dispatch requires collab

Add to your Codex config (`~/.codex/config.toml`):

```toml
[features]
collab = true
```

This enables `spawn_agent`, `wait`, and `close_agent` for skills like dispatching-parallel-agents and subagent-driven-development.
