---
name: research
description: Map how an area works TODAY (codebase or external/web) — spawn parallel sub-agents, synthesize into specs/research/YYYY-MM-DD-<slug>.md.
model: opus
---

# Research

Two branches, routed by the question:

- **Codebase**: the question is about this repo or code the user owns. Follow the steps below.
- **External/web**: the question is about the outside world (a library's state, a claim, a market, how something works off-repo). Load and follow [`WEB-RESEARCH.md`](WEB-RESEARCH.md) instead of the steps below. Mixed questions: run the codebase steps for the repo half, the web branch for the external half, synthesize in one doc.

## Codebase branch

Map how an area of the codebase works **today** and write it down. You are a **documentarian**, not a critic: describe what exists, where it lives, and how it connects — never suggest improvements, root-cause, critique, or recommend changes unless the user explicitly asks. This doc feeds `/plan`; any "should" you leak here pollutes the plan and produces bad code. That discipline is the skill.

## Execution style

Execute immediately — don't announce ("I'll now spawn…"), start with the first tool call. Pause only where a step says to. Invoked with a question or path: begin. Invoked with nothing: ask what to map, then wait.

## Steps

### 1. Read what's named
Read any files the user mentions FULLY (no `limit`/`offset`) before decomposing — you need full context before you split the work.

### 2. Decompose
Break the question into composable research areas. `ultrathink` about the patterns, connections, and architecture the user is really after.

### 3. Spawn parallel sub-agents
Run concurrently — each a documentarian (tell them WHAT to find, not how; remind them to describe, not evaluate):
- `codebase-locator` — WHERE things live
- `codebase-analyzer` — HOW the code works
- `codebase-pattern-finder` — existing patterns to point at

Use `Explore` for a question too diffuse for targeted locators; `WebSearch` only if the user explicitly asks.

### 4. Synthesize
Wait for ALL agents before proceeding. Connect findings across components with `file:line` evidence, answering the user's actual question. Stay on synthesis — don't deep-read files in main context.

### 5. Write the doc
Write to `specs/research/YYYY-MM-DD-<kebab-slug>.md` (create the dir) using the structure and metadata commands in [`RESEARCH-TEMPLATE.md`](RESEARCH-TEMPLATE.md). Fill the metadata from real command output first — never write placeholder values.

### 6. Permalinks, then present
On a pushed branch or main, swap local refs for GitHub permalinks (`gh repo view --json owner,name`). Then give the user the doc path and a concise summary with key references. Append follow-ups to the same doc under a `## Follow-up Research <date>` heading and bump `last_updated`.

Done when the doc answers the question **purely descriptively** (zero recommendations), every claim carries a `file:line`, and the metadata is real.
