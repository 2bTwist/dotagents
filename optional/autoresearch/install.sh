#!/usr/bin/env bash
# Optional package: autoresearch.
#
# SOURCED by install.sh's install_optional(), never executed. By the time this
# runs, the target's adapter is already in scope, so harness_root and
# harness_skill_dest resolve, and every write goes through the do_* helpers that
# enforce --dry-run in one place. Running this as a subprocess would lose all of
# that, which is why the package is a sourced function rather than a script.
#
# What makes this package harder than a skill: three components, three different
# destinations, and one of them must not follow --symlink.

optional_install() {
  local pkgdir="$1"
  local root skill_dest cmd_dest hook_dest

  root="$(harness_root)"
  skill_dest="$(harness_skill_dest autoresearch)"
  cmd_dest="$root/commands/autoresearch.md"
  hook_dest="$root/hooks/autoresearch-context.sh"

  # Named unconditionally, including under --dry-run and --list, so a plan run
  # shows every component rather than only the ones that happen to be missing.
  info "  skill   -> $skill_dest"
  info "  command -> $cmd_dest"
  info "  hook    -> $hook_dest"

  $LIST_ONLY && return 0

  autoresearch_place_dir  "$pkgdir/skills/autoresearch"          "$skill_dest" "skill"
  autoresearch_place_file "$pkgdir/commands/autoresearch.md"     "$cmd_dest"   "command"

  # The hook is ALWAYS copied, never linked, even when the run is in symlink
  # mode. Its absolute path gets written into settings.json, so a link into the
  # repo turns the loop into something that breaks silently the moment the
  # checkout moves or is deleted.
  if [ -e "$hook_dest" ] && ! $FORCE; then
    info "  skip hook (exists, use --force)"
  else
    do_rm "$hook_dest"
    do_copy "$pkgdir/hooks/autoresearch-context.sh" "$hook_dest"
    $DRY_RUN || chmod +x "$hook_dest"
  fi

  autoresearch_report_wiring "$root" "$hook_dest"
}

# Skill directory: follows the run's mode.
autoresearch_place_dir() {
  local src="$1" dest="$2" label="$3"
  if [ -e "$dest" ] && ! $FORCE; then
    info "  skip $label (exists, use --force)"
    return 0
  fi
  do_rm "$dest"
  if [ "$MODE" = "symlink" ]; then do_symlink "$src" "$dest"; else do_copy "$src" "$dest"; fi
}

# Single file: follows the run's mode.
autoresearch_place_file() {
  local src="$1" dest="$2" label="$3"
  if [ -e "$dest" ] && ! $FORCE; then
    info "  skip $label (exists, use --force)"
    return 0
  fi
  do_rm "$dest"
  if [ "$MODE" = "symlink" ]; then do_symlink "$src" "$dest"; else do_copy "$src" "$dest"; fi
}

# The one step the installer cannot do for you. Detect it rather than printing
# the same instruction at someone who already followed it.
autoresearch_report_wiring() {
  local root="$1" hook="$2"
  local settings="$root/settings.json"

  if [ -f "$settings" ] && grep -qF 'autoresearch-context.sh' "$settings"; then
    info "  hook already wired in $settings"
    return 0
  fi

  say ""
  say "   autoresearch needs one manual step. In $settings, under hooks.UserPromptSubmit:"
  say ""
  say "     { \"hooks\": [ { \"type\": \"command\", \"command\": \"$hook\" } ] }"
  say ""
  say "   Without it the loop has nothing sustaining it across turns."
}
