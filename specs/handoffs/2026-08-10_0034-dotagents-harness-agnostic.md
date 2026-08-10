---
date: 2026-08-10T00:34:00Z
git_commit: 478e732
branch: main
repository: dotagents
topic: "Restructure dotclaude into harness-agnostic dotagents: canonical source + per-harness adapters"
tags: [handoff, installer, adapters, skills, harness-agnostic]
status: in-progress
last_updated: 2026-08-10
type: handoff
---

# Handoff: dotagents harness-agnostic restructure

## Task(s)

Working from `specs/plans/2026-08-09-dotagents-harness-agnostic.md`. Read that plan first; it is
authoritative and decision-complete.

- **Phase 0 (reconcile drift, freeze inventory)** - COMPLETED, all 5 automated criteria pass
- **Phase 1 (canonical layout + capability metadata)** - COMPLETED, all criteria pass
- **Phase 2 (installer skeleton + smoke test, red first)** - COMPLETED, red-green cycle done
- **Phase 3 (four adapters)** - COMPLETED, built together with Phase 2 (the driver is inert without them)
- **Phase 4 (canonical instructions + per-harness rendering)** - PLANNED, next
- **Phase 5 (autoresearch multi-target)** - PLANNED
- **Phase 6 (rename, README, delete dead weight)** - PLANNED

Nothing is committed. 70 changed paths in the working tree, 41 of them git-detected renames.

## Critical References

1. `specs/plans/2026-08-09-dotagents-harness-agnostic.md` - the plan. Phases 4-6 are unstarted.
2. `specs/research/2026-08-09-skill-drift.md` - the three-way drift report Phase 0 resolved.
3. `install.d/_lib.sh` - the adapter helper contract. Any new harness starts by reading this.

## Recent changes

**Phase 0.** Merged pure supersets from `~/.claude`: `skills/research/WEB-RESEARCH.md` (new, 69 lines)
plus routing at `skills/research/SKILL.md:9-15`, and the local-skills-first protocol at
`skills/groundwork/REFERENCE.md:9-19`. Adopted 6 improvements from the `~/.codex` fork:
`skills/research/WEB-RESEARCH.md:42` (product/market-gap trap row), `skills/implement/SKILL.md:20`
(checkmarks are claims, not evidence), `skills/rigor/SKILL.md:22` (same-model caveat),
`skills/first-principles/SKILL.md:43` (same caveat), `skills/perf-loop/SKILL.md:44` (branch/worktree
isolation, never reset the working tree), `skills/perf-harness-init/templates/PERF.md:58` (staleness).

Dropped 9 Matt Pocock skills, added 5 of the user's own. Rewrote all 8 dangling `/grilling` and
`/grill-me` references to lead with behavior and name the skill as an optional accelerator
(`skills/plan/SKILL.md:27`, `skills/groundwork/SKILL.md:4,13,28,89`,
`skills/groundwork/PLAN_TEMPLATE.md:69`, `skills/first-principles/SKILL.md:58`,
`skills/first-principles/FORMAT.md:36`).

**Phase 1.** `git mv` of `.claude/skills` to `skills/` and `.claude/agents` to `agents/`. Added
`harness:` frontmatter to 7 skills.

**Phases 2+3.** `install.sh` rewritten (was 210 lines and broken; now a thin driver). New:
`install.d/_lib.sh`, `install.d/claude.sh`, `install.d/codex.sh`, `install.d/pi.sh`,
`install.d/agents.sh`, `test/install-smoke.sh`. `.gitignore:7-10` now ignores the unlock sentinel.

## Learnings

**The original bug, for the record.** `install.sh:93` (old) globbed `.claude/commands/*.md`, a
directory that did not exist. Without `nullglob` the literal glob reached `cp`, `cp` failed, and
`set -e` aborted before anything installed. It exited 0. The new `install.sh:38` sets
`shopt -s nullglob` specifically to kill that class.

**"Installed nothing" is the wrong invariant.** First implementation failed a rerun where every
skill already existed, because it counted what the run *wrote*. The correct invariant is what is
*present* after the run. Fixed at `install.sh:174`; both cases verified (rerun exits 0, empty canon
exits 1). If you touch that counter, re-run both cases.

**Codex is a fork, not a stale copy.** `~/.codex/skills/` holds independently rewritten variants
with real behavioral changes, some better than canon and some regressions (it renamed INP to
"interaction" and dropped `pull-requests: write` from CI while its own PERF.md still claimed PR
comments worked). Do not bulk-merge from `~/.codex`; adjudicate per item.

