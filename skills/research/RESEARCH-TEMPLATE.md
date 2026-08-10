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

## Web variant (external research)

Same metadata block (omit `git_commit`/`branch`/`repository` when not repo-bound; tag `[research, web, ...]`). Structure:

```markdown
# Research: <Question/Topic>

## Research Question
<Original user query.>

## Summary
<The answer. Load-bearing claims labeled [established]/[inferred]/[speculated].>

## Detailed Findings

### [Sub-question/Area]
- Finding, with label and source URL
- Methodology caveat in one clause where a number appears

## Sources
| Source | Publisher/Origin | Date | Tier | Cite-checked |
|---|---|---|---|---|
| <URL> | <who, and the true origin if syndicated> | <date> | primary/secondary/search-ranked | yes/no/n-a |

## Not Found / Unverified
<What was searched for and not found; claims left [inferred] and why.>

## Open Questions
<Including anything recommended for /rigor escalation.>
```
