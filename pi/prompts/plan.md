---
description: Build a phased implementation plan. Takes a task + optional research doc path. Writes to specs/plans/YYYY-MM-DD-<slug>.md
argument-hint: "<research path or task description>"
---

# Plan: $@

You are creating a phased implementation plan. The plan will feed `/implement` later, so precision matters.

## Hard rules

- Read all mentioned files FULLY (no partial reads) before writing anything.
- No open questions in the final plan. Resolve them before writing.
- Every phase has automated AND manual success criteria, split into two lists.
- Code snippets in phases must be concrete — exact file paths, exact code, not placeholders.
- Include a "What we're NOT doing" section to prevent scope creep.

## Steps

### 1. Read inputs fully
If the user referenced a research doc path, read it completely. If they referenced a ticket, read it. No skimming.

### 2. Understand current state
If you need more context than the research provided, invoke `/skill:codebase-locator` or `/skill:codebase-analyzer` for specific sub-questions. Keep the scope narrow.

### 3. Ask focused questions (if needed)
Only ask the user what the code itself can't answer — business logic, design preferences, feature boundaries. Don't ask "how is X implemented" (read it yourself).

### 4. Propose structure first
Before writing the full plan, show the user a brief outline:

```
Proposed phases:
1. <phase name> — <what it accomplishes>
2. <phase name> — <what it accomplishes>
3. <phase name> — <what it accomplishes>

Does this phasing make sense?
```

Wait for confirmation or redirection before writing the full plan.

### 5. Write the plan
Pick a kebab-case slug. Write to `specs/plans/YYYY-MM-DD-<slug>.md`:

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
// concrete code to add/modify
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

### 6. Sync directory and report
```bash
mkdir -p specs/plans
```
Tell the user where the plan was written. Offer to iterate or to run `/implement`.

## If the model is small (qwen2.5-coder:7b)

Keep plans shorter. Prefer 2-3 phases over 5. Shorter code snippets. More manual verification, fewer automated steps. Ask the user to break very large tasks into multiple plans.

## Anti-patterns

- Writing the plan without reading the research/ticket fully
- Skipping the structure confirmation step in step 4
- Leaving "open questions" in the final plan
- Code snippets with `// TODO` or pseudo-code instead of real code
- Missing the automated/manual split in success criteria
