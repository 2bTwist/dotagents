# autoresearch (vendored domain skill)

Autonomous experiment loop for Claude Code — give it a goal, a benchmark, and
files to modify; it loops forever (try idea → measure → keep winners → discard
losers → repeat). Useful for any optimization target with a measurable metric:
test runtime, bundle size, Lighthouse scores, model accuracy, build time, etc.

## Source

Vendored verbatim from
[drivelineresearch/autoresearch-claude-code](https://github.com/drivelineresearch/autoresearch-claude-code)
at commit `0f1ba8f` (2026-03-24), MIT licensed. That port is itself an
adaptation of [davebcn87/pi-autoresearch](https://github.com/davebcn87/pi-autoresearch),
which generalizes [karpathy/autoresearch](https://github.com/karpathy/autoresearch)
from ML training to any metric.

## Why it lives under `domain-skills/` and not the core kit

The core `.claude/` content implements Dex Horthy's ACE-FCA methodology
(research → plan → implement → compact). Autoresearch is a different pattern —
Karpathy-style autonomous optimization — and isn't part of that workflow. It
ships here as an **opt-in** domain skill installed via
`./install.sh --with-domain-skills`.

## Layout

Mirrors the upstream port's layout so files can be diffed against upstream
without renames:

```
skills/autoresearch/SKILL.md         # main skill, lays out the JSONL protocol and loop
commands/autoresearch.md             # /autoresearch slash command (start, resume, off)
hooks/autoresearch-context.sh        # UserPromptSubmit hook — injects loop reminder
```

## Install

```bash
./install.sh --with-domain-skills
```

The installer:
1. Symlinks the skill to `~/.claude/skills/autoresearch/`
2. Symlinks the slash command to `~/.claude/commands/autoresearch.md`
3. Copies the hook to `~/.claude/hooks/autoresearch-context.sh`
4. Prints the JSON snippet to add to `~/.claude/settings.json` under
   `hooks.UserPromptSubmit` (manual step — same as upstream)

After install, in any repo: `/autoresearch optimize <something measurable>`.

## Updating from upstream

```bash
# In a scratch directory
git clone https://github.com/drivelineresearch/autoresearch-claude-code.git upstream
cp upstream/skills/autoresearch/SKILL.md       domain-skills/claude/autoresearch/skills/autoresearch/
cp upstream/commands/autoresearch.md           domain-skills/claude/autoresearch/commands/
cp upstream/hooks/autoresearch-context.sh      domain-skills/claude/autoresearch/hooks/
# Update the commit hash in this README to match upstream HEAD
```

## License

Upstream is MIT. See the upstream `LICENSE` file. This repo is also MIT, so the
vendored files are compatible without separate notice.
