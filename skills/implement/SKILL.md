---
name: implement
description: Execute an approved plan from specs/plans/ one phase at a time, ticking checkboxes and pausing for manual verification between phases.
disable-model-invocation: true
---

# Implement

Execute an approved plan (`specs/plans/`, or wherever the user points) one phase at a time. The plan is your guide; reality can differ — follow its **intent**, adapt to what you find, surface mismatches.

## Execution style

Execute immediately — don't announce, start by reading the plan. Pause only between phases (manual verification) or on a mismatch.

## Start

Given a plan path (ask for one if absent):
- Read the plan FULLY and note existing `- [x]` checkmarks. Read the ticket and every file the plan references, fully (no `limit`/`offset`).
- Build a todo list from the phases, using the harness's task-tracking tool if it has one.
- If the plan already has checkmarks, treat them as claims, not evidence. Verify each against the current tree before resuming from the first unchecked item; a box you (or a past session) ticked is exactly the check author bias would have gotten wrong.

## Per phase

1. Implement the whole phase. If the plan's References name an installed skill for this phase's task class, **invoke it** rather than reinventing the approach.
2. Run the phase's automated success criteria (the plan specifies the exact commands). Fix every failure before moving on.
3. Check off completed items in the plan file (Edit) and in your todos.
4. **Pause for manual verification** — tell the human the phase is ready:
   ```
   Phase [N] Complete — Ready for Manual Verification
   Automated checks passed: [list]
   Please verify manually: [the plan's manual items]
   Tell me when done so I can start Phase [N+1].
   ```
   Don't check off manual items until the user confirms. If told to run phases consecutively, pause only after the last.

## On a mismatch

STOP — the codebase may have evolved since the plan was written. Present it plainly — **Expected** (plan) / **Found** (reality) / **Why it matters** — and ask how to proceed. Don't paper over it.

Done when every phase's automated criteria pass and its manual items are user-confirmed.
