#!/usr/bin/env bash
#
# dotclaude installer
# Copies commands/agents into ~/.claude/ (Claude Code) and prompts/skills
# into ~/.pi/agent/ (Pi, if installed). Works for either or both harnesses.
#
# Usage:
#   ./install.sh                       # install for all detected harnesses (safe default, won't overwrite)
#   ./install.sh --claude-only         # install only Claude Code bits
#   ./install.sh --pi-only             # install only Pi bits
#   ./install.sh --with-domain-skills  # also install domain skills (mobile/ASO etc.) from domain-skills/
#   ./install.sh --force               # overwrite existing files
#   ./install.sh --symlink             # symlink instead of copy (edits to this repo apply immediately)
#   ./install.sh --dry-run             # show what would happen
#

set -euo pipefail

MODE="copy"
FORCE=false
DRY_RUN=false
INSTALL_CLAUDE=true
INSTALL_PI=true
WITH_DOMAIN_SKILLS=false

for arg in "$@"; do
  case "$arg" in
    --symlink) MODE="symlink" ;;
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    --claude-only) INSTALL_PI=false ;;
    --pi-only) INSTALL_CLAUDE=false ;;
    --with-domain-skills) WITH_DOMAIN_SKILLS=true ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \?//' | head -27
      exit 0
      ;;
    *) echo "Unknown arg: $arg"; exit 1 ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

say() { echo "• $*"; }
do_cmd() {
  if $DRY_RUN; then
    echo "  DRY: $*"
  else
    eval "$@"
  fi
}

install_one() {
  local src="$1" dest_dir="$2"
  local name; name="$(basename "$src")"
  local dest="$dest_dir/$name"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if ! $FORCE; then
      echo "  skip  $dest (exists, use --force to overwrite)"
      return
    fi
    do_cmd "rm -rf '$dest'"
  fi

  if [[ "$MODE" == "symlink" ]]; then
    do_cmd "ln -s '$src' '$dest'"
    echo "  link  $dest -> $src"
  else
    do_cmd "cp -R '$src' '$dest'"
    echo "  copy  $dest"
  fi
}

say "Source:    $REPO_DIR"
say "Mode:      $MODE$($FORCE && echo ' (force)')"
$DRY_RUN && say "DRY RUN: no changes will be made"
echo

