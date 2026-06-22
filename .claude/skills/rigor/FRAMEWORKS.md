# Frameworks reference

Named, cited procedures behind the `/rigor` gate and adversary. Full sourcing: `specs/research/2026-06-21-rigor-skill.md`. **★ = core-8** (inline-weight; the rest load on demand). Each: **Gate** = pre-work question; **Attack** = how the forked adversary refutes a finished result.

## Shared spine (both classes)

- ★ **Grounded claim ledger** (CER + GRADE + Frankfurt). **Gate:** split each conclusion into claim / evidence / reasoning; assign certainty. **Attack:** force the 3-way split; label each claim established/inferred/speculated; **an "established" claim that can't produce a source is at most "inferred"**; tag sentences truth-tracking vs plausibility-tracking, the latter is slop, demand provenance or cut.
- ★ **Competing hypotheses + falsifier** (Platt Strong Inference + Popper + ACH). **Gate:** write the FULL set of explanations, not just the favored one; for each, what would EXCLUDE it. **Attack:** "what were the other 2-3 candidates, and what rules each out?" An answer that never had rivals is a guess. For each load-bearing claim demand its falsifier; unfalsifiable-claim-dressed-as-finding = the tell of slop.
- ★ **Lean over backwards + pre-mortem** (Feynman + Klein). **Gate:** add a "how this could be wrong" section, disconfirming evidence, alternatives, failure conditions; assume it failed in 6 months, why? **Attack:** "what did you leave out that cuts against this? Steelman the rejected alternative." Zero stated failure modes = cargo-cult: right form, missing integrity.

## Empirical branch (measure / optimize / benchmark)

- ★ **Pre-registration + no-peeking** (Kohavi; classical DoE). **Gate:** hypothesis, the ONE variable, controlled-equal conditions, metric, run-count, locked BEFORE measuring. **Attack:** "did you stop when it looked good (peeking)? Sample fixed in advance? Both arms identical (machine/cache/load)? Powered enough?"
- ★ **Mean ± CI over N runs, never best-of-1** (SRJPE, Georges et al. OOPSLA 2007). **Gate:** "how many independent runs; report mean ± 95% CI; warmup/steady-state policy." **Attack:** "show the spread. No CI = can't tell a real win from noise. Overlapping CIs = no win."
- ★ **Twyman + construct validity** (Ehrenberg/Kohavi; Wohlin). **Gate:** "if this looks suspiciously good, what artifact would produce it? Does the metric represent 'better' to the user?" **Attack:** "a 40% one-line win is more likely a broken benchmark, reproduce from clean, rule out caching/dead-code-elimination/units. Metric up but goal flat = surrogation."
- ★ **Benchmarking Crimes checklist** (Heiser; van der Kouwe et al.). **Gate/Attack:** baseline = current best (not my old code)? full suite or justified subset? absolute numbers + variance (not just %)? geometric mean for normalized ratios? not a microbenchmark-only claim? fair competitor setup?
- **USE Method** (Brendan Gregg). **Gate:** list every resource in the path + its Utilization/Saturation/Errors metric; which have NO metric (blind spots)? **Attack:** "did you confirm X was the bottleneck via U/S/E, or change what you knew how to change?"
- **Anti-methods** (Gregg): Street Light (look where the tools are easy), Random Change (tweak and keep the fast one). **Attack:** "no causal model + falsifier = Street-Light evidence, not a diagnosis."
- **Threats to validity** (Wohlin et al.): conclusion / internal / construct / external, the four axes for the "how this could be wrong" section.
- **Microbenchmark pitfalls** (JMH): warmup discarded? result consumed (no dead-code elimination)? steady-state across forks?
- **Goodhart / Campbell / surrogation / vanity-vs-actionable:** cheapest way to move the number WITHOUT improving the goal? what decision does each metric change (none = vanity)?

## Epistemic branch (verify / is-this-true / research)

- **ACH diagnosticity matrix** (Heuer, CIA 1999). **Gate:** evidence × hypothesis matrix; per fact, does it DISCRIMINATE between options or fit all? **Attack:** "strip every fact consistent with all hypotheses, if the conclusion collapses, it was non-diagnostic filler. Which hypothesis did you try hardest to disprove?"
- **GRADE certainty grading:** rate evidence High/Moderate/Low/Very-Low; rate DOWN for risk-of-bias, inconsistency, indirectness, imprecision. A claim can't ship at High with a small/indirect/imprecise base.
- **Consider-the-opposite** (Lord/Lepper/Preston 1984): actively argue the opposite conclusion, empirically beats "just be unbiased."
- **Anti-bullshit** (Frankfurt): bullshit = indifference to truth (distinct from lying). The precise diagnosis of plausible-but-unfounded output. Tag and cut.

## Process / output discipline

- **ADR** (Nygard): context / decision / consequences (ALL, not just upsides) / rejected alternatives, append-only. Shapes Pass 2's decision section.
- **RFC/PEP forced sections** (Rust/Python): Motivation, Alternatives-rejected, Drawbacks, Unresolved-questions. "Why should we NOT do this?" is mandatory.
- **Five Whys → contributing factors** (critique: Cook, Allspaw): ban single-root-cause / single-human conclusions; branch into contributing conditions.
- **Resulting / outcome bias** (Duke; Baron & Hershey): judge the decision by what was knowable at the time; demand a pre-committed rationale so the process defense is falsifiable. (This is why Pass 1 is locked.)

## Out of scope (organizational, team-only)
Blameless-postmortem *culture* (keep only systemic-not-individual framing); full RFC *governance* (voting, FCP). A solo+AI setup can't reproduce "many independent eyes", so lean on written, falsifiable artifacts the adversary can attack, not on social review.
