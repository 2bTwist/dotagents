---
description: Build a phased implementation plan. Takes a task + optional research doc path. Writes to specs/plans/YYYY-MM-DD-<slug>.md
argument-hint: "<research path or task description>"
---

# Plan: $@

**If the line above shows nothing after "Plan:", stop and ask what the user wants to plan. Do not proceed without a task.**

You are creating a phased implementation plan. The plan will feed `/implement` later, so precision matters.

## Your tools
You have `read`, `write`, `edit`, `bash`, `grep`, `find`, `ls`. That is all.

## Hard rules

- Read all mentioned files FULLY before writing anything.
- No open questions in the final plan. Resolve them first.
- Every phase has automated AND manual success criteria, split into two lists.
- Code snippets in phases must be concrete. No `// TODO` or pseudo-code.
- Include a "What we're NOT doing" section to prevent scope creep.

## Workflow

### Step 1: Read inputs fully
If the user referenced a research doc path, read it completely now. If they referenced a ticket file, read it. No skimming, no line-range reads.

### Step 2: Fill in missing context
If you need more context than the research/ticket gave you, do the work yourself using `grep`, `find`, `ls`, and `read`. Keep scope narrow — you are planning, not exploring.

Rules for reads in this step:
- Document what IS, not what SHOULD BE.
- File:line references for any claim you'll rely on in the plan.

### Step 3: Ask focused questions (only if needed)
Only ask the user what the code cannot answer: business logic, design preferences, feature boundaries. Do not ask "how is X implemented" — read it yourself.

### Step 4: Propose structure first
Before writing the full plan, show a brief outline:

```
Proposed phases:
1. <phase name> — <what it accomplishes>
2. <phase name> — <what it accomplishes>
3. <phase name> — <what it accomplishes>

Does this phasing make sense?
```

Wait for confirmation or redirection.

### Step 5: Write the plan
Pick a kebab-case slug. Create the directory and write the file:

```bash
mkdir -p specs/plans
```

Write to `specs/plans/YYYY-MM-DD-<slug>.md` using this structure:

```markdown
# <Task Name> Implementation Plan

## Overview
<1-2 sentences of what and why>

## Current State Analysis
<What exists today. Reference the research doc if one was used.>

## Desired End State
<Spec of what "done" looks like and how to verify it.>

### Key Discoveries
- <Constraint or pattern found with file:line>

## What We're NOT Doing
<Explicit out-of-scope list.>

## Implementation Approach
<High-level strategy.>

## Phase 1: <Descriptive Name>

### Changes Required

#### <file path>
**Changes**: <summary>

\`\`\`typescript
// concrete code to add or modify — no placeholders
\`\`\`

### Success Criteria

#### Automated
- [ ] Type check passes: `pnpm typecheck`
- [ ] Lint passes: `pnpm lint`
- [ ] Unit tests pass: `pnpm test`

#### Manual
- [ ] Feature works when tested via UI
- [ ] No regressions in related features

**Note**: After automated verification passes, pause for user to confirm manual checks before proceeding to Phase 2.

---

## Phase 2: <Descriptive Name>
[same structure]

---

## Testing Strategy
- Unit tests: <what to test, key edge cases>
- Integration: <end-to-end scenarios>
- Manual: <specific steps>

## References
- Research: `specs/research/<file>.md` (if used)
- Similar implementation: `<file:line>`
```

### Step 6: Report
Tell the user where the plan was written. Offer to iterate or to run `/implement`.

## For small local models (7B to 9B)

- Prefer 2-3 phases over 5
- Keep code snippets short (10-20 lines max per block)
- Lean more on manual verification, fewer automated checks
- If the task feels too big, say so and ask the user to break it into multiple plans

## Anti-patterns

- Writing the plan without reading the research/ticket fully
- Skipping the structure confirmation in step 4
- Leaving "open questions" in the final plan
- Code snippets with `// TODO` or pseudo-code
- Missing the automated/manual split in success criteria
- Calling a tool that does not exist. Your tools are `read`, `write`, `edit`, `bash`, `grep`, `find`, `ls`.
- Trying to delegate to another agent. Pi has no parallel dispatch.
