#!/usr/bin/env bash
#
# Shared helpers for install.d/<harness>.sh adapters.
# Sourced by install.sh. Never run directly.

# --- output ------------------------------------------------------------------

say()  { printf '%s\n' "$*"; }
info() { printf '  %s\n' "$*"; }
warn() { printf '  warn  %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

# --- filesystem --------------------------------------------------------------
# Every write goes through these, so --dry-run is enforced in one place.

do_mkdir() {
  if $DRY_RUN; then return 0; fi
  mkdir -p "$1"
}

do_rm() {
  if $DRY_RUN; then return 0; fi
  rm -rf "$1"
}

# do_write <dest-path>  (content on stdin)
do_write() {
  local dest="$1"
  if $DRY_RUN; then cat >/dev/null; return 0; fi
  do_mkdir "$(dirname "$dest")"
  cat >"$dest"
}

# do_copy <src> <dest>
do_copy() {
  if $DRY_RUN; then return 0; fi
  do_mkdir "$(dirname "$2")"
  cp -R "$1" "$2"
}

# do_symlink <src> <dest>
do_symlink() {
  if $DRY_RUN; then return 0; fi
  do_mkdir "$(dirname "$2")"
  ln -s "$1" "$2"
}

# --- frontmatter -------------------------------------------------------------

# frontmatter_field <file> <key>
# Echoes the scalar value of a top-level frontmatter key, or nothing.
frontmatter_field() {
  awk -v key="$2" '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---"  { exit }
    infm {
      if ($0 ~ "^" key ":") { sub("^" key ":[ \t]*", ""); print; exit }
    }
  ' "$1"
}

# harness_caps_of <file> <requires|degrades>
# Echoes space-separated capability names from the skill's `harness:` block.
harness_caps_of() {
  awk -v want="$2" '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---"  { exit }
    infm && /^harness:/ { inh=1; next }
    inh && /^[^ \t]/    { inh=0 }
    inh {
      line=$0
      sub(/^[ \t]+/, "", line)
      if (line ~ "^" want ":") {
        sub("^" want ":[ \t]*\\[", "", line)
        sub(/\].*$/, "", line)
        gsub(/,/, " ", line)
        print line
        exit
      }
    }
  ' "$1"
}

# strip_frontmatter_keys <file> <key>...
# Emits the file with the named top-level frontmatter keys removed, including
# any indented block that belongs to them. Body is passed through untouched.
strip_frontmatter_keys() {
  local file="$1"; shift
  local drop="$*"
  awk -v drop="$drop" '
    BEGIN { n=split(drop, d, " "); for (i=1;i<=n;i++) kill[d[i]]=1 }
    NR==1 && $0=="---" { infm=1; print; next }
    infm && $0=="---"  { infm=0; skip=0; print; next }
    infm {
      if ($0 ~ /^[^ \t]+:/) {
        key=$0; sub(/:.*$/, "", key)
        skip = (key in kill) ? 1 : 0
      } else if (skip && $0 ~ /^[ \t]/) {
        next          # indented continuation of a dropped key
      } else if ($0 !~ /^[ \t]/) {
        skip=0
      }
      if (skip) next
    }
    { print }
  ' "$file"
}

# --- capability gate ---------------------------------------------------------

# caps_satisfied <have-caps> <need-caps>
# Returns 0 if every needed capability is present. Echoes the missing ones.
caps_satisfied() {
  local have=" $1 " need="$2" missing=""
  local c
  for c in $need; do
    case "$have" in
      *" $c "*) ;;
      *) missing="$missing $c" ;;
    esac
  done
  if [ -n "$missing" ]; then
    printf '%s' "${missing# }"
    return 1
  fi
  return 0
}

# --- managed block -----------------------------------------------------------

MANAGED_BEGIN='<!-- BEGIN dotagents (managed) - edits below are overwritten on install -->'
MANAGED_END='<!-- END dotagents -->'

# write_managed_block <target-file> <content-file>
# Replaces only the region between the markers. Content outside is preserved.
# Appends the block when the file has no markers yet.
write_managed_block() {
  local target="$1" content="$2"
  local tmp; tmp="$(mktemp)"

  if [ -f "$target" ] && grep -qF "$MANAGED_BEGIN" "$target"; then
    awk -v b="$MANAGED_BEGIN" -v e="$MANAGED_END" -v cf="$content" '
      $0 == b { print; while ((getline line < cf) > 0) print line; close(cf); inb=1; next }
      $0 == e { inb=0; print; next }
      !inb    { print }
    ' "$target" >"$tmp"
  else
    { [ -f "$target" ] && { cat "$target"; printf '\n'; }
      printf '%s\n' "$MANAGED_BEGIN"
      cat "$content"
      printf '%s\n' "$MANAGED_END"
    } >"$tmp"
  fi

  if $DRY_RUN; then rm -f "$tmp"; return 0; fi
  do_mkdir "$(dirname "$target")"
  mv "$tmp" "$target"
}
