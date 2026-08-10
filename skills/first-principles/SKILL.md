---
name: first-principles
description: Produce a first-principles re-framing of a substantial task, decision, or product surface before /plan. The agent identifies the conventional incumbent approach, questions whether its core assumptions still hold, decomposes the problem into atomic primitives, and proposes the embarrassingly-good rebuild of the primitive most worth rethinking. Writes a 7-section analysis to specs/first-principles/YYYY-MM-DD-<slug>.md. Suggest invoking when about to start a substantial new feature surface, architectural decision, or product direction with an obvious incumbent approach to copy. Skip for /oneshot territory, bug fixes, pure mapping (/research), or work that already has prior art in this repo.
model: opus
---

# First-Principles Re-framing

Apply the seven-step Pierre Computer Company analysis to a topic the user names. **The agent does the reasoning; the user reviews and pushes back.** This is not an interview. The output is an agent-authored doc that questions the conventional framing before `/plan` operationalizes a solution.

The skill is **topic-agnostic**. It does not hardcode domain, stack, or industry. The argument the user supplies — fuzzy or precise — determines what the analysis targets.

## Execution style

Execute steps immediately. Do not announce what you are about to do. Start with the first tool call. Pause only where a step says to.

## CRITICAL RULES

1. **The analysis is yours.** This skill is not an interview. The user names the topic; the agent does the seven-step thinking and writes the doc. Do not punt the work back by asking the user "what's the lazy bias here?" — that's your job.
2. **Specific beats general.** Generic insights about "first principles" are useless. Every conclusion must be specific to the user's actual topic, with citations from sub-agent findings (repo, web, canon). Vague reframes are a failed run.
3. **Negative results are valid.** If the analysis concludes the conventional approach is correct and no reframe surfaces, emit a short doc recording that, hand off to `/plan` or `/oneshot`, and stop. Do not invent a reframe to fill sections.
4. **One mutable primitive.** Section 5 proposes the embarrassingly-good rebuild of *one* primitive, not all of them. Restraint over feature checklist. If multiple primitives are candidates, name the most underserved one and address only it.
5. **Cite or omit.** Every load-bearing claim (the named lazy bias, the named recent shift, the named bad primitive) cites either a URL from web search, a file path from the repo, or an entry from `CANON.md`. Uncited assertions are removed.

## Steps

### 1. Parse the topic

The argument is natural language. Strip filler ("I'm thinking about", "we should"), extract substantive nouns, derive:
- **Topic label** for the analysis (e.g. "background-job-system", "parcel-status-screen", "billing-architecture").
- **File slug** for the doc path: kebab-case, max 6 words. Path: `specs/first-principles/YYYY-MM-DD-<slug>.md`.

Restate in one sentence: *"Reading this as `<topic>`. Continuing unless you correct me."* Soft confirmation — proceed without waiting unless the user interrupts. If the argument is genuinely ambiguous (e.g. "fix the thing"), ask one clarifying question and wait.

### 2. Dispatch sub-agents in parallel

Spawn three sub-agents via the Task tool, all at once:

- **Conventional-approach mapper.** Task: *"For `<topic>`, identify the conventional approach. What does the dominant canon (vendor docs, top libraries, common blog patterns) say is the default solution? What problem assumptions does this default encode about scale, audience, deployment, performance, ergonomics? Return: named approach, 2-3 source URLs, the assumptions encoded."* Tools: WebSearch, WebFetch.
- **Recent-shifts analyst.** Task: *"For `<topic>`, identify what has shifted recently in the field that may invalidate the conventional assumptions. Critiques, replacements, new constraints, audience shifts, new affordances, recent failure modes. Return: 2-3 specific shifts with source URLs, dated. Skip lazy 'AI changes everything' takes — name concrete shifts."* Tools: WebSearch, WebFetch.
- **Repo decomposer.** Task: *"Map how `<topic>` appears in this repo. Identify atomic primitives (separate, separately-shippable units), dependencies between them, and any current implementation. Return: primitive list with file paths and line ranges, dependency notes."* Tools: Read, Grep, Glob, LS.

Verify every load-bearing sub-agent claim against its cited source before using it. Same-model sub-agents improve context separation; they do not produce independent evidence.

While sub-agents run, read `~/.claude/skills/first-principles/CANON.md` to load anchor examples. Scan `MEMORY.md` (in the project's auto-memory directory) if it exists, for standing constraints relevant to the topic.

### 3. Synthesize and write the analysis

Once sub-agents return, write `specs/first-principles/YYYY-MM-DD-<slug>.md` (create the dir if needed) following the 7-section structure in [`FORMAT.md`](FORMAT.md). When no reframe is warranted, use the **negative-result mode** doc defined there instead of inventing a reframe to fill sections.

### 4. Hand off

Output a 3-line chat summary:
1. Path to the doc.
2. The named lazy bias and the proposed rebuild's primitive (or "no reframe" if negative result).
3. The hand-off line from the doc.

Do not auto-invoke `/plan` or start a stress-test pass. Stop and wait.

## When invoked on the wrong task

If invoked on a task the description's SKIP guidance matches (bug fix, rename, color change, well-established repo pattern, work where the framing is already settled), push back in one sentence and suggest the right tool (`/oneshot`, `/research`, or direct `/plan`). Do not run a forced analysis.

## Iteration

When the user pushes back on the doc (e.g. "section 1 is wrong, the lazy bias is actually X"), edit the affected section(s) in place. Do not append a revision history — `specs/` is git-tracked and that's the audit trail. Re-output the chat summary after edits if the framing changed materially.
