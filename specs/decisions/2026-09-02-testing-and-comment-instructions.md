# Testing, testability, and comment instructions

Date: 2026-09-02
Status: implemented 2026-09-02

## Source

Two talks, transcripts in session scratchpad:

- Richard Hipp, "Reliability Lessons From SQLite" (SSW 2026), https://youtu.be/V_qzqY1bb7I
- Ryan, "I'm banning AI from writing tests", https://youtu.be/d38hMDWouKg

## Framing correction made during the grill

The opening question was "should this go in AGENTS.md". That premise was wrong. There is
no hand-edited global AGENTS.md in this system. `instructions/core.md` is one canonical
document rendered by `install.sh:185` into a managed block in every harness file, so
harness-agnostic is satisfied by writing to `core.md` and nothing else.

The axis that actually mattered is different: harness-agnostic is not project-agnostic.
`core.md` loads for all 52 repos. "Test files are opt-in" is right for a greenfield product
surface and wrong for `yt2md`, whose own AGENTS.md mandates fixture-based validation and
whose value is a conformance suite.

A second framing correction: the apparent timing collision between the new rule and
`core.md:80-83` was largely illusory. That bullet already requires a separate agent to author
tests from the requirement rather than the implementation, which structurally prevents the
tautology Ryan complains about, and the freeze prevents his churn. Ryan's actual failure
(a test asserting `noise-light.png` returns 200) is a traceability failure, not a timing one.
That is DO-178B's first element, requirements tracking, which Hipp named and skipped.

## Decisions

1. **core.md growth policy: strict cap.** Only rules that change default behavior in a typical
   session earn a `core.md` line. Everything else goes to `references/`. Ruled out: absorbing
   all five proposals (~15% growth on a deliberately lean 9,371-byte doc, and three of five are
   phase-specific so they misfire on repos with existing suites); a new top-level Testing
   section (duplicates the existing "Verification and author bias" section, and two sections
   about testing drift apart).

2. **The test-scope rule goes to repo contracts, not core.md.** The right default genuinely
   differs between `yt2md` and a greenfield product, so it is a per-repo call.
   Ruled out: a global traceability rule; a global timing rule (loses the unconditional
   red-first property, and would not have stopped the PNG test anyway, only delayed it).

3. **Delivery: generalize `core.md:99-102`.** Broaden the repository-contract bullet so a
   contract must also define test policy: what earns a test, when it is written, and what is
   explicitly out of scope. Rides machinery already live in 23 of 52 repos.
   Accepted cost: that bullet is currently scoped to durable-state concerns and sits in
   Architecture decisions because state ownership warrants a halt. Adding test policy widens it
   toward a general repo-contract checklist. It also fires when a contract is authored, not when
   a test is about to be written, which is why decision 4 exists.

4. **Fallback for the 29 repos with no contract: ask once, then write it down.** Absent a repo
   test policy, ask before creating the first test file in a repo and record the answer in that
   repo's contract. Bootstraps the uncovered repos organically and forces the per-repo decision.
   Accepted cost: it interrupts, and it sets a precedent, since `core.md` currently has no
   ask-first rule of this shape outside destructive actions.
   Ruled out: a global traceability default (the same commitment already declined, re-entering
   through the back door); no fallback (leaves the observed failure legal in 29 of 52 repos).

5. **`core.md:80-83` survives unchanged, including the separate-author clause.** It is the only
   mechanism making tests independent of the implementation, and one dispatch is cheap next to
   a suite that asserts nothing. Hipp's skepticism is about test authorship being the harder
   artifact, not about author independence being wrong.
   Accepted cost: on smaller non-trivial work the dispatch overhead exceeds its value, and
   "non-trivial" remains undefined, so the agent decides when to spend it.
   Ruled out: narrowing to high-risk work (the tautology failure is most common in ordinary
   product work); dropping it.

6. **Design-for-testability: one clause in Architecture decisions.** Testability is an
   architecture property decided before implementation. Hipp restructured SQLite to get it:
   pluggable VFS, swappable allocator, a `sqlite3_test_control` API shipped in production builds.
   Accepted cost: every other rule in that section demands a stop-and-confirm halt; this one does
   not, so the section's meaning blurs slightly. Wording must not imply a halt.
   Ruled out: appending to the Verification section (an architecture-time rule read at
   verification time is read too late); reference-only (ordinary work never designs seams).

7. **Comment standard: new reference plus a trigger clause.** Standard is Hipp's: the comment
   should be a sufficient prompt to reproduce the code. Supporting idea: an assert is an
   executable comment, preferred over a comment wherever the claim is checkable. Trigger goes in
   the existing "read local references on demand" bullet at `core.md:39-41`.
   Accepted cost: that bullet is already a four-topic grab-bag; a fifth entry makes it a list
   the agent skims. Also this will visibly increase comment volume across repos and cuts against
   the self-documenting-code convention.
   Ruled out: a core.md line (fails the strict cap); folding into high-risk-engineering (comments
   are an every-file concern); an untriggered file (dead text).

