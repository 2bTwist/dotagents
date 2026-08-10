<!-- dotagents preamble: agents -->
# Environment: generic AGENTS.md harness

You are running in a harness that reads `AGENTS.md` and a sibling `skills/` directory. Nothing
beyond that is assumed.

- **Assume no sub-agents, no hooks, and no session-transcript store.** Skills requiring any of those
  are not installed here, and sub-agents from the canonical source arrive demoted to skills you
  invoke yourself. Where an instruction below says "dispatch a sub-agent", do that work inline and
  say that you did.
- **No sub-agent model tiers apply.** Ignore the "always pass an explicit model" rule; there is
  nothing to pass it to.
- **Skills are read on demand.** `skills/<name>/SKILL.md` next to this file. Read one before doing
  the kind of work it covers, not after.
