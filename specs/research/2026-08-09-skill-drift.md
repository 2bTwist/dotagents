---
date: 2026-08-09
topic: "Three-way drift report: REPO vs CLAUDE vs CODEX copies of 11 workflow skills"
tags: [research, codebase, skills, drift]
status: complete
last_updated: 2026-08-09
---

# Skill drift report: REPO vs CLAUDE vs CODEX

**Scope**: `plan`, `research`, `implement`, `compact`, `oneshot`, `groundwork`, `first-principles`, `rigor`, `perf-loop`, `perf-harness-init`, `agent-latency-audit`.

**Locations**:
- REPO: `/Users/edmond/Projects/dotagents/skills/<name>/`
- CLAUDE: `/Users/edmond/.claude/skills/<name>/`
- CODEX: `/Users/edmond/.codex/skills/<name>/`

No symlinks were found inside any of these 11 skill directories in any location (checked with `ls -la` and `find -type l`; the one symlink under `~/.claude/skills/` — `autoresearch`— belongs to a different skill, not in scope).

**Structural fact that applies to every skill present in all three locations**: CODEX packages skills for the Codex CLI harness, not the Claude Code harness. Every CODEX `SKILL.md` frontmatter drops the `model:` and `disable-model-invocation:` keys entirely (present in REPO/CLAUDE for `plan`, `research`, `groundwork`, `first-principles`, `rigor`, `implement`), flattens multi-line YAML `description: |` blocks into a single quoted string, and every CODEX skill directory adds `agents/openai.yaml` (a 4-7 line Codex agent-routing manifest, present in every CODEX skill, absent from REPO/CLAUDE). CODEX also renames sibling template/reference files from flat `UPPERCASE.md` (REPO/CLAUDE convention) to `references/lowercase.md` (CODEX convention), and large binary/config trees from `templates/` (REPO/CLAUDE) to `assets/templates/` (CODEX). Body prose in CODEX is mechanically transformed in most files: em dashes (`—`) become colons (`:`), and slash-command references (`/plan`, `/grill-me`, `/implement`, etc.) become `$`-prefixed (`$plan`, `$grill-me`, `$implement`). Tool names are also generalized from Claude-Code-specific names (Grep/Glob/LS, Task tool, `TaskCreate`) to platform-neutral ones (`rg`, "bounded read-only subagents", `update_plan`). These mechanical patterns are noted once here rather than repeated in every per-skill section; per-skill sections call out content that goes beyond this mechanical layer.

None of the mechanical-only differences were classified as SUPERSET, because the original wording is replaced (not appended to) — see the per-file verdicts below for what's a clean superset vs a policy-level conflict.

## Summary table