**Codex has native sub-agents.** `~/.codex/agents/*.toml` with `name`/`description`/`model`/
`developer_instructions`. That is why only pi and agents-generic demote agents to skills.

**bash is 3.2.57 on this Mac and there is no bash 4+ on PATH.** No `mapfile`, no `declare -A`, and
expanding an empty array under `set -u` raises "unbound variable". Guard every `"${arr[@]}"` with a
`${#arr[@]} -gt 0` check. This bit the test author twice.

**Dead end not worth repeating:** do not try to make `--symlink` strip frontmatter. Linking the
directory is what makes repo edits apply live, and rewriting SKILL.md defeats it. The two are
mutually exclusive; copy mode strips, symlink mode does not.

## Artifacts

| Path | What |
|---|---|
| `specs/plans/2026-08-09-dotagents-harness-agnostic.md` | The plan, phases 4-6 remain |
| `specs/research/2026-08-09-skill-drift.md` | Three-way drift report |
| `install.sh` | Driver: target selection, capability gate, walk |
| `install.d/_lib.sh` | Helpers: `do_*` writers, frontmatter parse/strip, `caps_satisfied`, managed block |
| `install.d/{claude,codex,pi,agents}.sh` | The four adapters |
| `test/install-smoke.sh` | 688 lines, 297 assertions, frozen by test-freeze |
| `skills/` (16), `agents/` (3) | The canonical tree |

Scratch, outside the repo, safe to delete:
`/private/tmp/claude-501/-Users-edmond-Projects-dotclaude/151d60fa-bc0b-4887-b0fd-dd1339a45d3a/scratchpad/`
holds `install.sh.broken-original` and `red-repo/` (the red-run fixture). Keep them until Phase 6 in
case the red run needs reproducing.

## Action Items & Next Steps

1. **User: re-freeze the test.** `rm .claude/tests-unlocked`. It is gitignored, but it is still live.
2. **User: review and commit Phase 0-3.** No AI co-author trailer. Suggest splitting: one commit for
   the Phase 0 content reconciliation, one for the Phase 1 move plus capability tags, one for the
   installer and test.
3. **Phase 4** - canonical instructions. Split `~/.claude/CLAUDE.md` into portable
   `instructions/core.md` and non-shipped `instructions/references/*.local.md`. The strip list is in
   the plan's Phase 4. Render via the managed block; `write_managed_block` already exists at
   `install.d/_lib.sh:150` and is untested, no adapter calls it yet. Per-harness preambles go in
   `instructions/preamble/`; Pi's must carry the environment section from `~/.pi/agent/AGENTS.md`.
4. **Phase 5** - move `domain-skills/claude/autoresearch/` to `optional/autoresearch/` with a
   `PACKAGE` file declaring `requires: hooks slash-commands`. `install_optional` at `install.sh:196`
   already reads that format but has never run; there is no `optional/` directory yet.
5. **Phase 6** - rename, README rewrite, delete `pi/`, `SKILLS-CLEANUP.md`,
   `specs/handoffs/2026-06-17_1440-skills-cleanup.md`, `domain-skills/`.

## Other Notes

**Verify before trusting:** the Codex model tier map at `install.d/codex.sh:24` (`opus` to `gpt-5.4`,
`sonnet` to `gpt-5.4-mini`) is INFERRED from a single file, `~/.codex/agents/tldraw-offline.toml`.
It is flagged in the plan's Phase 3 manual criteria and is still unverified against the CLI.

**Running the test:** `./test/install-smoke.sh` from the repo root. It resolves `REPO_ROOT` from its
own location, not `cwd`, so use an absolute path when running it against a fixture. A `cd` leaking
between shell commands produced a false green once during this session; the tell was that the
"green" totals exactly matched the preceding red run.

**Red fixture:** `scratchpad/red-repo/` contains `skills/`, `agents/`, and a stub `install.sh` that
exits 0 having installed nothing, which is the original defect's exact observable behavior. Copy
`test/install-smoke.sh` into `red-repo/test/` and run with `--expect-broken`.

**Skills dropped but not deleted from the machine:** the 9 Matt Pocock skills still live in
`~/.claude/skills/` and are also served by the `mattpocock-skills@claude-plugins-official` plugin.
Dropping them from the repo does not remove them from Claude Code. It does mean Codex and Pi users
must install them separately, which Phase 6's README must state.
