---
description: Map how an area of the codebase works today. Writes to specs/research/YYYY-MM-DD-<slug>.md
argument-hint: "<question or topic>"
---

# Research Topic

> $@

Your task: produce a research document on the topic above. Document how it works today, with precise file:line references.

## Your tools
You have `read`, `write`, `edit`, `bash`, `grep`, `find`, `ls`. That is all. Do not invent other tools.

## Hard rules

- Document what IS, not what SHOULD BE. No recommendations, no critique, no "should", no "could be improved".
- Read files FULLY. Use `read` with a path. Do not pass line ranges.
- Use file:line references for every specific claim.
- If the user mentioned specific files, tickets, or commits, read them FIRST, completely, before anything else.

## Workflow (follow in order)

### Step 1: Read any mentioned inputs
If the user referenced files, commits, or tickets, read them fully now using `read` or `bash` (`git show <sha>`).

### Step 2: Locate relevant files
Use `grep`, `find`, and `ls` to find files related to the topic. Do NOT read file contents in this step — just build a list of paths grouped by purpose:

- Implementation (`*service*`, `*handler*`, `*store*`, core logic)
- Tests (`*test*`, `*spec*`, `__tests__`)
- Config (`*.config.*`, `*rc*`)
- Types (`*.d.ts`, `*.types.*`)

### Step 3: Analyze
Now `read` each relevant file fully. Trace how they work together. For each file note entry points, what it does, and how it connects to other files. Keep file:line references.

Rules for this step:
- Describe only. No quality evaluation. No suggestions. No critiques.
- If you find a pattern in use (factory, middleware chain, store update), name it with its file:line location.

### Step 4: Gather metadata
Run one bash call:

```bash
mkdir -p specs/research
git rev-parse --short HEAD 2>/dev/null || echo none
git branch --show-current 2>/dev/null || echo none
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
date -u +%Y-%m-%dT%H:%M:%SZ
```

### Step 5: Write the research doc
Pick a kebab-case slug describing the topic. Write to `specs/research/YYYY-MM-DD-<slug>.md` with this shape:

```markdown
---
date: <ISO timestamp>
git_commit: <short SHA>
branch: <branch>
repository: <repo name>
topic: "<user's question>"
status: complete
---

# Research: <topic>

## Summary
<3-5 sentence high-level answer in plain language.>

## Detailed Findings

### <Component/Area 1>
- <What exists> (`file.ext:line`)
- <How it connects to other pieces>

### <Component/Area 2>
...

## Code References
- `path/to/file.ts:123` — <what's there>
- `another/file.ts:45-67` — <what's there>

## Open Questions
<Anything the research couldn't pin down.>
```

### Step 6: Report
Tell the user where the doc was written. Give a 3-bullet summary of the key findings.

## Anti-patterns

- Dumping file contents into the research doc. Use file:line references instead.
- Writing "this should" or "this could". That's the plan phase's job, not research.
- Skipping reads and guessing. Read first, write second.
- Calling a tool that does not exist. Your tools are listed above — `read`, `write`, `edit`, `bash`, `grep`, `find`, `ls`. Nothing else.
- Trying to delegate to another agent. Pi has no parallel dispatch. You do the work in this one session.
