---
name: oneshot
description: Direct execution for small, contained, low-risk tasks (rename, color change, one-line fix) — skip full Research→Plan→Implement, with safety checks.
---

# One-shot

The escape hatch for changes too small for Research → Plan → Implement: renames, visual tweaks (color, spacing, font size), one-line fixes with an obvious cause, copy/config changes, a missing import/type/prop. Contained, obvious, low-risk.

**Escalate to `/plan`** the moment it isn't: new features, changes touching multiple concerns, unclear root cause (use `/research` first), anything that cascades (shared utilities, widely-consumed types), or any "while I'm here" temptation.

## Execution style

Execute immediately — no preamble, start with the first grep/read/edit. Pause only if a bail-out condition trips.

## Steps

1. **Locate.** Grep/Glob/LS to the exact file(s). If the target isn't obvious within a few searches, STOP — not one-shot material; offer `/research` or `/plan`.
2. **Read fully** (no `limit`/`offset`) the target and any close neighbour (import, type definition).
3. **Safety check before editing.** Grep the symbol for other affected sites; check for tests pinning the behaviour; check for a hidden invariant. If any answer surprises you, STOP → `/plan`.
4. **Edit.** Minimal diff. No unrelated cleanup, no drive-by refactor.
5. **Verify.** Run the smallest relevant check (type check / lint / targeted test, or the project's single check command). If the fix turns non-obvious, STOP → `/plan`.
6. **Report.** What changed (`file:line`), what you verified, and anything you noticed but deliberately left untouched.

## Guardrails

- **No scope creep** — editing a third file means escalate.
- **No half-measures** — if it can't be done cleanly in one shot, escalate; don't ship a partial fix.
- **No commits without asking.**
