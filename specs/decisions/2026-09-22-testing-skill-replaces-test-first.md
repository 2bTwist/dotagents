# Testing skill replaces the test-first rule

Date: 2026-09-22
Status: implemented 2026-09-22
Supersedes: decision 5 of `2026-09-02-testing-and-comment-instructions.md`

## Why

The only testing guidance loaded for ordinary work was a red-first ritual: the `core.md` bullet
("confirm new tests fail… keep them frozen while making them pass"), the `tdd` skill in both
harnesses, and red/green wording in the test-freeze hook and diagnosing-bugs. It taught models
to prove the line they just wrote. The substantive material (Hipp's seams, fault injection and
layered oracles; the Cogito case grid and principles) sat in `high-risk-engineering.md` and one
repository, where ordinary work never loads it. The owner rejects test-first development
outright: build the thing, then test it hard, with few sharp tests and a mode suited to the
domain.

## Decisions

1. **A model-invoked `testing` skill** carries the method. It triggers at the start of
   non-trivial work (claims, a case grid with an expected observation per cell, seams) and after
   it is built (attack the grid, a separate attacker, few durable tests), on defect fixes, and
   when judging a suite.
2. **The `core.md` bullet points to the skill** before and after building, keeps a separate
   agent that did not write the code attacking it from the requirement, and forbids editing a
   test to make it pass.
3. **The separate attacker applies to all non-trivial work**, as decision 5 had it, now as an
   attacker of the built code rather than a test-first author. The owner chose this over
   scoping it to user-visible, durable-state, or high-risk changes, accepting the cost: driving
   a built UI on a simulator costs more than the single test-authoring dispatch decision 5
   priced, and "non-trivial" stays a judgment call bounded by the skill's skip clause.
4. **The `tdd` skills are archived**, not deleted, to `~/.claude/skills-archive/tdd` and
   `~/.codex/skills-archive/tdd`.
5. **The test-freeze hook keeps its protection** with the red/green framing removed. It now
   also blocks `rm`, `unlink`, and `git rm` on test paths, because an adversarial audit showed
   deletion was an unguarded route around the freeze, and its block message proposes a new test
   to the user instead of inviting one.
6. **Test volume is judged by distinct reach**, in both the skill and
   `high-risk-engineering.md`: large suites are fine when each test reaches a failure the others
   cannot; near-duplicates are bloat.
7. **Live reproduction applies to defects only**, kept on demand behind a flag and re-checked
   when the fix's mechanism moves. Features get the grid, never a before-and-after check.

## Not adopted

- Scoping the attacker to risky surfaces (see 3).
- Requiring coverage targets. Coverage is used to find missed cells, never as a goal.

## Evidence

An adversarial audit by a separate agent found 18 defects in the first draft of the skill,
including autonomous test deletion, cells without expected outcomes, loading only after the
build, no stopping rule for the grid, and misquoting Hipp on test builds and volume. All were
addressed in the revision.