| skill | in REPO | in CLAUDE | in CODEX | files differing | superset or conflict | needs a human ruling? |
|---|---|---|---|---|---|---|
| plan | yes | yes | yes | SKILL.md, PLAN-TEMPLATE.md (both only REPO vs CODEX; REPO=CLAUDE identical) | REPO=CLAUDE identical; vs CODEX: CONFLICT (rewritten for Codex tool surface) | Yes (CODEX pair only) |
| research | yes | yes | yes | SKILL.md, RESEARCH-TEMPLATE.md, WEB-RESEARCH.md (CLAUDE/CODEX only; missing from REPO) | REPO→CLAUDE: SUPERSET (pure append). CLAUDE vs CODEX: CONFLICT (independent rewrite) | Yes (CLAUDE vs CODEX pair) |
| implement | yes | yes | yes | SKILL.md | REPO=CLAUDE identical; vs CODEX: CONFLICT | Yes (CODEX pair only) |
| compact | yes | yes | yes | SKILL.md, HANDOFF-TEMPLATE.md | REPO=CLAUDE identical; vs CODEX: CONFLICT | Yes (CODEX pair only) |
| oneshot | yes | yes | yes | SKILL.md | REPO=CLAUDE identical; vs CODEX: CONFLICT (rule #1 rewording changes the escalation policy) | Yes (CODEX pair only) |
| groundwork | yes | yes | yes | SKILL.md, REFERENCE.md, PLAN_TEMPLATE.md | REPO→CLAUDE: SUPERSET (REFERENCE.md, pure add) + one in-place rewording (SKILL.md 2a line). vs CODEX: CONFLICT (2a/2b protocol replaced wholesale) | Yes (CLAUDE SKILL.md line is minor; CODEX pair is a real ruling) |
| first-principles | yes | yes | yes | SKILL.md, CANON.md, FORMAT.md | REPO=CLAUDE identical; vs CODEX: CONFLICT (mostly mechanical, some subagent-count wording changes) | Mostly cosmetic; low priority |
| rigor | yes | yes | yes | SKILL.md, FRAMEWORKS.md (touched, not changed) | REPO=CLAUDE identical (FRAMEWORKS.md mtime differs, content is byte-identical). vs CODEX: CONFLICT (adversary-agent mechanism reworded: "forked Task sub-agent" → "fresh-context collaboration subagent", independence caveat added) | Yes (CODEX pair) |
| perf-loop | yes | yes | yes | SKILL.md | REPO=CLAUDE identical; vs CODEX: CONFLICT (tooling swapped: `mcp__MCP_DOCKER__browser_*` + Agent tool → "in-app-browser control skill" + "fresh-context collaboration subagent"; git-safety rule rewritten) | Yes (CODEX pair) |
| perf-harness-init | yes | yes | yes | SKILL.md + 7 of 18 template files | REPO=CLAUDE byte-identical (`diff -rq` empty) across all 19 files. vs CODEX: CONFLICT, including a real metric rename (`inp.ts`/`readInp`/`perf-results/inp.json` → `interaction.ts`/`readInteraction`/`perf-results/interaction.json`, plus a staleness check CODEX added that REPO/CLAUDE lack) and a CI permissions diff (`pull-requests: write` present in REPO/CLAUDE workflow, absent in CODEX) | Yes (CODEX pair — behavioral, not just prose) |
| agent-latency-audit | yes | **no** | **no** | n/a | n/a (single copy) | No — nothing to merge, confirmed REPO-only as expected |

## plan

**Presence**: REPO yes, CLAUDE yes, CODEX yes. No symlinks.

**File inventory**:
- REPO: `PLAN-TEMPLATE.md` (99 lines), `SKILL.md` (43 lines)
- CLAUDE: `PLAN-TEMPLATE.md` (99 lines), `SKILL.md` (43 lines)
- CODEX: `agents/openai.yaml` (4 lines, CODEX-only), `references/plan-template.md` (99 lines, renamed), `SKILL.md` (45 lines)

**Content diff**:
- `SKILL.md` REPO vs CLAUDE: **byte-identical** (`diff -q` empty).
- `SKILL.md` REPO/CLAUDE (43 lines) vs CODEX (45 lines): CONFLICT-class rewrite. Frontmatter drops `model: opus`; description is flattened to one quoted line. Body changes beyond the mechanical layer:
  ```
  -Then enumerate the installed skills and match each phase's task class to one (`ls ~/.claude/skills .claude/skills .agents/skills`). A locally-installed skill is pre-vetted for this stack — name it in the plan's References and in the relevant phase so `/implement` reuses it instead of reinventing the approach.
  +Then use the injected skill catalog and, when needed, inspect `~/.codex/skills` and `.agents/skills`. Match each phase's task class to the smallest applicable skill set. Name those skills in the plan's References and relevant phases so `$implement` reuses them.
  +
  +Mirror the durable phases into `update_plan` while working. The plan file remains the decision record; the live plan communicates progress.
  ```
  (7 lines quoted of an 11-line hunk; cut 4 lines of surrounding context.) CODEX also adds a whole `update_plan` (Codex-native live-progress) mechanism that has no REPO/CLAUDE counterpart.
- `PLAN-TEMPLATE.md` REPO vs CLAUDE: byte-identical.
- `PLAN-TEMPLATE.md` (99 lines) vs `references/plan-template.md` (99 lines, CODEX): same line count but content differs — one substantive change (manual-verification phrasing rewritten from "pause for manual confirmation before the next phase" to "record any genuine human/device acceptance check... continue with independent safe phases unless that check blocks them" — a real change in default pausing behavior), plus mechanical em-dash/`$`-command swaps elsewhere.

**Frontmatter**: REPO/CLAUDE: `name`, `description` (plain scalar), `model: opus`. CODEX: `name`, `description` (quoted string, JSON-escaped `→`), no `model` key.

**Sibling links**: REPO/CLAUDE link `](PLAN-TEMPLATE.md)`, resolves. CODEX links `](references/plan-template.md)`, resolves. Both conventions self-consistent.

**Private data scan**: no hits.

## research

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory** — this is the skill with the biggest REPO-vs-CLAUDE gap:
- REPO: `RESEARCH-TEMPLATE.md` (57 lines), `SKILL.md` (40 lines). **No `WEB-RESEARCH.md`.**
- CLAUDE: `RESEARCH-TEMPLATE.md` (88 lines), `SKILL.md` (47 lines), `WEB-RESEARCH.md` (69 lines, **missing from REPO entirely**)
- CODEX: `agents/openai.yaml` (4), `references/research-template.md` (101), `references/web-research.md` (90), `SKILL.md` (48)

**Content diff**:
- `SKILL.md` REPO (40) vs CLAUDE (47): **SUPERSET**. CLAUDE's diff is a pure insertion — a new "Two branches" routing section plus a `## Codebase branch` heading is inserted after the frontmatter; the rest of the file (everything from "Map how an area of the codebase works **today**..." onward) is byte-identical, confirmed by diffing REPO against the tail of CLAUDE. Added block (7 of 7 lines shown, nothing cut):
  ```
  +Two branches, routed by the question:
  +
  +- **Codebase**: the question is about this repo or code the user owns. Follow the steps below.
  +- **External/web**: the question is about the outside world (a library's state, a claim, a market, how something works off-repo). Load and follow [`WEB-RESEARCH.md`](WEB-RESEARCH.md) instead of the steps below. Mixed questions: run the codebase steps for the repo half, the web branch for the external half, synthesize in one doc.
  +
  +## Codebase branch
  +
  ```
  Frontmatter description also differs by wording only ("Map how an area of the codebase works TODAY" → "Map how an area works TODAY (codebase or external/web)").
- `RESEARCH-TEMPLATE.md` REPO (57) vs CLAUDE (88): **SUPERSET**, confirmed pure append — first 57 lines identical byte-for-byte, CLAUDE appends a 34-line "## Web variant (external research)" section with its own frontmatter/structure template. Not quoted here (see file for full text; it is the block feeding `WEB-RESEARCH.md`'s output format).
- `WEB-RESEARCH.md`: exists only in CLAUDE and CODEX, **absent from REPO**. This is the most important gap in this skill: REPO's `research/SKILL.md` doesn't even reference an external/web branch, so REPO is missing an entire capability CLAUDE has (and that CLAUDE's `SKILL.md` links to as `](WEB-RESEARCH.md)`).
- CLAUDE `WEB-RESEARCH.md` (69 lines) vs CODEX `references/web-research.md` (90 lines): **CONFLICT** — this is not a superset in either direction. Both are independent rewrites of the same web-research protocol with materially different structure and content: CLAUDE numbers stages "1. Decompose and set the bar" ... "7. Write the doc" with a 10-row question-trap table and cites a specific internal rigor doc (`specs/rigor/2026-07-19-how-ai-agents-research-quality.md`) as design rationale; CODEX's version is renumbered, drops that internal citation, and **adds an 11th trap-table row CLAUDE does not have** ("Product or market gap"). Sample of the diverging table (5 of 11 rows shown, 6 cut):
  ```
  CLAUDE:
  | How to do X | Vendors selling X outrank practitioners who did X | Practitioner-stratum queries (above) |
  | Best tool/library | Affiliate listicles; heaviest SEO pollution of any class | Issue trackers, changelogs, "switched from X to Y" posts, maintainer activity |
  CODEX:
  | How to do X | Vendors selling X outrank practitioners who did it | Search first-party build reports, postmortems, engineering blogs... |
  | Product or market gap | Vendor feature pages encourage feature-list comparison... | Compare the job, durable atom, capture decision, lifecycle... |
  ```
  CODEX also changes the model directives for sub-agents (CLAUDE pins `model: sonnet` for mapping agents and `model: haiku` for the cite-checker explicitly; CODEX's rewrite has no model pinning at all — it just says "read-only mapping subagents" / "a fresh verification subagent").
- `RESEARCH-TEMPLATE.md`/`research-template.md` CLAUDE (88) vs CODEX (101): **CONFLICT** — same "web variant" concept, different frontmatter fields (CODEX's web variant adds `supersedes: <optional prior artifact>`, a field CLAUDE's template doesn't have), different section set (CODEX's web variant adds a `## Counterevidence and Alternatives` section CLAUDE's lacks, and a `Interest` column in the sources table CLAUDE's lacks).

**Frontmatter**: REPO/CLAUDE: `model: opus`. CODEX: no `model` key; description text also reworded to explicitly enumerate use cases ("market or product research, current library or platform research, claim verification...").

**Sibling links**: REPO links only `](RESEARCH-TEMPLATE.md)` (no web-research link, consistent with REPO lacking that file). CLAUDE links `](WEB-RESEARCH.md)` and `](RESEARCH-TEMPLATE.md)`, both resolve. CODEX links `](references/web-research.md)` and `](references/research-template.md)`, both resolve.

**Private data scan**: no hits.

## implement

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory**: REPO `SKILL.md` (40 lines); CLAUDE `SKILL.md` (40 lines); CODEX `agents/openai.yaml` (7 lines, CODEX-only), `SKILL.md` (40 lines).

**Content diff**:
- REPO vs CLAUDE: byte-identical.
- REPO/CLAUDE vs CODEX: same line count (40) but CONFLICT-class differences beyond the mechanical layer. Frontmatter loses `disable-model-invocation: true`. Body changes:
  ```
  -- Build a `TaskCreate` todo list from the phases.
  -- If the plan already has checkmarks, trust the completed work and resume from the first unchecked item.
  +- Mirror the phases into `update_plan` so live progress is visible.
  +- Treat existing checkmarks as claims to verify against the current tree and relevant evidence before resuming from the first incomplete item.
  ```
  (all 4 changed lines shown, nothing cut) — this changes behavior: REPO/CLAUDE trusts existing checkmarks outright; CODEX requires re-verifying them against the tree before resuming. Also the "pause for manual verification" step is rewritten from a hard pause ("Don't check off manual items until the user confirms. If told to run phases consecutively, pause only after the last.") to a conditional one ("Continue with independent safe work when the manual check does not block it.") — another behavioral, not cosmetic, change.

**Frontmatter**: REPO/CLAUDE: `disable-model-invocation: true`. CODEX: that key is absent (dropped along with `model:` everywhere else).

**Sibling links**: none in any copy.

**Private data scan**: no hits.

## compact

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory**: REPO `HANDOFF-TEMPLATE.md` (54), `SKILL.md` (29). CLAUDE: same, same line counts. CODEX: `agents/openai.yaml` (4), `references/handoff-template.md` (54, renamed), `SKILL.md` (30).

**Content diff**:
- REPO vs CLAUDE: both files byte-identical.
- `SKILL.md` REPO/CLAUDE (29) vs CODEX (30): CONFLICT. Description is rewritten with different intent framing — REPO/CLAUDE: "Mid-session intentional compaction — write current state to a handoff file so work resumes in a fresh session with zero loss." CODEX: "Write a durable handoff file when the user asks to compact, hand off, pause, or preserve the state of ongoing work for another Codex task or future session." CODEX body adds an explanatory line REPO/CLAUDE lacks: "Codex already compacts active context automatically, so this skill is for durable cross-task state, not internal context management." — a genuine content addition explaining a Codex-specific runtime behavior that doesn't apply to Claude Code.
- `HANDOFF-TEMPLATE.md`/`references/handoff-template.md`: single one-line mechanical diff only (em dash → colon in "Learnings" section); otherwise identical.

**Frontmatter**: REPO/CLAUDE and CODEX both have only `name`/`description` (no `model` key in any copy for this skill — nothing to drop here).

**Sibling links**: REPO/CLAUDE `](HANDOFF-TEMPLATE.md)` resolves; CODEX `](references/handoff-template.md)` resolves (link text form: `[references/handoff-template.md](references/handoff-template.md)`).

**Private data scan**: no hits.

## oneshot

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory**: REPO `SKILL.md` (29); CLAUDE `SKILL.md` (29); CODEX `agents/openai.yaml` (4), `SKILL.md` (30).

**Content diff**:
- REPO vs CLAUDE: byte-identical.
- REPO/CLAUDE vs CODEX: CONFLICT, and this one has a real policy change worth flagging even though it's a single skill file. The "No scope creep" guardrail is not a mechanical reword — the trigger condition itself changed:
  ```
  -- **No scope creep** — editing a third file means escalate.
  +- **No scope creep** : escalate when the change crosses concerns, introduces a new decision, or requires broad verification. File count alone is not the boundary.
  ```
  REPO/CLAUDE's rule is a hard, countable trigger ("a third file"); CODEX's rule explicitly rejects that in favor of a judgment call ("File count alone is not the boundary"). Also "Locate" step: REPO/CLAUDE says "Grep/Glob/LS to the exact file(s)"; CODEX says "Use `rg` and `rg --files`" — a tool-availability difference, not just naming (Codex CLI doesn't have Claude Code's Grep/Glob/LS tools).

**Frontmatter**: no `model` key anywhere for this skill.

**Sibling links**: none in any copy.

**Private data scan**: no hits.

## groundwork

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory**: REPO `PLAN_TEMPLATE.md` (70), `REFERENCE.md` (97), `SKILL.md` (95). CLAUDE: `PLAN_TEMPLATE.md` (70), `REFERENCE.md` (**108**), `SKILL.md` (95, same count but differs). CODEX: `agents/openai.yaml` (4), `references/plan-template.md` (70, renamed), `references/reference.md` (66, renamed **and shorter**), `SKILL.md` (91).

**Content diff**:
- `PLAN_TEMPLATE.md` REPO vs CLAUDE: byte-identical.
- `SKILL.md` REPO (95) vs CLAUDE (95): differs despite equal line count. **Not a clean superset** — this is a 1-line-for-1-line rewrite of step 2a, not an append:
  ```
  -**2a — Skill collections.** Reuse the step 1 list. Fetch matching SKILL.md files raw. Capture: name, URL, load-bearing principles (verbatim quotes). Vetting criteria: see [REFERENCE.md](REFERENCE.md#skill-vetting).
  +**2a — Skill collections. Locally installed skills FIRST.** Before any web crawl, enumerate the skills already installed on this machine/repo and match by description — a locally-installed skill is pre-vetted for this stack and costs no network. Then reuse the step 1 list for web-published skills. Enumeration + matching: see [REFERENCE.md](REFERENCE.md#skill-crawl-protocol). For each match (local or remote), fetch/read the SKILL.md and capture: name, path/URL, load-bearing principles (verbatim quotes). Vetting criteria: see [REFERENCE.md](REFERENCE.md#skill-vetting). When the plan cites a locally-installed skill, name it so `/implement` knows to invoke it.
  ```
  CLAUDE's version is semantically a strict *elaboration* of REPO's — it adds a "check locally installed skills first" behavior and nothing REPO said is contradicted or lost — but because REPO's original sentence was deleted and replaced rather than appended after, `diff` shows it as 1 line removed / 1 line added, not a pure insertion. Flagging as SUPERSET-in-spirit but NOT a mechanical/pure-append diff; worth a human glance even though the direction of change (CLAUDE ⊇ REPO in meaning) looks unambiguous.
- `REFERENCE.md` REPO (97) vs CLAUDE (108): **SUPERSET**, confirmed pure addition (`diff` shows exactly 1 removed line — the file-header line count artifact — vs many added; body addition is an 11-line new paragraph + bash snippet under the existing "Skill-crawl protocol" heading, about checking `~/.claude/skills .claude/skills .agents/skills` locally before crawling GitHub). This addition is what step 2a's rewrite (above) points to.
- `SKILL.md`/`REFERENCE.md`/`PLAN_TEMPLATE.md` REPO/CLAUDE vs CODEX: **CONFLICT**, and the deepest one in this report. CODEX's step 2a/2b is not an elaboration of REPO/CLAUDE's — it's a different protocol entirely, reflecting a different local-skill-discovery mechanism (Codex's injected skill catalog vs Claude Code's `~/.claude/skills` + skills.sh/GitHub-org crawl). CODEX's `references/reference.md` (66 lines) is **shorter** than REPO's `REFERENCE.md` (97 lines) despite covering the same headings — it deletes REPO's entire GitHub-org / skills.sh aggregator crawl protocol (`gh api repos/mattpocock/skills/contents`, `npx skills@latest find`, links to `awesome-claude-code` etc., ~35 lines) and replaces it with a "read the Codex-injected catalog, don't crawl the web for skills" protocol. Sample (8 of ~35 removed lines shown, 27 cut):
  ```
  -gh api repos/mattpocock/skills/contents             | jq -r '.[] | select(.type=="dir") | .name'
  -gh api repos/humanlayer/skills/contents/plugins     | jq -r '.[] | select(.type=="dir") | .name'
  -gh api repos/anthropics/skills/contents/skills      | jq -r '.[] | select(.type=="dir") | .name'
  -Then query the **skills.sh aggregator** (covers more publishers than the three GitHub orgs above):
  -npx --yes skills@latest find "<task class keyword>"
  +Start with the skill catalog injected into the current Codex task. If a relevant skill is listed, read its `SKILL.md` completely before using it.
  +Do not download, execute, or install third-party skills during Groundwork.
  ```
  This is a platform capability difference (Codex CLI injects a skill catalog; Claude Code does not), not a wording preference — a merge cannot mechanically pick "the newer one" here without breaking one platform's workflow.

**Frontmatter**: REPO/CLAUDE: `model: opus`, multi-line YAML `description: |` block with embedded TRIGGER/SKIP guidance. CODEX: no `model` key, description flattened to one quoted string (TRIGGER/SKIP text preserved but on one line, `/grill-me`→`$grill-me` etc.).

**Sibling links**: REPO/CLAUDE: 4 anchored links into `REFERENCE.md` (`#skill-crawl-protocol`, `#skill-vetting`, `#academic-search`, `#solution-vetting`) plus `PLAN_TEMPLATE.md` — all resolve (anchors are headings in the target file; not independently verified as exact-match anchors beyond file existence, since GitHub-flavored anchor resolution isn't filesystem-checkable, but the heading text was confirmed present via `grep`). CODEX: 5 anchored links into `references/reference.md` (`#local-skill-matching`, `#academic-search`, `#packaged-solution-vetting`, `#reference-repository-vetting`) plus `references/plan-template.md` — all resolve; note CODEX's anchor set doesn't match REPO/CLAUDE's (`#skill-vetting`/`#solution-vetting` don't exist in CODEX's version; it split "Solution vetting" into two separate headings/anchors).

**Private data scan**: no hits.

## first-principles

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory**: REPO `CANON.md` (53), `FORMAT.md` (58), `SKILL.md` (64). CLAUDE: identical set/counts. CODEX: `agents/openai.yaml` (4), `references/canon.md` (53, renamed), `references/format.md` (58, renamed), `SKILL.md` (66).

**Content diff**:
- REPO vs CLAUDE: all three files byte-identical.
- REPO/CLAUDE vs CODEX: CONFLICT class but mostly mechanical here, with two content-bearing exceptions worth noting:
  1. Sub-agent dispatch: REPO/CLAUDE says "Spawn three sub-agents via the Task tool, all at once"; CODEX says "When parallelism materially improves the result, spawn up to three bounded subagents, leaving a slot for the main agent and adapting to the available concurrency" — CODEX makes parallel dispatch conditional/adaptive rather than REPO/CLAUDE's unconditional "all at once."
  2. CODEX adds an explicit independence caveat REPO/CLAUDE lacks: "Verify every load-bearing subagent claim against the cited source before using it. Same-model agents improve context separation but do not create independent evidence." — a new sentence, not present in REPO/CLAUDE at all.
- `CANON.md`/`references/canon.md` and `FORMAT.md`/`references/format.md`: mechanical only (em dash → colon, `/first-principles`→`$first-principles`, title line reworded "# CANON.md" → "# First-principles anchors"). No policy content changed.

**Frontmatter**: REPO/CLAUDE: `model: opus`. CODEX: no `model` key.

**Sibling links**: REPO/CLAUDE: `](FORMAT.md)` resolves (note: `CANON.md` is referenced only from within `FORMAT.md`'s body text as a bare mention "Reference an analog from CANON.md," not as a markdown link — so it wasn't picked up by the link grep, but it does exist on disk). CODEX: `](references/canon.md)` and `](references/format.md)` resolve; FORMAT.md's CODEX counterpart converts the CANON.md prose-mention into an actual markdown link `[canon.md](canon.md)` inside `references/format.md` — that link is relative to the `references/` directory and resolves correctly since `canon.md` is a sibling of `format.md` there.

**Private data scan**: no hits.

## rigor

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory**: REPO `FRAMEWORKS.md` (38), `RIGOR-TEMPLATE.md` (50), `SKILL.md` (70). CLAUDE: same counts (FRAMEWORKS.md has a **newer mtime**, 2026-08-09, vs REPO's 2026-06-21 — flagged because it looked like a recent edit, but confirmed **byte-identical content**, so it's a touch/rewrite-with-no-diff, not drift). CODEX: `agents/openai.yaml` (7), `references/frameworks.md` (38, renamed), `references/rigor-template.md` (50, renamed), `SKILL.md` (69).

**Content diff**:
- REPO vs CLAUDE: all three files byte-identical (confirmed via `diff -q`, despite FRAMEWORKS.md's differing mtime).
- `RIGOR-TEMPLATE.md` vs `references/rigor-template.md` (CODEX): **byte-identical body content** — the only difference between REPO and CODEX for this file is the path/rename, confirmed by an empty `diff -u` output. This is the cleanest file in the whole report.
- `FRAMEWORKS.md` vs `references/frameworks.md` (CODEX): one-line mechanical diff only (`/rigor` → `$rigor`), otherwise identical.
- `SKILL.md` REPO/CLAUDE (70) vs CODEX (69): CONFLICT, with one substantive mechanism change beyond the mechanical layer — how the adversarial reviewer is invoked:
  ```
  -3. **The adversary is not optional and not you.** It runs in a forked Task sub-agent prompted to refute, your own "it holds up" is author bias, weak evidence.
  +3. **The adversary is not optional and not you.** Run it in a fresh-context collaboration subagent prompted to refute. This reduces confirmation bias but does not create true independence because it may use the same model; ground its challenges in raw artifacts and external specifications.
  ```
  CODEX explicitly downgrades the strength claim ("reduces... but does not create true independence") that REPO/CLAUDE doesn't make, and drops the Claude-specific "forked Task sub-agent" mechanism name in favor of a generic "fresh-context collaboration subagent." The adversary prompt text itself is also reworded (not just retitled) in both copies — different sentences, same intent, quoted separately above in the diff read earlier; full prompt text differs enough that a byte-for-byte merge would need a human pick.

**Frontmatter**: REPO/CLAUDE: `disable-model-invocation: true`, `model: opus`. CODEX: neither key present.

**Sibling links**: REPO/CLAUDE: 3 links to `FRAMEWORKS.md` + 1 to `RIGOR-TEMPLATE.md`, all resolve. CODEX: 3 links to `references/frameworks.md` + 1 to `references/rigor-template.md`, all resolve.

**Private data scan**: no hits.

## perf-loop

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory**: REPO `SKILL.md` (54). CLAUDE `SKILL.md` (54). CODEX `agents/openai.yaml` (7), `SKILL.md` (54, same count, differs).

**Content diff**:
- REPO vs CLAUDE: byte-identical.
- REPO/CLAUDE vs CODEX: CONFLICT, and this is a tooling-availability conflict, not preference. The whole "Roles" and "Run + observe" sections swap Claude-Code-specific tool references for Codex-generic ones:
  ```
  -- **Adversarial verifier** (a SEPARATE sub-agent via the Agent tool): generates the flows and grades. The builder must not author the tests it's judged by. Prompt it to stress, not to confirm.
  +- **Adversarial verifier** (a fresh-context collaboration subagent): derives flows from the requirements and diff, then grades raw results. This separation reduces builder bias but is not independent evidence by itself.
  ```
  and
  ```
  -- Exploration / "weird stuff": drive the flows with `mcp__MCP_DOCKER__browser_*` (navigate/click/snapshot) and collect anomalies:
  +- Exploration / "weird stuff": use the in-app-browser control skill, or Chrome control when signed-in Chrome state is required, and collect anomalies:
  ```
  REPO/CLAUDE hardcodes the `mcp__MCP_DOCKER__browser_*` MCP tool; CODEX has no such MCP available and substitutes "an installed browser-control skill" generically. The "Diagnose → fix → re-verify" step also changes git-safety guidance: REPO/CLAUDE says "Commit on success; rollback on failure (gnhf pattern)"; CODEX says "Work on a dedicated branch or worktree... Restore only the scoped experimental diff on failure; never reset or clean the user's working tree" — a more conservative, more explicit git-safety rule not present in REPO/CLAUDE.

**Frontmatter**: no `model` key in any copy.

**Sibling links**: none in any copy.

**Private data scan**: no hits.

## perf-harness-init

**Presence**: REPO yes, CLAUDE yes, CODEX yes.

**File inventory**: REPO and CLAUDE both have `SKILL.md` (48) + 18 files under `templates/` (`.size-limit.js`, `budgets.json`, `e2e/invariants/a11y.spec.ts`, `e2e/invariants/smoke.spec.ts`, `e2e/perf.spec.ts`, `github-workflows/perf.yml`, `lighthouserc.js`, `PERF.md`, `perf/config.ts`, `perf/render-count.test.tsx`, `playwright.config.ts`, `tools/perf-check/cli.ts`, `tools/perf-check/engines/inp.ts`, `tools/perf-check/engines/lighthouse.ts`, `tools/perf-check/engines/size.ts`, `tools/perf-check/README.md`, `vitest.config.ts`, `vitest.setup.ts`) — **`diff -rq` between the two full directory trees returns nothing: all 19 files byte-identical.** CODEX: `agents/openai.yaml` (4), `SKILL.md` (63, larger), and 18 files under `assets/templates/` (same relative paths except `engines/inp.ts` is renamed `engines/interaction.ts`).

**Content diff** — this skill has the most consequential CODEX drift in the report because it touches shipped code, not just prose:
- REPO vs CLAUDE: fully identical, 19/19 files, confirmed by recursive `diff -rq`.
- `SKILL.md` REPO/CLAUDE (48) vs CODEX (63): CONFLICT, substantial rewrite of the setup steps — CODEX adds a concrete `package.json` scripts JSON block REPO/CLAUDE doesn't have, changes dependency list (`@axe-core/playwright`, `commander`, `start-server-and-test` added), and drops REPO/CLAUDE's Claude-specific step 5 ("create/merge `.claude/settings.json`... run `pnpm exec next telemetry disable`") in favor of "set env vars in package scripts and CI... Do not write Claude-specific settings." Also drops REPO/CLAUDE's unconditional "raise `react-hooks/exhaustive-deps` to error" in favor of "Preserve the repository's existing lint policy rather than globally ratcheting rules without a separate decision" — an explicit behavior downgrade (less aggressive by default).
- `engines/inp.ts` (REPO/CLAUDE, 14 lines) vs `engines/interaction.ts` (CODEX, 17 lines): **renamed file with a real functional change**, not just naming. REPO/CLAUDE's `readInp()` reads `perf-results/inp.json` unconditionally. CODEX's `readInteraction(maxAgeMs = 10 * 60_000)` reads `perf-results/interaction.json` **and adds a staleness check** (returns `null` if the recorded timestamp is more than 10 minutes old) that REPO/CLAUDE's version does not have. This is a behavior difference: a merge that silently takes REPO/CLAUDE's version loses stale-result protection; a merge that silently takes CODEX's version renames a metric key three call sites depend on (`cli.ts`, `budgets.json`'s `metrics.inp` → `metrics.interactionMs`, the `e2e/perf.spec.ts` writer).
- `e2e/perf.spec.ts` (53 → 54 lines): companion change to the above — REPO/CLAUDE clicks up to 8 arbitrary clickable elements ("Several real user behaviors: click through the interactive elements"); CODEX replaces that with a single named, asserted target ("Replace this locator with a named, representative product interaction during setup" + an `expect(target).toBeVisible()` assertion REPO/CLAUDE lacks). Different testing philosophy (broad-and-arbitrary vs narrow-and-explicit), not a superset of each other.
- `github-workflows/perf.yml` (62 → 63 lines): CODEX's CI job runs `pnpm e2e:perf` and `start-server-and-test` in the `e2e` job that REPO/CLAUDE's does not; CODEX also **removes** the `pull-requests: write` permission that REPO/CLAUDE's workflow has (REPO/CLAUDE: `permissions: contents: read` + `pull-requests: write`; CODEX: `permissions: contents: read` only) — a permissions reduction, worth a human look since REPO/CLAUDE's PERF.md claims "Bundle deltas are commented on the PR," which requires `pull-requests: write`; CODEX's workflow would not be able to do that even though CODEX's own PERF.md copy still says the same thing.
- `PERF.md` (65 → 68 lines), `tools/perf-check/cli.ts`, `tools/perf-check/engines/lighthouse.ts`, `tools/perf-check/README.md`, `budgets.json`, `lighthouserc.js`, `playwright.config.ts`, `e2e/invariants/a11y.spec.ts`: all differ, but changes here are small (4-10 changed lines each) and consistent with propagating the inp→interaction rename plus the mechanical em-dash/`$`-command layer — not separately quoted to stay within budget.
- Unchanged between REPO/CLAUDE and CODEX (content-identical despite the path prefix change): `.size-limit.js`, `tools/perf-check/engines/size.ts`, `vitest.config.ts`, `vitest.setup.ts`, `perf/config.ts`, `perf/render-count.test.tsx`, `e2e/invariants/smoke.spec.ts`.

**Frontmatter**: no `model` key in any copy.

**Sibling links**: none in any `SKILL.md` (the `templates/`/`assets/templates/` files are referenced only as bare paths in prose, not markdown links).

**Private data scan**: no hits.

## agent-latency-audit

**Presence**: REPO **yes**, CLAUDE **no**, CODEX **no** — confirmed exactly as the task noted to expect. `ls -la` on `/Users/edmond/.claude/skills/agent-latency-audit` and `/Users/edmond/.codex/skills/agent-latency-audit` both report "No such file or directory."

**File inventory**: REPO only: `SKILL.md` (71 lines). No `PLAN_TEMPLATE`, `REFERENCE`, or other siblings.

**Content diff**: n/a, single copy, nothing to diff.

**Frontmatter**: `name: agent-latency-audit`, `description: ...` (single paragraph, no `model` key, no `disable-model-invocation` key).

**Sibling links**: none.

**Private data scan**: no hits.

## What could not be determined

- **Anchor-level link resolution** (`#skill-vetting` etc.) was verified only by confirming the target file exists and the heading text is present via `grep`, not by a markdown-spec-accurate anchor slugifier. All headings referenced by anchors were found present in the target files by text match, so this is very likely fine, but it is not the same rigor as filesystem existence checks used for the file-path half of every link.
- **`CANON.md`'s reverse reference from `FORMAT.md`** is a bare-text mention in REPO/CLAUDE ("Reference an analog from CANON.md") rather than a markdown link, so it was not machine-verified as a link target — it was confirmed by reading the file, not by the grep pattern used for the rest of the sibling-link check.
- Byte-identical-content verdicts (e.g., `RIGOR-TEMPLATE.md` vs `references/rigor-template.md`, all of `perf-harness-init/templates/` REPO vs CLAUDE) were confirmed with `diff -q` / `diff -rq`, which is exact.
- This report did not open or diff `agents/openai.yaml` in any CODEX skill in detail beyond noting its existence and line count — it's a Codex-specific agent-routing manifest with no REPO/CLAUDE counterpart to diff against, so "drift" doesn't apply to it in the three-way sense the task asked for.

## FILES REQUIRING A HUMAN RULING

Only files with genuinely conflicting (not clean-superset) edits — where taking "the most-developed copy" is not obviously safe:

1. **`groundwork/SKILL.md`** (REPO/CLAUDE step 2a wording vs CODEX step 2a/2b) and **`groundwork/REFERENCE.md`** / **`groundwork/references/reference.md`** — CODEX's local-skill-discovery protocol is structurally different (Codex-injected catalog vs GitHub-org/skills.sh crawl), not a superset of REPO/CLAUDE's.
2. **`research/SKILL.md`**, **`research/RESEARCH-TEMPLATE.md`** — the CLAUDE→CODEX web-research routing text (CODEX's version has different sub-agent model-pinning and phrasing than CLAUDE's, both non-trivial).
3. **`research/WEB-RESEARCH.md`** (CLAUDE) vs **`research/references/web-research.md`** (CODEX) — independent rewrites of the same protocol; CODEX's trap table has an extra row CLAUDE's lacks, and CLAUDE cites an internal rigor doc CODEX drops.
4. **`plan/SKILL.md`** and **`plan/PLAN-TEMPLATE.md`** / **`plan/references/plan-template.md`** — CODEX's `update_plan` mechanism and the "record any genuine human/device acceptance check... continue with independent safe phases" pausing-behavior change vs REPO/CLAUDE's hard pause.
5. **`implement/SKILL.md`** — REPO/CLAUDE trusts existing plan checkmarks outright; CODEX requires re-verifying them before resuming. Also differing manual-verification pause behavior (hard pause vs conditional continue).
6. **`oneshot/SKILL.md`** — the "No scope creep" guardrail's trigger condition itself changed (REPO/CLAUDE: countable "third file"; CODEX: judgment-based "crosses concerns").
7. **`compact/SKILL.md`** — CODEX adds Codex-specific framing (auto-compaction context) not applicable to REPO/CLAUDE's target runtime; not a wording-only diff.
8. **`rigor/SKILL.md`** — the adversary-invocation mechanism and its independence-strength claim differ between REPO/CLAUDE and CODEX.
9. **`perf-loop/SKILL.md`** — REPO/CLAUDE hardcodes `mcp__MCP_DOCKER__browser_*` and "Agent tool" as the adversarial-verifier mechanism; CODEX has neither available and substitutes generic equivalents plus a stricter git-safety rule.
10. **`perf-harness-init/SKILL.md`**, **`perf-harness-init/templates/tools/perf-check/engines/inp.ts`** vs **`.../assets/templates/tools/perf-check/engines/interaction.ts`**, **`e2e/perf.spec.ts`**, **`github-workflows/perf.yml`** — a real metric rename with an added staleness check on the CODEX side, a testing-philosophy change (broad arbitrary clicks vs one named asserted target), and a CI permissions reduction (`pull-requests: write` dropped in CODEX) that contradicts CODEX's own copy of `PERF.md` still claiming PR bundle-delta comments work.
11. **`first-principles/SKILL.md`** — lower priority than the above (mostly mechanical) but the sub-agent-dispatch conditionality ("when parallelism materially improves the result" vs unconditional "all at once") and the added same-model-independence caveat are genuine content, not cosmetic.

Not requiring a ruling (clean supersets or byte-identical, safe to auto-resolve):
- `research/SKILL.md` and `research/RESEARCH-TEMPLATE.md`, REPO → CLAUDE direction only: pure appends, CLAUDE strictly contains REPO.
- `groundwork/REFERENCE.md`, REPO → CLAUDE direction only: pure append.
- `rigor/RIGOR-TEMPLATE.md` vs CODEX's `references/rigor-template.md`: byte-identical body.
- `rigor/FRAMEWORKS.md` REPO vs CLAUDE: byte-identical (mtime differs, content doesn't).
- All of `perf-harness-init/templates/` REPO vs CLAUDE: byte-identical, 19/19 files.
- `implement/SKILL.md`, `oneshot/SKILL.md`, `compact/{SKILL,HANDOFF-TEMPLATE}.md`, `first-principles/{CANON,FORMAT}.md`, `plan/{SKILL,PLAN-TEMPLATE}.md` — all byte-identical REPO vs CLAUDE.
