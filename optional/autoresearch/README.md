# autoresearch (optional package)

Autonomous experiment loop for Claude Code — give it a goal, a benchmark, and
files to modify; it loops forever (try idea → measure → keep winners → discard
losers → repeat). Useful for any optimization target with a measurable metric:
test runtime, bundle size, Lighthouse scores, model accuracy, build time, etc.

## Source

Vendored, not original work. `UPSTREAM.md` is the authoritative record: upstream
repository, pinned commit, license, and which files are byte-identical to
upstream versus rewritten locally. It is deliberately the only place the commit
hash appears, so there is nothing to keep in sync.

## Why it is an optional package and not a core skill

Two reasons, and only the second one is about taste.

The core content implements Dex Horthy's ACE-FCA methodology (research, plan,
implement, handoff). Autoresearch is a different pattern, Karpathy-style
autonomous optimization, and is not part of that workflow.

More importantly it is not portable. It is not a skill, it is a skill plus a
slash command plus a `UserPromptSubmit` hook, and the loop is sustained by the
hook rather than by the skill. On a harness with no hooks, installing the skill
would produce something that reads like it works and then quietly runs once and
stops. So the package declares what it needs in `PACKAGE`:

```
requires: hooks slash-commands
```

Any harness missing either capability declines the package by name and prints
why. Of the four supported targets, only Claude Code satisfies both.

## Layout

Mirrors the upstream port's layout so files can be diffed against upstream
without renames:

```
skills/autoresearch/SKILL.md         # main skill, lays out the JSONL protocol and loop
commands/autoresearch.md             # /autoresearch slash command (start, resume, off)
hooks/autoresearch-context.sh        # UserPromptSubmit hook, injects the loop reminder
PACKAGE                              # capability declaration read by the installer
install.sh                           # sourced by the installer, places the three components
UPSTREAM.md                          # provenance
```

## Install

```bash
./install.sh --target=claude --with-optional
```

Optional packages are opt-in. Without `--with-optional` nothing here is
installed anywhere.

The installer:
1. Places the skill at `~/.claude/skills/autoresearch/`
2. Places the slash command at `~/.claude/commands/autoresearch.md`
3. Copies the hook to `~/.claude/hooks/autoresearch-context.sh` and makes it executable
4. Prints the JSON to add to `~/.claude/settings.json` under `hooks.UserPromptSubmit`,
   or reports that it is already wired

Steps 1 and 2 follow the run's mode, so `--symlink` links them and repo edits
apply live. Step 3 never does: the hook's absolute path is recorded in
`settings.json`, so it is always a real copy, even under `--symlink`. A link
there would break the loop the moment the checkout moved.

Step 4 is the one thing the installer cannot do for you, because editing
`settings.json` in place risks a config file you may have hand-tuned.

After install, in any repo: `/autoresearch optimize <something measurable>`.

## Updating from upstream

```bash
# In a scratch directory
git clone https://github.com/drivelineresearch/autoresearch-claude-code.git upstream
cp upstream/skills/autoresearch/SKILL.md       optional/autoresearch/skills/autoresearch/
cp upstream/commands/autoresearch.md           optional/autoresearch/commands/
cp upstream/hooks/autoresearch-context.sh      optional/autoresearch/hooks/
```

Then update the commit, date, and the byte-identical table in `UPSTREAM.md`, and
re-run `cmp` against the fresh checkout so those claims stay true.

## License

Upstream is MIT. See the upstream `LICENSE` file. This repo is also MIT, so the
vendored files are compatible without separate notice.
