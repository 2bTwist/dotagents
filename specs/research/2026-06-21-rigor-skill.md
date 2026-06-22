# Research: A `/rigor` engineering-rigor skill

**Date:** 2026-06-21
**Status:** research complete, pending scope decision + `/plan`
**Goal:** Ground the design of a `/rigor` skill in established, cited methodology rather than invented advice. Build the rigor tool rigorously.

---

## 1. What this is for (decided via grilling)

The originating idea ("turn papers/talks into interactive explainers, use world models for the hard stuff") was a symptom. The grilling interview converged on the real need:

> **Rigor, operationalized.** Two targets: (1) *Edmond* follows a proper engineering process on his own work (the "make my browser faster" class) instead of changing what he knows how to change; (2) *the AI collaborator* operates at that level instead of producing the most plausible-sounding answer, chasing metrics that don't mean anything, on a soft foundation.

**Decided design (locked in grilling):**
- Audience: Edmond, learning/working (not a public product).
- Artifact: a **`/rigor` gating skill** — procedurally forces method *before* work, runs an **adversarial pass** *after*.
- Why a skill and not a doc: passive CLAUDE.md rules already exist and **don't bind**. The fix is an active gate + an independent check, not more prose.
- The war-story corpus / interactive explainer / daily digest are downstream and out of scope for now.

**The two failure modes `/rigor` must catch:**
- **(a) Empirical** — "make X faster": optimizing the wrong thing, reporting noise as a win, metric that doesn't represent the goal, unfair comparison.
- **(b) Epistemic** — "verify this claim": confident single answer that never had rivals, speculation stated as fact, unfalsifiable claims, plausibility-tracking instead of truth-tracking.

---

## 2. Scope recommendation (the deferred decision)

Edmond deferred the empirical-vs-epistemic scope to "after research." The frameworks now make the boundary clear:

**Recommendation: BOTH, unified by a "gate before, attack after" spine, but ship a focused CORE (≈8 procedures), not all 20.**

Rationale:
- The two failure modes are genuinely distinct literatures, but they share one structure: cheap *pre-work gates* that force honesty up front, and an *adversarial post-check* that attacks the result. That spine unifies them without bloat.
- Empirical is the harder, more *checkable* half (numbers, CIs, baselines) so it anchors the skill. Epistemic is what most directly fixes the AI-slop complaint, so it can't be dropped.
- Process/decision frameworks (ADR, RFC sections, pre-mortem) are the *output discipline* — they're how a finding gets recorded so the adversarial pass has something falsifiable to attack.

The "ship a focused core" point matters: `writing-great-skills` says every body line must change behavior. Twenty frameworks in one skill is a reference doc, not a gate. The **Top-5 lists** from each strand below are the candidate core.

---

## 3. Empirical / measurement frameworks

Each: **gate** = pre-work checklist question; **adversarial** = how the skeptic sub-agent attacks the result.

