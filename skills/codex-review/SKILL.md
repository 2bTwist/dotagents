---
name: codex-review
description: Get an independent code review from Codex CLI (the OpenAI coding agent) of uncommitted changes, a branch diff, or a commit, as a second perspective alongside Claude's own review. Use when the user asks for a Codex/GPT review or a second opinion on a diff, or before shipping broad or risky changes where an independent reviewer counters author bias. Claude verifies Codex's findings against the code before relaying them.
---

# Codex review

Adapted from Theo's (t3.gg) setup. An independent reviewer that did not author the change; useful precisely because of the author-bias rule (never be the sole verifier of your own output). Treat its output as evidence, not authority.

Prefer Claude's normal review for small local checks. Do not delegate review just to avoid reading the code.

## Command shapes

Codex CLI (>= 0.144.x) treats a custom PROMPT (positional or `-` stdin) as mutually exclusive with every review target flag (`--commit`, `--base`, `--uncommitted`), despite what its usage line suggests. Run the target flags bare; carry context another way (see below).

```bash
ARTIFACT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-review.XXXXXX")"

# uncommitted (staged + unstaged + untracked)
codex -C "$PWD" review --uncommitted > "$ARTIFACT_DIR/report.md"
# branch vs base
codex -C "$PWD" review --base main > "$ARTIFACT_DIR/report.md"
# single commit
codex -C "$PWD" review --commit <sha> > "$ARTIFACT_DIR/report.md"
```

Long diffs take minutes: pass an explicit Bash timeout (600000) or run in the background.

## Getting context into the review

With target flags, Codex sees only its default instructions plus the diff and repo:

- **A detailed commit message is the main context channel** for `--commit` reviews; write invariants and risky areas into it before requesting review.
- For custom instructions, use `codex exec` with a self-contained prompt (name the files/sha to inspect, the invariants to check, and "do not edit files"); it costs more quota than `review`.

## Reporting back

Verify each important finding against the code before relaying it; separate confirmed issues from unverified Codex suggestions. If Codex finds nothing, say that and name the review target it inspected. If `codex` is missing or fails, review directly instead.
