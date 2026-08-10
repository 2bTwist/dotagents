# dotagents: Harness-Agnostic Restructure Implementation Plan

## Overview

Convert this repo from a Claude Code dotfiles repo with a hand-written Pi fork into a single canonical
source of skills, agents, and instructions, plus per-harness adapters that install into Claude Code,
Codex CLI, Pi, or any AGENTS.md-reading harness. Rename it to `dotagents`.

The driver is not stale documentation. It is that the same content is currently maintained as three
divergent hand-copied forks, and the installer that was supposed to prevent that has been silently
installing nothing.

## Current State Analysis

### The installer is broken and has no detection

`install.sh:93` globs `.claude/commands/*.md`. That directory does not exist (it was retired in the
June cleanup, `SKILLS-CLEANUP.md:9`). With `nullglob` unset the literal glob string reaches `cp`,
`cp` fails, and `set -e` at `install.sh:17` aborts the script before agents or skills are ever
copied. Reproduced against a temporary `HOME`: three empty directories are created and nothing is
installed. There is no test, so this has been failing silently.

### Three divergent forks of the same skills

| Location | Workflow skills present |
|---|---|
| `.claude/skills/` (this repo) | 20 |
| `~/.claude/skills/` | 19 |
| `~/.codex/skills/` | 19 |
| `~/.pi/agent/skills/` | 1 (`grill-me`) |

They have drifted in content, not only in frontmatter:

- `~/.claude/skills/research/` gained a web-research branch (`WEB-RESEARCH.md`, 69 lines) plus routing
  in `SKILL.md:9-15`. The repo copy has neither.
- `~/.codex/skills/research/SKILL.md` is a third variant: reworded `description`, no `model` key, and
  it points at `references/web-research.md` instead of `WEB-RESEARCH.md`.
- `~/.claude/skills/groundwork/SKILL.md:55` and `REFERENCE.md:9-19` gained a "enumerate locally
  installed skills before any web crawl" protocol. The repo copy has neither.
- The repo has `agent-latency-audit`, which neither live install has.

### The same fork exists at the instructions layer

`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.pi/agent/AGENTS.md` all encode the same
preferences (pnpm, no AI attribution, no em dashes, no sycophancy, author-bias rule) in three
different wordings. `pi/AGENTS.workflow-section.md` was the manual patch for this and went stale:
it still describes a "prompt templates" era that no longer exists and 7B/32k local models.

### Two findings that reduce the work

**Codex has native skills.** `~/.codex/skills/` already holds 19 of them. The Codex adapter is a copy
plus frontmatter cleanup, not a translation.

**Codex has native sub-agents.** `~/.codex/agents/tldraw-offline.toml` uses `name`, `description`,
`model`, `developer_instructions`. The three `codebase-*` agents translate mechanically into TOML.
Only Pi and the generic AGENTS.md target need the demote-to-skill fallback.

### Provenance: much of what the repo ships is not the user's

Verified against the installed `mattpocock-skills@1.2.3` plugin cache and `SKILLS-CLEANUP.md:55,62`:

- `grill-me` is byte-identical to `productivity/grill-me` in Matt Pocock's plugin.
- `wayfinder` differs from his only in italics style (`*x*` vs `_x_`).
- `codebase-design`, `diagnosing-bugs`, `domain-modeling`, `grill-with-docs`,
  `improve-codebase-architecture`, `prototype`, `writing-great-skills` are his, per the cleanup log.
- `grilling` is a fork of his: the repo copy predates his rounds-and-frontier rewrite.

That plugin is enabled in `~/.claude/settings.json`, so the repo copies duplicate a plugin the user
already has, at a version behind it.

### Key Discoveries

- `install.sh:93` is the exact failure point, and `set -e` at `install.sh:17` turns it into a silent
  total failure rather than a partial install.
- `~/.claude/skills/autoresearch` is a symlink to `~/autoresearch-claude-code/skills/autoresearch`, a
  clone of `drivelineresearch/autoresearch-claude-code`. `domain-skills/claude/autoresearch/` is a
  vendored third copy.
- `~/.claude/commands/` is empty on the live machine, confirming the commands concept is fully dead.
- `~/.agents/skills/` is empty. It was deliberately emptied (`SKILLS-CLEANUP.md:69`) to shrink Pi's
  system prompt from ~5074 to ~1841 tokens. The Pi adapter must not undo that without intent.
