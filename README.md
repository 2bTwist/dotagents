# dotclaude

My opinionated, always-updating list of workflows and skills for working with AI coding agents. Built primarily for **Claude Code**, but agent-agnostic in spirit, the same slash commands and sub-agents are ported to **Pi** (local-model CLI).

Slash commands, sub-agents, skills, and memory templates that treat context as a first-class resource: plan in short compacted artifacts, let sub-agents do heavy reading in forked context, keep the human reviewing at the highest-leverage point.

Open source under MIT. Fork it, adapt it, or drop it in as-is.

## Install

```bash
git clone https://github.com/2bTwist/dotclaude.git
cd dotclaude
./install.sh
```

Auto-detects which harnesses are on your `PATH` and installs for each (`~/.claude/` for Claude Code, `~/.pi/agent/` for Pi). Flags: `--claude-only`, `--pi-only`, `--symlink`, `--force`, `--dry-run`, `--with-domain-skills`. Start a fresh session after install.

## What's included

**Slash commands** (Claude Code, with Pi variants where noted):

| Command | Purpose |
|---|---|
| `/groundwork` | Lay the foundation for a task class that's new in the repo. Crawls skill collections, vendor docs, and reference repos, then writes a phased plan. Claude only. |
| `/first-principles` | Re-frame a task from scratch: name the incumbent approach, question its assumptions, decompose into primitives, rebuild the one worth rethinking. Claude only. |
| `/research` | Map how an area of the codebase works today. Parallel sub-agents, strict no-recommendations rule. |
| `/plan` | Turn a task into a phased plan with code snippets and per-phase verification. |
| `/implement` | Execute a plan phase by phase, pausing for manual verification. |
| `/compact` | Mid-session compaction to disk for a clean restart. Claude only (Pi has its own). |
| `/oneshot` | Escape hatch for small tasks. Skip the full loop with guardrails against scope creep. |
| `/rigor` | Gate an investigation or benchmark behind grounded method, then refute it. Claude only. |

**Sub-agents** (Claude): `codebase-locator` (where does X live), `codebase-analyzer` (how does X work), `codebase-pattern-finder` (show me examples of X). On Pi these are user-invoked skills.

**Skills**: `grill-me` (interrogates a vague idea before it becomes a plan), `first-principles` (backs the slash command).

**Memory templates** (`memory-templates/`): sample memory files to seed a per-project memory directory.

**Domain skills** (`domain-skills/`, opt-in via `--with-domain-skills`): my own non-methodology skills (ASO audits, App Store keyword ranks, autonomous optimization loops). Skip the flag if you don't want them.

## Typical workflow

```
/research how does the auth flow work today?   -> specs/research/<date>-auth-flow.md
/plan <research doc> add passkey support       -> specs/plans/<date>-add-passkey.md
/implement <plan doc>                          -> phase by phase, you verify between
```

Reach for `/groundwork` upstream of `/plan` for task classes new to the repo. Use `/oneshot` or just talk to the agent for small tweaks. The full loop is for hard problems, not every task.

## Philosophy

1. **Frequent intentional compaction.** Keep context lean; compact to disk when it fills.
2. **Sub-agents are for context control, not role-play.** They fork to read and return a compressed answer.
3. **Research documents what IS, not what SHOULD BE.** Recommendations pollute the plan phase.
4. **Read files fully.** Partial reads cause hallucinated plans.
5. **Leverage hierarchy.** Bad research beats bad plan beats bad code. Review goes up the stack.

## Customize

Prompt files are just markdown with YAML frontmatter, edit freely (swap `pnpm` for `npm`, change spec paths, whatever). If your opinions differ a lot, fork it.

## Credits

Built on Dex Horthy / HumanLayer's [Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents); commands and agents adapted from [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)'s `.claude/` (Apache 2.0). Pi variants target Mario Zechner's [Pi](https://github.com/badlogic/pi-mono). `grill-me` vendored from [Matt Pocock](https://github.com/mattpocock/skills) (MIT). `autoresearch` vendored from [Driveline Research](https://github.com/drivelineresearch/autoresearch-claude-code) (MIT). `/first-principles` draws on [Pierre Computer Company](https://pierre.computer), Bret Victor, and Christopher Alexander.

## License

MIT. See [LICENSE](./LICENSE). Portions adapted from humanlayer/humanlayer under Apache 2.0.
