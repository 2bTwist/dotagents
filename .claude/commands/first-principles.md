---
description: |
  Produce a first-principles re-framing of a substantial task, decision, or product surface before /plan. The agent names the conventional incumbent approach, questions whether its core assumptions still hold, decomposes the problem into atomic primitives, and proposes the embarrassingly-good rebuild of the primitive most worth rethinking. Writes a 7-section analysis to specs/first-principles/YYYY-MM-DD-<slug>.md. Pierre Computer Company is the originating reference; CANON.md extends the lineage.

  TRIGGER when:
  - User is about to start a substantial new feature surface, architectural decision, or product direction.
  - The space has an obvious incumbent approach that everyone copies.
  - The user signals they want to challenge the framing, not just execute it.

  SKIP when:
  - Quick fix, rename, typo, color change (use /oneshot).
  - Pure mapping or debugging (use /research).
  - Pattern already exists in this repo (use /research, then /plan).
  - User has already decided on the framing and wants execution (use /plan directly).
model: opus
argument-hint: <topic — natural language>
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
  - WebSearch
  - WebFetch
  - Skill
---

# First-Principles

You are running the `first-principles` skill on the user's topic.

## Argument

Arguments: $ARGUMENTS

Natural language. Examples:
- `/first-principles add background jobs to the API`
- `/first-principles redesign the parcel status screen`
- `/first-principles how should we model billing`
- `/first-principles real-time driver tracking`

If no argument is provided, respond with:
```
What do you want me to apply first-principles framing to? Describe it however you want — "add X", "redesign Y", or just "Y" all work.
```
Then wait.

## Run the skill

Invoke the `first-principles` skill with the argument as the topic. The skill at `~/.claude/skills/first-principles/SKILL.md` defines:
- The 7-section analysis structure.
- The parallel sub-agent dispatch (conventional-approach mapper, recent-shifts analyst, repo decomposer).
- The negative-result mode (when no reframe is warranted).
- The output path (`specs/first-principles/YYYY-MM-DD-<slug>.md`).
- The hand-off behavior.

Read `~/.claude/skills/first-principles/CANON.md` for anchor examples when an analogy sharpens the analysis. Do not name-drop canon entries on every invocation.

The user reviews the agent-authored doc and pushes back where the framing misses. Edit affected sections in place when corrections come.
