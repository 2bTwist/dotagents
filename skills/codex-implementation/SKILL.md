---
name: codex-implementation
description: Delegate a scoped, well-specified code change to Codex CLI (the OpenAI coding agent) as a second implementation engine, then inspect its diff and verification before reporting. Use when the user asks to delegate work to Codex or GPT, when a bounded task benefits from a parallel agent producing a patch, or when Claude usage limits make offloading mechanical implementation attractive. Claude stays responsible for scoping, review, and the final verdict.
---

# Codex implementation

Adapted from Theo's (t3.gg) Fable-plus-Codex setup. Codex implements; Claude scopes the task, reviews the diff, checks verification, and owns the result. `~/.codex/AGENTS.md` already carries Edmond's global conventions, so Codex follows them.

Do not let Codex commit, push, deploy, or edit global config unless the user explicitly asked.

## Workflow

1. Pin current state with `git status --short`; note user changes already present (never let them be clobbered or reverted).
2. Define scope: files or behavior to change, files to avoid, constraints, verification commands.
3. Run:

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-impl.XXXXXX")"
PROMPT="$ARTIFACT_DIR/prompt.md"   # write the self-contained prompt here
codex exec -C "$PWD" --add-dir "$ARTIFACT_DIR" -s workspace-write \
  -o "$ARTIFACT_DIR/report.md" "$(cat "$PROMPT")" </dev/null
```

- Default `-s workspace-write`. Escalate to `danger-full-access` only for work that truly needs machine-level access (simulators, global package state), and say so.
- Codex runs can exceed the Bash default timeout: pass an explicit timeout (600000) or run in the background and read the report file when notified.
- Parallel Codex implementation runs need separate worktrees so edits do not collide.

## Prompt requirements

Tell Codex: the goal and acceptance criteria; repo path and branch; which existing patterns/files/tests to inspect first; what must not change; that it must preserve unrelated user changes; that it must not commit, push, deploy, or touch global config; which verification commands to run (or to explain why skipped); and to end with a concise report (files changed, verification result, open questions).

Keep the task bounded. If the ask bundles several substantial changes, split into separate runs.

## After Codex

Always read `git diff` yourself before telling the user it is done; Codex's report is evidence, not authority. Run the cheapest reliable verification directly when practical. If Codex changed unrelated files or left the repo worse, stop and report with the diff summary. If `codex` is missing or fails, offer to implement directly instead.