- Dropping Matt's skills creates 8 dangling references from skills that stay:
  `plan/SKILL.md:27`, `groundwork/SKILL.md:4,13,28,89`, `groundwork/PLAN_TEMPLATE.md:69`,
  `first-principles/SKILL.md:56`, `first-principles/FORMAT.md:36`.
- `~/.claude/skills/tailscale/SKILL.md:22-26` contains the user's tailnet name, email, device names,
  and tailnet plus LAN IPs. Excluded from scope by decision, and a standing reason to scan before
  publishing anything.
- `LICENSE:3` is `Copyright (c) 2026 2bTwist` and does not name the repo, so the rename does not
  touch it.
- Remote is `git@github.com:2bTwist/dotclaude.git`. GitHub redirects after a rename.

## Desired End State

One canonical tree. `./install.sh --target=<harness>` installs from it correctly for Claude Code,
Codex CLI, Pi, or a generic AGENTS.md consumer. A smoke test fails loudly if an adapter installs
nothing, installs a skill the target cannot run, or leaks a non-portable frontmatter key.

Verify by running `test/install-smoke.sh`, which exercises every target against a temporary `HOME`
and asserts the installed inventory against the canonical source.

## What We're NOT Doing

- Not vendoring Matt Pocock's skills. They come from his plugin on Claude Code, and the README will
  state plainly that Codex and Pi users must install them separately.
- Not shipping `tailscale` (contains personal network topology) or `emil-design-eng` (provenance
  could not be established).
- Not shipping the tool-specific skills: the Cloudflare batch, `tldraw-offline`, `turnstile-spin`,
  `sqlalchemy-alembic-expert`, `web-perf`.
- Not rewriting `rigor` or `agent-latency-audit` to work without Claude Code. They get tagged and
  skipped elsewhere.
- Not converting the installer to Node/TypeScript. Bash, with adapters as separate files.
- Not preserving the hand-written Pi prompts.
- Not touching the user's live `~/.claude`, `~/.codex`, or `~/.pi` outside an explicit install run.

## Implementation Approach

Canonical source plus adapters. An adapter is a bash file that declares which capabilities its
harness has and how to place a skill, an agent, and the instructions block. The core installer walks
the canonical tree and calls into the adapter; it never contains harness-specific knowledge.

Ordering is driven by two constraints. Drift must be reconciled before anything reads from canon, so
that is Phase 0. The smoke test must exist before the adapters, so each adapter is written against a
check that fails, which is Phase 2 and is the direct answer to how this broke undetected.

## Phase 0: Reconcile the three-way drift and freeze the inventory

### Overview

Produce one winning copy per skill and settle exactly what ships. Nothing else can start until this
lands. This phase reverses `SKILLS-CLEANUP.md:14` ("Source of truth = live, then push"); after this
plan the repo is canonical and `--symlink` makes the live installs a view of it.

### Changes Required

#### 1. Merge report

**File**: `specs/research/2026-08-09-skill-drift.md` (new, disposable)

For each of the 11 kept skills, diff repo against `~/.claude/skills/` and `~/.codex/skills/`. Take the
most-developed version, which is `~/.claude` in every known case. Record every file where copies
disagreed and which won. Present before committing.

Known merges to land:
- `research/`: take `~/.claude` version, including `WEB-RESEARCH.md` and the `SKILL.md:9-15` routing,
  and the `RESEARCH-TEMPLATE.md` web variant.
- `groundwork/`: take `~/.claude` version, including the local-skills-first protocol.
- `agent-latency-audit/`: repo is the only copy, take as-is.

Normalize the sibling-file convention to the winner's (`WEB-RESEARCH.md`, uppercase, flat). The Codex
`references/web-research.md` layout is discarded, and any in-file links updated to match.

#### 2. Final canonical inventory

**Ships (16 skills):**

| Kept from repo (11) | Added from `~/.claude` (5) |
|---|---|
| `plan`, `research`, `implement`, `compact`, `oneshot` | `codex-imagegen` |
| `groundwork`, `first-principles`, `rigor` | `codex-implementation` |
| `perf-loop`, `perf-harness-init`, `agent-latency-audit` | `codex-review` |
| | `design-engineering` |
| | `animation-vocabulary` |

