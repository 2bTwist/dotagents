---
name: plan
description: Create a decision-complete, phased implementation plan after grounding in the code, then write it to specs/plans/YYYY-MM-DD-<slug>.md.
model: opus
---

# Plan

Create a detailed, phased implementation plan by grounding in the code, resolving every open decision, then writing it down. Be skeptical — verify against the repo, don't assume.

## Execution style

Execute steps immediately. Don't announce ("I'll now read…"); start with the first tool call. Pause only where a step says to (Step 3 structure confirmation, Step 5 review).

If invoked with a file / ticket / research path, read it FULLY first, then begin. If invoked with nothing, ask for the task (or a path to one) and wait.

## Steps

### 1. Ground in the code

Read every referenced file FULLY (no `limit`/`offset`) before anything else. Then spawn the read-only research agents in parallel — `codebase-locator` (find related files), `codebase-analyzer` (how it works today), `codebase-pattern-finder` (patterns to model after). Read everything they surface, fully. Cross-reference the task against what the code actually does; note discrepancies and the true scope.

Done when you can state the current behavior with `file:line` references, not guesses.

### 2. Resolve every open decision

Resolve anything the code can't answer with the user. For a substantial plan, interview them down the decision tree: work one branch at a time, resolving each decision before the ones that depend on it, and for every question surface its edge cases and name the tradeoff it makes against the alternative you're rejecting. If a `grilling` skill is installed, use it for this. For a small plan, just ask the few questions the code couldn't answer.

Then enumerate the installed skills and match each phase's task class to one (`ls ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills .claude/skills .agents/skills 2>/dev/null`). A locally-installed skill is pre-vetted for this stack — name it in the plan's References and in the relevant phase so `/implement` reuses it instead of reinventing the approach.

Done when no open questions remain. Every decision is made before you write.

### 3. Confirm the phase structure

Present the overview and the phase list (each phase's name + what it accomplishes). Get the user's sign-off on phasing and granularity before writing any detail.

### 4. Write the plan

Write to `specs/plans/YYYY-MM-DD-<kebab-slug>.md` (create `specs/plans/` if needed), following the structure in [`PLAN-TEMPLATE.md`](PLAN-TEMPLATE.md).

### 5. Review

Point the user at the draft. Ask whether the phases are scoped right and the success criteria are specific enough, then iterate in place until they're satisfied.
