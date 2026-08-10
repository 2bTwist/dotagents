---
name: crew
description: Run this session as a first mate. Decompose a multi-part task, dispatch the parts to agents in parallel, supervise them, and integrate the results yourself. Use when work splits into parts that can run at once, when a review should run alongside the build, or to triage already-running sessions. User-invoked.
disable-model-invocation: true
model: opus
harness:
  requires: [subagents]
---

# Crew

You are the **first mate**. The crew does the work; you keep the judgment. You decide what gets
built, split it so the parts cannot collide, brief each part well enough that its report means
something, and verify what comes back before any of it reaches the captain.

The dispatch policy already exists: the **Agent loop efficiency** section of your core instructions
owns blast radius, disjoint file sets, briefing contents, the explicit model per dispatch, and the
rule that a green report is a claim rather than evidence. This skill owns the loop that applies it.
Follow that policy, do not restate it.

## Execution style

Execute immediately. Do not narrate the decomposition before dispatching. Pause only at the
integration gate, and wherever a step says to.

## Steps

### 1. Intake

State the goal in one sentence and name the artifact that ends it. If the request points at a plan
or spec, read it fully before splitting anything.

If the spec is ambiguous, stop and settle it in writing first. An ambiguous spec sent to four
crewmates buys four different interpretations and a merge you cannot referee.

**Done when:** you can name the finished artifact and the gate that proves it.

### 2. Decompose by blast radius

Keep the parts where a mistake is expensive and invisible in a diff. Delegate the parts where a
mistake surfaces as a failing test or an obvious diff. Give every part a disjoint file set.

**Done when:** every file the change will touch belongs to exactly one part, and you can say which
parts you are keeping and why.

### 3. Brief each part

Each brief carries: the ground truth by path rather than your paraphrase of it, the part's own file
set, the files that belong to other crewmates, the evidence its report must carry, an instruction to
stop and report a blocker rather than route around it, and "say what you could not do".

Naming the neighbours' files is what stops a concurrent edit from being reported as a bug.

**Done when:** every brief names its own files, its neighbours' files, and its evidence bar.

### 4. Dispatch

Send every independent part in ONE message. Parts sent in separate messages queue instead of
overlapping, which makes the parallelism decorative. Pass an explicit model on each dispatch. Give
any part that writes its own worktree. Start the review concurrently with the build rather than
after it.

One case is deliberately serial: a test written to fail first. Its whole value is the ordering, so
wait for the author to report red before dispatching the implementation it covers.

**Done when:** all independent parts left in a single message.

### 5. Supervise

Wait for completion notifications and do the work you kept while they run. A crewmate that reports a
blocker gets a real answer, from you or from the captain. Route blocked work back, never around.

**Done when:** every dispatched part is accounted for as reported, failed, or abandoned with a
stated reason.

### 6. Integrate, and treat this as a gate

Read every diff. Re-run the gates yourself. Check each load-bearing claim against the source that
supposedly backs it. A crewmate reporting success is the author of that claim, and author bias is
exactly what this step exists to catch.

**Done when:** nothing reaches the captain that you have not verified yourself, and every part you
could not finish is named as unfinished.

## Choosing the crew shape

| | In-process crew | Peer-session crew |
|---|---|---|
| What it is | Background agents inside this session | Separate agent sessions you address by name |
| Isolation | A worktree per agent, created and cleaned for you | Whatever each session already has |
| Lifetime | Dies with this session | Outlives it |
| You can watch it work | No, you get a report | Yes, if it runs somewhere visible |
| Cost | One dispatch | A full session each, with its own context and permissions |

Default to the in-process crew. It needs no setup and the harness notifies you when a part lands.
Reach for peer sessions only when the work must outlive this session, or when you need to watch and
intervene mid-flight. Triage of an existing fleet is a different job with its own hazards: see
[`FLEET.md`](FLEET.md).

## When not to run a crew

- A change that fits in one file set. One agent, or just do it.
- An exploratory question. Answer it.
- A spec you cannot state in one sentence. Settle the spec first; parallelism multiplies ambiguity.
- Work whose parts share files. Sequence it, or re-split until the sets are disjoint.
