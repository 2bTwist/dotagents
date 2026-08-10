# dotagents

One canonical set of skills, sub-agents, and instructions, plus adapters that install them into
Claude Code, Codex CLI, Pi, or any harness that reads `AGENTS.md`.

The content is written once. Harness-specific knowledge (where files go, how sub-agents are
declared, which frontmatter keys to strip) lives in `install.d/<target>.sh` and nowhere else. That
split is the whole point: before it existed, the same skills were maintained as three hand-copied
forks that drifted apart in content, not just in frontmatter.

The methodology is context engineering: plan in short compacted artifacts, let sub-agents do heavy
reading in forked context, keep the human reviewing at the highest-leverage point.

Open source under MIT. Fork it, adapt it, or drop it in as-is.

## Install

```bash
git clone https://github.com/2bTwist/dotagents.git
cd dotagents
./install.sh
```

With no arguments it installs into every harness it detects on the machine. Start a fresh session in
each harness afterwards.

| Flag | Effect |
|---|---|
| `--target=<name>` | Install one harness. Repeatable. `claude`, `codex`, `pi`, `agents`. |
| `--dest=<path>` | Where `--target=agents` writes. Required for that target only. |
| `--list` | Print what would install where, and what is skipped and why. Writes nothing. |
| `--dry-run` | Run the full install path, write nothing. |
| `--force` | Overwrite files that already exist. Without it, existing files are left alone. |
| `--symlink` | Link instead of copy, so repo edits apply live. Frontmatter is not rewritten in this mode. |
| `--with-optional` | Also install `optional/` packages. |

`--symlink` and frontmatter stripping are mutually exclusive by design. A symlink points at the repo
file, so repo-only keys such as `harness:` stay visible to the harness. Use copy mode if that
matters, symlink mode if live editing matters more.

## Targets

| Target | Root | Sub-agents | Not installed here |
|---|---|---|---|
| `claude` | `~/.claude` | Native, markdown with frontmatter | nothing |
| `codex` | `~/.codex` | Native, translated to TOML | `agent-latency-audit`, `autoresearch` |
| `pi` | `~/.pi/agent` | No sub-agent concept, demoted to user-invoked skills | `agent-latency-audit`, `rigor`, `autoresearch` |
| `agents` | wherever `--dest` points | Assumed absent, demoted to skills | `agent-latency-audit`, `rigor`, `autoresearch` |

Nothing in that last column is a bug or a gap to fill later. Each entry is a skill whose core
mechanism the harness cannot provide, declined by name rather than installed as something that would
read like it works and then quietly do nothing.

Pi installs into `~/.pi/agent/skills`, deliberately not `~/.agents/skills`. Pi auto-loads both, and
the second was emptied on purpose to keep Pi's system prompt small.

## What is included

### Skills

| Skill | What it does |
|---|---|
| `groundwork` | Lay the foundation for a task class new to the repo. Fetches canonical guidance, finds reference implementations, compares against the repo, writes a phased plan. |
| `first-principles` | Re-frame a task from scratch: name the incumbent approach, question its assumptions, decompose into primitives, rebuild the one worth rethinking. |
| `research` | Map how an area works today, in the codebase or on the web. Parallel sub-agents, strict no-recommendations rule. |
| `plan` | Turn a task into a decision-complete phased plan with per-phase verification. |
| `implement` | Execute a plan one phase at a time, pausing for manual verification between phases. |
| `oneshot` | Escape hatch for small contained tasks, with guardrails against scope creep. |
| `compact` | Mid-session compaction to a handoff file, so work resumes in a fresh session with nothing lost. |
| `rigor` | Gate an investigation or benchmark behind grounded method, then try to refute it. |
| `agent-latency-audit` | Attribute an agent session's wall-clock time across inference, tool execution, approval waits, and external processes. |
| `design-engineering` | Design direction and taste for UI work, applied before markup rather than after. |
| `animation-vocabulary` | Reverse-lookup glossary for naming a motion effect precisely. |
| `perf-harness-init` | Scaffold the performance harness (budgets, measurement engines, verifier CLI, CI) into a React or web project. |
| `perf-loop` | Diff-driven browser test and performance optimization loop that runs until budgets pass. |
| `codex-review` | Get an independent review of a diff from Codex CLI, verified against the code before relaying. |
| `codex-implementation` | Delegate a scoped change to Codex CLI, then inspect its diff and verification. |
| `codex-imagegen` | Generate or edit real image files through Codex CLI's bundled imagegen skill. |

### Sub-agents

`codebase-locator` (where does X live), `codebase-analyzer` (how does X work), `codebase-pattern-finder`
(show me examples of X). All three are read-only and forbidden from suggesting changes, because their
job is to return a compressed answer about what exists, not an opinion about it.

Claude Code and Codex CLI get them as native sub-agents. Pi and the generic target get them as skills
you invoke yourself, which loses the forked context but keeps the instructions.

### Instructions

`instructions/core.md` is one portable document rendered into each harness's instructions file inside
a managed block:

```
<!-- BEGIN dotagents (managed) - edits below are overwritten on install -->
...
<!-- END dotagents -->
```

Only the block is replaced. Anything you hand-wrote outside it survives every later install. Each
harness also gets a preamble from `instructions/preamble/<target>.md`, seeded once above the block
and never overwritten, which is where harness quirks get added by hand.

Machine-specific details (tool inventories, local paths, hardware) belong in
`instructions/references/*.local.md`, which is gitignored. A clone carries only
`instructions/references/README.md` describing the convention. This keeps `core.md` portable: it
refers to local references by role, so it renders identically on any machine.

### Optional packages

