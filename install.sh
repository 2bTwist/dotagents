#!/usr/bin/env bash
#
# dotagents installer
#
# Installs the canonical skills/ and agents/ tree into whichever agent harness
# you name. Harness-specific knowledge lives in install.d/<target>.sh; this file
# only walks the tree and calls into an adapter.
#
# Usage:
#   ./install.sh                          # every detected harness
#   ./install.sh --target=claude          # one harness (repeatable)
#   ./install.sh --target=agents --dest=. # generic AGENTS.md, into a directory
#   ./install.sh --list                   # what would install where, and what is skipped
#   ./install.sh --dry-run                # show the plan, write nothing
#   ./install.sh --force                  # overwrite existing files
#   ./install.sh --symlink                # link instead of copy (repo edits apply live)
#   ./install.sh --with-optional          # also install optional/ packages
#
# Targets: claude, codex, pi, agents

set -uo pipefail
shopt -s nullglob        # an unmatched glob yields nothing, never a literal path

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE="copy"
FORCE=false
DRY_RUN=false
LIST_ONLY=false
WITH_OPTIONAL=false
DEST=""
TARGETS=()

ALL_TARGETS=(claude codex pi agents)

# DEST is read by install.d/agents.sh, which shellcheck cannot follow.
# shellcheck disable=SC2034
for arg in "$@"; do
  case "$arg" in
    --target=*)     TARGETS+=("${arg#*=}") ;;
    --dest=*)       DEST="${arg#*=}" ;;
    --symlink)      MODE="symlink" ;;
    --force)        FORCE=true ;;
    --dry-run)      DRY_RUN=true ;;
    --list)         LIST_ONLY=true; DRY_RUN=true ;;
    --with-optional) WITH_OPTIONAL=true ;;
    -h|--help)      grep '^#' "$0" | sed 's/^# \?//' | head -22; exit 0 ;;
    *)              echo "Unknown arg: $arg" >&2; exit 1 ;;
  esac
done

source "$REPO_DIR/install.d/_lib.sh"

[ -d "$REPO_DIR/skills" ] || die "no skills/ directory at $REPO_DIR"
[ -d "$REPO_DIR/agents" ] || die "no agents/ directory at $REPO_DIR"

# --- target selection --------------------------------------------------------