8. **Deep procedure extends `references/high-risk-engineering.md`.** Into "Verify independently":
   injectable seams over mocks (substitute allocator, clock, filesystem, transport so real
   failure paths execute), test hooks shipped in the production artifact as acceptable cost,
   testing the deliverable and not only the source, layered oracles (coverage, then fuzzing,
   then semantic/differential fuzzing, then AI, each blind to what the next finds), and test-size
   budgets (test code larger than source is fine; 10-20% of shipped code existing only for
   testing is fine).
   Accepted cost: that file loads only for high-blast-radius work, so mid-risk code never sees it.
   Decision 6 partially mitigates this by promoting the single most time-sensitive item.

9. **Agent-proposed fixes: one line in high-risk-engineering.** Treat agent-found defects as high
   value and agent-proposed fixes as suspect; check for a known solution before accepting a
   workaround-shaped fix. Hipp's case: an AI found a real quicksort stack overflow and proposed a
   depth-limited fallback; the correct fix (recurse on the smaller partition, loop the larger) was
   published by Sedgewick decades earlier and was also faster.
   Accepted cost: the failure mode is not high-risk-specific, so filing it there misses the
   ordinary code where it occurs.

## Deliberately not adopted

- 100% MCDC coverage as a target. Not portable to this stack, and the maintenance burden Hipp
  describes (TH3 is 6.5x the size of SQLite and still takes ongoing check-ins after 17 years) is
  not justified outside avionics-adjacent work.
- Mutation testing as a requirement. Hipp explicitly could not make it reliable.
- Fossil over Git. Interesting, not actionable.

## Open, separate from this change

The `compact` skill collides by name with Claude Code's built-in `/compact`. There is only one
skill on disk; the perceived duplicate is the built-in. Renaming to `handoff` matches vocabulary
already used everywhere else (`HANDOFF-TEMPLATE.md`, `specs/handoffs/`, `core.md:136` reads
"Explicit session handoff"). Touch points: skill directory, frontmatter `name`, `core.md:136`,
`README.md:78`, and `test/instructions-smoke.sh` lines 29, 57, 796-812.

## Implementation note

Two things surfaced during implementation that the grill did not anticipate.

**core.md is under a hard word gate, and was sitting exactly on it.**
`test/global-instructions-pruning-smoke.sh` enforces at most half of a 2639-word baseline, so
1319 words. core.md measured exactly 1319 before this change. The strict cap chosen in round 1
was therefore mechanically enforced, not merely a preference. The 122 words added were paid for
by moving the sub-agent-dispatch and development-server paragraphs out of Conditional procedures
into a new `references/agent-operations.md`, named in the on-demand reference list, and by
tightening the three core.md additions. core.md is back at exactly 1319.

Accepted cost: those two paragraphs previously fired every session and now fire only when the
reference is opened. This is the same dead-text risk noted against decision 7.

**Edit 1 initially broke a smoke assertion.** `global-instructions-pruning-smoke.sh` requires
"state" within 40 characters of "contract". Rewording the bullet to say a stateful repository's
contract "must also define a state contract:" restores it. Keep that adjacency if the bullet is
edited again.

Final state: 594 checks pass across all five runnable suites. Rendered by
`./install.sh --instructions-only` into `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and
`~/.pi/agent/AGENTS.md`, with 6 reference files each.

**The `compact` to `handoff` rename is done** (2026-09-02, second pass). `skills/compact` moved to
`skills/handoff` via `git mv`, frontmatter `name` updated, and references updated in `core.md`,
`README.md`, `optional/autoresearch/README.md`, and `test/instructions-smoke.sh` (path, prose
labels, and the four COMPACT_* variable names). Stale installed copies were removed from all three
harness skill directories, which would otherwise have produced the real duplicate the rename was
meant to prevent.

Two things were deliberately left alone:

- The word "compact" as an adjective, in "a compact reasoning handoff" (`core.md`,
  `high-risk-engineering.md`) and "one compact batch" (`groundwork`). These are not the skill
  name, and `global-instructions-pruning-smoke.sh:172-173` actively asserts the first one.
- The skill description still reads "Use only when the user explicitly asks to compact, hand off,
  or wrap up for a clean restart." The collision being fixed is the `/compact` slash command;
  keeping "compact" as a natural-language trigger preserves prose discovery, and the exact string
  is asserted by instructions-smoke test #17.

Historical records in `specs/research/2026-08-09-skill-drift.md` and
`specs/plans/2026-08-09-dotagents-harness-agnostic.md` keep the old name, as dated records should.
