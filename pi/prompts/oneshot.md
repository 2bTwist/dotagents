---
description: Small task escape hatch. Skip full research/plan/implement. Rename, one-line fix, small tweak.
argument-hint: "<task>"
---

# One-shot: $@

You are executing a small, focused task directly. No research phase. No plan phase. Just do it carefully and stay in scope.

## When this prompt is appropriate

- Renames (variable, function, file)
- Simple visual tweaks (color, spacing, font size)
- One-line bug fixes where the cause is obvious
- Small copy/text changes
- Trivial config changes
- Missing import, type, or prop

## When to bail out

If any of these is true, STOP and tell the user to use `/plan` instead:

- The task touches more than 2 files
- The root cause of a bug isn't immediately obvious from reading one file
- The change might cascade (shared util, widely-imported type)
- You're tempted to add "while I'm here" scope
- The fix would benefit from a test plan

## Steps

### 1. Locate the target
Use `grep`, `find`, or `ls` to find the file(s). If the target isn't obvious within 2-3 searches, STOP. The task isn't one-shot material.

### 2. Read fully
Read the target file(s) completely. No partial reads.

### 3. Safety check
Before editing:
- `grep` for the symbol being renamed/changed to see who depends on it
- Look for tests that pin the behavior
- Note any invariant the change might violate

If anything surprises you, STOP and switch to `/plan`.

### 4. Make the minimal edit
Use `edit`. Keep the diff tight. No unrelated cleanup. No drive-by refactors.

### 5. Verify
Run the smallest relevant check — type check, lint, or targeted test. If it fails and the fix isn't obvious, STOP and escalate.

### 6. Report
Tell the user:
- What changed (`file.ext:line`)
- What you verified
- Anything you noticed but deliberately did NOT touch (shows respect for scope)

## Guardrails

- No scope creep. If you find yourself editing a third file, stop and escalate to `/plan`.
- No half-measures. If the task can't be done cleanly in one shot, escalate.
- No commits without asking. Make the change, let the user decide when to commit.
- Still read fully. Even one-shot edits benefit from full file context.
