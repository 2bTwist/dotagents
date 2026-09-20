# Decision: program design, reviewable units, and a read set for a human

**Date:** 2026-09-19
**Status:** proposed; awaiting confirmation before any file is changed

## Problem

A talk on why software factories fail ("Why Software Factories Fail", Dex/HumanLayer) names a
failure mode this harness does not currently guard against. Reinforcement learning rewards a
binary outcome: the tests pass and nothing visibly broke. Maintainability is not in that signal,
so design smells are not penalised and code bent to satisfy a check is rewarded the same as code
that fits the system. The talk's claim is that an agent-driven codebase degrades within three to
six months, that review is the real bottleneck, and that the missing planning layer is **program
design**: the types, signatures, call paths and layout that sit between architecture and code.

An audit of `instructions/core.md`, the skills, the agents and the hooks found four gaps and
three controls that already hold.

Already held:

- `hooks/test-freeze.py` blocks edits to frozen tests (it cites ImpossibleBench 2025: GPT-5 cheated
  on 54% of tasks, Opus 4.1 on 50%, and over 79% of Claude-family cheating was plain test
  modification).
- Tests are authored by a separate agent from the requirement, confirmed red, then frozen.
- `core.md` already prefers constraints and types over tests, and real paths over mocks.

Gaps:

1. No artifact settles program design. `groundwork` and a grill settle *what* and *why*;
   `implement` then chooses signatures, layout and call paths while writing code, silently.
2. Nothing bounds a change to a size a person can actually read. Phase D of the current project
   shipped as three PRs only because the author chose to split them.
3. Nothing names the pressure to shape production code so a test passes: a guard, a fallback, a
   widened type, a swallowed failure. The test-freeze hook stops the test being edited; it does
   not stop the code being bent instead.
4. Nothing states which files a human must read line by line, so "reviewed" can mean anything.

## Decisions

| Choice | Decision | Reasoning | Rejected |
|---|---|---|---|
| Where program design lives | A new standalone skill, `skills/program-design/`, writing `specs/design/YYYY-MM-DD-<slug>.md` | The user asked for a file in the repo's `specs/` convention, so the design survives compaction and is reviewable on its own. | A section inside a grill's decision record (mixes *what* with *how*, and a grill is an interview). A phase of `implement` (the point is to settle it before code). |
| How it is invoked | Model-invocable; the description carries its own TRIGGER and SKIP lines | The user's instruction: "YOU will decide when to invoke this yourself". | User-invoked only (the gap is the agent skipping the layer, not the user forgetting). Always-on (`oneshot`-sized work would pay for it). |
| Its scope | Signatures and types, the touched surface's boundaries, the main flow's call path plus one failure path, state ownership, seams, and the shapes ruled out | These are the decisions that otherwise get made inside the implementation, where nobody sees them. | Full pseudocode (becomes a draft implementation and loses the one-sitting property). Diagrams only (says nothing about what a caller sees). |
| Handoff | `implement` reads a design file when one covers the work, builds to it, and surfaces a mismatch | One line in an existing skill, no new coupling. | A new orchestrating skill. |
| Reviewability threshold | Roughly 800 added lines of code, excluding tests, lockfiles, generated output, vendored code and docs | The user picked this number. It is a prompt to split, not a gate: a hook counting lines would fire on generated files and on legitimate single-commit moves. | A hard hook. No number (an unbounded "keep it small" is a no-op). |
| Test-shaped code control | A philosophy bullet in `core.md`, language-agnostic, with the diff-reading detail in a reference | The user: "this can just be a line in agents.md to review and more like a philosphy so it's not tied to a linguage or thing so make it agnostic". The smells vary by language; the pressure does not. | A lint rule or hook (per-language, and the same construct is correct elsewhere). A review sub-agent (cost on every change). |
| Read set | Named by agnostic risk class: money, identity, durable state and migrations, concurrency, external effects, trust boundaries, silent failure | The user: "again this is not specific to this project", and no cadence requirement. | A fixed percentage of the diff. A per-repo list (does not port). A review cadence or schedule. |
| Where the four lines go | One line each in `core.md`, details in `instructions/references/reviewable-change.md` | The user's choice. `core.md` is loaded every turn, so it carries the rule and the trigger; the procedure is read on demand. | All of it in `core.md` (always-loaded bulk). All of it in a reference (nothing points at it, so it never loads). |

## Changes

1. `instructions/core.md`, Working contract: **Ship reviewable units** (the 800-line prompt, the
   split, the pointer to the new reference).
2. `instructions/core.md`, Verification and author bias: **Shape the code for the system, not for
   the tests**, and **Name the read set**.
3. `instructions/core.md`, Conditional procedures: one line routing to `program-design`.
4. `instructions/references/reviewable-change.md` (new): sizing the unit and where to split, the
   read set by risk class, the language-agnostic smells to look for in your own diff, and what the
   reviewer is told.
5. `skills/program-design/SKILL.md` (new): the seven steps, the completion criterion, and the rule
   that keeps it a design rather than a draft implementation.
6. `skills/implement/SKILL.md`: one bullet, read the design file when one exists.

Net always-loaded cost: four bullets in `core.md`, roughly 20 lines. Everything else is reached by
a pointer or a trigger.

## Completion criterion

`core.md` carries the four lines; the reference and the skill exist; `implement` reads a design
file when present; `./install.sh` renders them into the harnesses; and the next non-trivial feature
produces a `specs/design/` file before its first line of implementation code.

## Accepted tradeoffs

- One more artifact between a settled decision and running code. Contained work is exempt, but the
  boundary is the agent's judgment, so some designs will be written for work that did not need one.
- The 800-line threshold is a number without evidence behind it. It will sometimes force a split
  that costs more in rebasing than it saves in review.
- A stack of small PRs moves work from the author's diff to the author's rebases, and a
  squash-merged parent forces `rebase --onto` on every child.
- "Name the read set" is self-reported. It makes coverage claims falsifiable; it does not make them
  true.
- The design file can drift from the code it describes, like any doc. Nothing checks it.
