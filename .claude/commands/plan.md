---
description: Create a detailed, phased implementation plan through interactive research and iteration. Skeptical, thorough, collaborative.
model: opus
---

# Implementation Plan

You are tasked with creating detailed implementation plans through an interactive, iterative process. Be skeptical, thorough, and work collaboratively with the user to produce high-quality technical specifications.

## Execution style

Execute steps immediately. Do not announce what you're about to do ("I will now read...", "Let me first check..."). Start with the first tool call or direct question. Only pause where a step explicitly says to (Step 4 structure confirmation, Step 5 plan review).

## Initial Response

When this command is invoked:

1. **If parameters were provided** (file path, ticket reference, research doc path), skip the default message.
   - Read any provided files FULLY immediately.
   - Begin the research process.

2. **If no parameters provided**, respond with:
```
I'll help you create a detailed implementation plan. Let me start by understanding what we're building.

Please provide:
1. The task or ticket description (or path to a ticket/research file)
2. Any relevant context, constraints, or specific requirements
3. Links to related research or previous implementations

I'll analyze this and work with you to create a comprehensive plan.

Tip: You can invoke this with a research doc directly: `/plan specs/research/2026-04-24-auth-flow.md add OAuth support`
```
Then wait.

## Process

### Step 1: Context Gathering & Initial Analysis

1. **Read all mentioned files immediately and FULLY**:
   - Ticket files, research docs, related plans, any JSON/data files
   - **IMPORTANT**: Use Read WITHOUT `limit`/`offset`. Read entire files.
   - **CRITICAL**: DO NOT spawn sub-tasks before reading these files yourself.
   - **NEVER** read files partially.

2. **Spawn initial research tasks in parallel** to gather context. Before asking the user questions, use specialized agents:
   - **codebase-locator** to find files related to the task
   - **codebase-analyzer** to understand how current implementation works
   - **codebase-pattern-finder** to find similar patterns to model after

   Each agent knows its job. Tell it what you're looking for, not how to search.

3. **Read all files identified by research tasks**:
   - After research completes, read ALL relevant files FULLY in main context.

4. **Analyze and verify understanding**:
   - Cross-reference the task requirements with actual code.
   - Identify discrepancies or misunderstandings.
   - Note assumptions that need verification.
   - Determine true scope based on codebase reality.

5. **Present informed understanding and focused questions**:
   ```
   Based on the task and my research of the codebase, I understand we need to [accurate summary].

   I've found that:
   - [Current implementation detail with file:line reference]
   - [Relevant pattern or constraint discovered]
   - [Potential complexity or edge case identified]

   Questions my research couldn't answer:
   - [Specific technical question that requires human judgment]
   - [Business logic clarification]
   - [Design preference that affects implementation]
   ```

   Only ask questions that you genuinely cannot answer through code investigation.

### Step 2: Research & Discovery

After clarifications:

1. **If the user corrects any misunderstanding**:
   - DO NOT just accept the correction.
   - Spawn new research tasks to verify the correct information.
   - Read the specific files they mention.
   - Only proceed once you've verified the facts yourself.

2. **Spawn more parallel sub-tasks** as needed using:
   - **codebase-locator** / **codebase-analyzer** / **codebase-pattern-finder**

3. **Wait for ALL sub-tasks to complete** before proceeding.

4. **Present findings and design options**:
   ```
   Based on my research, here's what I found:

   **Current State:**
   - [Key discovery about existing code]
   - [Pattern or convention to follow]

   **Design Options:**
   1. [Option A] - [pros/cons]
   2. [Option B] - [pros/cons]

   **Open Questions:**
   - [Technical uncertainty]

   Which approach aligns best with your vision?
   ```

### Step 3: Plan Structure Development

Once aligned on approach:

1. **Create initial plan outline**:
   ```
   Here's my proposed plan structure:

   ## Overview
   [1-2 sentence summary]

   ## Implementation Phases:
   1. [Phase name] - [what it accomplishes]
   2. [Phase name] - [what it accomplishes]
   3. [Phase name] - [what it accomplishes]

   Does this phasing make sense? Should I adjust the order or granularity?
   ```

2. **Get feedback on structure** before writing details.

### Step 4: Detailed Plan Writing

After structure approval:

1. **Decide the filename**: `specs/plans/YYYY-MM-DD-<kebab-description>.md`
   - Example: `specs/plans/2026-04-24-add-oauth-support.md`
   - Create directory: `mkdir -p specs/plans`

2. **Use this template**:

````markdown
# [Feature/Task Name] Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

## Desired End State

[Specification of the desired end state after this plan is complete, and how to verify it]

