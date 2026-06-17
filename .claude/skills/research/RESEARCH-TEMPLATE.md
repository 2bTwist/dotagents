# Research document template

## Gather metadata first

Run in parallel and use the real output — no placeholders:

```bash
git rev-parse --short HEAD
git branch --show-current
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
date -u +"%Y-%m-%dT%H:%M:%SZ"
date +%Y-%m-%d
```

Filename: `specs/research/YYYY-MM-DD-<kebab-slug>.md` (today's date + a brief topic slug).

## Structure

```markdown
---
date: <ISO timestamp>
git_commit: <short SHA>
branch: <branch name>
repository: <repo name>
topic: "<the question / topic>"
tags: [research, codebase, <relevant-component-names>]
status: complete
last_updated: <YYYY-MM-DD>
---

# Research: <Question/Topic>

**Date**: <ISO timestamp> · **Commit**: <short SHA> · **Branch**: <branch> · **Repo**: <repo>

## Research Question
<Original user query.>

## Summary
<What was found, answering the question by describing what exists. No recommendations.>

## Detailed Findings

### [Component/Area]
- What exists (`file.ext:line`)
- How it connects to other components
- Implementation details (without evaluation)

## Code References
- `path/to/file.ts:123` — what's there
- `another/file.ts:45-67` — what that block does

## Architecture Documentation
<Current patterns, conventions, design as found in the codebase.>

## Open Questions
<Areas needing further investigation.>
```
