---
name: groundwork
description: |
  Lay the foundation before acting. Frames the underlying problem, asks focused questions when ambiguity would change the research, fetches canonical guidance, finds 2-3 reference implementations, compares to the current repo, and produces a phased cleanup plan that hands off for stress-testing and then to /implement. Topic-agnostic.

  TRIGGER: brand-new project, first instance of a task class in a repo, audit/cleanup of an accreted area, "how should I set this up" / "what's the right way to do X", or any architecture decision before code exists.
  SKIP: quick fixes (/oneshot), pure debugging or mapping (/research), or explicit "just do it" / "skip the research".
model: opus
---

# Groundwork

Produce a phased cleanup plan for any task class. Output is implementation-ready, citation-backed, and hands off to a stress-test pass and then `/implement`. Topic-agnostic — no hardcoded stack, framework, or author.

## Execution

Execute steps immediately. Do not announce. Pause only where a step says to.

## Critical rules

1. **No recommendation without a source.** Every load-bearing decision cites a published author/vendor doc/paper from step 2 OR a maintained library/reference-repo file path from step 3. At least one decision per cleanup phase must cite a step-3 source. Otherwise flag as "judgment call, no canonical source."
2. **Step 3 is mandatory.** Survey 2-3 reputable real-world solutions unless the topic is purely abstract.
3. **Convergent practice beats single-author recommendation.** Conventions across multiple production repos beat any single author's principle.
4. **Vendor docs beat tutorials. Peer-reviewed papers beat blog summaries** for research-adjacent topics.
5. **Good existing patterns beat external canonical.** Document what matches and leave it alone. Do not ratify the status quo. Do not propose blanket migration.
6. **Output is a phased cleanup plan.** At least one phase with file paths, ordered steps, and verification. Description-only output is a failed run.
7. **Implementation-ready.** Explicit file paths, ordered steps, code snippets where they reduce ambiguity, automated verification.
8. **Do not start the stress-test pass automatically.** End with the hand-off line and stop.
9. **Scope to the task.** 2-3 converging signals beat 8 weak ones.
10. **Classify problems, not preferred tools.** An LLM, database, cache, framework, or algorithm is a candidate technique, not the problem class. Keep classifications provisional and allow multiple, uncertain, or novel classes.

## Argument

Natural language. Examples:
- `/groundwork rate-limiting-middleware`
- `/groundwork we need a background job system that retries on failure`

Normalize internally after the problem-framing interview: strip filler ("I'm trying to", "we need"), keep substantive nouns.
- **Working problem label** for queries and chat summary (e.g. "background-job failure recovery"). It may combine domains and does not have to match a published skill name.
- **File slug** for the plan path: kebab-case, max 6 words. Used as `specs/plans/YYYY-MM-DD-groundwork-<slug>.md`.

In step 1, restate the working frame so the user can correct it.

If no argument: respond `What are you trying to do? Describe it however you want.` Then wait.

## Steps

### 1. Frame the problem, then infer research lanes

Start from the user's desired outcome, observed evidence, constraints, and system boundary. Do not start from a proposed technology or force the request into a single familiar label. Use [REFERENCE.md](REFERENCE.md#problem-framing-protocol) for the framing dimensions and research routing.

Inspect the prompt and available repository context first. If missing information would materially change the problem classification, source disciplines, or success criteria, ask **one compact batch of 1-3 high-information questions and wait**. Ask only what is missing. Typical targets are the observable outcome, the actual failure or evidence, constraints and unacceptable tradeoffs, and which of several plausible interpretations the user means. If the request is already concrete and bounded, ask nothing.

After the answers, or immediately when the context is sufficient, state a concise working frame:

- desired outcome and success condition;
- primary and secondary problem classes, each marked as established, hybrid, uncertain, or potentially novel;
- evidence, constraints, and important unknowns;
- research lanes and candidate technique families to investigate, without choosing a solution yet.

Restate it as: *"I read this as `<working frame>`. The labels are research hypotheses, not a solution commitment. Continuing unless you correct me."* Proceed unless interrupted. If ambiguity remains that would send the research down materially different paths, ask one focused follow-up and wait. A missing exact category is a valid result; use adjacent mechanisms without inventing certainty.

Identify scenario: (a) existing repo, new task class; (b) brand new project; (c) accreted area being audited.

### 2. Find canonical guidance

**2a — Skill collections. Locally installed skills FIRST.** Before any web crawl, enumerate the skills already installed on this machine/repo and match their descriptions to the problem frame and research lanes. A locally-installed skill is pre-vetted for this stack and costs no network. Then search web-published skills as possible evidence and technique leads, never as the authority that defines the problem. Enumeration + matching: see [REFERENCE.md](REFERENCE.md#skill-crawl-protocol). For each match (local or remote), fetch/read the SKILL.md and capture: name, path/URL, load-bearing principles (verbatim quotes). Vetting criteria: see [REFERENCE.md](REFERENCE.md#skill-vetting). When the plan cites a locally-installed skill, name it so `/implement` knows to invoke it.

**2b — Library/vendor docs.** If the topic maps to a library/SDK/framework, prefer `context7` MCP (`resolve-library-id` → `query-docs`) — bypasses search noise and stale training data. Otherwise WebSearch "<task class> best practices <year>" and WebFetch top 2-4 high-signal results. Verbatim quotes.

**2c — Academic literature** (research-adjacent topics only — ML, algorithms, distributed systems, crypto, formal methods). Skip explicitly for engineering ergonomics. Protocol: see [REFERENCE.md](REFERENCE.md#academic-search).

### 3. Survey real-world solutions

Identify 2-3 reputable solutions. Two modes:
- **Mode A — packaged solutions** (libraries, SDKs, services). If a maintained library satisfies the working frame's success criteria and constraints across every material research lane, the plan adopts it. Building needs an explicit reason.
- **Mode B — reference open-source repos**, for patterns teams implement inline (auth flows, data pipelines, monorepo structure).

Vetting criteria: see [REFERENCE.md](REFERENCE.md#solution-vetting). For each solution, capture: name, URL, qualification reason, API surface or 2-3 conventions with file paths, divergence from other solutions.

If 2-3 reputable solutions cannot be found: state the queries used, treat the absence as a finding.

### 4. Map current repo (scenarios a and c)

Spawn an Explore subagent or do it directly. Capture: stack, file paths and counts of existing instances, the canonical local pattern, anti-patterns with file paths and line numbers, coverage gaps.

This map is the input to step 5. Without concrete file paths, step 5 is vague.

For scenario b: skip, capture user-stated constraints (deployment target, performance bounds, team size).

### 5. Write the phased plan

Write to `specs/plans/YYYY-MM-DD-groundwork-<slug>.md`. Create `specs/plans/` if missing. Structure: see [PLAN_TEMPLATE.md](PLAN_TEMPLATE.md).

After writing, output a brief chat summary: working problem frame, plan path, phase count and titles, first phase's effort and verification.

### 6. Hand off

End the chat summary with:

> Stress-test this plan's tradeoffs before building (the `grilling` skill if installed). Then `/implement specs/plans/<file>` to execute Phase 1.

Stop. Do not invoke other commands.

## When invoked on the wrong task

If the SKIP block matches, push back in one sentence and suggest `/oneshot` (trivial work) or `/research` (pure mapping, debugging) instead.
