---
name: agent-latency-audit
description: Measure where an agent session's wall-clock actually goes, then fix the parts that matter. Parses Claude Code session transcripts to attribute time across inference, tool execution, approval waits, and external processes. Use when the user says the agent "feels slow", asks what's causing latency/bottlenecks, wants tool calls "in ms", or wants to optimize how the agent operates. Topic- and project-agnostic.
harness:
  requires: [claude-transcripts]
---

# Agent Latency Audit

A discipline for answering "what is making this agent slow?" with evidence, not intuition. The data already exists: Claude Code writes every session to JSONL with per-message timestamps, so the full wall-clock can be reconstructed.

**Measure before you optimize, because the intuitive answer is the wrong one.** The felt cause is "the tools are slow." The wall-clock almost always sits in **model inference, the number of round-trips, approval/human waits, and external processes (builds, installs, network)** — none of which get faster when a tool does. Making ripgrep go 14.7ms → 1.7ms is a satisfying multiple and a rounding error on the session. Phase 1 produces the actual split for *this* project, so the report rests on that number rather than on this paragraph.

## Phase 1 — Reconstruct the wall-clock from transcripts

Transcripts live at `~/.claude/projects/<sanitized-cwd>/*.jsonl`, one JSON object per line. Run the parser beside this file:

```
node <this skill dir>/attribute.mjs ~/.claude/projects/<sanitized-cwd>
```

It streams every session file (they reach gigabytes; nothing is read whole), pairs each `tool_use` to its `tool_result` by `tool_use_id` and diffs the top-level `timestamp` fields for true tool wall-clock, diffs user→assistant pairs for model turnaround, and prints per-tool `{n, p50, p99, max, total}` sorted by **total** (frequency × duration), not by peak.

Its closing `TOOL SHARE` line is the headline number, with one caveat it prints for you: the denominator is measured time only, so it is an upper bound on the tool share of true end-to-end wall-clock, and it still counts approval waits and external processes as "tool." Phase 2 splits those out.

Then band each tool's distribution (`<300ms / 0.3-1s / 1-3s / 3-10s / >10s`). **Bimodality is the tell**: a tool with two clusters is not one operation with variance, it is two different things sharing a name (see Phase 2).

## Phase 2 — Attribute, don't assume

A `tool_use → tool_result` delta conflates several things. Separate them:

- **Read/Grep/Glob need no approval** → they are the pure harness floor (typically 1-31ms). Use them as the control.
- **Edit/Write/Bash often need approval** → a fat cluster in the 3-10s band is *human approval-click time*, not tool speed. Confirm by comparing allowlisted vs non-allowlisted commands: same command class, large p50 gap = approval tax.
- **External processes** (build/install/test/network) → irreducible runtime; lever is frequency, not speed.
- **Model turnaround** → queue + prefill + generate. Usually the single largest total. Scales with context size and how much the agent thinks, not with hardware.

Prove micro-costs locally before claiming them. Example: shell-init is the usual culprit behind a "slow" Bash floor — `zsh -i` re-sources the full profile *every call* (a stateless-shell-per-call design). Benchmark it: `zsh -i -c true` vs `zsh -c true`; profile the rc with `zmodload zsh/zprof`; time each `eval "$(...)"` line (version managers like pyenv/rbenv/nvm run external binaries on every shell). Then multiply the saving by the call count from Phase 1 before celebrating — that product, not the multiple, is what the session gets back.

## Phase 3 — Fix by leverage, highest first

Rank fixes by total wall-clock returned, and name which are physics vs config vs habit:

1. **Round-trip count (highest).** Fewer, better searches. Definition-first ranking, filter out tests/vendor/generated, group and trim output so the *first* result is right and the agent stops re-searching. Batch independent tool calls into one turn (amortizes per-call overhead; 10 ops in one shell ≈ per-op cost of one). Read the right file once instead of bouncing.
2. **Approval & human waits.** Allowlist read-only commands. Don't wrap commands in `cd path;` or `VAR=…;` prefixes — the cwd persists between calls, and the compound defeats allowlist matching, forcing a prompt that costs ~1-2s of human time per call. Use absolute paths / `git -C`. Consider acceptEdits mode.
3. **Don't fixed-`sleep`-poll.** Background long jobs and let the harness wake on completion; fixed sleeps over-wait and silently dominate (often hours across a project's history).
4. **Context size.** Keep tool output and full-file Reads out of context unless they'll be used — prefill is re-paid every turn. Compact intentionally.
5. **External process frequency.** Incremental type-check/build caches, fewer clean rebuilds. Not "make the build ms"; make it run rarely.
6. **Tool/shell micro-speed (lowest).** Real, and worth the free wins once (trim shell profile, cache completions). Never the headline: rank it by its Phase-1 total, which is what puts it here.

## Output

A short report, done when all four are in it:

- The time-attribution table from Phase 1, sorted by total, with the `TOOL SHARE` line and its caveat.
- The Phase-2 split: for every tool whose distribution was bimodal, which cluster is tool speed, which is approval, which is an external process.
- A leverage-ranked fix list, each item labelled physics / config / habit, each carrying the wall-clock it returns.
- One sentence naming the single highest-leverage change. If that sentence says "a tool was slow," re-check Phase 2 — you have probably read an approval wait or a build as tool time.
