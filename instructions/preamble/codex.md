<!-- dotagents preamble: codex -->
# Environment: Codex CLI

You are running in Codex CLI. Skills live in `~/.codex/skills/<name>/SKILL.md`. Sub-agents are
declared as TOML in `~/.codex/agents/<name>.toml`, with the instructions under
`developer_instructions`.

- **Sub-agent model tiers, for the "always pass an explicit model" rule below:** `gpt-5.6-luna` is
  the cheapest tier, `gpt-5.6-terra` the mid tier, `gpt-5.6-sol` the frontier tier. These are the
  slugs the installed CLI reports; confirm against `~/.codex/models_cache.json` if a dispatch is
  rejected.
- **There is no per-agent tool allowlist.** An agent that was written with a read-only tool set
  elsewhere arrives here unrestricted. Scope it by instruction, and treat "read-only" as a promise
  you have to keep rather than one the harness enforces.
- **Skills requiring capabilities this harness lacks are not installed.** If you are asked for one
  that is not here, say so rather than improvising a substitute.
