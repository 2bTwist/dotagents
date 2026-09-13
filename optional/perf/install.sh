#!/usr/bin/env bash
# Optional package: perf.
#
# SOURCED by install.sh's install_optional(), never executed, so harness_skill_dest
# and the do_* writers are in scope and --dry-run is enforced in one place.
#
# Two plain skills, no hooks or commands, so placement follows the run's mode
# exactly like a skill in skills/ would.

optional_install() {
  local pkgdir="$1" name src dest
  for src in "$pkgdir"/skills/*/; do
    name="$(basename "$src")"
    dest="$(harness_skill_dest "$name")"
    info "  skill -> $dest"
    $LIST_ONLY && continue
    if [ -e "$dest" ] && ! $FORCE; then
      info "  skip $name (exists, use --force)"
      continue
    fi
    do_rm "$dest"
    if [ "$MODE" = "symlink" ]; then do_symlink "${src%/}" "$dest"; else do_copy "${src%/}" "$dest"; fi
  done
}
