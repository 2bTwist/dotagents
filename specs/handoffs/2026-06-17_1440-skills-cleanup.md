---
date: 2026-06-17T18:40:17Z
git_commit: 5489168
branch: main
repository: dotclaude
topic: "Unify + trim personal workflow skills against Matt Pocock's rubric"
tags: [handoff, skills, claude-config, workflow-commands]
status: in-progress
last_updated: 2026-06-17
type: handoff
---

# Handoff: skills/commands cleanup

Cleaning up the user's **global** workflow slash commands (in `~/.claude`, source-of-truth synced to `~/Projects/dotclaude`). Goal: unify on skills, trim bloat against Matt Pocock's `writing-great-skills` rubric (sprawl / sediment / no-op / duplication / progressive disclosure). Full plan + status: `dotclaude/SKILLS-CLEANUP.md`.

## Locked decisions (don't re-litigate)

1. **Unify on skills.** Workflow entry points become skills, `~/.claude/commands/` retired. Orchestrators = **user-invoked** (`disable-model-invocation: true`); engines = **model-invoked**.
2. **Source of truth = live, then push.** Edit `~/.claude/skills/`, then copy into `dotclaude/.claude/skills/`; **user commits**. Do NOT touch `~/.agents` / `~/.pi` without asking (different thin per-runtime versions; dotclaude has NO `.agents`).
3. **Scope = "only the skills the user created"** — the workflow set. NOT Matt's installed engines, NOT imported/domain skills (aso-audit, keyword-ranks, animation-vocabulary, teach, tdd, sqlalchemy, codebase-*).
4. **Global skills stay project-agnostic** — never hardcode BeSeen/supabase/repo paths. Verification examples use the user's universal `pnpm` default only.
5. `plan` **delegates its Q&A to `/grilling`** (user chose this on a re-ask).
6. Style model = Matt's `diagnosing-bugs` / `writing-great-skills`: leading words, per-phase completion criteria, no "be thorough" no-ops.

## Done (live `~/.claude/skills/` AND synced to `dotclaude/.claude/skills/`, UNCOMMITTED)

- `plan` 358→44 + `PLAN-TEMPLATE.md` 99; `research` 173→41 + `RESEARCH-TEMPLATE.md` 57; `implement` 89→40; `compact` 95→30 + `HANDOFF-TEMPLATE.md` 54; `oneshot` 68→30; `first-principles` 116→65 + `FORMAT.md` 58 (command already deleted, `model: opus` pinned).
- `grilling` = engine (our edge-case/tradeoff line folded in); `grill-me` = thin wrapper `Run a /grilling session.`
- Installed Matt engines: `diagnosing-bugs`, `prototype`, `domain-modeling`, `grill-with-docs`, `codebase-design`, `improve-codebase-architecture`, `writing-great-skills` (deps self-contained, verified no dangling refs).
- `groundwork` (95) left AS-IS on purpose — already rubric-compliant (uses sibling disclosure, no no-ops).
- dotclaude working tree: 7 commands deleted, 15 new skill dirs, 2 modified. **A suggested commit message was given; user had not committed yet at handoff.**

## Critical References

- `dotclaude/SKILLS-CLEANUP.md` — the plan + status (READ FIRST).
- `~/.claude/skills/writing-great-skills/SKILL.md` (+ `GLOSSARY.md`) — the rubric to apply.
- `~/.claude/skills/diagnosing-bugs/SKILL.md` — the style model.

## Action Items & Next Steps

1. **Commit the dotclaude sync** (if user hasn't): `cd ~/Projects/dotclaude && git add -A .claude && git commit` (NO Claude co-author trailer — user's global rule).
2. **`autoresearch`** — the one remaining command (`~/.claude/commands/autoresearch.md`, 49l, a router) + a 255-line engine skill (`~/.claude/skills/autoresearch/`) that SHARE the name, plus a triple copy in `dotclaude/domain-skills/{claude,pi}/autoresearch`. Fold the off/resume/fresh routing into the engine without breaking the autonomous loop, set user-invoked, delete the command. Its own careful pass — do NOT rush.
3. **Answer two open questions** before acting on them: (a) is `~/plugins/edmond-workflows` published/shared or abandoned? (it's untracked, only-copy, plugin-shaped — do NOT delete on assumption). (b) Are `tdd`/`teach`/`aso-audit`/`keyword-ranks` "ones the user created" (in scope) or imported (out)?
4. Decide whether to propagate cleaned skills to `~/.agents` / `~/.pi` (separate call; they hold different thin versions).

## Learnings / state of mind

- Shell is **zsh**: `for x in $VAR` does NOT word-split. Use a literal list or `${(z)VAR}`. (Bit me once during the sync.)
- The `grill-me` lineage: user's old copy = Matt's pre-split monolith. Matt has since split into `grilling` (engine) + `grill-me` (wrapper) + `grill-with-docs`. We adopted that structure and kept our edge-case/tradeoff addition in the engine.
- Did NOT put the AskUserQuestion-box rule into `grilling` on purpose — it's Claude-specific and `grilling` may sync to non-Claude runtimes. The BeSeen memory `feedback_grill_me_question_box` already enforces it for Claude.

## Other Notes (separate, unrelated thread — already DONE)

Earlier this session, three BeSeen UI changes were completed + user-verified (uncommitted in `~/Projects/BeSeen`): (1) `SensationChip` pure-tag restyle, (2) `PromptAnswerScreen` strip-down, (3) check-in header collapse rebuilt as a **scroll-linked scrub + static paddingTop** (snappy threshold-commit was the bug; large-title cross-dissolve was a failed detour — see memory `feedback_ui_motion_research_first`). These are finished; not part of the skills work.
