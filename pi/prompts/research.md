---
description: Map how a feature/area of the codebase works today. Writes to specs/research/YYYY-MM-DD-<slug>.md
argument-hint: "<question or topic>"
---

# Research: $@

You are documenting how this area of the codebase works. Produce a research document, not an opinion piece.

## Hard rules

- Document what IS, not what SHOULD BE.
- No recommendations, no critique, no "should", no "could be improved".
- Read files FULLY (never partial). Small models drift when they skim.
- Use file:line references for every claim.
- If the user mentioned specific files, read them FIRST, in full, before doing anything else.

## Steps

### 1. Read any mentioned files
If the user referenced specific files, tickets, or commits in the prompt above, read them completely now using `read` or `bash`. Do not skim.

### 2. Locate (sequential skills)
Invoke `/skill:codebase-locator` with a specific question about where the relevant files live. Wait for its output. Do not load analyzer until locator has finished.

### 3. Analyze
Invoke `/skill:codebase-analyzer` with a specific question about how the located files work together. Use the file list from step 2 as input. Trace data flow with file:line references.

### 4. Find patterns (optional)
If the research involves comparing to existing patterns, invoke `/skill:codebase-pattern-finder`. Skip this step if not needed.

### 5. Gather metadata
Run these in one bash call:
```bash
mkdir -p specs/research
echo "commit=$(git rev-parse --short HEAD 2>/dev/null || echo none)"
echo "branch=$(git branch --show-current 2>/dev/null || echo none)"
echo "repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"
echo "date=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

### 6. Write the research doc
Pick a kebab-case slug describing the topic. Write to `specs/research/YYYY-MM-DD-<slug>.md` using this structure:

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
<3-5 sentence high-level answer. What exists, in plain language.>

## Detailed Findings

### <Component 1>
- <What exists> (`file.ext:line`)
- <How it connects to other pieces>

### <Component 2>
...

## Code References
- `path/to/file.ts:123` — <what's there>
- `another/file.ts:45-67` — <what's there>

## Open Questions
<Anything the research couldn't pin down.>
```

### 7. Report
Tell the user where the doc was written. Give a 3-bullet summary of the key findings. Offer to kick off `/plan` next.

## If you get stuck

If a skill invocation fails or returns nothing useful, fall back to direct `bash`, `grep`, `find`, `read` tool use. Don't abandon the research.

If the codebase is too large to map in one pass, narrow the question and tell the user. "I can map the auth flow OR the session refresh logic, but not both in one pass — which do you want first?" is a valid response.

## Anti-patterns

- Dumping entire file contents into the doc (use file:line references instead)
- Writing recommendations, suggestions, or critique
- Saying "this should" or "this could" — the user will delete those sections
- Skipping the skills and writing the doc from guesses
