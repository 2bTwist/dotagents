---
name: perf-loop
description: Drive a settled web change to a passing perf budget — read the git diff, generate browser flows targeting what changed, run them against a throttled prod build, fix what hitches, repeat until budgets pass or a tradeoff needs escalating. Invoke deliberately once a design is settled, alongside /implement, never while prototyping. Needs the harness perf-harness-init installs.
harness:
  degrades: [subagents, mcp-browser]
---

# perf-loop

An invokable "we mean it now" state, not a prototyping aid. Requires the harness
(run `perf-harness-init` first if absent). No third-party browser-testing tool —
uses the agent + Playwright + the `mcp__MCP_DOCKER__browser_*` tools + our
`perf-check` verifier.

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

**DONE** when all four boxes check. Any unchecked box → step 4.

- [ ] `pnpm perf:check --json` returns `verdict === "pass"` — every budget in `budgets.json` met.
- [ ] Functional e2e + a11y invariants green.
- [ ] Every anomaly from step 2's three lists is either fixed or written up as a severe tradeoff.
- [ ] No **cheap win** left: a fix touching one file, changing no API, risking no invariant, that this run's measurement says would move a metric.

On DONE, report the final numbers against each budget, plus the diff.

### 4. Diagnose → fix → re-verify
- Pick the worst metric/anomaly. Read the CPU profile (`perf-results/*.cpuprofile`) / console / network to find the cause.
- Apply ONE focused fix (code-split, defer/lazy, debounce, reduce DOM/paint, image/font, a memo the compiler can't infer). Work on a dedicated branch or worktree and commit each proven improvement. On failure restore only the scoped experimental diff; never `reset` or `clean` the user's working tree.
- Re-run invariants; if a fix breaks one, revert it and try another approach. Loop.

## Stop / escalate

Three exits, and no fourth:

- **Done:** the step-3 gate, all four boxes.
- **Severe tradeoff:** the only path to a budget breaks an invariant or costs UX → STOP, write `specs/perf/<date>-<slug>-tradeoff.md` (metric, blocker, options + UX cost, recommendation), escalate. Do not proceed.
- **Cap:** 8 iterations of step 4. On the 8th, stop and escalate with the best-achieved number and the remaining gap for each failing budget. Never silently accept "good enough."

## Measurement honesty
- **Budgets terminate the loop; "excellent" only ranks what to fix next.** The per-layer bar is sub-µs hot fns, sub-frame (~<100ms) INP, sub-1s LCP. Chasing a metric past its budget is how this loop fails to end.
- A suspiciously big win is a measurement bug until reproduced from a clean prod build (Twyman's law).
