#!/usr/bin/env bash
# Adapter: generic AGENTS.md consumer (Cursor, Amp, opencode, Zed, ...)
# Writes into a directory you name with --dest. Assumes nothing beyond
# "reads AGENTS.md and a skills/ directory".
#
# HARNESS_* are the adapter contract: install.sh sources this file and reads them.
# shellcheck disable=SC2034

HARNESS_NAME="generic AGENTS.md"
HARNESS_CAPS=""

HARNESS_DROP_KEYS="harness model disable-model-invocation tools"

harness_detect() {
  # Not machine-detectable: it is wherever you point it.
  [ -n "${DEST:-}" ]
}

harness_root() {
  [ -n "${DEST:-}" ] || die "--target=agents requires --dest=<path>"
  printf '%s' "$DEST"
}

harness_skills_dir() { printf '%s' "$(harness_root)/skills"; }
harness_skill_dest() { printf '%s' "$(harness_root)/skills/$1"; }

harness_agent_install() {
  local src="$1" name dest
  name="$(basename "$src" .md)"
  dest="$(harness_root)/skills/$name/SKILL.md"

  if [ -e "$dest" ] && ! $FORCE; then
    info "skip  $name (exists, use --force)"
    return 0
  fi
  [ -e "$(dirname "$dest")" ] && do_rm "$(dirname "$dest")"

  strip_frontmatter_keys "$src" $HARNESS_DROP_KEYS | do_write "$dest"
  info "agent $name (demoted to skill: no sub-agent concept assumed)"
}

harness_instructions_dest() { printf '%s' "$(harness_root)/AGENTS.md"; }