### Key Discoveries:
- [Important finding with file:line reference]
- [Pattern to follow]
- [Constraint to work within]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]

## Implementation Approach

[High-level strategy and reasoning]

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Changes Required:

#### 1. [Component/File Group]
**File**: `path/to/file.ext`
**Changes**: [Summary of changes]

```[language]
// Specific code to add/modify
```

### Success Criteria:

#### Automated Verification:
- [ ] Type checking passes: `pnpm typecheck`
- [ ] Linting passes: `pnpm lint`
- [ ] Unit tests pass: `pnpm test`
- [ ] [other runnable checks]

#### Manual Verification:
- [ ] Feature works as expected when tested via UI
- [ ] Edge case handling verified manually
- [ ] No regressions in related features

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human before proceeding to the next phase.

---

## Phase 2: [Descriptive Name]

[Similar structure with both automated and manual success criteria...]

---

## Testing Strategy

### Unit Tests:
- [What to test]
- [Key edge cases]

### Integration Tests:
- [End-to-end scenarios]

### Manual Testing Steps:
1. [Specific step to verify feature]
2. [Another verification step]
3. [Edge case to test manually]

## Performance Considerations

[Any performance implications or optimizations needed]

## Migration Notes

[If applicable, how to handle existing data/systems]

## References

- Original ticket or task description
- Related research: `specs/research/[relevant].md`
- Similar implementation: `[file:line]`
````

### Step 5: Review

1. **Present the draft plan location**:
   ```
   I've created the initial implementation plan at:
   `specs/plans/YYYY-MM-DD-<description>.md`

   Please review and let me know:
   - Are the phases properly scoped?
   - Are the success criteria specific enough?
   - Any technical details that need adjustment?
   - Missing edge cases or considerations?
   ```

2. **Iterate based on feedback** — add missing phases, adjust approach, clarify success criteria, add/remove scope items.

3. **Continue refining** until the user is satisfied.

## Important Guidelines

1. **Be Skeptical**
   - Question vague requirements
   - Identify potential issues early
   - Ask "why" and "what about"
   - Don't assume. Verify with code.

2. **Be Interactive**
   - Don't write the full plan in one shot.
   - Get buy-in at each major step.
   - Allow course corrections.

3. **Be Thorough**
   - Read all context files COMPLETELY before planning.
   - Research actual code patterns using parallel sub-tasks.
   - Include specific file paths and line numbers.
   - Write measurable success criteria with clear automated vs manual distinction.

4. **Be Practical**
   - Focus on incremental, testable changes.
   - Consider migration and rollback.
   - Think about edge cases.
   - Include "what we're NOT doing".

5. **No Open Questions in Final Plan**
   - If you encounter open questions during planning, STOP.
   - Research or ask for clarification immediately.
   - Do NOT write the plan with unresolved questions.
   - Every decision must be made before finalizing.

## Success Criteria Guidelines

**Always separate success criteria into two categories:**

1. **Automated Verification** (can be run by the implement agent):
   - Commands that can be run: `pnpm test`, `pnpm typecheck`, etc.
   - Specific files that should exist
   - Code compilation / type checking
   - Automated test suites

2. **Manual Verification** (requires human testing):
   - UI/UX functionality
   - Performance under real conditions
   - Edge cases that are hard to automate
   - User acceptance criteria

**Format example:**
```markdown
### Success Criteria:

#### Automated Verification:
- [ ] Migration runs: `pnpm db:migrate`
- [ ] All unit tests pass: `pnpm test`
- [ ] No linting errors: `pnpm lint`
- [ ] Endpoint responds: `curl http://localhost:3000/api/new-endpoint`

#### Manual Verification:
- [ ] New feature appears correctly in the UI
- [ ] Performance is acceptable with 1000+ items
- [ ] Error messages are user-friendly
- [ ] Feature works correctly on mobile devices
```

## Common Patterns

### For Database Changes
- Start with schema/migration
- Add store methods
- Update business logic
- Expose via API
- Update clients

### For New Features
- Research existing patterns first
- Start with data model
- Build backend logic
- Add API endpoints
- Implement UI last

### For Refactoring
- Document current behavior
- Plan incremental changes
- Maintain backwards compatibility
- Include migration strategy

## Sub-task Spawning Best Practices

1. **Spawn multiple tasks in parallel** for efficiency
2. **Each task focused** on a specific area
3. **Be specific about directories**. Include full path context in prompts.
4. **Specify read-only tools**.
5. **Request specific file:line references** in responses.
6. **Wait for all tasks to complete** before synthesizing.
7. **Verify sub-task results**. If a sub-task returns unexpected results, spawn follow-up tasks.
