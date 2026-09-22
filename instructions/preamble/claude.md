<!-- dotagents preamble: claude -->
# Environment: Claude Code

- **Sub-agent model tiers, for the explicit-model rule in `references/agent-operations.md`:** `haiku` is the
  cheapest tier, `sonnet` the mid tier, `opus` the frontier tier.
- **Per-agent tool allowlists work here.** An agent's `tools:` frontmatter is honored, so scope a
  dispatch by tool as well as by instruction.
- **Session transcripts are readable** at `~/.claude/projects/<project-slug>/*.jsonl`. Skills that
  audit past sessions depend on this and are installed only here.
- **Keep replies brief.** The first sentence says what happened or what
  you found, with detail after it. Before the first tool call, say in one sentence what you're
  about to do; while working, update only when you find something or change direction.
