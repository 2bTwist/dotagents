---
name: implement
description: Execute settled work phase by phase from either a decision record (specs/decisions/, the usual case after a grill) or a plan (specs/plans/), dispatching a phase's independent parts in parallel, ticking checkboxes and pausing for manual verification between phases.
disable-model-invocation: true
harness:
  degrades: [subagents]
---

# Implement

Execute settled work one phase at a time. The source is a **decision record** (`specs/decisions/`, what a finished grill produces and the usual case) or a **plan** (`specs/plans/`), or wherever the user points. It is your guide; reality can differ — follow its **intent**, adapt to what you find, surface mismatches.

## Execution style

Execute immediately — don't announce, start by reading the source document. Pause only between phases (manual verification) or on a mismatch.

## Start

Given a path (ask for one if absent):
- Read it FULLY and note existing `- [x]` checkmarks. Read the ticket and every file it references, fully (no `limit`/`offset`).
- **If it is a decision record, derive the phases yourself before writing any code.** A decision record settles *what* and *why*; it rarely states *in what order* or *checked how*. Build that from it and put it to the user for approval in one message, then proceed on their confirmation:
  - **Phases**, ordered by the record's own sequencing where it states one, and otherwise so that each phase leaves the tree working.
  - **The exact command that gates each phase.** Take it from the repository contract, not from habit. Where a repo separates gates that may read sensitive or operational material from those that may not, name which tier each command is in, and never schedule a gate the user has not authorized: say so and stop instead.
  - **Manual verification items** per phase, meaning whatever only the user can confirm.
  - Anything the record explicitly left undecided, listed as out of scope rather than resolved by you.
  Derivation is inference, not instruction. Where the record is silent on something that changes what you would build, ask rather than pick.
- Build a todo list from the phases, using the harness's task-tracking tool if it has one.
- If it already has checkmarks, treat them as claims, not evidence. Verify each against the current tree before resuming from the first unchecked item; a box you (or a past session) ticked is exactly the check author bias would have gotten wrong.

## Per phase

1. **Split the phase, or decide not to.** Most phases are one coherent change: build it yourself. When a phase holds parts that touch disjoint file sets and do not depend on each other, dispatch them concurrently. A long serial build is what needs justifying, not the parallelism. A numbered phase list is a decomposition, not a schedule. Mechanics, including the dispatch record and the integration gate: [`DISPATCH.md`](DISPATCH.md).
2. Implement the parts you kept. If the source names an installed skill for this phase's task class, **invoke it** rather than reinventing the approach.
3. Run the phase's automated success criteria (the exact commands the source specifies, or the ones you derived and the user approved). Fix every failure before moving on.
4. Check off completed items in your todos, and in the source document when it carries checkboxes. Never add checkboxes to a decision record: it is a record of what was decided, not a worksheet.
5. **Pause for manual verification** — tell the human the phase is ready:
   ```
   Phase [N] Complete — Ready for Manual Verification
   Automated checks passed: [list]
   Please verify manually: [this phase's manual items]
   Tell me when done so I can start Phase [N+1].
   ```
   Don't check off manual items until the user confirms. If told to run phases consecutively, pause only after the last.

## On a mismatch

STOP — the codebase may have evolved since the document was written. Present it plainly — **Expected** (the document) / **Found** (reality) / **Why it matters** — and ask how to proceed. Don't paper over it.

Done when every phase's automated criteria pass, its manual items are user-confirmed, and nothing reached the user that you did not verify yourself.
