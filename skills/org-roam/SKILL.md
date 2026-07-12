---
name: org-roam
description: Use when the user asks about their personal notes, references prior thinking, or needs context from their org-roam knowledge graph — e.g. "check my org-roam notes on X", "I wrote about this before", "what did I note about Y"
---

# Org-Roam Knowledge Base

Searching the user's org-roam notes is done by a dedicated subagent, **not** by this skill directly. This skill exists so the request resolves consistently whether you reach for it as a skill or an agent — either way, the actual search runs in the `superpowers:org-roam` subagent, which has isolated context and the full database schema.

## What to do

Dispatch the `superpowers:org-roam` agent via the `Agent` tool with `subagent_type: "superpowers:org-roam"`. Pass it the user's query and any relevant context about what they're looking for.

```
Agent(
  subagent_type: "superpowers:org-roam",
  description: "Search org-roam notes",
  prompt: "Search the user's org-roam knowledge base for <topic>. <Any context about why / what to return>."
)
```

The agent searches both the SQLite database (`~/.config/emacs/.local/cache/org-roam.db`) and the org files (`~/Documents/org/org-roam/`), follows backlinks when warranted, and returns a concise digest of relevant notes. Relay its summary to the user.

## Do not

- Do **not** query the org-roam database or grep the org files yourself — dispatch the agent so the search stays in isolated context and your session context is preserved for coordination.
- Do **not** try to invoke org-roam via the `Skill` tool for the actual search — this skill only points you to the agent.
