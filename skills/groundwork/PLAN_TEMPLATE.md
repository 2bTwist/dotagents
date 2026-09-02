# Groundwork plan template

Copy this structure verbatim into `specs/plans/YYYY-MM-DD-groundwork-<slug>.md`. Fill each section with concrete content from steps 1-4 of [SKILL.md](SKILL.md).

---

# Groundwork: <task class> — <YYYY-MM-DD>

## Problem frame

- **Desired outcome and success condition:** <observable result>
- **Evidence and current failure:** <what is known, with repo paths or user evidence where available>
- **Working classes:** <primary and secondary classes, each marked established, hybrid, uncertain, or potentially novel>
- **Problem shape:** <diagnosis, optimization, coordination, transformation, etc.>
- **Constraints and invariants:** <what cannot be traded away>
- **Open uncertainties:** <facts that remain provisional>
- **Research lanes:** <disciplines and technique families to investigate without choosing a solution yet>

## Current state (5 bullets max)
Concrete facts about the current repo. No analysis.

## Solutions surveyed
For each of 2-3 reputable solutions (libraries, services, or reference repos):
- **<Name>** (URL) — why it qualifies.
  - For libraries / services: API surface (1-2 lines), license, integration cost.
  - For reference repos:
    - Convention 1 — <repo>/<file>:<line range> — 1-line description.
    - Convention 2 — <repo>/<file>:<line range> — 1-line description.

**Convergence note:** which library OR conventions recur across multiple sources. If fewer than 2 reputable solutions were found, state the search queries used and call out the absence.

**Build vs adopt.** If a maintained library satisfies the working frame's success criteria and constraints across every material research lane, the plan adopts it and the cleanup phases integrate it. If the plan recommends building from scratch, this section names the off-the-shelf candidates considered and the explicit reason none fit (license, scale, dependency surface, performance, control over data, team capacity, etc.).

## Skills available to install
Existing agent skills that match the working problem frame, found in step 2a. Skip this section if no skills matched.

- **<skill name>** (`<repo>/<path>`) — SKILL.md description, 1-2 lines. Install via `npx skills@latest add <repo>/<path>` or copy SKILL.md (and any supporting files) into this harness's skills directory.

## Canonical guidance consulted
For each of 2-4 sources (combine 2a skills + 2b search results + 2c papers if applicable):
- **<Author / vendor / paper>** (URL) — the load-bearing principle or claim, 1-2 lines. For papers, include `(<authors>, <year>)` and the citation count or survey-confirmation status if known.

## What's good (do not change)
3-7 file paths in this repo that already match good practice (cross-checked against reference repos and canonical guidance). One sentence per file.

## Cleanup phases

### Phase 1: <action verb leading title>

**Why.** Deviation from good practice. Cite both: (a) an author principle, vendor doc, or paper, and (b) a step-3 source — either a reference-repo file path showing the production pattern, OR a maintained library/service that addresses this task.

**Reference pattern.** Either:
- `<repo>/<file>:<line>` — quote the relevant snippet (5-15 lines), OR
- `<package@version>` (URL) — the API surface that addresses this task (1-3 lines), license, and why this library over alternatives.

**Files affected.**
- /full/path/to/file1.ext
- /full/path/to/file2.ext

**Steps.**
1. Concrete action with code snippet or diff if it reduces ambiguity. Where applicable, the snippet matches the reference-repo pattern shape, adapted to this repo's conventions.
2. Next concrete action.
3. ...

**Verification.**
- [ ] Automated check (test runs, typecheck, grep returns 0, etc.).
- [ ] Manual check if needed.

**Effort.** Low / Medium / High, with one-line reason.

**Trigger.** Now / After X / Before Y / When Z.

### Phase 2: ...

## Out of scope
Things a reader might expect but that are not in this plan, with one-line reasons.

## Hand-off
Stress-test this plan's tradeoffs before building (the `grill-me` skill if installed).
Then `/implement specs/plans/YYYY-MM-DD-groundwork-<slug>.md` to execute Phase 1.
