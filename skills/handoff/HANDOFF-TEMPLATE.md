# Handoff document template

## Gather metadata first

Run in parallel, use the real output:

```bash
git rev-parse --short HEAD
git branch --show-current
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
date -u +"%Y-%m-%dT%H:%M:%SZ"
date +%Y-%m-%d
```

Path: `specs/handoffs/YYYY-MM-DD_HHMM-<kebab-slug>.md` (HHMM 24-hour, e.g. `1355`).

## Structure

```markdown
---
date: <ISO timestamp>
git_commit: <short SHA>
branch: <branch name>
repository: <repo name>
topic: "<concise task description>"
tags: [handoff, <relevant-component-names>]
status: in-progress
last_updated: <YYYY-MM-DD>
type: handoff
---

# Handoff: <concise description>

## Task(s)
<The task(s), each marked completed / in progress / planned. If working from a plan, name the phase and link the plan/research doc.>

## Critical References
<Up to 3 must-read files or docs: plan/research paths, key decisions. Blank if none.>

## Recent changes
<Recent changes in `file:line` syntax. References over code blocks.>

## Learnings
<Patterns, root causes, gotchas, hidden constraints — with file paths.>

## Artifacts
<Every artifact produced/updated (paths, `file:line`) the next agent must read to resume.>

## Action Items & Next Steps
<Concrete next steps, priority order.>

## Other Notes
<Related code areas, environment quirks, blockers considered.>
```
