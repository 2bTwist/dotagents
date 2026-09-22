---
name: testing
description: Test a change across the surfaces it touches, not only the path just written. Use when starting non-trivial implementation (claims, case grid, seams), when that work is built (attack the grid, keep few durable tests), when fixing a reported defect, and when judging an existing suite. Skip for one-line fixes with an obvious cause, copy or colour changes, and renames.
---

# Testing

**Tests verify the claims you thought to make, and defects live in the claims you did not.** An agent that builds a feature and then tests it restates what it built: the checks pass by construction. The defects sit in the neighbouring cells: the gesture that shares this one's timing window, the item another feature is holding, the surface drawn on top, the reload halfway through. This skill moves attention to those cells, and keeps every check able to say "no".

## Before building

1. **Write the claims.** What a person should observe when it works, and what must stay true when it fails: nothing lost, nothing duplicated, nothing stuck.
2. **Draft the case grid** (below), with the expected observation in every cell. A cell nobody can answer is a design question: ask the user, never guess.
3. **Design the seams.** Make the clock, filesystem, allocator, transport, and failure points substitutable so every error path can actually run, and plan test hooks that ship in the real build. Seams cannot be cheaply retrofitted.
4. **Prefer removing a cell to testing it.** Where a bad state can be made unrepresentable by a type, constraint, or state machine, do that.

Done when the claims are written, every grid cell has an expected observation or a question to the user, and the seams the grid needs are in the design.

## After building

Build and make it work first, driving it by hand or script as you go. Durable tests written while the code is still changing shape pin a draft.

1. **Attack the grid** on the real path, with the mode each domain needs (table below).
2. **Dispatch a separate attacker** for non-trivial work: an agent that did not write the code, given the grid with expected observations and a brief to take wrong turns. It runs against the built code in the shared tree or on committed HEAD (a fresh worktree branches from the default branch and sees the old code), attacks, and reports every cell it entered and what it tried. It dispatches no attacker of its own. The author writes the durable tests from its findings.
3. **Keep what earns a place** (below), few and sharp.
4. **Report** (below).

Done when every cell in the grid is driven, ruled impossible by construction, or listed as not driven with a reason, and the attacker's report is in.

## The case grid

Rows are the **states** the changed code reads or writes, plus the states of any surface that can overlap it. Columns are the **inputs** that can actually reach it. Merge cells that must behave identically. The scoped grid, finished, is the stopping rule.

- **States to consider:** nothing, one, many, far too many; mid-gesture, mid-animation, mid-request, editing, selected; undo showing; a write refused; an asset missing; offline; first run, after upgrade, after a crash; large text and accessibility layouts.
- **Inputs from the user:** the intended one and every neighbour sharing its input: tap and double-tap share a timing window, swipe and scroll share a direction. Include the system's own controls: keyboard return key, back swipe, tab bar, system sheets.
- **Inputs from elsewhere in the product:** another feature deletes, moves, or edits the item this one holds; a menu, sheet, or keyboard is open over this surface when it closes or resizes.
- **Outside events:** reload, background and resume, process kill, rotation, permission revoked, clock change, network drop, a second device or tab writing the same record.

A defect is a hole in the grid, and holes have neighbours: when deleting a selected item breaks, check archiving, moving, and editing it from another device.

## Mode by domain

Use the mode that can see the failure.

| Surface | What fails there | Mode that sees it |
| --- | --- | --- |
| UI and interaction | gesture overlap, layering, focus, state after dismissal, reload mid-flow | drive the real app on the path a person takes (simulator, device, browser automation); make gesture arbitration explicit in code, then drive timed events deterministically (press durations, tap counts) rather than judging a video; assert what a person would notice |
| Pure logic | edge values, invariants over all inputs | property-based tests; each property states an invariant independent of the implementation, never a restatement of it |
| Parsers, decoders, untrusted input | inputs nobody imagined | fuzzing, seeded with real inputs |
| Anything with a second implementation or a reversible form | wrong answers that neither crash nor assert | differential (against a reference, the old version, a naive implementation) and metamorphic (round trip; the same query asked two equivalent ways) |
| API and backend | contract drift, auth edges, idempotency, partial failure | real requests against a real server and store; send the same request twice; kill a dependency mid-call |
| Database and migrations | data loss, constraint gaps, migrations that only work on empty tables | a real engine with production-shaped data; migrate a copy forward; confirm constraints reject what the code assumes never happens |
| Durable state and crash safety | torn writes, lost acknowledged writes, failed recovery | fault injection through the seams: fail the write, fail the fsync, kill between steps, loop the injection point forward; reopen and check invariants |
| Concurrency and sync | lost updates, ordering, duplicate delivery | two writers on one record; deliver out of order and twice; interleave deterministically where the runtime allows |
| Performance, memory, frames | regressions no single call shows | repeated measurement against a baseline |

Test the deliverable as well as the source: a check that only passes in a special test build is not checking what ships.

## Attack, not confirm

- **Drive wrong turns:** cancel halfway, go back, do it twice, do it fast, do it while something else is open.
- **Settle, then read.** Assert only once the state is stable (animation done, request resolved, write committed).
- **Predict, then run.** Write the expected result before running; an unpredicted result, including a pass, is information.
- **Compare instead of thresholding.** When an assertion needs a magic constant, look for the comparison hiding behind it: old against new, with against without.
- **Use coverage to find cells**, never as a target: an untaken branch is a candidate cell you missed.
- **Distrust clean results.** Point the probe at a known-bad case to confirm it can fail.

## Fixing a reported defect

- Reproduce it on the real path, and keep a way to reproduce it on demand, behind a flag, as a lasting positive control. Re-check that it still reproduces whenever the fix's mechanism moves. This before-and-after check belongs to defects only; features get the grid.
- Treat your own fix as a hypothesis. Before adding a limit, fallback, or retry, look for the known solution to that class of problem; it is usually simpler.
- Check the defect's sibling cells in the grid.

## What earns a durable test

A durable test earns its place when all three hold:

1. It can fail, and failing means something a person would notice or data would be wrong.
2. It checks behaviour through an interface meant to stay stable.
3. Nothing stronger already covers it: a type, a constraint, a lint rule, another test.

Each test reaches a distinct failure the others cannot. One parameterized or property test covering forty cells is sharp; forty hand-written near-duplicates are bloat. Typical misses: checking that an asset or route exists, asserting a function returns what it currently returns, asserting a mock was called. The number of tests is never a result.

**Existing tests are evidence.** Never edit or delete one to make a change pass. When a test looks wrong or redundant, propose the change or deletion to the user with the reason, and let the user rule. Ask before adding the first test file to a repository that has no test policy, and propose new test files rather than adding them silently when the repository policy says so.

## Running

- While iterating, run only the tests that exercise the change; they should finish in about five minutes, or the selection is wrong.
- The full suite runs at merge, in the background, and never holds work. A test that fails in the full run and passes alone is a suite defect: file and fix it, never rerun until it passes.
- A repository test policy overrides this section.

## Report

- **Driven:** cells exercised, with mode and evidence (command, recording, measurement), and expected against observed.
- **Impossible by construction:** cells ruled out, and what rules them out.
- **Not driven:** open cells, with the reason and the risk.
- **Attacker:** what it tried, what it found, what was fixed or ruled on.
- **Durable tests:** added, and proposed changes or deletions awaiting the user.
