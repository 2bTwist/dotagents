# Decision: add `discuss`, a tutor that builds understanding of research before a grill

**Date:** 2026-09-13
**Status:** accepted; skill written at `skills/discuss/`

## Problem

Research runs produce long markdown files that are too much to read. The user wants an intense,
single-session discussion that walks through every load-bearing finding, respects how findings
build on each other, and ends with enough shared understanding to take part in a grill. The goal
is knowledge, not a decision.

## Model

Adaptive traversal of a pruned prerequisite DAG, gated by mastery checks against a live model of
the learner.

- Findings are nodes; `A -> B` means B needs A. Mutually explaining findings collapse into one
  unit (strongly connected components), leaving a DAG.
- Pruning is backward chaining from the decisions the grill will face: a node is load-bearing when
  some decision depends on it.
- The learner's knowledge state and its fringe (nodes whose prerequisites are mastered) choose the
  next concept (Knowledge Space Theory). A stumble points back at a weak prerequisite.
- After a cluster, teach the edges: how concepts connect, including across independent clusters.

## Decisions

| Choice | Decision | Reasoning | Rejected |
|---|---|---|---|
| Relation to `teach` | Separate skill | Matt Pocock's `teach` is multi-session, builds a workspace and HTML lessons, and aims at long-term retention. `discuss` is one session, bounded to existing research, aimed at grill readiness. | Mode of `teach` (edits an upstream skill, loads unrelated body). Use `teach` as-is (creates workspace files and more reading). |
| Name | `discuss` | User-invoked, so the name is a handle; body leading words steer behavior. | `walk-me-through`, `brief-me` ("brief" implies a one-way summary). |
| Invocation | `disable-model-invocation: true`; the description still names its trigger because Codex and Pi strip that key | No always-loaded context on Claude Code; never starts by surprise. | Model may suggest after research (permanent context load). |
| Input | Args (paths or glob), else research in the conversation, else ask. A discussion file as the arg resumes it. | Covers written and conversation-only research. | Named files only; latest doc in `specs/research/` (wrong when several runs are recent). |
| Map build | File input: one frontier-tier sub-agent reads the docs and returns a compact graph with `file:line` anchors. Conversation input, or no sub-agents: build inline. | Keeps raw research out of the teaching context. A fresh sub-agent cannot see conversation-only research. The graph is lossy, so open anchored lines when a detail is pressed. | Always inline (fills context early). Mid tier (edge and decision links are the core judgment). |
| Decisions to prune against | Agent infers candidate decisions and shows them at the top of the brief map; user edits before teaching | Research docs are documentarian and rarely name decisions; the user often cannot name them yet either. | Ask user first (answering blind). No pruning (unanchored importance, run-to-run variance). |
| Map visibility | Brief map first: clusters, order, decisions fed | Lets the user prune known clusters and catch wrong edges, the likeliest agent error. | Reveal at end. Never show (wrong edges uncatchable). |
| Oversize map | Say so at map time; user picks clusters; the rest stay pending in the discussion file | Protects focus for the cross-cluster synthesis at the end. | Push through the whole map. |
| Turn shape | One concept per turn in plain chat: the decision it feeds, explanation with a concrete scenario, small diagram if spatial, then a check | Working memory is small. Teach-back needs free text, so no question box. | One cluster per turn (long messages recreate the reading problem). Follow the user's lead (fuzzy bound). |
| Mastery gate | Teach-back in the user's words on load-bearing concepts, pushing on errors and omissions; light check on supporting detail | Premature completion, by the agent or by a polite user, is the main failure mode. | Teach-back on every node (fatigue on leaves). User declares "got it" (makes intensity optional). |
| Opinions | Tradeoffs and the strongest case for each side, no verdicts; forming choices go on a "for the grill" list | Avoids anchoring the grill on a position already taken. | Opinions on request; full opinions. |
| Research gaps | Contradictions, stale claims, and uncovered questions become flagged nodes on the "for the grill" list; verify the cited `file:line` only when understanding depends on it | Keeps flow without silently building on a wrong prerequisite. | Pause and re-research. Note and move on (corrupts dependents). |
| Output | Chat recap plus a saved discussion file. First settled as "no file" and reversed by the user in the same session. | Survives compaction, early stops, and a grill in a later session; makes resume possible. | Recap only. Offer a file each time. |
| File location | `specs/discussions/YYYY-MM-DD-<slug>.md`; ask when the project has no `specs/` | Matches the `research` naming convention and stays visible in the project. | Beside the research doc (no home for conversation-only or multi-doc research). Under the harness config dir (invisible, unversioned). |
| File contents | Map and state only: status, decisions, clusters and edges with anchors, per-concept state, gaps, "for the grill" list, one line per connection, source fingerprints | Short and scannable, so the fix does not recreate the long-doc problem. | Teach-back gist per concept (preserves subtle misreadings). Full study notes (rebuilds the long doc). |
| Write timing | At map confirmation, after each cluster, and at the recap, with a status line | State survives early stops; the status keeps a partial file from reading as finished. | Recap only. |
| Resume | Reuse the saved map; recall prompts on mastered load-bearing concepts, misses return to pending, continue from the fringe | Fluency fades between sessions. | Trust the record. |
| Source drift | Compare recorded fingerprints (`git hash-object`, mtime outside git); changed sources send their anchored concepts to pending and only those clusters rebuild | Keeps the map from teaching claims a corrected doc no longer makes. | Ignore drift. Always rebuild (expensive, fuzzy mastery matching). |

## Completion criterion

Every load-bearing concept in the chosen clusters entered the knowledge state through a teach-back
the user gave, never because the agent declared it; every flagged gap sits on the "for the grill"
list; the discussion file matches that state; the recap is delivered.

## Accepted tradeoffs

- Sessions are slower and quiz-like on concepts the user already half knows.
- The map is a lossy summary; wrong edges are caught only if the user reviews the map.
- Every run leaves an untracked file under `specs/discussions/` to commit or delete.
- The file records what was learned, not study notes; relearning means rerunning `discuss`.
- Each resume spends a few minutes on recall before new material.
- A trivial edit to a source doc can reopen a whole cluster.
- Withholding verdicts can feel evasive when the user asks directly.
- Some research gaps enter the grill still open.
