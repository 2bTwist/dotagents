#!/usr/bin/env bash
# Adapter: Pi (~/.pi/agent)
# Skills only. No sub-agent concept, so agents are demoted to user-invoked skills.
#
# HARNESS_* are the adapter contract: install.sh sources this file and reads them.
# shellcheck disable=SC2034

HARNESS_NAME="Pi"
HARNESS_CAPS=""

HARNESS_DROP_KEYS="harness model disable-model-invocation tools"

harness_detect() {
  command -v pi >/dev/null 2>&1 || [ -d "$HOME/.pi/agent" ]
}

harness_root()       { printf '%s' "$HOME/.pi/agent"; }

# Deliberately NOT ~/.agents/skills. Pi auto-loads both, and that directory was
# emptied on purpose to keep Pi's system prompt small. Writing there would
# silently undo that.
harness_skills_dir() { printf '%s' "$HOME/.pi/agent/skills"; }
harness_skill_dest() { printf '%s' "$HOME/.pi/agent/skills/$1"; }

# No sub-agents: an agent becomes a skill the user invokes directly.
harness_agent_install() {
  local src="$1" name dest
  name="$(basename "$src" .md)"
  dest="$HOME/.pi/agent/skills/$name/SKILL.md"

  if [ -e "$dest" ] && ! $FORCE; then
    info "skip  $name (exists, use --force)"
    return 0
  fi
  [ -e "$(dirname "$dest")" ] && do_rm "$(dirname "$dest")"

  strip_frontmatter_keys "$src" $HARNESS_DROP_KEYS | do_write "$dest"
  info "agent $name (demoted to skill: Pi has no sub-agents)"
}

harness_instructions_dest() { printf '%s' "$HOME/.pi/agent/AGENTS.md"; }
