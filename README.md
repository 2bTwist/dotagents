# dotclaude

My portable coding-agent setup. Slash commands, sub-agents, prompt templates, skills, and memory templates that implement Dex Horthy's [Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents) methodology across both **Claude Code** and **Pi** (local-model CLI agent).

Open source under MIT. Fork it, adapt it, or drop it in as-is.

---

## Why this exists

Coding agents work great on greenfield toys. On real, brownfield codebases, the default loop (chat back and forth until you run out of context) produces slop. Dex Horthy's ACE-FCA methodology fixes that by treating context like a first-class resource: plan your work in short compacted artifacts, let sub-agents handle heavy reading in forked context windows, and keep the human reviewing at the highest-leverage point in the pipeline.

This repo is a concrete, opinionated implementation of that methodology, installed globally so every coding-agent session has access to the same commands and sub-agents regardless of which harness or repo you're in.

## Credit upfront

Everything in `.claude/commands/` and `.claude/agents/` is adapted from [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)'s `.claude/` directory with project-specific bits stripped out. The Pi variants under `pi/` are the same prompts adapted for [Pi](https://github.com/badlogic/pi-mono)'s prompt-template and skill systems. If this kit saves you time, thank Dex.

See [Credits & attribution](#credits--attribution) for the full list.

---

## Install

```bash
git clone https://github.com/2bTwist/dotclaude.git
cd dotclaude
./install.sh
```

The installer auto-detects which harnesses are on your `PATH` and installs for each:

- If Claude Code is in use, it populates `~/.claude/commands/` and `~/.claude/agents/`
- If `pi` is on `PATH`, it populates `~/.pi/agent/prompts/` and `~/.pi/agent/skills/` and reminds you to append the workflow section to your `~/.pi/agent/AGENTS.md`

Flags:
- `./install.sh --claude-only` — only Claude Code files
- `./install.sh --pi-only` — only Pi files
- `./install.sh --symlink` — symlink instead of copy (edits in this repo apply immediately)
- `./install.sh --force` — overwrite existing files
- `./install.sh --dry-run` — show what would happen

After install, start a fresh agent session. Slash commands appear automatically.

---

## What's included

### For Claude Code (`.claude/`)

**Slash commands** (`.claude/commands/`):

| Command | Purpose | Model |
|---|---|---|
| `/groundwork` | Lay the foundation before acting on a task class that's new in the repo. Crawls published agent-skill collections, vendor docs, and 2-3 reputable reference repos, then writes a phased cleanup plan at `specs/plans/YYYY-MM-DD-groundwork-<slug>.md`. Hands off to `/grill-me` and `/implement`. Topic-agnostic: no hardcoded task classes, authors, or stacks. | `opus` |
| `/research` | Map how an area of the codebase works today. Spawns parallel sub-agents, synthesizes to `specs/research/YYYY-MM-DD-<slug>.md`. Strict no-recommendations rule. | `opus` |
| `/plan` | Turn a task (plus optional research doc) into a phased plan at `specs/plans/YYYY-MM-DD-<slug>.md`. Interactive, skeptical, includes code snippets and split automated/manual verification per phase. | `opus` |
| `/implement` | Execute a plan phase by phase. Ticks automated checkboxes. Pauses for manual verification between phases. Stops on mismatch. | inherit |
| `/compact` | Mid-session intentional compaction. Writes state to `specs/handoffs/` for clean session restart. | inherit |
| `/oneshot` | Escape hatch for small tasks (rename, color change, one-line fix). Skip full RPI with hard guardrails against scope creep. | inherit |

**Sub-agents** (`.claude/agents/`):

| Agent | Purpose | Tools | Model |
|---|---|---|---|
| `codebase-locator` | "Where does X live?" Returns file paths grouped by purpose. Never reads file contents. | Grep, Glob, LS | `sonnet` |
| `codebase-analyzer` | "How does X work?" Reads files, returns file:line-anchored explanations. No critique. | Read, Grep, Glob, LS | `sonnet` |
| `codebase-pattern-finder` | "Show me existing examples of pattern X." Returns actual working code. | Grep, Glob, Read, LS | `sonnet` |

**Skills** (`.claude/skills/`):

| Skill | Purpose |
|---|---|
| `grill-me` | Interviews you relentlessly about a plan or design. Pairs upstream of `/plan` to stress-test a vague idea before it becomes a plan. Vendored from [mattpocock/skills](https://github.com/mattpocock/skills) under MIT. |

### For Pi (`pi/`)

**Prompt templates** (`pi/prompts/`):

| Command | Purpose |
|---|---|
| `/research` | Same idea as Claude's, but the sub-agent rules (locate → analyze → document) are inlined directly into the prompt. Pi has no model-dispatched sub-agents, so the main session walks the steps using grep/find/read. Writes to `specs/research/YYYY-MM-DD-<slug>.md`. |
| `/plan` | Phased plans at `specs/plans/YYYY-MM-DD-<slug>.md`. Tuned for smaller local models: fewer phases, shorter snippets. |
| `/implement` | Phase-by-phase execution with pauses for manual verification. |
| `/oneshot` | Small-task escape hatch. Same shape as Claude's. |

**No `/compact` for Pi.** Pi ships native `/compact` with auto-compaction and a well-designed structured summary format (Goal → Progress → Next Steps → Critical Context). Use Pi's version.

**No `/groundwork` for Pi.** Groundwork crawls multiple skill repos, vendor docs, and 2-3 reference codebases via `gh api`, WebFetch, and a parallel Explore sub-agent. That research load doesn't fit a 32k local-model context window, and Pi's web/search skills are opt-in rather than first-class. On Pi, do the foundation work in a Claude session and pick up at `/plan` and `/implement` locally if you want to keep execution off-device.

**Sub-agent skills** (`pi/skills/`) — user-invoked, optional:

| Skill | Purpose |
|---|---|
| `codebase-locator` | Invoke as `/skill:codebase-locator <question>`. Same rules as Claude's. |
| `codebase-analyzer` | Invoke as `/skill:codebase-analyzer <question>`. |
| `codebase-pattern-finder` | Invoke as `/skill:codebase-pattern-finder <question>`. |
| `grill-me` | Invoke as `/skill:grill-me <idea or plan>`. Same skill as Claude's, vendored from Matt Pocock. |

Pi skills are **user-triggered slash commands**, not model-dispatched sub-agents. Typing `/skill:codebase-locator ...` loads that skill's rules into your current Pi session. The model cannot invoke skills on its own — they are a user control, not a callable tool. The `/research` and `/plan` prompt templates don't rely on skills; they inline the same discipline directly, so the workflow works whether or not you invoke the skills manually. Use the skills when you want a single-purpose, scoped session.

**AGENTS.md workflow section** (`pi/AGENTS.workflow-section.md`): A snippet to append to your `~/.pi/agent/AGENTS.md` that teaches Pi about the new commands and skills. The installer does not overwrite your existing `AGENTS.md` — copy the section manually.

### Memory templates (`memory-templates/`)

Sample generic memory files (`preferences.md`, `collaboration.md`, `MEMORY.md` index) showing the structure. Drop them into your per-project memory directory as a starting point and customize. These are templates, not prescriptive. Claude Code memory lives at `~/.claude/projects/<encoded-path>/memory/` per project.

---

## Typical workflow

Same shape on both harnesses. Example for Claude Code:

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

For task classes that are **new in the repo** (first time adding rate limiting, first background job system, brand-new project type), reach for `/groundwork` upstream of `/plan`. It crawls canonical guidance and 2-3 reference repos and writes a phased cleanup plan you can hand straight to `/grill-me` and `/implement`. Skip it for work that has prior art in the repo — `/research` already covers that ground.

For small tweaks: skip RPI, use `/oneshot` or just talk to the agent directly. RPI is for hard problems, not every task.

For mid-session drift: Claude uses `/compact`, Pi uses its built-in `/compact`. Both dump state for a clean session restart.

### Local-model honesty (Pi)

On `qwen2.5-coder:7b` with a 32k context window, expect shorter plans, narrower research scopes, and more iteration than the same workflow on a frontier model. For harder reasoning, switch to a 9B reasoning model via `pi --model qwen3.5:9b`. The prompts are tuned for this — e.g. `/plan` on Pi will prefer 2-3 phases over 5.

---

## Philosophy (what's baked in)

Five principles run through every prompt in this kit:

1. **Frequent intentional compaction.** Keep context at 40–60% utilization. When it fills up, compact to disk and restart. [Dex's "dumb zone" concept.](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)
2. **Sub-agents are for context control, not role-play.** No "frontend-engineer" or "QA" agents. Only agents that fork (Claude) or scope (Pi) to handle heavy reading and return a compressed answer.
3. **Research documents what IS, never what SHOULD BE.** Recommendations pollute the plan phase. The researcher's hard rule: no suggestions, no critique, no "should."
4. **Read files fully.** No `limit`/`offset`. Partial reads cause hallucinated plans.
5. **Leverage hierarchy.** Bad research beats bad plan beats bad code. Put human review at the top of the stack, not the bottom.

These aren't abstract — they're enforced by the prompts themselves. Every documentarian agent or skill has a "CRITICAL: YOUR ONLY JOB IS TO DOCUMENT" block. Every file-reading instruction says "read fully."

---

## Customize

- **Prompt files are just markdown** with YAML frontmatter. Edit to fit your tooling (change `pnpm` to `npm`, swap verification commands, whatever).
- **Memory templates** are samples. Adapt them or ignore them.
- **Default spec paths** (`specs/research/`, `specs/plans/`, `specs/handoffs/`) are set in the prompts. Change them if your team has a different `docs/` or `specs/` convention.
- **Fork it.** If your opinions differ significantly, fork. That's the point of open source.

---

## Differences between the Claude and Pi versions

| Feature | Claude Code | Pi |
|---|---|---|
| Slash commands | Yes, via `~/.claude/commands/*.md` | Yes, via `~/.pi/agent/prompts/*.md` |
| Sub-agent dispatch | Parallel via `Task` tool, forked context | Sequential skill invocation, shared context |
| Model routing per command | `model: opus` / `model: sonnet` in frontmatter | Single session-wide model; switch via `pi --model <id>` |
| Intentional compaction | `/compact` writes to `specs/handoffs/` | Built-in `/compact` with structured summary |
| File-context auto-discovery | `CLAUDE.md` | `AGENTS.md` AND `CLAUDE.md` (Pi reads both) |
| Skills interop | Native skill loader | Native + can read `~/.claude/skills/` via settings |

---

## Resources

### Core material

- **[Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents)** — Dex Horthy's canonical write-up of the methodology. Start here.
- **[Y Combinator talk (Aug 2025)](https://www.youtube.com/watch?v=IS_y40zY-hc)** — the 20-minute condensed version. (Check `hlyr.dev/ace` for the current link.)
- **[humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)** — the actively-maintained source of the commands and agents in this kit. Has many more commands (`ralph_*`, `iterate_plan`, `debug`, `describe_pr`, etc.) that weren't ported here.
- **[12-Factor Agents](https://github.com/humanlayer/12-factor-agents)** — Dex's earlier framework on building reliable LLM applications. Foundational reading.
- **[12-Factor Agents talk, AI Engineer World's Fair 2025](https://www.youtube.com/watch?v=8kMaTybvDUw)** — one of the top-rated talks of the conference.

### Cited within the methodology

- **[Sean Grove — "Specs are the new code"](https://www.youtube.com/watch?v=8rABwKRsec4)** — AI Engineer 2025. The framing that specs/plans become the artifact, code becomes the build output.
- **[Yegor Denisov-Blanch — Stanford developer productivity study](https://www.youtube.com/watch?v=tbDDYKRFjhk)** — the data on AI coding tools creating rework in brownfield codebases.
- **[Geoff Huntley — "Ralph Wiggum as a software engineer"](https://ghuntley.com/ralph/)** — the "run an agent in a while loop" pattern. The original 170k-token context-window-as-resource framing.
- **[Blake Smith — "Code Review Essentials for Software Teams"](https://blakesmith.me/2015/02/09/code-review-essentials-for-software-teams.html)** — the mental-alignment framing for code review that Dex builds on.
- **[BAML (BoundaryML/baml)](https://github.com/BoundaryML/baml)** — the 300k LOC Rust codebase Dex used to prove the methodology works on real brownfield code.

### Claude Code ecosystem

- **[anthropics/claude-code](https://github.com/anthropics/claude-code)** — the CLI itself.
- **[Claude Code docs — sub-agents](https://docs.claude.com/en/docs/claude-code/sub-agents)** — official docs on custom sub-agent syntax.
- **[Claude Code docs — slash commands](https://docs.claude.com/en/docs/claude-code/slash-commands)** — official docs on custom slash commands.

### Pi ecosystem

- **[badlogic/pi-mono](https://github.com/badlogic/pi-mono)** — Mario Zechner's open-source coding-agent CLI. Monorepo; `@mariozechner/pi-coding-agent` is the installable package.
- **[pi.dev](https://pi.dev)** — project home page.
- **[Agent Skills standard](https://agentskills.io/specification)** — the spec Pi's skills implement. Anthropic-originated, harness-portable.
- **[badlogic/pi-skills](https://github.com/badlogic/pi-skills)** — community skill repo (web search, browser automation, transcription, etc.).
- **[anthropics/skills](https://github.com/anthropics/skills)** — Anthropic's reference skill collection (document processing, web dev).

---

## Credits & attribution

- **Dex Horthy ([@dexhorthy](https://github.com/dexhorthy))** and the **[HumanLayer](https://humanlayer.dev)** team — the methodology, the original prompts, and most of the structural choices in this kit. The commands and agents are adapted from [humanlayer/humanlayer/.claude](https://github.com/humanlayer/humanlayer/tree/main/.claude) with their names and core rules preserved. HumanLayer's code is Apache 2.0 licensed; adapted portions retain that attribution.
- **Mario Zechner ([@badlogic](https://github.com/badlogic))** — for [Pi](https://github.com/badlogic/pi-mono), the local-first coding-agent CLI. The prompt-template and skill architecture made porting this kit to Pi straightforward.
- **Matt Pocock ([@mattpocock](https://github.com/mattpocock))** — for the [grill-me skill](https://github.com/mattpocock/skills/tree/main/grill-me), vendored here under his MIT license. The "explore the codebase instead of asking" rule is a design insight worth studying. See [his writeup](https://www.aihero.dev/my-grill-me-skill-has-gone-viral).
- **Geoff Huntley ([@ghuntley](https://ghuntley.com))** — the "Ralph Wiggum" loop, the 170k-token resource framing, and the discipline of minimizing context window usage. This kit's compaction patterns trace back to his work.
- **Sean Grove** — the "specs are the new code" framing that underpins why `/research` and `/plan` produce persistent, reviewable artifacts.
- **Anthropic** for Claude Code and the Agent Skills standard.

---

## Contributing

Issues and PRs welcome. Keep in mind:

- This is an opinionated kit. PRs that change the opinions (e.g. "add more optional arguments") are less likely to land than PRs that fix bugs or tighten prompts.
- If you have a substantially different philosophy, **fork it**. That's encouraged.
- For typos, doc fixes, installer bugs, or generically useful command/skill additions, open a PR directly.

## License

MIT. See [LICENSE](./LICENSE).

Portions adapted from [humanlayer/humanlayer](https://github.com/humanlayer/humanlayer) under Apache 2.0.
