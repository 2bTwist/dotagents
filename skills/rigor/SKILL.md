---
name: rigor
description: Gate an investigation, benchmark, or claim behind grounded engineering method, then refute it. User-invoked.
disable-model-invocation: true
model: opus
harness:
  requires: [subagents]
---

# Rigor

Make a piece of work **grounded**, every claim traceable to a source or a measurement, every result hardened against the way it could be fooling you. Two moves: a **gate** that locks the method *before* the work, and an **adversary** that tries to *refute* the result after. The output is a referenceable doc in `specs/rigor/`.

The thing this prevents: the most plausible-sounding answer, a metric that doesn't mean what you think, a win that's really a measurement bug, a conclusion that never had a rival. Grounded beats plausible.

## Execution

Execute steps immediately. Do not announce. The gate (Step 2) is a hard stop, do not cross it until its criterion is met.

## Critical rules

1. **No locked pre-registration, no execution.** Step 2 fully filled and locked is the gate. If you catch yourself measuring or concluding before Pass 1 exists, stop, that is the exact failure this skill prevents.
2. **Pass 1 is immutable once work starts.** A wrong hypothesis is recorded as wrong in Pass 2, never edited away in Pass 1. The lock is what makes a solo result trustworthy.
3. **The adversary is not optional and not you.** It runs in a forked Task sub-agent prompted to refute, your own "it holds up" is author bias, weak evidence. A same-model sub-agent buys context separation, not true independence, so ground its challenges in the raw artifacts and external specs rather than in its own reasoning.
4. **Every "established" claim carries a source.** No source means it is at most "inferred." Downgrade or go find it.
5. **Grounded, not exhaustive.** Apply the core procedures; reach into [`FRAMEWORKS.md`](FRAMEWORKS.md) only for the branch in play.

## Argument

Natural language: the thing to investigate, measure, or verify (e.g. `/rigor does caching the parser actually make builds faster`, `/rigor verify that this library is unmaintained`). File slug: kebab-case, max 6 words, for `specs/rigor/YYYY-MM-DD-<slug>.md`.

If no argument: ask `What are you investigating, measuring, or verifying?` and wait.

## Steps

### 1. Detect the class

Classify the task: **empirical** (measure / optimize / benchmark / "make X faster") or **epistemic** (verify / is-this-true / research a claim). Restate in one sentence: *"Reading this as an `<empirical|epistemic>` task. Continuing unless you correct me."* Soft confirm, proceed unless interrupted. The class selects which branch of [`FRAMEWORKS.md`](FRAMEWORKS.md) loads in Steps 2 and 4.

### 2. GATE, pre-register (hard stop)

Create `specs/rigor/YYYY-MM-DD-<slug>.md` from [`RIGOR-TEMPLATE.md`](RIGOR-TEMPLATE.md) and fill **Pass 1 only**. Apply the shared spine + the in-play branch from [`FRAMEWORKS.md`](FRAMEWORKS.md).

**Completion criterion, Pass 1 is locked when every box is checked:**

- [ ] **Goal** stated in plain language, with no metric in it.
- [ ] **2+ competing hypotheses**, each with an explicit falsifier (what observation excludes it). One hypothesis is not started.
- [ ] **The ONE variable** changing is named, and the held-equal conditions listed.
- [ ] **Metric AND what's not being measured** both stated (empirical); or **evidence standard** stated (epistemic: what would count as proof, what would change your mind).
- [ ] **Run-count / sample** decided up front (empirical: N runs, mean ± CI intended, not best-of-1).

Show Pass 1 to the user before executing, they often re-rank hypotheses instantly. Don't block if AFK, but the boxes must be checked. **No locked Pass 1, no Step 3.**

### 3. Execute

Do the work against the locked design. Change one variable at a time. Record what you actually tried, including dead ends, into Pass 2 "What I tried." For empirical: real runs, real numbers with spread. Do not edit Pass 1.

### 4. ATTACK, spawn the adversary

Spawn a forked Task sub-agent to **refute** the result. Give it the doc path, the result, and the in-play branch of `FRAMEWORKS.md`. Use this prompt verbatim:

> You are an adversarial reviewer. Your job is to REFUTE the conclusion in this rigor doc, not to bless it. Default to "this is not yet grounded" and make the work prove otherwise. Using the gate/attack checks in `~/.claude/skills/rigor/FRAMEWORKS.md` (shared spine + the `<class>` branch), produce a list of challenges. For each: the specific claim or result attacked, the check it fails, and why. Only HIGH-SIGNAL challenges, a result that is definitely wrong, a metric that definitely doesn't represent the goal, an "established" claim with no source, a win not reproduced from clean, a conclusion with no competing hypothesis ruled out. Do NOT flag style, taste, or input-dependent maybes. If you are not certain a challenge is real, drop it. Return the surviving challenges; if none survive, say so and state which checks you ran.

Then **validate** each returned challenge yourself against the doc/code (flag→validate→filter): keep only the ones that hold with high confidence, drop false positives. Write the survivors (or a justified clean pass) into Pass 2 "Adversarial verdict," and resolve each, fix the work, downgrade the claim, or record why it stands.

### 5. Finalize

Complete Pass 2 (results, how-this-could-be-wrong, decision + rejected alternatives + consequences, claim ledger). Set Status: concluded. Output a brief chat summary: doc path, the verdict, any claim still `[speculated]`. Do not auto-invoke another skill.

## When invoked on the wrong task

If it's a quick fact, a typo, or a conversational question with no investigation, no measurement, and no contested claim, the always-on "Grounded claims" rule already covers it, push back in one sentence and skip the gate.
