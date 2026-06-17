---
name: compact
description: Mid-session intentional compaction — write current state to a handoff file so work resumes in a fresh session with zero loss.
---

# Compact to handoff

Write a handoff doc so a fresh session (or future-you) resumes with zero loss. Thorough but concise — compact the context without dropping the key details.

## Execution style

Execute immediately — gather metadata, write the file, report. No preamble.

## Steps

1. **Path + metadata.** `specs/handoffs/YYYY-MM-DD_HHMM-<kebab-slug>.md` (HHMM 24-hour; `mkdir -p specs/handoffs`). Gather metadata via the commands in `HANDOFF-TEMPLATE.md`.
2. **Write** the handoff using the frontmatter + structure in [`HANDOFF-TEMPLATE.md`](HANDOFF-TEMPLATE.md).
3. **Report** the path and the resume line:
   ```
   Handoff created at: specs/handoffs/<file>.md
   Resume in a new session with:
   "Read specs/handoffs/<file>.md and continue from Next Steps."
   ```

## What makes a handoff resumable

- Prefer `file:line` references over pasted code blocks.
- Capture **state of mind**: the hypothesis you were testing, the approach you ruled out — so the next agent doesn't repeat a dead end.
- The template is a floor, not a ceiling — add more when it helps.
