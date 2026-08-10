# Rigor doc template

Write to `specs/rigor/YYYY-MM-DD-<kebab-slug>.md`. Two passes. **Pass 1 (pre-registration) is filled and locked BEFORE any work or measurement.** Do not edit Pass 1 after results exist, if a hypothesis was wrong, say so in Pass 2, never rewrite Pass 1 to match the answer. That lock is the whole point: it stops the goalposts from moving.

````markdown
# Rigor: [question in plain language]

**Date:** YYYY-MM-DD
**Class:** empirical | epistemic
**Status:** pre-registered | in-progress | concluded

## Pass 1, Pre-registration (LOCKED before work)

### Goal (plain language)
[What I actually want to know or improve, stated without any metric. The metric below is a proxy for THIS.]

### Competing hypotheses
[2+ live explanations/approaches, not just the favored one. For each: what observation would EXCLUDE it (its falsifier). One hypothesis = not started.]
- H1: …, falsified if …
- H2: …, falsified if …

### Design
- **The ONE variable changing:** […]
- **Held equal (controlled conditions):** [machine, input, cache state, load, warmup, version, time…]
- **Metric:** [what I measure], **NOT measuring (and why):** [what's deliberately out of scope]
- **Runs / sample:** [N independent runs; for empirical: report mean ± 95% CI, not best-of-1; min detectable effect if known]

## Pass 2, Results & verdict (after work)

### What I tried
[Chronological, including dead ends and rejected approaches. Honesty over tidiness.]

### Results
[Numbers WITH spread: mean ± CI, absolute values (not just %), the actual measurements. Overlapping CIs = no win.]

### How this could be wrong (lean over backwards)
[Threats to validity, conclusion (enough sample?), internal (what else changed?), construct (does the metric mean the goal?), external (generalizes?). The disconfirming evidence. What I left out that cuts against the conclusion.]

### Decision + rejected alternatives + consequences
[ADR-style. What I'm doing, what I rejected and why, ALL consequences including the negative ones.]

### Claim ledger
[Every load-bearing claim, labeled. `[established]` MUST carry a source.]
- [established] …, source: …
- [inferred] …, reasoning: …
- [speculated] …

### Adversarial verdict
[What the refutation pass found. Each surviving challenge + how it was resolved, or a justified clean pass.]
````
