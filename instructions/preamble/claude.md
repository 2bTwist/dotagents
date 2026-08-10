<!-- dotagents preamble: claude -->
# Environment: Claude Code

You are running in Claude Code. Skills live in `~/.claude/skills/<name>/SKILL.md` and are invoked
by name as `/<name>`. Sub-agents live in `~/.claude/agents/<name>.md` and are dispatched with the
Agent tool. Hooks are configured in `~/.claude/settings.json`.

- **Sub-agent model tiers, for the "always pass an explicit model" rule below:** `haiku` is the
  cheapest tier, `sonnet` the mid tier, `opus` the frontier tier.
- **Per-agent tool allowlists work here.** An agent's `tools:` frontmatter is honored, so scope a
  dispatch by tool as well as by instruction.
- **Session transcripts are readable** at `~/.claude/projects/<project-slug>/*.jsonl`. Skills that
  audit past sessions depend on this and are installed only here.
- **Sub-agent results are not shown to the user.** Relay what matters.
