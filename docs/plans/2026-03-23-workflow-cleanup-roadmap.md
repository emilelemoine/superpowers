# Workflow Cleanup — Roadmap

> **For agentic workers:** REQUIRED: Use superpowers:executing-plans to implement each step below.

**Goal:** Reduce redundancy, clarify roles, fix confusing handoffs, and clean personality-specific content across the superpowers plugin's workflow skills and agents.

**Architecture:** Sequential cleanup across 15 files — consolidating review layers, deduplicating plan-writing content, fixing execution handoffs, and normalizing phrasing. All changes are to markdown skill/agent definitions.

**Tech Stack:** Markdown (Claude Code plugin skill files)

**Design doc:** `docs/specs/2026-03-23-workflow-cleanup-design.md`

---

## DAG

Step 1: Review consolidation and plan deduplication  [sequential]
Step 2: Execution fixes, phrasing cleanup, deprecation removal  [sequential, depends: 1]

## Steps

| Step | File | Purpose | Commits |
|------|------|---------|---------|
| 1 | `2026-03-23-workflow-cleanup-step-01.md` | Delete code-reviewer, rewrite requesting-code-review, make refactor review optional, strip writing-plans, update code-planner, update CLAUDE.md | 6 |
| 2 | `2026-03-23-workflow-cleanup-step-02.md` | Add parallel steps guidance, fix worktree handoff, fix spec path, consolidate cleanup docs, delete deprecated commands, tone down phrasing | 8 |
