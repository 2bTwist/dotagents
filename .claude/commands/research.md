---
description: Document how an area of the codebase works today by spawning parallel sub-agents and synthesizing their findings into a research doc.
model: opus
---

# Research Codebase

You are tasked with conducting comprehensive research across the codebase to answer a question by spawning parallel sub-agents and synthesizing their findings.

## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN THE CODEBASE AS IT EXISTS TODAY
- DO NOT suggest improvements or changes unless the user explicitly asks
- DO NOT perform root cause analysis unless the user explicitly asks
- DO NOT propose future enhancements unless the user explicitly asks
- DO NOT critique the implementation or identify "problems"
- DO NOT recommend refactoring, optimization, or architectural changes
- ONLY describe what exists, where it exists, how it works, and how components interact

You are creating a technical map of the existing system. This document will feed into `/plan` later. Contamination here (opinions, suggestions, "shoulds") pollutes the plan phase and produces bad code. Discipline matters.

## Initial Setup

When this command is invoked:

1. **If a parameter was provided** (question, ticket path, file path), skip the prompt and begin.
2. **If no parameter**, respond with:
```
I'm ready to research the codebase. What's the question or area you want mapped?
```
Then wait.

## Steps

### 1. Read any directly mentioned files first
- If the user mentions specific files (tickets, docs, JSON), read them FULLY first.
- **IMPORTANT**: Use the Read tool WITHOUT `limit`/`offset` parameters. Read entire files.
- **CRITICAL**: Read these files yourself in the main context before spawning sub-tasks. You need full context before decomposing.

### 2. Analyze and decompose the research question
- Break the query into composable research areas.
- Ultrathink about the underlying patterns, connections, and architectural implications the user might be seeking.
- Identify specific components, patterns, or concepts to investigate.
- Consider which directories, files, or architectural patterns are relevant.

### 3. Spawn parallel sub-agent tasks
Use the Agent tool with these subagent types to research different aspects concurrently:

- **codebase-locator** for finding WHERE files and components live
- **codebase-analyzer** for understanding HOW specific code works (without critiquing it)
- **codebase-pattern-finder** for finding examples of existing patterns (without evaluating them)

All three are documentarians, not critics. They describe what exists without suggesting improvements or identifying issues.

**Optional:**
- Use the **Explore** subagent for broader codebase exploration if the question is too diffuse for targeted locators.
- Use **WebSearch** (directly) for external documentation ONLY if the user explicitly asks.

Guidance for spawning:
- Start with locator agents to find what exists.
- Then use analyzer agents on the most promising findings.
- Run multiple agents in parallel when they're searching for different things.
- Each agent knows its job. Tell it what you're looking for, not HOW to search.
- Remind agents they are documenting, not evaluating.

### 4. Wait and synthesize
- **IMPORTANT**: Wait for ALL sub-agent tasks to complete before proceeding.
- Compile all findings.
- Connect findings across different components.
- Include specific file paths and line numbers for reference.
- Highlight patterns, connections, and architectural decisions.
- Answer the user's specific question with concrete evidence.

### 5. Gather metadata
Run in parallel:
```bash
git rev-parse --short HEAD
git branch --show-current
basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
date -u +"%Y-%m-%dT%H:%M:%SZ"
date +%Y-%m-%d
```

Decide on a filename: `specs/research/YYYY-MM-DD-<kebab-description>.md`
- YYYY-MM-DD is today's date
- description is a brief kebab-case summary of the research topic
- Examples: `2026-04-24-auth-flow.md`, `2026-04-24-avatar-prompt-screen.md`

Create the directory if needed: `mkdir -p specs/research`

### 6. Write the research document
Structure with YAML frontmatter then content:

```markdown
---
date: <ISO timestamp from step 5>
git_commit: <short SHA>
branch: <branch name>
repository: <repo name>
topic: "<user's question / topic>"
tags: [research, codebase, <relevant-component-names>]
status: complete
last_updated: <YYYY-MM-DD>
---

# Research: <User's Question/Topic>

**Date**: <ISO timestamp>
**Git Commit**: <short SHA>
**Branch**: <branch name>
**Repository**: <repo name>

## Research Question
<Original user query>

## Summary
<High-level description of what was found, answering the user's question by describing what exists. No recommendations.>

## Detailed Findings

### [Component/Area 1]
- Description of what exists (`file.ext:line`)
- How it connects to other components
- Current implementation details (without evaluation)

### [Component/Area 2]
...

## Code References
- `path/to/file.ts:123` - Description of what's there
- `another/file.ts:45-67` - Description of the code block

## Architecture Documentation
<Current patterns, conventions, and design implementations found in the codebase>

## Open Questions
<Any areas that need further investigation>
```

### 7. Add GitHub permalinks (if applicable)
- Check current branch and whether the commit is pushed.
- If on main/master or pushed, generate permalinks:
  ```bash
  gh repo view --json owner,name
  ```
  Format: `https://github.com/<owner>/<repo>/blob/<commit>/<file>#L<line>`
- Replace local file references with permalinks where it helps.

### 8. Present findings
- Tell the user where the doc was written (`specs/research/...md`).
- Give a concise summary with key file references.
- Ask if they have follow-up questions.

### 9. Handle follow-ups
If the user has follow-ups, append to the same research document under a new `## Follow-up Research <timestamp>` section. Update the `last_updated` frontmatter field.

## Important notes

- Always use parallel Task agents to maximize efficiency and minimize context usage.
- Always run fresh codebase research. Don't rely on older research docs alone.
- Focus on finding concrete file paths and line numbers for developer reference.
- Research documents should be self-contained with all necessary context.
- Each sub-agent prompt should be specific and focused on read-only documentation.
- Document cross-component connections and how systems interact.
- Include temporal context (when the research was conducted).
- Keep the main agent focused on synthesis, not deep file reading.
- **CRITICAL**: You and all sub-agents are documentarians, not evaluators.
- **REMEMBER**: Document what IS, not what SHOULD BE.
- **NO RECOMMENDATIONS**: Only describe the current state of the codebase.
- **File reading**: Always read mentioned files FULLY (no `limit`/`offset`) before spawning sub-tasks.
- **Ordering**: Read mentioned files (step 1) → decompose (step 2) → spawn agents (step 3) → wait for all (step 4) → metadata (step 5) → write doc (step 6). Never write with placeholder values.
