---
date: 2026-08-10T05:41:30Z
git_commit: 478e732
branch: main
repository: dotagents
topic: "dotagents harness-agnostic restructure: Phases 4 and 5 landed, Phase 6 (rename, README, deletions) remains"
tags: [handoff, installer, adapters, instructions, optional-packages, testing]
status: complete
last_updated: 2026-08-10
type: handoff
---

# Handoff: dotagents restructure, Phase 6 remaining

> **CLOSED 2026-08-10.** Phase 6 landed in a later session. All six phases are complete and the plan's
> automated criteria are green. What remains is entirely user action: commit, `rm .claude/tests-unlocked`,
> and rename the GitHub repo and the local directory. See "Phase 6 outcome" at the bottom before
> reading the rest, which is preserved as the record of where that session started.

Supersedes `specs/handoffs/2026-08-10_0034-dotagents-harness-agnostic.md`. Read this one; that one
is now only useful for the Phase 0-3 detail it records.

## Task(s)

Working from `specs/plans/2026-08-09-dotagents-harness-agnostic.md`, which is authoritative and
decision-complete.

- **Phase 0** (reconcile drift, freeze inventory) - COMPLETED
- **Phase 1** (canonical layout + capability metadata) - COMPLETED
- **Phase 2** (installer skeleton + smoke test, red first) - COMPLETED
- **Phase 3** (four adapters) - COMPLETED. Its last open manual criterion, the Codex model tier
  map, was closed this session.
- **Phase 4** (canonical instructions + per-harness rendering) - COMPLETED this session
- **Phase 5** (autoresearch as an optional package) - COMPLETED this session
- **Phase 6** (rename, README, delete dead weight) - PLANNED, next and unstarted

Nothing is committed. 79 changed paths in the working tree, 45 git-detected renames.

## Critical References

1. `specs/plans/2026-08-09-dotagents-harness-agnostic.md` - the plan. Only Phase 6 remains.
2. `install.d/_lib.sh` - adapter helper contract. Any new harness starts by reading this.
3. `optional/autoresearch/install.sh` - the optional-package contract, in 87 lines.

## Recent changes

