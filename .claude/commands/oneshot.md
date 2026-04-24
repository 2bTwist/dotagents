---
description: Direct execution for small tasks (rename, color change, one-line fix, small tweak). Skip full RPI. Still does basic safety checks.
---

# One-Shot

You are tasked with executing a small, focused task directly. This is the escape hatch for changes that don't warrant full Research → Plan → Implement. Use it when the task is contained, obvious, and low-risk.

## When to use

- Renames (variable, function, file)
- Simple visual tweaks (color, spacing, font size)
- One-line bug fixes where the root cause is obvious
- Small copy/text updates
- Trivial config changes
- Adding a missing import, type, or prop

## When NOT to use

- New features → use `/plan`
- Changes that touch multiple concerns → use `/plan`
- Bugs where the root cause is unclear → use `/research` first
- Anything that might cascade (shared utility changes, type changes visible to many consumers) → use `/plan`
- Anything where you're tempted to add "while I'm here" scope → use `/plan`

## Process

### 1. Locate the target
- Use Grep/Glob/LS to find the exact file(s) to change.
- If the target isn't obvious within a few searches, STOP. The task isn't one-shot material. Tell the user and offer `/research` or `/plan`.

### 2. Read fully
- Read the target file(s) COMPLETELY (no `limit`/`offset`).
- Read any closely-related file if the change has a neighbor (e.g. import, type definition).

### 3. Safety checks before editing
Ask yourself:
- Does this change affect anything else? `Grep` for the symbol being renamed/changed.
- Are there tests that pin this behavior? If yes, will the change break them?
- Is there a hidden invariant this change might violate?

If any of those answers surprise you, STOP. Switch to `/plan`.

### 4. Make the edit
- Use Edit or Write for the change.
- Keep the diff minimal. No unrelated cleanup. No drive-by refactors. No "while I'm here."

### 5. Verify
- Run the smallest relevant check: type check, lint, or targeted test.
- If the project has a single command (e.g. `pnpm check`), run it.
- If it fails, debug and fix. If the fix is non-obvious, STOP and switch to `/plan`.

### 6. Report
Tell the user:
- What changed (`file.ext:line`)
- What you verified (`pnpm typecheck` passed, etc.)
- Anything you noticed but deliberately did NOT touch (preserves trust; shows you saw it but respected scope)

## Guardrails

- **No scope creep.** If you find yourself editing a third file, stop and escalate to `/plan`.
- **No half-measures.** If the task can't be done cleanly in one shot, escalate. Don't ship a partial fix.
- **No commits without asking.** Make the change. Let the user decide when to commit.
- **Still read fully.** Even one-shot edits benefit from full file context. No partial reads.
