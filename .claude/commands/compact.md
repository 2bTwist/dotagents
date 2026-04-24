---
description: Mid-session intentional compaction. Write current state to a handoff file so work can resume in a fresh session with clean context.
---

# Compact to Handoff

You are tasked with writing a handoff document so another agent (or future-you in a new session) can pick up this work. The document must be thorough but **concise**. Compact the session context without losing any of the key details of what you're working on.

## When to use
- Context window is filling up and quality is degrading
- You need to start a fresh session but want zero-loss continuity
- You're about to hit a hard debugging pivot and want a checkpoint

## Process

### 1. Filepath & Metadata

Determine the path: `specs/handoffs/YYYY-MM-DD_HHMM-<kebab-description>.md`
- YYYY-MM-DD is today's date
- HHMM is 24-hour time (e.g. `1355` for 1:55 pm)
- description is a brief kebab-case summary

Create the directory: `mkdir -p specs/handoffs`

Gather metadata in parallel:
```bash
git rev-parse --short HEAD
git branch --show-current
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
date -u +"%Y-%m-%dT%H:%M:%SZ"
date +%Y-%m-%d
```

### 2. Write the handoff

Use the defined filepath and this YAML frontmatter plus template:

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
<Description of the task(s) you were working on, with status (completed / in progress / planned). If working from an implementation plan, call out which phase you're on. Reference the plan or research doc you were working from.>

## Critical References
<Up to 3 most important files or docs that must be consulted: plan paths, research paths, architectural decisions. Leave blank if none.>

## Recent changes
<Describe recent changes you made in `file:line` syntax. Avoid large code blocks — use references.>

## Learnings
<Important things you learned: patterns, root causes of bugs, gotchas, hidden constraints. Include explicit file paths.>

## Artifacts
<Exhaustive list of artifacts you produced or updated (filepaths, `file:line` references). Anything the next agent needs to read to resume.>

## Action Items & Next Steps
<Concrete list of next steps for the next agent, in priority order.>

## Other Notes
<Anything else worth passing on that doesn't fit above: related code areas, environmental quirks, blockers you considered.>
```

### 3. Report

After writing, respond to the user with:

```
Handoff created at: `specs/handoffs/<filename>.md`

To resume in a new session, start the new session and point it at the file:
"Read specs/handoffs/<filename>.md and continue from the Next Steps."
```

## Guidelines

- **More information, not less.** This template is a minimum, not a ceiling. Include more if needed.
- **Be thorough and precise.** Include top-level objectives AND lower-level details.
- **Avoid excessive code snippets.** Brief snippets for key changes are fine, but prefer `/path/to/file.ext:line` references that the next agent can follow when ready. Example: `app/(auth)/sign-in.tsx:12-24`.
- **State of mind matters.** If you have a hypothesis you were testing, or a failed approach you ruled out, write it down. Saves the next agent from repeating the dead end.
