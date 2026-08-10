#!/usr/bin/env bash
# Adapter: Claude Code (~/.claude)
# Native skills and native sub-agents. The reference implementation.
#
# HARNESS_* are the adapter contract: install.sh sources this file and reads them.
# shellcheck disable=SC2034

HARNESS_NAME="Claude Code"
HARNESS_CAPS="subagents claude-transcripts mcp-browser hooks slash-commands"

# Frontmatter keys Claude Code does not understand. `harness:` is repo-only.
HARNESS_DROP_KEYS="harness"

harness_detect() {
  command -v claude >/dev/null 2>&1 || [ -d "$HOME/.claude" ]
}

harness_root()        { printf '%s' "$HOME/.claude"; }
harness_skills_dir()  { printf '%s' "$HOME/.claude/skills"; }
harness_skill_dest()  { printf '%s' "$HOME/.claude/skills/$1"; }

# Native sub-agents: markdown with frontmatter, copied as-is.
harness_agent_install() {
  local src="$1" name dest
  name="$(basename "$src")"
  dest="$HOME/.claude/agents/$name"

  if [ -e "$dest" ] && ! $FORCE; then
    info "skip  agents/$name (exists, use --force)"
    return 0
  fi
  [ -e "$dest" ] && do_rm "$dest"

  strip_frontmatter_keys "$src" $HARNESS_DROP_KEYS | do_write "$dest"
  info "agent $name"
}

harness_instructions_dest() { printf '%s' "$HOME/.claude/CLAUDE.md"; }
