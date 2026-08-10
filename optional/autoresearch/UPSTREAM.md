# Upstream provenance

This package is vendored, not original work.

| Field | Value |
|---|---|
| Upstream repository | https://github.com/drivelineresearch/autoresearch-claude-code |
| Vendored commit | `0f1ba8f36de4dfd481b57d93e9b970936839f266` |
| Commit date | 2026-03-24 |
| License | MIT, Copyright (c) 2026 Kyle |

## What is verbatim and what is not

Verified with `cmp` on 2026-08-10 against a clone of the upstream repository at
that commit:

| File | Status |
|---|---|
| `skills/autoresearch/SKILL.md` | byte-identical to upstream |
| `commands/autoresearch.md` | byte-identical to upstream |
| `hooks/autoresearch-context.sh` | byte-identical to upstream |
| `README.md` | local rewrite, not upstream. Describes this repo's packaging, not the upstream project |

Upstream also ships `install.sh`, `uninstall.sh`, `examples/`, `experiments/`,
`plots/`, `imgs/`, and its own `CLAUDE.md`. None of those are vendored here: this
repo installs the package through its own adapter mechanism, and the rest is
project scaffolding for the upstream repo itself.

## Provenance chain

The upstream port is itself an adaptation of
[davebcn87/pi-autoresearch](https://github.com/davebcn87/pi-autoresearch), which
generalizes [karpathy/autoresearch](https://github.com/karpathy/autoresearch)
from ML training loops to any measurable metric.

## Three copies exist on a developer machine, and that is deliberate

1. This vendored snapshot, pinned to the commit above. It is what the installer ships.
2. A separate working clone, if you keep one. On the maintainer's machine
   `~/.claude/skills/autoresearch` is a symlink into such a clone, which means a
   live install may be tracking upstream's `main` rather than this snapshot.
3. Whatever a given harness currently has installed.

If the installed skill and this snapshot disagree, check for that symlink before
concluding the installer is at fault.

## Updating the snapshot

Re-vendor the three files from a fresh checkout, update the commit and date in
the table above, and re-run `cmp` so the verbatim claims stay true. Do not edit
the vendored files in place: a local fix that is not upstreamed becomes invisible
drift the next time someone re-vendors.
