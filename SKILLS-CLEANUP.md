# Skills / commands cleanup

Trim and unify the personal workflow skills against Matt Pocock's `writing-great-skills`
rubric (sprawl / sediment / no-op / duplication / progressive disclosure). Keep intent,
cut bloat, remove redundant pieces.

## Locked decisions

1. **Unify on skills.** Convert the command-based entry points to skills. Retire `~/.claude/commands/`.
   - **Orchestrators** (plan, research, implement, compact, oneshot, groundwork, first-principles) →
     **user-invoked** (`disable-model-invocation: true`), zero context load.
   - **Engines** (tdd, diagnosing-bugs, domain-modeling, codebase-design, a grilling engine) →
     **model-invoked**, so orchestrators + the model can reach them.
2. **Source of truth = live, then push.** Edit `~/.claude/skills/`, verify, then copy into this
   `dotclaude` repo (and `.agents`/`.pi` where the skill is shared) and commit. Reconcile drift in
   favor of live.

## Live inventory (2026-06-17)

Commands (to convert → skill, then trim): plan **358**, research 173, compact 95, implement 89,
oneshot 68, first-principles 61, autoresearch 49.
Skills already: groundwork 95, first-principles 115 (DUP with the command), grill-me 12, tdd 109,
teach 131, animation-vocabulary 144, keyword-ranks 162, sqlalchemy-alembic-expert 64.
Dead: `~/plugins/edmond-workflows` (inactive — empty installed_plugins.json, not in settings).

## Per-file rubric pass

For each: cut **no-ops** (lines the model already obeys) sentence-by-sentence; collapse
**duplication** to a single source; push **reference** into sibling files (progressive disclosure)
to kill **sprawl**; prefer **leading words** over restated phrases; verify intent preserved.

## Phased plan

- **Phase 0 — quick wins.** Delete the dead `edmond-workflows` plugin. Resolve `first-principles`
  duplication (keep one — skill, since we're unifying; fold any unique content from the command in).
- **Phase 1 — engines in.** Cherry-pick Matt's skills (chosen): `prototype`, `grill-with-docs` +
  `domain-modeling`, `diagnosing-bugs`, `codebase-design` (+ `improve-codebase-architecture`).
  Add a `grilling` engine + keep `writing-great-skills` as the reference rubric.
- **Phase 2 — orchestrators.** Convert + trim plan → research → implement → compact → oneshot →
  groundwork into lean user-invoked skills that reach the engines; disclose detail into sibling files.
- **Phase 3 — sync.** Copy cleaned skills into dotclaude (+ .agents/.pi); user commits.

Each file: show before/after diagnosis for sign-off before writing.

## Status (2026-06-17)

Scope narrowed (user): **only the skills the user created** (the workflow set) — NOT Matt's installed engines, NOT imported/domain skills (aso-audit, keyword-ranks, animation-vocabulary, teach, tdd, sqlalchemy, codebase-*).

Done (live `~/.claude/skills/`, command retired):
- `plan` 358 → 44 + PLAN-TEMPLATE 99. Delegates to `/grilling`.
- `research` 173 → 41 + RESEARCH-TEMPLATE 57. "documentarian" leading word, dedup ~5 restatements.
- `implement` 89 → 40. `compact` 95 → 30 + HANDOFF-TEMPLATE 54. `oneshot` 68 → 30.
- `first-principles` 116 → 65 + FORMAT 58 (template disclosed); command already deleted, opus pinned.
- `grilling` engine + `grill-me` thin wrapper; our edge-case/tradeoff line folded into grilling.
- Installed Matt engines: diagnosing-bugs, prototype, domain-modeling, grill-with-docs, codebase-design, improve-codebase-architecture, writing-great-skills. Deps self-contained.

Left as-is: `groundwork` (already compliant — uses disclosure, no no-ops).

RESOLVED (2026-06-17, session 2):
- **`autoresearch` — left as-is (out of scope).** On inspection it's an imported/vendored skill, not user-authored: `~/.claude/skills/autoresearch` symlinks into `~/autoresearch-claude-code/` (a clone of upstream `drivelineresearch/autoresearch-claude-code`), and the dotclaude copy is `domain-skills/claude/autoresearch/`, vendored verbatim + diff-able + cp-updated. The autonomous loop is sustained by the `UserPromptSubmit` hook, not model-invocation. Locked decision #3 excludes imported skills, so the "fold routing / clean it" action item was dropped. (An exploratory edit to the clone was made then fully reverted; clone is pristine, command symlink restored.)
- **Orchestrator invocation reversed (user request).** Hitting the `Skill(plan)` "UI command, not a skill" error showed the `disable-model-invocation: true` guard was blocking model-initiated launches the user actually wants. Removed the flag from **plan, research, compact, oneshot, first-principles** (now model-invocable) in both `~/.claude` and dotclaude. **implement** stays user-invoked. **groundwork** was already model-invocable (TRIGGER/SKIP description, no flag). Caveat logged: the four bare-description skills may auto-fire; tune descriptions (not restore flag) if so.
- **Scope of "yours":** edmond-workflows = leave untouched (untracked, inert in Claude). tdd/teach = imported (Matt's), left alone. aso-audit + keyword-ranks = user's, given the rubric pass.
- **keyword-ranks:** 162 → 91 lines; Python template disclosed to sibling `keyword-ranks.py`; Origin tightened. Synced to `domain-skills/claude/keyword-ranks/`.
- **aso-audit:** cleaned LOCAL ONLY (179 → 175): killed 5 dead sibling-skill refs + Appeeky sediment + expert preamble; framework kept inline. **Not pushed to dotclaude** (user: project-specific + hacky, stays local). dotclaude copies (claude+pi, 179l) are now intentionally stale.
- **.agents/.pi propagation:** deferred (user: dotclaude only for now).

RESOLVED (2026-06-22, session 3):
- **ASO + keyword-ranks scoped to the BeSeen project.** `aso-audit`, `aso-and-apple-ads`, and `keyword-ranks` are app-specific; they now live in `~/Projects/BeSeen/.claude/skills/` (local/gitignored per BeSeen convention) and were deleted from all global dirs (`~/.claude`, `~/.agents`, `~/.pi/agent`). Removed the stale `domain-skills/claude/{aso-audit,keyword-ranks}` and `domain-skills/pi/aso-audit` copies from this repo so `install.sh --with-domain-skills` can't re-add them globally. (aso-and-apple-ads was never tracked here.)
- **De-bloated the Pi system prompt.** Pi auto-loads `~/.pi/agent/skills` + `~/.agents/skills`. Moved the BeSeen Expo/RN skills (deploy, submit, migrate, building-native-ui, react-native-best-practices) out of `~/.agents/skills` (they already live in BeSeen), and emptied `~/.agents/skills` of the project-agnostic workflow set (kept in `~/.claude/skills` + this repo). Pi system prompt: ~5074 → ~1841 tokens, 18 → 4 skills.

STILL OPEN:
1. **User commits the dotclaude working tree** (locked decision #2; NO Claude co-author trailer).