# ---- Claude Code ----
if $INSTALL_CLAUDE; then
  SRC_CLAUDE_COMMANDS="$REPO_DIR/.claude/commands"
  SRC_CLAUDE_AGENTS="$REPO_DIR/.claude/agents"
  SRC_CLAUDE_SKILLS="$REPO_DIR/.claude/skills"
  DEST_CLAUDE_COMMANDS="$HOME/.claude/commands"
  DEST_CLAUDE_AGENTS="$HOME/.claude/agents"
  DEST_CLAUDE_SKILLS="$HOME/.claude/skills"

  say "Claude Code destination: $HOME/.claude/"
  do_cmd "mkdir -p '$DEST_CLAUDE_COMMANDS' '$DEST_CLAUDE_AGENTS' '$DEST_CLAUDE_SKILLS'"

  echo "Claude commands:"
  for f in "$SRC_CLAUDE_COMMANDS"/*.md; do
    install_one "$f" "$DEST_CLAUDE_COMMANDS"
  done

  echo
  echo "Claude sub-agents:"
  for f in "$SRC_CLAUDE_AGENTS"/*.md; do
    install_one "$f" "$DEST_CLAUDE_AGENTS"
  done

  echo
  echo "Claude skills:"
  if [[ -d "$SRC_CLAUDE_SKILLS" ]]; then
    for d in "$SRC_CLAUDE_SKILLS"/*/; do
      [[ -d "$d" ]] && install_one "${d%/}" "$DEST_CLAUDE_SKILLS"
    done
  fi

  if $WITH_DOMAIN_SKILLS; then
    SRC_DOMAIN_CLAUDE="$REPO_DIR/domain-skills/claude"
    if [[ -d "$SRC_DOMAIN_CLAUDE" ]]; then
      echo
      echo "Claude domain skills:"
      for entry in "$SRC_DOMAIN_CLAUDE"/*; do
        # autoresearch is multi-target (skill + command + hook); handled separately below
        [[ "$(basename "$entry")" == "autoresearch" ]] && continue
        [[ -e "$entry" ]] && install_one "$entry" "$DEST_CLAUDE_SKILLS"
      done
    fi

    SRC_AUTORESEARCH="$REPO_DIR/domain-skills/claude/autoresearch"
    if [[ -d "$SRC_AUTORESEARCH" ]]; then
      DEST_CLAUDE_HOOKS="$HOME/.claude/hooks"
      do_cmd "mkdir -p '$DEST_CLAUDE_HOOKS'"

      echo
      echo "Claude autoresearch (skill + command + hook):"
      install_one "$SRC_AUTORESEARCH/skills/autoresearch" "$DEST_CLAUDE_SKILLS"
      install_one "$SRC_AUTORESEARCH/commands/autoresearch.md" "$DEST_CLAUDE_COMMANDS"
      # Hook script needs a stable absolute path — always copy, never symlink
      DEST_HOOK="$DEST_CLAUDE_HOOKS/autoresearch-context.sh"
      if [[ -e "$DEST_HOOK" ]] && ! $FORCE; then
        echo "  skip  $DEST_HOOK (exists, use --force to overwrite)"
      else
        do_cmd "cp '$SRC_AUTORESEARCH/hooks/autoresearch-context.sh' '$DEST_HOOK'"
        do_cmd "chmod +x '$DEST_HOOK'"
        echo "  copy  $DEST_HOOK"
      fi

      SETTINGS="$HOME/.claude/settings.json"
      if [[ -f "$SETTINGS" ]] && grep -q "autoresearch-context.sh" "$SETTINGS" 2>/dev/null; then
        say "Autoresearch hook already wired into $SETTINGS"
      else
        echo
        say "Final step (manual): add the autoresearch hook to $SETTINGS"
        echo '      "hooks": {'
        echo '        "UserPromptSubmit": ['
        echo '          { "hooks": [ { "type": "command", "command": "~/.claude/hooks/autoresearch-context.sh" } ] }'
        echo '        ]'
        echo '      }'
        echo
      fi
    fi
  fi
  echo
fi

# ---- Pi ----
if $INSTALL_PI; then
  if ! command -v pi >/dev/null 2>&1 && ! $FORCE; then
    say "Pi not detected on PATH. Skipping Pi install (use --force to install anyway, or --claude-only to silence this)."
    echo
  else
    SRC_PI_PROMPTS="$REPO_DIR/pi/prompts"
    SRC_PI_SKILLS="$REPO_DIR/pi/skills"
    DEST_PI_PROMPTS="$HOME/.pi/agent/prompts"
    DEST_PI_SKILLS="$HOME/.pi/agent/skills"

    say "Pi destination: $HOME/.pi/agent/"
    do_cmd "mkdir -p '$DEST_PI_PROMPTS' '$DEST_PI_SKILLS'"

    echo "Pi prompt templates:"
    for f in "$SRC_PI_PROMPTS"/*.md; do
      install_one "$f" "$DEST_PI_PROMPTS"
    done

    echo
    echo "Pi skills:"
    for d in "$SRC_PI_SKILLS"/*/; do
      install_one "${d%/}" "$DEST_PI_SKILLS"
    done

    if $WITH_DOMAIN_SKILLS; then
      SRC_DOMAIN_PI="$REPO_DIR/domain-skills/pi"
      if [[ -d "$SRC_DOMAIN_PI" ]]; then
        echo
        echo "Pi domain skills:"
        for entry in "$SRC_DOMAIN_PI"/*; do
          [[ -e "$entry" ]] && install_one "$entry" "$DEST_PI_SKILLS"
        done
      fi
    fi

    echo
    say "Heads up: Pi's ~/.pi/agent/AGENTS.md is NOT overwritten automatically."
    say "Append the workflow section from 'pi/AGENTS.workflow-section.md' manually."
    echo
  fi
fi

say "Done."
if $INSTALL_CLAUDE; then
  say "Claude: start a fresh session. Slash commands: /groundwork /first-principles /research /plan /implement /compact /oneshot"
fi
if $INSTALL_PI; then
  say "Pi: start a fresh session. Slash commands: /research /plan /implement /oneshot (Pi has its own /compact native)"
  say "Pi: sub-agent skills available as /skill:codebase-locator, /skill:codebase-analyzer, /skill:codebase-pattern-finder"
fi
