# Decision: trim the fixed context baseline before building any new agent tooling

**Date:** 2026-09-11
**Status:** executed 2026-09-11 (skills, plugin, repo move); all steps executed, measured
**Source evidence:** ~/Projects/specs/rigor/2026-09-11-next-agent-tooling-to-build.md

## Context
A census of 687 transcripts (119 sessions, 11 projects) measured where friction and
tokens go. Corrected, compaction-aware figures on main-thread input: fixed per-turn
baseline 17.2% (median 45,168 tokens at first turn, re-sent in full after every
compaction), subagent dispatches 26.5% of all input with no hypothesis yet, Bash file
dumps 7.1%, web-retrieval errors 41.6% of tool errors but concentrated in 5 sessions.
The user ran out of credits once and asked twice why ~63 skills cost ~9.1k tokens.

## Decisions
1. **Objective is token cost**, not reliability or capability. Fetch CLI and transcript
   CLI are deferred, not rejected.
2. **Trim first, then investigate subagents, then build.** No build starts until the
   subagent rigor pass reports. The Bash file-dump hook is designed (block repeated
   dumps of unchanged content with a pointer to where it was shown; hash by content;
   never suppress after Edit/Write to that path) but waits.
3. **Skill trim is invoked-only, triaged by hand.** Kept despite zero invocations:
   oneshot, plan (referenced by CLAUDE.md), prototype, show-me, grill-with-docs,
   improve-codebase-architecture, animation-vocabulary (referenced), emil-design-eng,
   codex-implementation, codex-review, tailscale. Archived: all 9 Cloudflare skills
   (agents-sdk, cloudflare, cloudflare-email-service, cloudflare-one,
   cloudflare-one-migrations, durable-objects, sandbox-sdk, turnstile-spin,
   workers-best-practices), setup-matt-pocock-skills, perf-harness-init, perf-loop,
   web-perf, tldraw-offline (agent definition stays), sqlalchemy-alembic-expert.
   Deleted: autoresearch (empty directory in ~/.claude/skills).
4. **Archive location.** Unmanaged skills move to ~/.claude/skills-archive (reversible
   by moving back). dotagents-managed perf-harness-init and perf-loop move to
   optional/perf in the repo with an optional install.sh, so a plain ./install.sh does
   not restore them.
5. **mattpocock plugin disabled.** wait-what and writing-for-agents are copied into
   ~/.claude/skills first. Local customized grilling, tdd, research shadowed the plugin
   already (43 vs 22, 109 vs 38, 48 vs 12 lines). Cost: no upstream updates for the two
   copied skills; 8 never-used plugin engineering skills are dropped.
6. **MCP connectors.** Disconnect Figma (0 calls) and Google Calendar (0 calls) via
   claude.ai connector settings; the user performs this. Gmail, Drive, context7,
   searxng, MCP_DOCKER, cloudflare-browser stay.
7. **Measurement.** Before = first-turn input total of this session's transcript.
   After = first-turn input total of a fresh session started after the trim. Recorded
   here; no gate.
8. **Subagent investigation pre-registered now** as a rigor doc (hypotheses: fan-out
   count, opus where sonnet suffices, oversized prompts or returned results, nested
   agents), run after the trim.
9. **Scope guards.** Kept unmanaged skills stay in ~/.claude for now; adoption into
   dotagents is a separate task. Repo changes are left uncommitted for the user; the
   user's existing uncommitted edits are not touched.

## Rejected
- Reliability-first (fetch CLI): only 15 sessions had web errors, 89% in 5.
- Guard hook on Agent dispatches now: risks blocking legitimate opus work before the
  cause is measured.
- Keeping the plugin for its two used skills: 11 duplicate or unused descriptions per turn.
- Deleting archived skills: reversibility preferred; cloudflare set is 2MB of reference.
- Building the file-dump hook in parallel: user chose strict sequencing.

## Consequences
- Archived skills are invisible until restored by hand.
- Trimming reduces discoverability; the census list is the restore guide.
- Baseline decomposition is still an estimate; the before/after number is the truth.

## Measurement log
- Before (this session, 2026-09-11, model claude-fable-5-1, cwd ~/Projects): first-turn
  input total 33,234 tokens (cache_creation 21,607 + cache_read 11,625 + 2). Lower than
  the 45,168 corpus median; compare against a fresh session in the same cwd and model.
- After (fresh session 95eec4ef via `claude -p`, same model, cwd ~/Projects): first-turn
  input total 22,837 tokens (cache_creation 14,804 + cache_read 8,031 + 2).
  Delta: -10,397 tokens per turn (-31%). Caveat: the before was an interactive session
  and the after was non-interactive print mode, which may load a slightly different
  prefix; re-check against the first interactive session's transcript.
- Connectors: Figma and Google Calendar were not disconnected at the account level;
  they were added to disabledMcpServers for all 49 project entries in ~/.claude.json
  (backup at ~/.claude.json.bak-2026-09-11). Re-enable per project via /mcp.
- README.md perf rows removed after all (two-line deletion, user asked to proceed).

## Execution notes
- README.md lines 84-85 still list perf-harness-init and perf-loop in the default skill
  table. Not edited because README.md carries the user's own uncommitted changes.
- Repo smoke tests: install 310/310, optional 41/41, instructions 174/174 pass.
  global-instructions-pruning fails 1 check (core.md at 1341 words vs 1319 cap) and
  repository-adapter fails 1 check (codex-cli 0.153.4 vs qualified 0.144.1). Both fail
  identically with all working-tree changes stashed, so both predate this work.
- ~/.claude/settings.json backed up to settings.json.bak-2026-09-11 before the plugin flip.
