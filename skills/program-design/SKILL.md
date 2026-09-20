---
name: program-design
description: |
  Settle program design before implementation: types and signatures for the touched surface, the call path of the main flow, state ownership, the seams tests will use, and the shapes ruled out. Writes specs/design/YYYY-MM-DD-<slug>.md for `implement` to build from.
  TRIGGER: settled intent that spans more than one module, or introduces a state machine, protocol, persistence shape, or public interface; a phase whose review would otherwise be the first time anyone sees its structure.
  SKIP: contained work (`oneshot`), work whose structure already exists and is only extended, or mapping and debugging (`research`).
model: opus
---

# Program design

Architecture says which parts exist. Program design says what they look like from the call
site: the types, the signatures, the path a request takes, and where a test gets in. It is
the layer that decides whether the diff is a joy or a burden to read, and a model will
otherwise settle it silently while writing the code.

## Execution style

Execute immediately: read the settled intent, then the code it lands in. Ask only where the
design would differ by more than a rename. Pause once, at the end, for approval.

## Steps

1. **Read the intent and the ground.** The decision record, plan, or the user's ask, fully,
   then every file the change lands in. Names, existing conventions and current shapes are
   evidence; match them rather than inventing a parallel vocabulary.
2. **Draw the surface.** Name each module the change touches and the boundary between them.
   For each boundary, state what crosses it and what stays inside.
3. **Write the signatures.** Types, function and method signatures, error shapes, and the
   owner of every piece of state the change reads or writes. Enough that a reader can call
   the code before it exists. Where a stored invariant appears, load
   your high-risk-engineering reference and put the guarantee at the lowest layer that can
   enforce it.
4. **Trace the call path.** The main flow end to end, hop by hop, and one failure path:
   what fails, who notices, what the user sees, what is left behind.
5. **Name the seams.** What a test substitutes (clock, transport, storage, permission,
   device) and which seams ship as part of the deliverable.
6. **Name what is out.** Each shape considered and rejected, one line with its cost. This is
   what stops the same ground being re-litigated mid-build.
7. **Write it down and put it up.** `specs/design/YYYY-MM-DD-<slug>.md`, or where the repo
   keeps such docs; ask when there is no convention. Then show the signatures and the call
   path in chat and wait for approval.

Done when every entry point of the touched surface has a signature, the main flow's call path
names each hop, every seam names what substitutes it, the rejected shapes are recorded, and
the user has approved. Then hand to `implement`, which builds from the file.

## Keep it a design, not a draft

Signatures and call paths, not bodies. When a body is the only way to settle a question,
write the smallest one that answers it and mark it as a sketch. A design that grows into an
implementation loses the property that makes it worth reading: it fits in one sitting.