| Framework | Origin | Gate step | Adversarial check |
|---|---|---|---|
| **SRJPE** (mean ± 95% CI over N runs, never best-of-1) | Georges, Buytaert, Eeckhout, OOPSLA 2007 ([pdf](https://dri.es/files/oopsla07-georges.pdf)) | "How many independent runs? Report mean ± CI, not a single number. State warmup/steady-state policy first." | "Show the spread. No CI = can't tell a real 8% win from noise. Overlapping CIs = no win." |
| **Benchmarking Crimes** checklist | Gernot Heiser ([list](https://gernot-heiser.org/benchmarking-crimes.html)); van der Kouwe et al. ([arXiv:1801.02381](https://arxiv.org/abs/1801.02381)) | "Baseline = current best (not my old code)? Full suite or justified subset? Absolute numbers + variance? Geometric mean for normalized ratios?" | Walk result against each crime: missing absolute baseline, microbenchmark-only, arithmetic mean of normalized scores, cherry-picked subset. |
| **Microbenchmark pitfalls** (warmup, dead-code elimination) | JMH / Oracle ([article](https://www.oracle.com/technical-resources/articles/java/architect-benchmarking.html)) | "Is the timed work actually observed (result consumed), warmed up, steady-state across multiple process launches?" | "Prove the optimizer didn't delete your workload. Show discarded warmup + stable steady-state across forks." |
| **USE Method** (Utilization/Saturation/Errors per resource) | Brendan Gregg ([usemethod](https://www.brendangregg.com/usemethod.html); [ACM Queue](https://queue.acm.org/detail.cfm?id=2413037)) | "List every resource in the path + its U/S/E metric. Which resources have NO metric? Name them — blind spots, not absences." | "Did you confirm X was the bottleneck via U/S/E, or change what you knew how to change? Show the saturation evidence." |
| **Anti-methods** (Street Light / Random Change) | Gregg, ACM Queue | "What's your hypothesis for the bottleneck, and what would falsify it? 'Try changes, keep the fast one' = Random Change anti-method, stop." | "Could this win be a coincidence of try-order? No causal model + falsifier = Street-Light evidence, not a diagnosis." |
| **Threats to validity** (conclusion/internal/construct/external) | Wohlin et al., *Experimentation in SE* ([notes](https://homepages.dcc.ufmg.br/~figueiredo/disciplinas/lectures/experiment-validity-threats_v01.pdf)) | 4 questions: enough sample (conclusion)? what else changed (internal)? does the metric mean "faster" to the user (construct)? generalizes beyond this machine (external)? | Attack each axis: underpowered → noise; two things changed → confound; proxy metric → measuring wrong thing; one laptop → doesn't generalize. |
| **Goodhart / Campbell / Twyman** | Goodhart 1975; Campbell 1979; Twyman/Ehrenberg ([Kohavi pdf](https://www.exp-platform.com/Documents/TwymansLaw.pdf)) | "Cheapest way to move this number WITHOUT improving the goal? If it exists, add a guardrail. If result is suspiciously good, treat as bug-until-proven." | "Did you improve the real thing or just the number? A 40% one-line win is more likely a broken benchmark — reproduce from clean, rule out caching/DCE/units error." |
| **Surrogation / vanity vs actionable** | Choi et al.; Ries, *Lean Startup* | "Write the real goal in plain language ABOVE the metric. The metric is a proxy for ___. What decision does each metric change? None = vanity, drop it." | "Restate the user goal. Did this win move it? Metric up but goal flat = surrogation." |
| **Pre-registration + no-peeking** | Kohavi, *Trustworthy Online Controlled Experiments* | "Before measuring: hypothesis, the ONE variable changing, controlled-equal conditions, min detectable effect, run count. List confounds held constant." | "Did you stop when it looked good (peeking)? Sample fixed in advance? Both arms identical (machine/cache/load)? Powered enough?" |

**Top 5 for a solo+AI workflow:** USE Method · mean±CI over N runs · Benchmarking Crimes checklist · Twyman + construct-validity paired · pre-registration/no-peeking.
*Split:* USE + mean±CI + pre-registration are **pre-work gates**; Crimes + Twyman/construct are **adversarial post-checks**.

---

## 4. Epistemic / reasoning frameworks

| Framework | Origin | Gate step | Adversarial check |
|---|---|---|---|
| **Strong Inference** (multiple hypotheses, crucial experiment that *excludes*) | Platt, *Science* 1964 ([pdf](https://www.whoi.edu/cms/files/platt64sci_72743.pdf)) | "Write the FULL set of competing explanations, not just the favored one. For each, what would exclude it? Only one hypothesis = haven't started." | "What were the other 2-3 live candidates, and what rules each out? An answer that never had rivals is a guess in a lab coat." |
| **Cargo Cult Science** ("lean over backwards") | Feynman, Caltech 1974 ([text](https://www.themarginalian.org/2012/06/08/richard-feynman-caltech-cargo-cult-science/)) | "Add a 'how this could be wrong' section: disconfirming evidence, alternatives, failure conditions. Empty = leaning toward yourself." | "What did you leave out that cuts against this? Zero stated failure modes = cargo-cult-shaped: right form, missing integrity." |
| **Falsifiability** | Popper, *Logic of Scientific Discovery* ([SEP](https://plato.stanford.edu/entries/popper/)) | "For the central claim: what observation would prove it false? What would change my mind? Nothing → relabel as value/definition, not finding." | "State the falsifier for each load-bearing claim. Unfalsifiable claims dressed as findings = the tell of plausible slop." |
| **Analysis of Competing Hypotheses** (diagnosticity matrix) | Heuer, *Psychology of Intelligence Analysis* (CIA, 1999) ([overview](https://en.wikipedia.org/wiki/Analysis_of_competing_hypotheses)) | "Build evidence × hypothesis matrix. For each fact: does it discriminate between options or fit all? Discard non-diagnostic. Pick fewest-inconsistencies, not most-support." | "Which cited evidence is actually diagnostic? Strip every fact consistent with all hypotheses — if the conclusion collapses, it was filler." |
| **CER + GRADE** (claim/evidence/reasoning split + certainty grade) | McNeill & Krajcik 2011; GRADE Working Group ([grade](https://www.gradeworkinggroup.org/)) | "Separate every conclusion into Claim / Evidence / Reasoning. Attach a certainty label (High/Mod/Low). Empty evidence or reasoning slot can't ship at High." | "Force the 3-way split, attack each slot. **A claim labeled 'established' must produce a source; if it can't, it's at most 'inferred.'**" |
| **Pre-mortem + consider-the-opposite** | Klein, *HBR* 2007 ([hbr](https://hbr.org/2007/09/performing-a-project-premortem)); Lord/Lepper/Preston 1984 | "Assume this answer is wrong in 6 months — what was the cause? Then argue the opposite conclusion as strongly as I can." | "Steelman the rejected alternative — is your version strong enough to be fair? Pre-mortem: most likely way this is wrong?" |
| **Anti-bullshit** (indifference to truth) | Frankfurt, *On Bullshit* 1986/2005; [*Machine Bullshit* arXiv:2507.07484](https://arxiv.org/abs/2507.07484) | "For every claim: am I asserting because I *checked* it, or because it *sounds* right here? Generated-for-fit = mark speculation or kill." | "Tag each sentence truth-tracking vs plausibility-tracking. The plausibility-tracking ones are the slop — demand provenance or cut." |

**Top 5 for catching AI slop:** Established/Inferred/Speculated labeling (source required for "established") · list competing hypotheses · state the falsifier · the "leaning over backwards" disconfirmation section · diagnosticity strip + pre-mortem.

---

## 5. Process / decision frameworks (output discipline)

These shape *how a finding is recorded* so the adversarial pass has a falsifiable artifact to attack.

| Framework | Origin | Portable kernel for solo+AI |
|---|---|---|
| **ADR** (context / decision / consequences, append-only, rejected alternatives) | Nygard 2011 ([blog](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)) | **Highest fit.** Forces *why + rejected alternatives + all consequences (not just upsides)*. Fits this repo's `specs/` habit. |
| **RFC/PEP forced sections** (Motivation, Alternatives-rejected, Drawbacks, Unresolved-questions) | [Rust RFCs](https://github.com/rust-lang/rfcs); [PEP 1](https://peps.python.org/pep-0001/) | The *template*, not the governance. "Why should we NOT do this?" as a mandatory section. Maps onto `/plan` + `first-principles`. |
| **Five Whys → contributing factors** | Toyota; critique: Cook *How Complex Systems Fail* ([site](https://how.complexsystems.fail/)); Allspaw *The Infinite Hows* | The *critique* is portable: ban single-root-cause / single-human conclusions, branch into contributing conditions. Pairs with `diagnosing-bugs`. |
| **Pre-mortem** | Klein, HBR 2007 | Runs solo with the AI as the independent dissenter. (Also in §4.) |
| **Resulting / outcome bias** | Duke, *Thinking in Bets*; Baron & Hershey 1988 | Judge the decision by what was knowable *at the time*; demand a *pre-committed* written rationale so the process defense is falsifiable. |

**Out of scope (organizational, team-only):** blameless-postmortem *culture* (keep only the systemic-not-individual framing); full RFC *governance* (voting, FCP, sub-team sign-off).

**One load-bearing caveat:** several of these derive value from *multiple independent reviewers*. In a solo+AI setup the AI is **not** a truly independent reviewer of work it co-authored — this is exactly the author-bias trap in the global CLAUDE.md. So `/rigor` must lean on *written, falsifiable artifacts* (ADR consequences, pre-committed pre-mortem lists, claim labels) that a later adversarial pass can attack — not on a "many eyes" mechanism it can't reproduce.

### Where elite process is publicly visible (corpus seeds, for later)
Open-process (exposes real reasoning): **Rust RFC repo**, **Python PEPs**, **Oxide Computer RFDs + "Oxide and Friends" podcast**, **TigerBeetle TIGER_STYLE + VOPR streams**, **Ladybird/Andreas Kling live-coding**. Outcome-only (hides the decision process): **Cloudflare/Stripe/Discord eng blogs**.

---

## 6. How `/rigor` should be built (house-style reuse map)

From reading the existing skills in `~/.claude/skills/`:

- **Pre-work GATE → model on `grilling` + `diagnosing-bugs` Phase 1.** Grilling's one-question-at-a-time, recommend-an-answer, pressure-test mechanic; diagnosing-bugs' hard-gate enforcement shape (*"No red-capable command, no Phase 2"*) with `- [ ]` completion checklists and a blunt refusal to proceed. Gate completion criterion must be exhaustive and checkable (a vague one invites premature completion).
- **Adversarial post-check → model on the code-review plugin's flag→validate→filter.** Spawn the skeptic as a body-level Task sub-agent with a verbatim-quoted prompt + explicit tools (the `research`/`first-principles` parallel idiom). Apply high-signal-only discipline (*"If you are not certain an issue is real, do not flag it"*) + an explicit do-NOT-flag list. Add a second validation pass so each finding is independently confirmed. Name the author-bias compensation explicitly.
- **Output doc → model on `plan`/`research`.** Path `specs/rigor/YYYY-MM-DD-<slug>.md`, dir created if missing, structure in a sibling `RIGOR-TEMPLATE.md` linked relatively, real metadata only, closing chat summary + hand-off line that does NOT auto-invoke the next skill.
- **Body skeleton → model on `groundwork`/`first-principles`.** Mission paragraph → `## Execution style` (verbatim house block) → `## Critical rules` numbered invariants → `## Steps` with per-step completion criteria → `## When invoked on the wrong task` push-back. Use `model: opus` (reasoning-heavy). Frontmatter: house style always sets `name:`; reserve `context: fork` in favor of body-spawned Task sub-agents.

**Skill-authoring essentials:** `~/.claude/skills/rigor/SKILL.md`; the directory name becomes `/rigor`; the body stays in context once loaded (keep it tight, push reference material to linked supporting files); `disable-model-invocation: true` if it should only ever fire by hand.

---

## 7. Open questions for `/plan`

1. **Invocation shape.** One gate that auto-detects empirical-vs-epistemic task type, or two sub-modes (`/rigor measure` vs `/rigor verify`)? Or a single gate whose checklist branches?
2. **Where does the gate bite?** A solo dev won't invoke `/rigor` for every task. Should it be: (a) manual-only, (b) auto-triggered by keywords ("benchmark", "faster", "verify"), or (c) wired so the AI self-invokes when it detects an empirical/epistemic claim is about to be made? Option (c) is what most directly fixes the "stop feeding me slop" complaint but is the hardest to make bind.
3. **Core set size.** Which ~8 of the 20 procedures make the shipped core? (Candidate: the two Top-5 lists, deduped.)
4. **Adversarial pass cost.** Always spawn a sub-agent, or only above a complexity threshold? Sub-agent spawn ≈ 130s overhead.
5. **Does the AI bind to this by default, or only on explicit invoke?** The deepest question: a skill the user must remember to call won't fix in-the-moment slop. Is there a lighter always-on CLAUDE.md hook ("before any empirical claim, label established/inferred/speculated") that `/rigor` escalates from?

---

## Sources
All frameworks verified against primary or authoritative secondary sources (cross-checked ≥2 where possible). Full citations inline above. Research via 4 parallel sub-agents (empirical, epistemic, process/decision, house-conventions); searxng MCP was down mid-run so web strands used built-in WebSearch fallback.