**Phase 4, canonical instructions.** New `instructions/core.md` (the portable document, split out of
`~/.claude/CLAUDE.md` with the plan's strip list applied), `instructions/preamble/{claude,codex,pi,
agents}.md`, `instructions/references/README.md`, and two gitignored `instructions/references/
*.local.md` holding the machine specifics. Installer wiring at `install.sh:186` (`install_instructions`)
and `install.sh:228` (`install_references`). `.gitignore:12-14` ignores `instructions/references/*.local.md`.

**Phase 5, optional packages.** `git mv domain-skills/claude/autoresearch optional/autoresearch`,
plus new `optional/autoresearch/{PACKAGE,UPSTREAM.md,install.sh}` and a rewritten `README.md` there.
`install_optional` at `install.sh:262` now SOURCES the package rather than executing it.

**Phase 3 leftover closed.** `install.d/codex.sh:24` model tier map was a generation stale. Verified
against `~/.codex/models_cache.json` (the catalog the installed CLI fetches for itself): `opus` ->
`gpt-5.6-sol`, `sonnet` -> `gpt-5.6-terra`, `haiku` -> `gpt-5.6-luna`.

**Shellcheck.** `shellcheck -S warning` now exits 0 across `install.sh`, all four adapters, the
package installer, and all three test files. It did not before: eleven SC2034/SC1090 findings were
silenced with targeted directives naming why (the adapter contract variables are read by the driver
that sources them).

## Learnings

**Do not parallelise test authoring with implementation.** This was the session's real mistake. For
Phase 4 I dispatched the test author and implemented concurrently; the implementation landed first,
the test came back green on its first run, and its red-first evidence was gone. Recovering cost a
full round of mutation testing. For Phase 5 I held the implementation until the author reported red,
and the cycle was clean. The general rule in `instructions/core.md` says to parallelise by default;
a red-first test is the standing exception, because its value is entirely in the ordering.

**Mutation testing is the recovery when red-first is lost, and is worth doing anyway.** 22 mutants
across the two phases. Two of my own mutants were mis-designed in an instructive way: truncating
`instructions/core.md` (the test's own oracle, so output and expectation moved together) and deleting
the hook's `chmod +x` (`cp -R` preserves the mode bit, so nothing changed). A mutant that survives is
first a suspicion about the mutant, not about the test. Harnesses are in the scratchpad listed below.

**`cp -R` preserves the executable bit, so the hook `chmod +x` looks redundant and is not.** Mutant
P4c proved it earns its place: with the repo's mode bit lost in checkout, the chmod repairs it and
the install stays correct. Do not delete it as dead code.

**The optional-package installer had to be sourced, not executed.** A subprocess inherits neither the
adapter's `harness_*` functions nor the `do_*` writers that enforce `--dry-run` in one place, so it
would know neither where to install nor how to honour a dry run. `install.sh:262` sources it and
calls `optional_install`, with `unset -f` on both sides so a package that forgets to define one is
reported rather than silently running its predecessor's.

**The managed block holds `core.md` verbatim, and machine specifics install as separate files.** This
was an open choice in the plan. Concatenating the `*.local.md` files into the block would have made
the block content depend on gitignored files, so a clone and the maintainer's machine would render
different blocks and the content assertion could not have a stable oracle. Instead `<harness-root>/
references/` gets the local files and `core.md` refers to them by role.

**test-freeze froze the new test file the moment the agent created it.** Its own comment says only
EXISTING tests are frozen and that creating one is the good direction, but a file created seconds ago
is "existing" by its `Path.exists()` check. The user unlocked and reported the friction. A narrow fix
was proposed and NOT applied: exempt test files git does not track yet, so a test freezes once
committed rather than once it exists. `~/.claude/hooks/test-freeze.py:170` is the check.

**Everything from the previous handoff still holds:** bash is 3.2.57 with no bash 4+ on PATH (no
`mapfile`, no `declare -A`, guard every `"${arr[@]}"` under `set -u`); "installed nothing" is the
wrong invariant, measure what is PRESENT (`install.sh:216`); Codex is a fork not a stale copy, so
adjudicate per item; `--symlink` and frontmatter stripping are mutually exclusive by design.

## Artifacts

| Path | What |
|---|---|
| `specs/plans/2026-08-09-dotagents-harness-agnostic.md` | The plan. Phase 6 remains |
| `instructions/core.md` | Portable instructions, rendered into every harness's managed block |
| `instructions/preamble/*.md` | Four harness preambles, seeded once, outside the block |
| `instructions/references/README.md` | The local-reference convention (ships) |
| `instructions/references/*.local.md` | Machine specifics (gitignored, 2 files) |
| `optional/autoresearch/PACKAGE` | `requires: hooks slash-commands` |
| `optional/autoresearch/UPSTREAM.md` | Provenance: repo, commit `0f1ba8f36de...`, what is verbatim |
| `optional/autoresearch/install.sh` | Sourced package installer, 87 lines |
| `install.sh` | 298 lines. Driver, instructions, references, optional packages |
| `test/install-smoke.sh` | 688 lines, 297 assertions, green |
| `test/instructions-smoke.sh` | 630 lines, 158 assertions, green |
| `test/optional-smoke.sh` | 603 lines, 41 assertions, green |

Scratch, outside the repo, safe to delete once Phase 6 lands:
`/private/tmp/claude-501/-Users-edmond-Projects-dotclaude/74722512-05c2-4428-b751-6fb61b20265e/scratchpad/`
holds `mutate.sh` through `mutate5.sh` (the 22 mutants) and the Phase 5 drafts. Keep them until Phase
6 is verified, since they are the cheapest way to re-prove the suites after the rename.

## Action Items & Next Steps

1. **User: re-freeze the tests** when satisfied with the diff. `rm .claude/tests-unlocked`. It is
   gitignored but live, and it lingered unnoticed once already.
2. **User: review and commit Phases 0-5.** No AI attribution. Suggested split: Phase 0 content
   reconciliation; Phase 1 move plus capability tags; Phases 2-3 installer, adapters, and the smoke
   test; Phase 4 instructions; Phase 5 optional packages.
3. **Phase 6, the only remaining phase.** Its success criteria are in the plan. In order:
   - Delete `pi/`, `SKILLS-CLEANUP.md`, `specs/handoffs/2026-06-17_1440-skills-cleanup.md`, and the
     now-empty `domain-skills/` (only `domain-skills/claude/` remains on disk; git already records
     the four autoresearch files as renames, so it vanishes on commit).
   - Rename `dotclaude` to `dotagents` in `README.md` and `install.sh:3`. `LICENSE:3` does not name
     the repo and is untouched. The GitHub rename and the local directory rename are user actions;
     the remote is `git@github.com:2bTwist/dotclaude.git` and GitHub redirects.
   - Rewrite `README.md`. It has three standing errors: it tabulates 7 slash commands that are
     skills, its Skills line names 2 of 20, and its domain-skills line still advertises the ASO
     skills removed in `a504cf1` and `ea6b6f8`. Add the target matrix with per-harness skip reasons,
     the adapter contract for adding a harness, and a plain statement that Matt Pocock's skills are
     no longer bundled and where to get them. Keep the humanlayer, Matt Pocock, Driveline, and Pierre
     credits; add Theo (t3.gg) for the `codex-*` skills and animations.dev for `animation-vocabulary`.
     No em dashes.
   - Re-run all three suites and `shellcheck -S warning` after the rename; grep for stale `dotclaude`
     references outside `specs/plans/`.
4. **Optional, user's call:** the `test-freeze.py` fix described in Learnings. Not applied.

## Other Notes

**Running the suites.** `./test/<name>.sh` from anywhere; each resolves the repo root from its own
location, not `cwd`. A `cd` leaking between shell commands produced a false green once; the tell was
that the "green" totals exactly matched the preceding red run.

**Manual criteria the automated suites do not cover,** and which the plan leaves explicitly manual:
whether a translated Codex agent behaves correctly when dispatched, whether Pi's system prompt stays
small, whether `instructions/core.md` still reads as the user's actual preferences, and whether each
live instruction file after install is at least as good as today's hand-written version. Also
uncovered by any suite: the autoresearch `settings.json` already-wired detection, verified by hand
this session in both directions.

**`~/.agents/skills/` must stay empty.** Pi auto-loads it as well as `~/.pi/agent/skills/`, and it
was deliberately emptied to shrink Pi's system prompt from ~5074 to ~1841 tokens
(`SKILLS-CLEANUP.md:69`). `install.d/pi.sh:22` documents this; do not "fix" it.

**Dropped skills still live on the machine.** The 9 Matt Pocock skills remain in `~/.claude/skills/`
and are also served by the `mattpocock-skills@claude-plugins-official` plugin. Dropping them from the
repo does not remove them from Claude Code, but it does mean Codex and Pi users must install them
separately. Phase 6's README must say so.

---

## Phase 6 outcome (appended on close)

Deleted `pi/`, `SKILLS-CLEANUP.md`, `specs/handoffs/2026-06-17_1440-skills-cleanup.md`, and the
emptied `domain-skills/`. `install.sh:3` already read `dotagents`, so the rename was README-only.
`README.md` rewritten from 71 to 232 lines: target matrix with per-harness skip reasons, adapter
contract, capability gating, a "Not bundled" section pointing at mattpocock/skills, and a Verify
section. All 16 skills named and cross-checked in both directions. No em dashes.

Verified: three suites 297 / 158 / 41 with 0 failed, `shellcheck -S warning` exit 0, and a clean
clone into a fresh HOME installing all four targets (claude 16+3 native, codex 15+3 TOML, pi 14+3
demoted, generic 14+3 demoted) with no `harness:` key leaking into any installed file.

**Two criteria closed short of literal, both annotated in the plan.** The `grep dotclaude` check is
narrowed: nothing that ships carries the old name, but dated handoffs still describe the rename task
in prose and literal `/private/tmp/...-dotclaude/` scratchpad paths remain. Rewriting those would make
a historical record inaccurate. The identity fields that would be wrong after the rename were fixed:
`repository:` in both handoff frontmatters and the stale absolute path in
`specs/research/2026-08-09-skill-drift.md:14`. The clean-clone run overlaid the working tree onto the
clone because nothing is committed, which also meant it carried the gitignored `references/*.local.md`;
a real clone installs only `references/README.md`.

**Dangling reference introduced by this phase.** Line 170 above cites `SKILLS-CLEANUP.md:69` for why
`~/.agents/skills/` must stay empty. That file is now deleted. The reason survives in
`install.d/pi.sh:22`, which is the copy that matters, but the citation here no longer resolves.

**Unrelated change made in the same session.** A new engineering-principles bullet, "The installed
version is the spec, not the one you learned", was added to `instructions/core.md:198` and mirrored
into `~/.claude/CLAUDE.md:179`. Both existing "use every library the way its maintainers do" bullets
gave up their "Read them over recalled knowledge" clause so that meaning lives in one place.
