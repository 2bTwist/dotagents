# dotclaude

My Claude Code setup. Slash commands, sub-agents, and memory templates that implement Dex Horthy's [Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents) methodology globally across every Claude Code session.

Open source under MIT. Fork it, adapt it, or drop it in as-is.

---

## Why this exists

Claude Code works great on greenfield toys. On real, brownfield codebases, the default loop (chat back and forth until you run out of context) produces slop. Dex Horthy's ACE-FCA methodology fixes that by treating context like a first-class resource: plan your work in short compacted artifacts, let sub-agents handle heavy reading in forked context windows, and keep the human reviewing at the highest-leverage point in the pipeline.

This repo is a concrete, opinionated implementation of that methodology, installed globally so every Claude Code session has access to the same commands and agents regardless of which repo you're in.

## Credit upfront

Everything in `.claude/commands/` and `.claude/agents/` is adapted from [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)'s `.claude/` directory with project-specific bits stripped out. If this kit saves you time, thank Dex.

See [Credits & attribution](#credits--attribution) for the full list.

---

## Install

```bash
git clone https://github.com/2bTwist/dotclaude.git
cd dotclaude
./install.sh
```

The installer copies everything into `~/.claude/`. Run `./install.sh --symlink` instead if you want live updates (edits in the repo apply immediately to all sessions), or `./install.sh --force` to overwrite existing files.

After install, start a fresh Claude Code session. The slash commands (`/research`, `/plan`, `/implement`, `/compact`, `/oneshot`) and three sub-agents are available globally.

## What's included

### Slash commands (`.claude/commands/`)

| Command | Purpose | Model |
|---|---|---|
| `/research` | Map how an area of the codebase works today. Spawns parallel sub-agents, synthesizes to `specs/research/YYYY-MM-DD-<slug>.md`. Strict no-recommendations rule. | `opus` |
| `/plan` | Turn a task (plus optional research doc) into a phased plan at `specs/plans/YYYY-MM-DD-<slug>.md`. Interactive, skeptical, includes code snippets and split automated/manual verification per phase. | `opus` |
| `/implement` | Execute a plan phase by phase. Ticks automated checkboxes. Pauses for manual verification between phases. Stops on mismatch. | inherit |
| `/compact` | Mid-session intentional compaction. Writes state to `specs/handoffs/` for clean session restart. | inherit |
| `/oneshot` | Escape hatch for small tasks (rename, color change, one-line fix). Skip full RPI with hard guardrails against scope creep. | inherit |

### Sub-agents (`.claude/agents/`)

| Agent | Purpose | Tools | Model |
|---|---|---|---|
| `codebase-locator` | "Where does X live?" Returns file paths grouped by purpose. Never reads file contents. | Grep, Glob, LS | `sonnet` |
| `codebase-analyzer` | "How does X work?" Reads files, returns file:line-anchored explanations. No critique. | Read, Grep, Glob, LS | `sonnet` |
| `codebase-pattern-finder` | "Show me existing examples of pattern X." Returns actual working code. | Grep, Glob, Read, LS | `sonnet` |

### Memory templates (`memory-templates/`)

Sample generic memory files (`preferences.md`, `collaboration.md`, `MEMORY.md` index) showing the structure. Drop them into your per-project memory directory as a starting point and customize to your own rules. These are templates, not prescriptive.

---

## Typical workflow

For non-trivial work in a real codebase:

```
/research how does the auth flow work today?
  -> writes specs/research/2026-04-24-auth-flow.md
  -> read it, push back if the map is wrong

/plan specs/research/2026-04-24-auth-flow.md add passkey support
  -> interactive Q&A, writes specs/plans/2026-04-24-add-passkey-support.md
  -> read the plan, iterate until it's right

/implement specs/plans/2026-04-24-add-passkey-support.md
  -> executes phase 1, ticks automated boxes, pauses for manual check
  -> you verify, tell it to proceed to phase 2
  -> repeat
```

For small tweaks: skip RPI, use `/oneshot` or just talk to Claude directly. RPI is for hard problems, not every task.

For mid-session drift: `/compact` dumps state to a handoff file, start a fresh session with clean context.

---

## Philosophy (what's baked in)

Five principles run through every prompt in this kit:

1. **Frequent intentional compaction.** Keep context at 40–60% utilization. When it fills up, compact to disk and restart. [Dex's "dumb zone" concept.](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)
2. **Sub-agents are for context control, not role-play.** No "frontend-engineer" or "QA" agents. Only agents that fork a context window to handle heavy reading and return a compressed answer.
3. **Research documents what IS, never what SHOULD BE.** Recommendations pollute the plan phase. The researcher's hard rule: no suggestions, no critique, no "should."
4. **Read files fully.** No `limit`/`offset`. Partial reads cause hallucinated plans.
5. **Leverage hierarchy.** Bad research beats bad plan beats bad code. Put human review at the top of the stack, not the bottom.

These aren't abstract — they're enforced by the prompts themselves. Every documentarian agent has a "CRITICAL: YOUR ONLY JOB IS TO DOCUMENT" block. Every file-reading instruction says "no limit/offset."

---

## Customize

- **Slash commands are just markdown files** with YAML frontmatter. Open any file in `.claude/commands/`, edit to fit your tooling (change `pnpm` to `npm`, swap the verification commands, whatever).
- **Memory templates** in `memory-templates/` are samples. Your real memory lives at `~/.claude/projects/<encoded-path>/memory/` per project. Copy the templates, adapt them, or ignore them.
- **Default spec paths** (`specs/research/`, `specs/plans/`, `specs/handoffs/`) are set in the commands. Change them if your team already has a `docs/` or `specs/` convention you want to reuse.
- **Fork it.** If your opinions differ significantly, fork. That's the point of open source.

---

## Resources

### Core material

- **[Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents)** — Dex Horthy's canonical write-up of the methodology. Start here.
- **[Y Combinator talk (Aug 2025)](https://www.youtube.com/watch?v=IS_y40zY-hc)** — the 20-minute condensed version. (Note: check `hlyr.dev/ace` for the current link.)
- **[humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)** — the actively-maintained source of the commands and agents in this kit. Has many more commands (`ralph_*`, `iterate_plan`, `debug`, `describe_pr`, etc.) that weren't ported here.
- **[12-Factor Agents](https://github.com/humanlayer/12-factor-agents)** — Dex's earlier framework on building reliable LLM applications. Foundational reading.
- **[12-Factor Agents talk, AI Engineer World's Fair 2025](https://www.youtube.com/watch?v=8kMaTybvDUw)** — one of the top-rated talks of the conference.

### Cited within the methodology

- **[Sean Grove — "Specs are the new code"](https://www.youtube.com/watch?v=8rABwKRsec4)** — AI Engineer 2025. The framing that specs/plans become the artifact, code becomes the build output.
- **[Yegor Denisov-Blanch — Stanford developer productivity study](https://www.youtube.com/watch?v=tbDDYKRFjhk)** — the data on AI coding tools creating rework in brownfield codebases.
- **[Geoff Huntley — "Ralph Wiggum as a software engineer"](https://ghuntley.com/ralph/)** — the "run an agent in a while loop" pattern. The original 170k-token context-window-as-resource framing.
- **[Blake Smith — "Code Review Essentials for Software Teams"](https://blakesmith.me/2015/02/09/code-review-essentials-for-software-teams.html)** — the mental-alignment framing for code review that Dex builds on.
- **[BAML (BoundaryML/baml)](https://github.com/BoundaryML/baml)** — the 300k LOC Rust codebase Dex used to prove the methodology works on real brownfield code.

### Ecosystem

- **[anthropics/claude-code](https://github.com/anthropics/claude-code)** — the CLI itself.
- **[Claude Code docs — sub-agents](https://docs.claude.com/en/docs/claude-code/sub-agents)** — official docs on custom sub-agent syntax.
- **[Claude Code docs — slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands)** — official docs on custom slash commands.

---

## Credits & attribution

- **Dex Horthy ([@dexhorthy](https://github.com/dexhorthy))** and the **[HumanLayer](https://humanlayer.dev)** team — the methodology, the original prompts, and most of the structural choices in this kit. The commands and agents are adapted from [humanlayer/humanlayer/.claude](https://github.com/humanlayer/humanlayer/tree/main/.claude) with their names and core rules preserved. HumanLayer's code is Apache 2.0 licensed; adapted portions retain that attribution.
- **Geoff Huntley ([@ghuntley](https://ghuntley.com))** — the "Ralph Wiggum" loop, the 170k-token resource framing, and the discipline of minimizing context window usage. This kit's `/compact` command owes its shape to his compaction patterns.
- **Sean Grove** — the "specs are the new code" framing that underpins why `/research` and `/plan` produce persistent, reviewable artifacts.
- **Anthropic** for Claude Code itself.

---

## Contributing

Issues and PRs welcome. Keep in mind:

- This is an opinionated kit. PRs that change the opinions (e.g. "add more optional arguments") are less likely to land than PRs that fix bugs or tighten prompts.
- If you have a substantially different philosophy, **fork it**. That's encouraged.
- For typos, doc fixes, installer bugs, or generically useful command additions, open a PR directly.

## License

MIT. See [LICENSE](./LICENSE).

Portions adapted from [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer) under Apache 2.0.
