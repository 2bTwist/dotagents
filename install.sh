#!/usr/bin/env bash
#
# dotclaude installer
# Copies commands and agents into ~/.claude/ for global use across Claude Code sessions.
#
# Usage:
#   ./install.sh                 # copy files (safe default, won't overwrite)
#   ./install.sh --force         # copy files, overwriting existing ones
#   ./install.sh --symlink       # symlink instead of copy (edits to this repo apply immediately)
#   ./install.sh --dry-run       # show what would happen
#

set -euo pipefail

MODE="copy"
FORCE=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --symlink) MODE="symlink" ;;
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \?//' | head -20
      exit 0
      ;;
    *) echo "Unknown arg: $arg"; exit 1 ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_COMMANDS="$REPO_DIR/.claude/commands"
SRC_AGENTS="$REPO_DIR/.claude/agents"
DEST_COMMANDS="$HOME/.claude/commands"
DEST_AGENTS="$HOME/.claude/agents"

say() { echo "• $*"; }
do_cmd() {
  if $DRY_RUN; then
    echo "  DRY: $*"
  else
    eval "$@"
  fi
}

say "Source:      $REPO_DIR"
say "Destination: $HOME/.claude"
say "Mode:        $MODE$($FORCE && echo ' (force)')"
$DRY_RUN && say "DRY RUN: no changes will be made"
echo

do_cmd "mkdir -p '$DEST_COMMANDS' '$DEST_AGENTS'"

install_one() {
  local src="$1" dest_dir="$2"
  local name; name="$(basename "$src")"
  local dest="$dest_dir/$name"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if ! $FORCE; then
      echo "  skip  $dest (exists, use --force to overwrite)"
      return
    fi
    do_cmd "rm -f '$dest'"
  fi

  if [[ "$MODE" == "symlink" ]]; then
    do_cmd "ln -s '$src' '$dest'"
    echo "  link  $dest -> $src"
  else
    do_cmd "cp '$src' '$dest'"
    echo "  copy  $dest"
  fi
}

echo "Commands:"
for f in "$SRC_COMMANDS"/*.md; do
  install_one "$f" "$DEST_COMMANDS"
done

echo
echo "Agents:"
for f in "$SRC_AGENTS"/*.md; do
  install_one "$f" "$DEST_AGENTS"
done

echo
say "Done."
say "Start a fresh Claude Code session. Slash commands: /research /plan /implement /compact /oneshot"
say "Sub-agents appear in the Agent tool's subagent_type list."
