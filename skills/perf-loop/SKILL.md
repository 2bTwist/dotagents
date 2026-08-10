---
name: perf-loop
description: Diff-driven autonomous browser test + performance optimization loop for serious React/web implementation. Invoke deliberately (alongside /implement) when a design is settled and you want a change driven to an EXCELLENT bar — not while prototyping. It reads the git diff, generates targeted end-to-end user flows for what changed, drives them in a real browser, detects perf hitches + weird behavior, fixes them, and re-runs until budgets pass — stopping only at the budget or a severe tradeoff it escalates. Triggers "run the perf loop", "optimize until excellent", "perf-loop this", "test this PR in the browser".
harness:
  degrades: [subagents, mcp-browser]
---

# perf-loop

An invokable "we mean it now" state, not a prototyping aid. Requires the harness
(run `perf-harness-init` first if absent). No third-party browser-testing tool —
uses the agent + Playwright + the `mcp__MCP_DOCKER__browser_*` tools + our
`perf-check` verifier. Design: portfolio `specs/plans/2026-06-22-groundwork-perf-harness.md`.

## Preconditions (stop if missing)
1. `budgets.json` calibrated (non-null budgets) — else run `pnpm perf:calibrate`.
2. Invariant suites exist: `e2e/invariants/*` (functional + a11y).
3. `pnpm perf:check --json` returns valid JSON. Measure PROD builds only.

## Roles (independent verification)
- **Builder** (main agent): writes/optimizes the code.
- **Adversarial verifier** (a SEPARATE sub-agent via the Agent tool): generates the flows and grades. The builder must not author the tests it's judged by. Prompt it to stress, not to confirm.

## Hard invariants (the loop CANNOT trade away)
- Functional e2e + a11y stay green (correctness > perf).
- Cannot edit `budgets.json` (the gate is fixed; ratcheting is a human `pnpm perf:calibrate`).
- Cannot silently remove a feature/animation to hit a number.

## The loop
### 1. Diff → what to test (the intelligence is here)
- `git diff` (target: unstaged / branch / the PR). Map changed files → affected routes, components, user flows.
- The adversarial verifier generates **targeted real-user flows** for exactly what changed, e.g. "PR touched FileRow + tab logic → open a file, switch tabs fast, rapid-click rows." Not fixed scripts — derived from the diff each run.

### 2. Run + observe (real browser, throttled prod build)
- Deterministic numbers: `pnpm e2e:perf` (INP proxy + CPU profile) + `pnpm perf:check --json`.
- Exploration / "weird stuff": drive the flows with `mcp__MCP_DOCKER__browser_*` (navigate/click/snapshot) and collect anomalies:
  - perf: INP, long animation frames, CPU profile hot spots, CWV deltas
  - correctness: console errors, failed network requests, broken interactions
  - visual/a11y: layout shift, contrast, dead links, missing metadata

### 3. Gate
- `verdict==="pass"` AND invariants green AND no anomalies AND no cheap win toward `target` → **DONE**. Report final numbers + diff.

### 4. Diagnose → fix → re-verify
- Pick the worst metric/anomaly. Read the CPU profile (`perf-results/*.cpuprofile`) / console / network to find the cause.
- Apply ONE focused fix (code-split, defer/lazy, debounce, reduce DOM/paint, image/font, a memo the compiler can't infer). Work on a dedicated branch or worktree and commit each proven improvement. On failure restore only the scoped experimental diff; never `reset` or `clean` the user's working tree.
- Re-run invariants; if a fix breaks one, revert it and try another approach. Loop.

## Stop / escalate
- **Done:** budgets pass + invariants green + no anomalies.
- **Severe tradeoff:** the only path to budget breaks an invariant or needs a UX sacrifice → STOP, write `specs/perf/<date>-<slug>-tradeoff.md` (metric, blocker, options + UX cost, recommendation), escalate. Do not proceed.
- **Cap:** stop after N iterations (default 8) or the token/time ceiling; escalate with best-achieved numbers + smallest remaining gap. Never silently accept "good enough."

## Measurement honesty
- "Excellent" is per-layer: sub-µs hot fns, sub-frame (~<100ms) INP, sub-1s LCP. Don't chase nanoseconds on CWV (impossible → non-terminating loop).
- A suspiciously big win is a measurement bug until reproduced from a clean prod build (Twyman's law).
