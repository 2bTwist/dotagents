# Reviewable change

Load this when sizing a change for review, naming what a person must read, or checking a
diff you authored before asking anyone to read it.

The premise: a model can pass the checks without holding the design. Nothing in its
training rewards a codebase that stays workable, so the reviewable unit and the read set
are the controls that keep a human in the loop where it matters.

## Size the unit

Count added lines of code a reviewer must reason about. Exclude tests, lockfiles, generated
output, vendored code and docs. Past roughly 800, split.

Split along a seam that already exists, in this order of preference:

1. **By layer.** Data access, then the logic above it, then the surface. Each lands working.
2. **By capability.** One user-visible behaviour per unit, with its own tests.
3. **By risk.** Isolate the migration, the money path, or the protocol change so the
   reviewer's attention is not spent on the rest.

A stack of dependent units costs rebasing when the parent merges, and a squash-merged parent
forces `rebase --onto`. Budget that cost once, rather than paying it in unread diffs.

When the change cannot split, because a contract and its only caller move together, say so
in one line and name the part that carries the risk.

## Name the read set

Name the few files that need line-by-line human reading, by risk class:

money, identity, durable state and its migrations, concurrency and ordering, external
effects, trust and security boundaries, anything whose failure is silent.

Everything else is read at the reviewer's discretion. State what was driven, what was not,
and who read what. Never imply review coverage that did not happen: an unread file reported
as reviewed is worse than an unread file.

## Check your own diff first

The cheapest path for a model is the one that makes the check pass. Read the diff for work
shaped by that pressure, in any language:

- a failure caught and dropped, or a fallback that hides the error the caller needed;
- a branch, flag, or environment check that exists so a test can run;
- a type widened, a check disabled, or an assertion loosened to accommodate a call site;
- a guard added without a case that reaches it;
- state duplicated because the existing owner was awkward to reach.

Each one is either a defect to fix or a missing seam to add. Fix it, or say why it stands.
A test that cannot reach the code is a design result, not a testing problem.

## What the reviewer is told

State, in the PR or the handoff: what changed and why, the unit's boundary and why it splits
there, the read set, the checks that ran, the legs that were not driven, and every decision
whose reversal would be expensive.
