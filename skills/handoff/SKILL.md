---
name: handoff
description: Write the session's state to a handoff file in specs/handoffs/ so a fresh session resumes where this one stopped. Use only when the user explicitly asks to compact, hand off, or wrap up for a clean restart.
---

# Compact to handoff

Write a handoff doc so a fresh session resumes where this one stopped. The handoff replaces the context, so treat everything not written down as lost — that is the bar, and it is why this is legwork rather than a summary.

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

## Done when

Every one of these holds. An unwritten item is a dead end the next session will walk into again.

- [ ] Every task the session was mid-way through appears under **Task(s)**, with its current state, not just its name.
- [ ] Every file this session edited appears under **Recent changes**, and every uncommitted change is named as uncommitted.
- [ ] Every approach ruled out appears under **Learnings** with the reason it was ruled out.
- [ ] Every open question the session was blocked on appears under **Action Items**, addressed to whoever answers it.
- [ ] Every path in the doc resolves — check them, do not recall them.