`optional/` holds things that are not part of the core methodology and are not portable.
`--with-optional` installs them. Each declares its needs in a `PACKAGE` file and is skipped by name
on any harness that cannot satisfy them.

Currently one: `autoresearch`, an autonomous experiment loop vendored from Driveline Research. It
needs `hooks` and `slash-commands`, so it installs on Claude Code only. See
`optional/autoresearch/UPSTREAM.md` for the pinned commit and which files are byte-identical to
upstream.

### Memory templates

`memory-templates/` holds sample memory files for seeding a per-project memory directory. The
installer does not touch them. Copy them by hand into a project when you want them.

## Capability gating

A skill declares what it needs from the harness in its frontmatter:

```yaml
harness:
  requires: [claude-transcripts]   # skipped entirely where unavailable
  degrades: [subagents]            # installed, with a warning naming what is missing
```

The vocabulary is `subagents`, `claude-transcripts`, `mcp-browser`, `hooks`, and `slash-commands`.
Each adapter lists what its harness has in `HARNESS_CAPS`.

`requires` is for a skill whose core mechanism is the capability. `agent-latency-audit` parses Claude
Code session transcripts, so without them it has nothing to read. `degrades` is for a skill that
still works but does less. `research` fans out to sub-agents when it can and reads serially when it
cannot, so it installs everywhere and says so.

Run `./install.sh --list` to see every decision before making any of them.

## Adding a harness

Write `install.d/<name>.sh` and add the name to `ALL_TARGETS` in `install.sh`. Read
`install.d/_lib.sh` first: it holds the shared helpers, and every write goes through its `do_*`
functions so `--dry-run` is enforced in one place rather than reimplemented per adapter.

The contract is three variables and six functions:

```bash
HARNESS_NAME="..."        # label used in output
HARNESS_CAPS="..."        # space-separated capabilities this harness provides
HARNESS_DROP_KEYS="..."   # frontmatter keys to strip on install; always includes `harness`

harness_detect()               # exit 0 if this harness is present on the machine
harness_root()                 # its config directory
harness_skills_dir()           # where skills live
harness_skill_dest <name>      # destination directory for one skill
harness_agent_install <md>     # install one sub-agent, however this harness models them
harness_instructions_dest()    # the file the managed block is written into
```

`install.d/claude.sh` is the reference implementation and the shortest. `install.d/codex.sh` shows a
non-trivial `harness_agent_install`, translating markdown sub-agents into Codex TOML including a
model tier map. `install.d/pi.sh` shows the demote-to-skill fallback.

Bash on macOS is 3.2, so the adapters avoid `mapfile` and `declare -A` and guard every array
expansion under `set -u`.

## Not bundled

Matt Pocock's skills used to ship here and no longer do. They are his work, they are maintained
upstream, and vendoring them meant carrying a copy that drifted. Get them from
[mattpocock/skills](https://github.com/mattpocock/skills). Claude Code users can also install the
`mattpocock-skills` plugin, which serves them directly.

The same applies to anything in `optional/`: `UPSTREAM.md` records where it came from, and upstream
is the place to get updates.

## Typical workflow

```
/research how does the auth flow work today?   -> specs/research/<date>-auth-flow.md
/plan <research doc> add passkey support       -> specs/plans/<date>-add-passkey.md
/implement <plan doc>                          -> phase by phase, you verify between
```

Reach for `/groundwork` upstream of `/plan` for task classes new to the repo. Use `/oneshot` or just
talk to the agent for small tweaks. The full loop is for hard problems, not every task.

## Philosophy

1. **Frequent intentional compaction.** Keep context lean; compact to disk when it fills.
2. **Sub-agents are for context control, not role-play.** They fork to read and return a compressed answer.
3. **Research documents what IS, not what SHOULD BE.** Recommendations pollute the plan phase.
4. **Read files fully.** Partial reads cause hallucinated plans.
5. **Leverage hierarchy.** Bad research beats bad plan beats bad code. Review goes up the stack.

## Verify

Three suites, each resolving the repo root from its own location rather than the working directory:

```bash
./test/install-smoke.sh        # installer, adapters, capability gating
./test/instructions-smoke.sh   # managed block, preambles, references
./test/optional-smoke.sh       # optional package contract
shellcheck -S warning install.sh install.d/*.sh optional/*/install.sh test/*.sh
```

The suites assert installed state against the canonical source, which is an oracle derived from the
requirement rather than from the installer's own behavior.

## Customize

Skills are markdown with YAML frontmatter. Edit freely: swap `pnpm` for `npm`, change spec paths,
rewrite `instructions/core.md` to your own preferences. If your opinions differ a lot, fork it.

## Credits

Built on Dex Horthy / HumanLayer's
[Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents);
skills and agents adapted from [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)'s
`.claude/` (Apache 2.0). The Pi target follows Mario Zechner's
[Pi](https://github.com/badlogic/pi-mono). Earlier versions vendored skills from
[Matt Pocock](https://github.com/mattpocock/skills) (MIT); they are no longer bundled, see
[Not bundled](#not-bundled). `autoresearch` vendored from
[Driveline Research](https://github.com/drivelineresearch/autoresearch-claude-code) (MIT). The
`codex-*` skills follow Theo Browne's [t3.gg](https://t3.gg) approach of running a second coding
agent as an independent reviewer and implementer. `animation-vocabulary` is distilled from Emil
Kowalski's [animations.dev](https://animations.dev/vocabulary). `first-principles` draws on
[Pierre Computer Company](https://pierre.computer), Bret Victor, and Christopher Alexander.

## License

MIT. See [LICENSE](./LICENSE). Portions adapted from humanlayer/humanlayer under Apache 2.0.
