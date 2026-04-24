# Append this to your ~/.pi/agent/AGENTS.md

> Copy the section below (everything under "## Workflow entry points") to the end of your `~/.pi/agent/AGENTS.md`. Don't replace the file — append. If the file doesn't exist yet, see Pi's docs or create one with your own preferences on top.

---

## Workflow entry points (for non-trivial work)

For anything beyond a small conversational edit, use these prompt templates. They implement Dex Horthy's ACE-FCA (Advanced Context Engineering for Coding Agents) methodology, adapted for Pi and local models.

- **`/research <question>`** maps how an area of the codebase works today. Walks through locate → analyze steps in one session using grep/find/read. Writes to `specs/research/YYYY-MM-DD-<slug>.md`. Documents what IS, never what SHOULD BE.
- **`/plan <task or research path>`** turns a task (plus optional research doc) into a phased plan at `specs/plans/YYYY-MM-DD-<slug>.md`. Interactive: asks focused questions, proposes options, then writes phases with code snippets and split automated/manual verification.
- **`/implement <plan path>`** executes an approved plan one phase at a time. Ticks automated boxes, pauses for manual verification between phases.
- **`/oneshot <task>`** is the escape hatch for small tasks (rename, color change, one-line fix). Skip research/plan, go direct.

Pi's native `/compact` handles mid-session compaction — no custom wrapper needed.

### Sub-agent skills (user-invoked, optional)

These are skills you can invoke directly as a user slash-command when you want a focused, scoped session. They load their own rules into the conversation. They are NOT tools the model calls on its own — Pi dispatches skills when the user types the command.

- **`/skill:codebase-locator`** — find WHERE files live (paths grouped by purpose, no file contents)
- **`/skill:codebase-analyzer`** — explain HOW code works (file:line references, no critique)
- **`/skill:codebase-pattern-finder`** — show existing patterns with working code snippets

The `/research` and `/plan` prompt templates don't need these skills to work — they inline the same discipline directly. Use the skills when you want a single-purpose session, not a full research/plan flow.

### When NOT to use this workflow

Small conversational edits, typo fixes, exploratory "what if" questions. RPI is for brownfield or complex work, not every task.

### Don't outsource the thinking

Magic prompts don't exist. When research and plan documents come back, the user reads them. That's the high-leverage review point, not the eventual PR.

### Local-model honesty

On a 7B model with a 32k context window, expect shorter plans, narrower research scopes, and more iteration than the same workflow on a frontier model. For harder reasoning, switch to a 9B reasoning model via `pi --model <reasoning-model>`.

### Core principles baked into the prompt templates

1. Read files FULLY. Never partial.
2. Document what IS, never what SHOULD BE (research phase).
3. Split automated and manual verification in plans.
4. Stop on mismatch. Don't silently adapt.
5. Scope discipline. Never add "while I'm here" work.