if [ ${#TARGETS[@]} -eq 0 ]; then
  for t in "${ALL_TARGETS[@]}"; do
    [ "$t" = "agents" ] && continue        # needs an explicit --dest
    # shellcheck source=/dev/null
    ( source "$REPO_DIR/install.d/$t.sh"; harness_detect ) && TARGETS+=("$t")
  done
  [ ${#TARGETS[@]} -eq 0 ] && die "no harness detected. Name one with --target=<claude|codex|pi|agents>"
fi

for t in "${TARGETS[@]}"; do
  [ -f "$REPO_DIR/install.d/$t.sh" ] || die "unknown target '$t' (no install.d/$t.sh)"
done

# --- one target --------------------------------------------------------------

install_target() {
  local target="$1"
  local installed=0 skipped=0 present=0

  # shellcheck source=/dev/null
  source "$REPO_DIR/install.d/$target.sh"

  say ""
  say "== $HARNESS_NAME ($target)"
  say "   root: $(harness_root)"
  [ -n "$HARNESS_CAPS" ] && say "   capabilities: $HARNESS_CAPS" || say "   capabilities: none"

  do_mkdir "$(harness_skills_dir)"

  local skill_md name requires degrades missing dest
  for skill_md in "$REPO_DIR"/skills/*/SKILL.md; do
    name="$(basename "$(dirname "$skill_md")")"

    requires="$(harness_caps_of "$skill_md" requires)"
    degrades="$(harness_caps_of "$skill_md" degrades)"

    if [ -n "$requires" ]; then
      if ! missing="$(caps_satisfied "$HARNESS_CAPS" "$requires")"; then
        info "SKIP  $name -- needs [$missing], $HARNESS_NAME has no such capability"
        skipped=$((skipped + 1))
        continue
      fi
    fi

    if [ -n "$degrades" ]; then
      if ! missing="$(caps_satisfied "$HARNESS_CAPS" "$degrades")"; then
        warn "$name: degraded, [$missing] unavailable here"
      fi
    fi

    dest="$(harness_skill_dest "$name")"

    if [ -e "$dest" ] && ! $FORCE; then
      info "skip  $name (exists, use --force)"
      present=$((present + 1))
      continue
    fi

    if $LIST_ONLY; then
      info "would install $name -> $dest"
      present=$((present + 1))
      continue
    fi

    [ -e "$dest" ] && do_rm "$dest"

    if [ "$MODE" = "symlink" ]; then
      # Whole-directory link: repo edits apply live. Frontmatter is NOT
      # rewritten in this mode, so repo-only keys remain visible.
      do_symlink "$(dirname "$skill_md")" "$dest"
      info "link  $name"
    else
      # Copy siblings and subdirectories, then rewrite SKILL.md frontmatter.
      do_copy "$(dirname "$skill_md")" "$dest"
      strip_frontmatter_keys "$skill_md" $HARNESS_DROP_KEYS | do_write "$dest/SKILL.md"
      info "skill $name"
    fi
    installed=$((installed + 1))
    present=$((present + 1))
  done

  local agent_md
  for agent_md in "$REPO_DIR"/agents/*.md; do
    if $LIST_ONLY; then
      info "would install agent $(basename "$agent_md")"
      continue
    fi
    harness_agent_install "$agent_md"
  done

  install_instructions "$target"

  if $WITH_OPTIONAL && [ -d "$REPO_DIR/optional" ]; then
    install_optional "$target"
  fi

  say "   installed: $installed, already present: $((present - installed)), skipped: $skipped"

  # A target that ends up with no skills at all is broken, not successful, and
  # this is the exact failure the previous installer exited 0 on. Measure what
  # is PRESENT, not what this run wrote: a rerun that correctly skips everything
  # already installed has done its job.
  if [ "$present" -eq 0 ]; then
    printf 'error: %s: no skills present after install. Refusing to report success.\n' "$target" >&2
    return 1
  fi
  return 0
}

# --- instructions ------------------------------------------------------------
#
# One canonical document, rendered into each harness's instructions file inside a
# managed block. Only the block is replaced, so anything the user hand-wrote in
# that file survives every later install. The per-harness preamble sits ABOVE the
# block and is seeded once, never overwritten, because it is where harness quirks
# get added by hand.

install_instructions() {
  local target="$1"
  local core="$REPO_DIR/instructions/core.md"
  local preamble="$REPO_DIR/instructions/preamble/$target.md"
  local dest sentinel tmp

  [ -f "$core" ] || { warn "no instructions/core.md; skipping instructions"; return 0; }

  dest="$(harness_instructions_dest)"

  if $LIST_ONLY; then
    info "would render instructions -> $dest"
    return 0
  fi

  if [ -f "$preamble" ]; then
    # First line of a preamble is its sentinel comment. Present means seeded.
    sentinel="$(head -1 "$preamble")"
    if [ ! -f "$dest" ] || ! grep -qF "$sentinel" "$dest"; then
      if ! $DRY_RUN; then
        tmp="$(mktemp)"
        { cat "$preamble"
          printf '\n'
          [ -f "$dest" ] && cat "$dest"
        } >"$tmp"
        do_mkdir "$(dirname "$dest")"
        mv "$tmp" "$dest"
      fi
      info "preamble seeded ($target)"
    fi
  fi

  write_managed_block "$dest" "$core"
  info "instructions -> $dest"

  install_references
}

# Machine-local reference files, read on demand. Gitignored in the repo, so a
# clone carries only the README. The repo copy is canonical: these are overwritten
# on every install rather than skipped, since the installed copy is a pure copy.
install_references() {
  local srcdir="$REPO_DIR/instructions/references"
  local destdir ref
  [ -d "$srcdir" ] || return 0

  destdir="$(harness_root)/references"

  if $LIST_ONLY; then
    info "would install references -> $destdir"
    return 0
  fi

  if [ "$MODE" = "symlink" ]; then
    if [ ! -L "$destdir" ]; then
      [ -e "$destdir" ] && do_rm "$destdir"
      do_symlink "$srcdir" "$destdir"
    fi
    info "link  references/"
    return 0
  fi

  do_mkdir "$destdir"
  local n=0
  for ref in "$srcdir"/*.md; do
    do_rm "$destdir/$(basename "$ref")"
    do_copy "$ref" "$destdir/$(basename "$ref")"
    n=$((n + 1))
  done
  info "references/ ($n files)"
}

# --- optional packages -------------------------------------------------------

install_optional() {
  local target="$1" pkg pname requires missing
  for pkg in "$REPO_DIR"/optional/*/; do
    pname="$(basename "$pkg")"
    requires=""
    [ -f "$pkg/PACKAGE" ] && requires="$(grep -E '^requires:' "$pkg/PACKAGE" 2>/dev/null | sed 's/^requires:[ ]*//')"

    if [ -n "$requires" ] && ! missing="$(caps_satisfied "$HARNESS_CAPS" "$requires")"; then
      info "SKIP  optional/$pname -- needs [$missing], $HARNESS_NAME has no such capability"
      continue
    fi
    if [ -f "$pkg/install.sh" ]; then
      info "optional $pname"
      # SOURCED, not executed. A package needs the target adapter's harness_*
      # functions to know where things go, and the do_* writers so --dry-run is
      # enforced in one place rather than reimplemented per package. A subprocess
      # would inherit neither, which is why this is not `"$pkg/install.sh"`.
      unset -f optional_install
      # shellcheck source=/dev/null
      source "$pkg/install.sh"
      if declare -f optional_install >/dev/null 2>&1; then
        optional_install "${pkg%/}"
      else
        warn "optional/$pname: install.sh defines no optional_install(), skipped"
      fi
      unset -f optional_install
    fi
  done
}

# --- run ---------------------------------------------------------------------

say "dotagents"
say "source: $REPO_DIR"
say "mode:   $MODE$($FORCE && echo ' (force)')"
$DRY_RUN && say "DRY RUN: nothing will be written"

rc=0
for t in "${TARGETS[@]}"; do
  install_target "$t" || rc=1
done

say ""
if [ $rc -eq 0 ]; then
  say "Done. Start a fresh session in each harness."
else
  say "Finished with errors. See above."
fi
exit $rc