**Agents (3):** `codebase-locator`, `codebase-analyzer`, `codebase-pattern-finder`. Adapted from
humanlayer/humanlayer under Apache 2.0 and already credited in the README. Attribution carries over.

**Dropped (9, all Matt Pocock's):** `codebase-design`, `diagnosing-bugs`, `domain-modeling`,
`grill-me`, `grill-with-docs`, `grilling`, `improve-codebase-architecture`, `prototype`,
`writing-great-skills`.

#### 3. Resolve the 8 dangling references

**Files**: `plan/SKILL.md:27`, `groundwork/SKILL.md:4,13,28,89`, `groundwork/PLAN_TEMPLATE.md:69`,
`first-principles/SKILL.md:56`, `first-principles/FORMAT.md:36`

Rewrite each so the behavior is described first and the skill is named as an optional accelerator.
This keeps them working on Claude Code via the plugin and degrades to plain prose elsewhere.

```markdown
Before: run a `/grilling` session on the open decisions
After:  interview the user on the open decisions one branch at a time, resolving dependencies
        between them (the `grilling` skill if installed)
```

### Success Criteria

#### Automated Verification
- [ ] Merge report exists: `test -f specs/research/2026-08-09-skill-drift.md`
- [ ] Canonical tree holds exactly 16 skills: `ls skills | wc -l` returns 16
- [ ] Zero dangling references to dropped skills:
      `grep -rnE '/(grilling|grill-me|grill-with-docs|domain-modeling|codebase-design|prototype|diagnosing-bugs|improve-codebase-architecture|writing-great-skills)\b' skills/ agents/` returns nothing
- [ ] No broken sibling links: every `](*.md)` target in a `SKILL.md` resolves on disk
- [ ] No private data: `grep -rniE '/Users/edmond|ndanjiedmond|ts\.net|100\.9[0-9]\.|192\.168\.' skills/ agents/` returns nothing

#### Manual Verification
- [ ] User signs off on the merge report, in particular the research and groundwork merges
- [ ] User confirms the 16-skill list and the 9 drops
- [ ] Reworded references still read naturally and lose no instruction

**After this phase passes automated verification, pause for manual confirmation before the next phase.**

---

## Phase 1: Canonical layout and capability metadata

### Overview

Move content to a harness-neutral layout and tag what cannot travel, so adapters can skip or degrade
honestly instead of installing something that silently cannot work.

### Changes Required

#### 1. Layout

```
skills/<name>/SKILL.md          # was .claude/skills/
agents/<name>.md                # was .claude/agents/
instructions/                   # Phase 4
install.d/                      # Phase 2
test/                           # Phase 2
```

Use `git mv` so history follows.

#### 2. Capability frontmatter

**File**: each `skills/*/SKILL.md` needing it

```yaml
harness:
  requires: [claude-transcripts]   # hard blocker: adapter SKIPS if target lacks it
  degrades: [subagents]            # installs, but loses something; adapter WARNS
```

Capability vocabulary, deliberately small:

| Capability | Meaning |
|---|---|
| `subagents` | can dispatch parallel sub-agents |
| `claude-transcripts` | can read `~/.claude/projects/<slug>/*.jsonl` |
| `mcp-browser` | has `mcp__MCP_DOCKER__browser_*` tools |
| `hooks` | supports `UserPromptSubmit` hooks |
| `slash-commands` | has a `commands/` directory concept |

Assignments, from the audit:

| Skill | `requires` | `degrades` |
|---|---|---|
| `agent-latency-audit` | `claude-transcripts` | |
| `rigor` | `subagents` | |
| `perf-loop` | | `subagents`, `mcp-browser` |
| `perf-harness-init` | | `mcp-browser` |
| `research`, `plan`, `first-principles` | | `subagents` |
| `implement` | | `subagents` |
| all others | | |

`rigor` requires rather than degrades because `SKILL.md:22` states the adversarial pass "is not
optional and not you", so a single-agent harness cannot honor its central guarantee.

### Success Criteria

#### Automated Verification
- [ ] `git log --follow skills/research/SKILL.md` shows pre-move history
- [ ] Every `harness:` block parses and uses only the five defined capability names
- [ ] `.claude/` no longer exists in the repo: `test ! -d .claude`

#### Manual Verification
- [ ] Capability assignments match the audit, especially `rigor` as `requires`

**After this phase passes automated verification, pause for manual confirmation before the next phase.**

---

## Phase 2: Installer skeleton and the smoke test, red first

### Overview

Rewrite `install.sh` as a thin driver, and build the smoke test **before** the adapters. Run it
against the current broken installer first and watch it fail. That failure is the proof the test is
real, and it is exactly the tripwire whose absence let `install.sh:93` rot.

### Changes Required

#### 1. Smoke test, written by a separate agent

**File**: `test/install-smoke.sh`

Per the standing author-bias rule, brief a separate agent with the REQUIREMENT, not the
implementation, and read the test before running it:

> Given a canonical tree of N skills and M agents, and a target harness, an install run must place
> every skill the target can run into that harness's skill directory, place no skill whose `requires`
> capability the target lacks, leak no non-portable frontmatter key, and exit non-zero if it installs
> nothing.

The oracle is the canonical source inventory, derived from the requirement, not from whatever the
installer produces. Assertions:

- exit code is 0 and installed count is greater than 0 (catches the current failure)
- installed set equals canonical set minus skills whose `requires` the target lacks
- `agent-latency-audit` and `rigor` are absent from every non-Claude target
- no installed file contains an unexpanded `*`
- no `disable-model-invocation`, `model:`, or `harness:` key survives where the target does not accept it
- `--dry-run` writes nothing: `HOME` tree is byte-identical before and after
- rerunning without `--force` overwrites nothing and still exits 0

#### 2. Installer core

**File**: `install.sh` (rewrite)

```bash
# Target selection: explicit flag, else auto-detect by PATH plus config dir.
#   --target=claude|codex|pi|agents   (repeatable)
#   --target=all                      (every detected harness)
#   --dest=<path>                     (required for --target=agents)
# Retained: --symlink --force --dry-run --list
set -euo pipefail
shopt -s nullglob   # the specific defect that caused the silent failure
```

Core walks `skills/` and `agents/`, and for each candidate calls the adapter hooks. It contains no
harness-specific paths.

#### 3. Adapter contract

**File**: `install.d/_lib.sh` plus one file per target

An adapter defines:

| Symbol | Contract |
|---|---|
| `HARNESS_NAME` | display name |
| `HARNESS_CAPS` | space-separated capabilities this harness has |
| `harness_detect()` | 0 if installed on this machine |
| `harness_skill_dest <name>` | absolute path for a skill directory |
| `harness_agent_install <file>` | place one agent, in whatever form the harness uses |
| `harness_frontmatter <file>` | filter stdin, emitting only keys this harness accepts |
| `harness_instructions_dest` | path of the file receiving the managed instructions block |

The core skips a skill when `requires` is not a subset of `HARNESS_CAPS`, printing the reason. It
warns on `degrades` and installs anyway.

### Success Criteria

#### Automated Verification
- [ ] **Red first**: `test/install-smoke.sh` run against the pre-rewrite `install.sh` FAILS on the
      installed-count assertion. Record the output in the commit message.
- [ ] After the rewrite, `./install.sh --dry-run --target=all` exits 0 and writes nothing
- [ ] `shellcheck install.sh install.d/*.sh test/install-smoke.sh` passes
- [ ] `./install.sh --list` prints all 16 skills with per-target skip reasons

#### Manual Verification
- [ ] The smoke test was written by a separate agent from the requirement, and reviewed before first run
- [ ] The red run failed for the right reason, not an unrelated error

**After this phase passes automated verification, pause for manual confirmation before the next phase.**

---

## Phase 3: The four adapters

### Overview

Implement `claude`, `codex`, `pi`, and `agents`, each turning green in the smoke test as it lands.

### Changes Required

#### 1. Frontmatter translation

| Canonical key | claude | codex | pi | agents |
|---|---|---|---|---|
| `name`, `description` | keep | keep | keep | keep |
| `model: <tier>` | keep | map | drop | drop |
| `disable-model-invocation` | keep | drop | drop | drop |
| `harness:` | strip | strip | strip | strip |
| `tools:` (agents only) | keep | drop, warn | drop | drop |

`harness:` is repo metadata and must never reach an installed file.

#### 2. Per-adapter specifics

**`install.d/claude.sh`** - caps: all five. `~/.claude/skills/<name>/`, `~/.claude/agents/<name>.md`
verbatim. The reference implementation.

**`install.d/codex.sh`** - caps: `subagents`, `slash-commands`. `~/.codex/skills/<name>/`. Agents
become `~/.codex/agents/<name>.toml`:

```toml
name = "codebase-locator"
description = "..."
model = "gpt-5.4-mini"
developer_instructions = '''
<markdown body>
'''
```

`tools:` has no equivalent, so it is dropped with a printed warning naming the lost restriction.
Model map: `sonnet` to `gpt-5.4-mini`, `opus` to `gpt-5.4`. Confirm the tier names against installed
Codex before shipping; do not guess.

**`install.d/pi.sh`** - caps: none of the five. `~/.pi/agent/skills/<name>/`. Agents are demoted to
skills, since Pi has no sub-agent concept. Skips `rigor` and `agent-latency-audit`. Must not write to
`~/.agents/skills/`, which was deliberately emptied to keep Pi's system prompt small
(`SKILLS-CLEANUP.md:69`); Pi auto-loads both, so writing there would silently undo that.

**`install.d/agents.sh`** - caps: none. Requires `--dest`. Writes `<dest>/skills/<name>/` and a
managed block in `<dest>/AGENTS.md`. Agents demoted to skills.

### Success Criteria

#### Automated Verification
- [ ] `test/install-smoke.sh` passes for all four targets
- [ ] Codex TOML parses: `python3 -c "import tomllib,sys;[tomllib.load(open(f,'rb')) for f in sys.argv[1:]]" $HOME/.codex/agents/*.toml` against the temp HOME
- [ ] `grep -rl "harness:" <temp-HOME>` returns nothing for every target
- [ ] Pi and agents targets install 14 skills, not 16, and name the two skipped

#### Manual Verification
- [ ] A real `--target=codex` install is loadable by Codex, and a translated agent is dispatchable
- [ ] Pi still starts with a small system prompt; `~/.agents/skills/` untouched
- [ ] Codex model tier names verified against the installed CLI, not assumed

**After this phase passes automated verification, pause for manual confirmation before the next phase.**

---

## Phase 4: Canonical instructions with per-harness rendering

### Overview

Collapse the three divergent instruction files into one canonical portable document plus per-harness
preambles, and install it into a managed block so hand-written content survives. This replaces the
manual copy-paste that `pi/AGENTS.workflow-section.md` asked for and that went stale.

### Changes Required

#### 1. The split

**Ships** (`instructions/core.md`), portable and non-identifying: commit style, tone, debugging
discipline, objectivity, the verification-primitive ranking, author bias, grounded claims,
engineering principles, context budget, agent loop efficiency, workflow entry points.

**Does not ship** (`instructions/references/*.local.md`, gitignored, generated from the live file on
first run): `~/bin`, searxng on `localhost:8888`, `~/local-ai-stack.md`, `~/.claude/machine-fixes.md`,
`~/.claude/security-defaults.md`, named MCP servers (`MCP_DOCKER`, `claude-in-chrome`,
`cloudflare-browser`), the `2bTwist` GitHub handle, and the email address.

`instructions/core.md` refers to these by role, not by path, so a stranger cloning the repo gets
working guidance and the user's machine keeps its specifics:

```markdown
Before: For recurring Mac issues, read `~/.claude/machine-fixes.md`.
After:  For recurring environment issues, read your machine-fixes reference if you keep one.
```

Ship `instructions/references/README.md` documenting the convention and how to write your own.

#### 2. Managed block

```markdown
<!-- BEGIN dotagents (managed) - edits below are overwritten on install -->
...rendered from instructions/core.md...
<!-- END dotagents -->
```

The installer replaces only between the markers, appending the block if absent. Everything outside is
never touched, which is what makes this safe to run against an existing `CLAUDE.md`.

#### 3. Per-harness preamble

**Files**: `instructions/preamble/{claude,codex,pi,agents}.md`

Prepended outside the managed block, harness-specific and not overwritten. Pi's carries the real
environment section from `~/.pi/agent/AGENTS.md` ("You are running inside Pi", the tool list, the
local-model honesty note), which is genuinely Pi-specific and must survive.

### Success Criteria

#### Automated Verification
- [ ] `grep -rniE 'ndanjiedmond|2bTwist|localhost:8888|~/bin|local-ai-stack|machine-fixes|MCP_DOCKER' instructions/core.md` returns nothing
- [ ] Installing twice is idempotent: second run leaves the target file byte-identical
- [ ] Content outside the markers survives: seed a file with a sentinel line, install, assert the sentinel remains
- [ ] `instructions/references/*.local.md` is gitignored: `git check-ignore` succeeds

#### Manual Verification
- [ ] `instructions/core.md` still reads as the user's actual preferences, not a generic doc
- [ ] Each of the three live instruction files, after install, is at least as good as today's hand-written version
- [ ] Nothing personally identifying is left in anything the repo tracks

**After this phase passes automated verification, pause for manual confirmation before the next phase.**

---

## Phase 5: The autoresearch multi-target case

### Overview

`autoresearch` is the hardest packaging case: a skill, a slash command, a hook script, and a manual
`settings.json` edit. It is vendored from `drivelineresearch/autoresearch-claude-code` and is the one
component that genuinely cannot install anywhere but Claude Code.

### Changes Required

**File**: `domain-skills/claude/autoresearch/` moves to `optional/autoresearch/`

Tag the package `requires: [hooks, slash-commands]`, which only the Claude adapter satisfies. Every
other adapter declines it by name and prints why, rather than installing a skill whose autonomous loop
is sustained by a hook that will never fire.

Keep it opt-in behind `--with-optional` (renamed from `--with-domain-skills`, since ASO is gone and
`domain-skills` no longer describes the contents). Keep copying the hook rather than symlinking, since
it needs a stable absolute path (`install.sh:132`). Keep printing the manual `settings.json` step, and
keep the existing already-wired detection at `install.sh:143`.

Record upstream provenance in `optional/autoresearch/UPSTREAM.md`: source repo, vendored commit, and
that `~/.claude/skills/autoresearch` is a symlink into a separate local clone, so three copies exist
and this one is the vendored snapshot.

### Success Criteria

#### Automated Verification
- [ ] `./install.sh --target=codex --with-optional` installs no autoresearch file and prints the reason
- [ ] `./install.sh --target=claude --with-optional --dry-run` lists skill, command, and hook
- [ ] Hook is copied never symlinked, and is executable, even under `--symlink`
- [ ] `optional/autoresearch/UPSTREAM.md` records repo and commit

#### Manual Verification
- [ ] The manual settings.json instruction still prints and is still correct
- [ ] Running with autoresearch already wired reports it rather than duplicating

**After this phase passes automated verification, pause for manual confirmation before the next phase.**

---

## Phase 6: Rename, README, and delete the dead weight

### Overview

Rename to `dotagents`, rewrite the README against what the repo actually contains, and delete what the
restructure obsoletes. Last, so nothing is renamed while still being edited.

### Changes Required

#### 1. Delete

| Path | Reason |
|---|---|
| `pi/` | Superseded by `install.d/pi.sh` |
| `SKILLS-CLEANUP.md` | June cleanup, complete; its rulings are captured in this plan |
| `specs/handoffs/2026-06-17_1440-skills-cleanup.md` | Same |
| `domain-skills/` | Emptied by the move to `optional/` |

#### 2. Rename

`LICENSE:3` does not name the repo, so it is untouched. Blast radius:

- `README.md`: title, clone URL, install instructions
- `install.sh:3`: header comment
- `specs/` mentions of `dotclaude`
- GitHub repo rename, a user action; the remote is `git@github.com:2bTwist/dotclaude.git` and GitHub
  redirects the old URL
- local directory rename, a user action

#### 3. README rewrite

Correct the three standing errors: it tabulates 7 slash commands that are skills, its "Skills" line
names 2 of 20, and its domain-skills line still advertises the ASO skills removed in `a504cf1` and
`ea6b6f8`. Add: target matrix with per-harness skip reasons, the adapter contract for adding a
harness, and an explicit statement that Matt Pocock's skills are no longer bundled and where to get
them. Keep the existing humanlayer, Matt Pocock, Driveline, and Pierre credits, and add Theo (t3.gg)
for the `codex-*` skills and animations.dev for `animation-vocabulary`.

No em dashes anywhere in the README, per the user's tone rule.

### Success Criteria

#### Automated Verification
- [x] No stale references: `grep -rn "dotclaude" . --exclude-dir=.git` returns nothing outside `specs/plans/`
      NARROWED. Nothing ships with the old name: `README.md` and `install.sh` are clean. What remains
      is dated records under `specs/handoffs/` that describe the rename task itself, plus literal
      `/private/tmp/...-dotclaude/` scratchpad paths. Rewriting those would make a historical record
      inaccurate about what existed when it was written. The identity fields that WOULD be wrong after
      the rename were fixed: `repository:` in both handoff frontmatters and the stale absolute repo
      path in `specs/research/2026-08-09-skill-drift.md:14`.
- [x] Deleted paths are gone: `test ! -d pi && test ! -d domain-skills && test ! -f SKILLS-CLEANUP.md`
- [x] No em dashes in the README: `grep -n "—" README.md` returns nothing
- [x] Every skill named in the README exists: cross-check the table against `ls skills/`
      All 16 named, all 16 exist, none unmentioned (checked both directions).
- [x] Full suite green: `test/install-smoke.sh` 297, `instructions-smoke.sh` 158,
      `optional-smoke.sh` 41, 0 failed. `shellcheck -S warning` exits 0.

#### Manual Verification
- [x] A clean clone into a fresh temporary HOME installs correctly for all four targets
      claude 16 skills + 3 native agents + autoresearch; codex 15 + 3 TOML agents (`agent-latency-audit`
      skipped); pi 14 + 3 demoted (`rigor` also skipped); generic 14 + 3 demoted. No `harness:` key
      leaked into any installed file. CAVEAT: nothing is committed yet, so the clone was overlaid with
      the working tree. That also means the clone carried the gitignored `references/*.local.md`; a
      real clone installs only `references/README.md`.
- [ ] README is accurate to a stranger, with no unstated dependency on this machine
- [ ] User renames the GitHub repo and the local directory

---

## Testing Strategy

The load-bearing check is `test/install-smoke.sh`, and it is a constraint over produced state rather
than an interaction test: it asserts the installed inventory against the canonical source, an oracle
derived from the requirement rather than from the installer's own behavior.

The red-first run in Phase 2 is what makes it trustworthy. The current installer fails the
installed-count assertion for the real reason, so the test is proven to catch the exact class of
defect that has been live and undetected.

- Constraint, per target: installed set equals canonical set minus unsatisfied `requires`
- Constraint: no repo-only frontmatter key (`harness:`) reaches any installed file
- Idempotence: second install is a no-op; `--dry-run` writes nothing
- Preservation: content outside the managed instructions markers survives, verified with a sentinel
- End to end, manual and irreducible: clean clone, fresh HOME, install each target, then start each
  harness and invoke a skill. Nothing cheaper substitutes for driving the real path.

Not automatable and explicitly left manual: whether a translated Codex agent behaves correctly when
dispatched, and whether Pi's system prompt stays small.

## Migration Notes

The user's live installs become generated artifacts. Recommended first real run is `--symlink`, so
editing a skill in the repo takes effect immediately and there is no push step to forget. This is the
direct replacement for the "edit live, then copy to the repo" workflow in `SKILLS-CLEANUP.md:14`, and
it is what stops the fork from reforming.

Before the first non-dry install, back up `~/.claude/skills`, `~/.codex/skills`, and `~/.pi/agent`.
The 9 dropped skills stay in `~/.claude/skills/` and keep working; they are simply no longer this
repo's responsibility, and Claude Code also serves them from the plugin.

`~/.codex/skills/` currently holds hand-copied variants that this installer will overwrite under
`--force`. Phase 0's merge report is the only record of what those variants contained, which is why it
is written down rather than done in-session.

## References

- Task: harness-agnostic restructure, decisions settled in session 2026-08-09
- Drift report, produced in Phase 0: `specs/research/2026-08-09-skill-drift.md`
- Prior cleanup and its rulings: `SKILLS-CLEANUP.md:9,14,55,62,69`
- Broken installer: `install.sh:17,93,132,143`
- Codex agent format precedent: `~/.codex/agents/tldraw-offline.toml`
- Pi environment preamble to preserve: `~/.pi/agent/AGENTS.md`
- Relevant installed skill: `implement` - invoke to execute this plan phase by phase
