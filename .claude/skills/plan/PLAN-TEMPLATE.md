# Plan document template

Write the plan to `specs/plans/YYYY-MM-DD-<kebab-slug>.md` using this structure.

````markdown
# [Feature/Task Name] Implementation Plan

## Overview

[Brief description of what we're implementing and why.]

## Current State Analysis

[What exists now, what's missing, key constraints discovered — with `file:line` references.]

## Desired End State

[The end state after this plan is complete, and how to verify it.]

### Key Discoveries
- [Important finding with `file:line` reference]
- [Pattern to follow]
- [Constraint to work within]

## What We're NOT Doing

[Explicit out-of-scope items, to prevent scope creep.]

## Implementation Approach

[High-level strategy and reasoning.]

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes.]

### Changes Required

#### 1. [Component/File Group]
**File**: `path/to/file.ext`
**Changes**: [Summary]

```[language]
// Specific code to add/modify
```

### Success Criteria

#### Automated Verification
- [ ] Type checking passes: `<typecheck command>`
- [ ] Linting passes: `<lint command>`
- [ ] Tests pass: `<test command>`

#### Manual Verification
- [ ] [Behaviour to confirm by hand]
- [ ] Edge case handling verified
- [ ] No regressions in related features

**After this phase passes automated verification, pause for manual confirmation before the next phase.**

---

## Phase 2: [Descriptive Name]

[Same structure: changes + automated and manual success criteria.]

---

## Testing Strategy

- Unit: [what to test, key edge cases]
- Integration: [end-to-end scenarios]
- Manual steps: [specific verification steps]

## Performance Considerations

[Any performance implications or optimizations.]

## Migration Notes

[If applicable, how to handle existing data/systems.]

## References

- Original ticket or task
- Related research: `specs/research/[relevant].md`
- Similar implementation: `[file:line]`
- Relevant installed skill(s): `<name>` — invoke during implementation
````

## Success criteria: the split

Every phase separates two kinds of checks. Keep them distinct so `/implement` knows what it can self-verify versus what needs you.

- **Automated** — anything the implement agent can run: type check, lint, tests, a build, a `curl`, "file exists". Write the actual command.
- **Manual** — anything needing a human: UI/UX, performance under real conditions, hard-to-automate edge cases, acceptance.

Use the project's own commands (read `package.json`/CI/CLAUDE.md for the real ones); the placeholders above are not literal.
