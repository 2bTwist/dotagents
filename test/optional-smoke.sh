#!/usr/bin/env bash
#
# optional-smoke.sh — optional-package installer contract smoke test.
#
# Verifies the "optional packages" requirement (Phase 5) against ./install.sh,
# independent of how install_optional() implements it. The concrete package
# under test is optional/autoresearch, which requires the capabilities
# `hooks` and `slash-commands`. Of the four harnesses, only Claude Code
# declares both (see install.d/claude.sh), so it is the sole satisfying
# target; codex, pi, and agents each fail the gate.
#
# Contract asserted here (see install.sh's `install_optional` and the
# optional-package requirement in the repo's task description):
#   1. Without --with-optional, no autoresearch file lands under any target's
#      root, for all four targets.
#   2. With --with-optional, a target lacking a required capability installs
#      zero autoresearch files anywhere under its root, and stdout names the
#      package and the missing capability.
#   3. With --with-optional, the satisfying target (claude) installs all
#      three components (skill, slash command, hook), each non-empty.
#   4. The hook is executable after install.
#   5. The hook is a real file, never a symlink, even under --symlink, byte-
#      identical to the repo's copy, and still executable.
#   6. --with-optional --dry-run against the satisfying target writes nothing
#      (tree hash unchanged) yet names all three components in its output.
#   7. optional/autoresearch/UPSTREAM.md exists and records the upstream repo
#      and a real-looking commit SHA (hex, >=7 chars, not a placeholder).
#   8. optional/autoresearch/PACKAGE exists, declares required capabilities,
#      and every capability named is one of the five the repo defines.
#   9. Two consecutive --with-optional installs into the same HOME both exit
#      0 and leave the target's autoresearch files byte-identical.
#  10. Every install run this script performs exits 0 (checked inline by
#      run_installer, tagged [#10], output printed on failure).
#
# Companion to install-smoke.sh and instructions-smoke.sh; this file covers
# optional/ packages only and does not repeat their assertions.
#
# Written for bash 3.2 (macOS's stock /bin/bash, which this script's
# `#!/usr/bin/env bash` shebang resolves to on a machine with no newer bash on
# PATH). That means: no associative arrays, no `mapfile`/`readarray`, and
# every `"${arr[@]}"` expansion is guarded with a `${#arr[@]} -gt 0` check,
# because bash <4.4 treats expanding an empty array under `set -u` as an
# unbound-variable error.
#
# Usage:
#   ./test/optional-smoke.sh
#
set -uo pipefail

# ---------------------------------------------------------------------------
# Paths and prerequisites
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALLER="$REPO_ROOT/install.sh"
PKG_NAME="autoresearch"
PKG_DIR="$REPO_ROOT/optional/$PKG_NAME"
PACKAGE_FILE="$PKG_DIR/PACKAGE"
UPSTREAM_FILE="$PKG_DIR/UPSTREAM.md"
SRC_SKILL_MD="$PKG_DIR/skills/$PKG_NAME/SKILL.md"
SRC_COMMAND_MD="$PKG_DIR/commands/$PKG_NAME.md"
SRC_HOOK_SH="$PKG_DIR/hooks/$PKG_NAME-context.sh"

PASS=0
FAIL=0
GROUP="init"

group() {
  GROUP="$1"
  echo
  echo "== $1 =="
}

pass() {
  PASS=$((PASS + 1))
  echo "PASS [$GROUP] $*"
}

fail() {
  FAIL=$((FAIL + 1))
  echo "FAIL [$GROUP] $*"
}

die() {
  echo "ABORT: $*" >&2
  exit 2
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required tool '$1' not found on PATH"
}

need_cmd find
need_cmd grep
need_cmd cmp
need_cmd shasum
need_cmd wc

[[ -f "$INSTALLER" ]] || die "installer not found at $INSTALLER"

# ---------------------------------------------------------------------------
# Safety: never touch the real HOME. Every HOME/dest we hand the installer
# lives under our own mktemp root, checked before every use.
# ---------------------------------------------------------------------------

REAL_HOME="${HOME:-}"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/optional-smoke.XXXXXX")" || die "mktemp failed"
# shellcheck disable=SC2329  # invoked indirectly via `trap ... EXIT` below
cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

assert_safe_dir() {
  local d="$1"
  if [[ -z "$d" || "$d" == "/" || "$d" == "$REAL_HOME" ]]; then
    die "refusing to use unsafe directory '$d' as a test HOME/dest"
  fi
  case "$d" in
    "$TMP_ROOT"/*) : ;;
    *) die "refusing to use directory '$d' outside test tmp root '$TMP_ROOT'" ;;
  esac
}

new_home() {
  local d
  d="$(mktemp -d "$TMP_ROOT/home.XXXXXX")" || die "mktemp failed"
  assert_safe_dir "$d"
  printf '%s' "$d"
}

new_dest() {
  local d
  d="$(mktemp -d "$TMP_ROOT/dest.XXXXXX")" || die "mktemp failed"
  assert_safe_dir "$d"
  printf '%s' "$d"
}

# ---------------------------------------------------------------------------
# Ground truth encoded directly from the requirement and from install.d/*.sh
# (transcribed, not sourced at runtime -- same convention install-smoke.sh
# and instructions-smoke.sh use: expected behavior is encoded from the
# adapter source/requirement, not learned by calling into the installer).
# ---------------------------------------------------------------------------

VALID_CAPS="subagents claude-transcripts mcp-browser hooks slash-commands"
REQUIRED_CAPS="hooks slash-commands"

ALL_TARGETS=(claude codex pi agents)
SATISFYING_TARGETS=(claude)
FAILING_TARGETS=(codex pi agents)

target_caps() {
  case "$1" in
    claude) printf '%s' "subagents claude-transcripts mcp-browser hooks slash-commands" ;;
    codex) printf '%s' "subagents slash-commands" ;;
    pi) printf '%s' "" ;;
    agents) printf '%s' "" ;;
  esac
}

caps_has() {
  local caps="$1" want="$2" c
  for c in $caps; do
    [[ "$c" == "$want" ]] && return 0
  done
  return 1
}

cap_is_valid() {
  local c="$1" v
  for v in $VALID_CAPS; do
    [[ "$v" == "$c" ]] && return 0
  done
  return 1
}

# missing_caps_for TARGET -> space-separated REQUIRED_CAPS the target lacks.
missing_caps_for() {
  local target="$1" caps missing="" c
  caps="$(target_caps "$target")"
  for c in $REQUIRED_CAPS; do
    caps_has "$caps" "$c" || missing="$missing $c"
  done
  printf '%s' "${missing# }"
}

# root_path TARGET HOME DEST -> harness_root() for TARGET, transcribed from
# each install.d/<target>.sh.
root_path() {
  local target="$1" home="$2" dest="$3"
  case "$target" in
    claude) printf '%s/.claude' "$home" ;;
    codex) printf '%s/.codex' "$home" ;;
    pi) printf '%s/.pi/agent' "$home" ;;
    agents) printf '%s' "$dest" ;;
  esac
}

# The three Claude Code component destinations. Claude's skills dir is
# harness_skill_dest() = $HOME/.claude/skills/<name>; slash commands and
# hooks are Claude Code's own conventional subdirectories directly under
# harness_root() ($HOME/.claude/commands, $HOME/.claude/hooks). No adapter
# function exists yet for the latter two (the feature is unimplemented), so
# these are the destinations to be derived by the implementation, not read
# from it.
claude_skill_md() { printf '%s/.claude/skills/%s/SKILL.md' "$1" "$PKG_NAME"; }
claude_command_md() { printf '%s/.claude/commands/%s.md' "$1" "$PKG_NAME"; }
claude_hook_sh() { printf '%s/.claude/hooks/%s-context.sh' "$1" "$PKG_NAME"; }

# autoresearch_file_count ROOT -> count of any path under ROOT whose name
# mentions the package, case-insensitively. Deliberately broad (not tied to
# the three specific destinations above) so the opt-in and negative-gate
# checks catch a leak to *any* path, not just the ones this script predicts.
autoresearch_file_count() {
  local root="$1"
  [[ -d "$root" ]] || { printf '0'; return; }
  find "$root" -iname "*${PKG_NAME}*" 2>/dev/null | wc -l | tr -d ' '
}

snapshot_tree() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    printf 'NO_SUCH_DIR'
    return
  fi
  {
    find "$dir" -mindepth 1 \( -type d -o -type f \) 2>/dev/null | sort
    find "$dir" -type f -print0 2>/dev/null | sort -z | xargs -0 shasum -a 256 2>/dev/null
  } | shasum -a 256 | awk '{print $1}'
}

# run_installer TARGET HOME DEST [EXTRA_ARGS...] -> sets RC and OUT globals,
# and asserts [#10] the run exited 0 (output printed on failure).
run_installer() {
  local target="$1" home="$2" dest="$3"
  shift 3
  local cmd=(bash "$INSTALLER" "--target=$target")
  if [[ "$target" == "agents" ]]; then
    cmd+=("--dest=$dest")
  fi
  if [[ $# -gt 0 ]]; then
    cmd+=("$@")
  fi
  OUT="$(cd "$REPO_ROOT" && HOME="$home" "${cmd[@]}" 2>&1)"
  RC=$?

  local label="$target $*"
  if [[ "$RC" -eq 0 ]]; then
    pass "[#10] install run exits 0 ($label)"
  else
    fail "[#10] install run exits 0 ($label) (expected 0, got $RC; output: $OUT)"
  fi
}

# ---------------------------------------------------------------------------
# [#7] Provenance: optional/autoresearch/UPSTREAM.md
# ---------------------------------------------------------------------------

group "provenance"

if [[ -s "$UPSTREAM_FILE" ]]; then
  pass "[#7] $UPSTREAM_FILE exists and is non-empty"

  if grep -qiE 'github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' "$UPSTREAM_FILE"; then
    pass "[#7] UPSTREAM.md records an upstream repository (github.com/<owner>/<repo> reference)"
  else
    fail "[#7] UPSTREAM.md records an upstream repository (expected a github.com/<owner>/<repo> reference, found none)"
  fi

  # Extract hex tokens of at least 7 chars and reject placeholders: a
  # commit-shaped token whose characters are all the same (0000000, fffffff,
  # xxxxxxx-as-hex is impossible since x isn't hex, but 0000000/aaaaaaa are)
  # is not a real vendored commit.
  candidates=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && candidates+=("$line")
  done < <(grep -oE '\b[0-9a-f]{7,40}\b' "$UPSTREAM_FILE" 2>/dev/null)

  real_sha=""
  if [[ ${#candidates[@]} -gt 0 ]]; then
    for c in "${candidates[@]}"; do
      if [[ ! "$c" =~ ^(.)\1+$ ]]; then
        real_sha="$c"
        break
      fi
    done
  fi

  if [[ -n "$real_sha" ]]; then
    pass "[#7] UPSTREAM.md records a real-looking commit SHA ($real_sha)"
  else
    fail "[#7] UPSTREAM.md records a real-looking commit SHA (expected a >=7-char hex token that is not a same-character placeholder, found none in: $(tr '\n' '|' <"$UPSTREAM_FILE" 2>/dev/null || true))"
  fi
else
  fail "[#7] $UPSTREAM_FILE exists and is non-empty (missing or empty)"
  fail "[#7] UPSTREAM.md records an upstream repository (cannot check: file missing)"
  fail "[#7] UPSTREAM.md records a real-looking commit SHA (cannot check: file missing)"
fi

# ---------------------------------------------------------------------------
# [#8] Package declaration: optional/autoresearch/PACKAGE
# ---------------------------------------------------------------------------

group "package-declaration"

if [[ -s "$PACKAGE_FILE" ]]; then
  pass "[#8] $PACKAGE_FILE exists and is non-empty"

  declared_raw="$(grep -E '^requires:' "$PACKAGE_FILE" 2>/dev/null | sed 's/^requires:[ ]*//' | head -1)"
  # Tolerate either bracketed/comma-separated or bare-space-separated forms.
  declared_clean="$(printf '%s' "$declared_raw" | tr -d '[],')"

  declared_caps=()
  for c in $declared_clean; do
    declared_caps+=("$c")
  done

  if [[ ${#declared_caps[@]} -gt 0 ]]; then
    pass "[#8] PACKAGE declares a non-empty 'requires:' capability list (${declared_caps[*]})"
  else
    fail "[#8] PACKAGE declares a non-empty 'requires:' capability list (expected a 'requires:' line naming at least one capability, got: '$declared_raw')"
  fi

  bad_declared=()
  if [[ ${#declared_caps[@]} -gt 0 ]]; then
    for c in "${declared_caps[@]}"; do
      cap_is_valid "$c" || bad_declared+=("$c")
    done
  fi
  if [[ ${#declared_caps[@]} -gt 0 && ${#bad_declared[@]} -eq 0 ]]; then
    pass "[#8] every capability PACKAGE declares is in the valid set ($VALID_CAPS)"
  else
    fail "[#8] every capability PACKAGE declares is in the valid set (expected subset of [$VALID_CAPS], got: '${declared_raw}'${bad_declared[0]:+, unknown: ${bad_declared[*]}})"
  fi
else
  fail "[#8] $PACKAGE_FILE exists and is non-empty (missing or empty)"
  fail "[#8] PACKAGE declares a non-empty 'requires:' capability list (cannot check: file missing)"
  fail "[#8] every capability PACKAGE declares is in the valid set (cannot check: file missing)"
fi

# ---------------------------------------------------------------------------
# [#1] Opt-in: without --with-optional, no autoresearch file anywhere, for
# every target.
# ---------------------------------------------------------------------------

group "opt-in"

for target in "${ALL_TARGETS[@]}"; do
  home="$(new_home)"
  dest=""
  [[ "$target" == "agents" ]] && dest="$(new_dest)"

  run_installer "$target" "$home" "$dest"

  root="$(root_path "$target" "$home" "$dest")"
  n="$(autoresearch_file_count "$root")"
  if [[ "$n" -eq 0 ]]; then
    pass "[#1] $target: no autoresearch file under root without --with-optional"
  else
    fail "[#1] $target: no autoresearch file under root without --with-optional (expected 0, found $n under $root)"
  fi
done

# ---------------------------------------------------------------------------
# [#2] Capability gate, negative: targets lacking a required capability
# install zero autoresearch files, and stdout names the package + missing cap.
# ---------------------------------------------------------------------------

group "capability-gate-negative"

for target in "${FAILING_TARGETS[@]}"; do
  home="$(new_home)"
  dest=""
  [[ "$target" == "agents" ]] && dest="$(new_dest)"

  run_installer "$target" "$home" "$dest" --with-optional
  out="$OUT"

  root="$(root_path "$target" "$home" "$dest")"
  n="$(autoresearch_file_count "$root")"
  if [[ "$n" -eq 0 ]]; then
    pass "[#2] $target: --with-optional installs zero autoresearch files (missing capability)"
  else
    fail "[#2] $target: --with-optional installs zero autoresearch files (expected 0, found $n under $root)"
  fi

  missing="$(missing_caps_for "$target")"
  named=0
  for cap in $missing; do
    if printf '%s\n' "$out" | grep -F -- "$PKG_NAME" | grep -qF -- "$cap"; then
      named=1
    fi
  done
  if [[ "$named" -eq 1 ]]; then
    pass "[#2] $target: installer output names '$PKG_NAME' and its missing capability ($missing)"
  else
    fail "[#2] $target: installer output names '$PKG_NAME' and its missing capability (expected a line mentioning '$PKG_NAME' and one of [$missing], got: $(printf '%s' "$out" | tail -10 | tr '\n' '|'))"
  fi
done

# ---------------------------------------------------------------------------
# [#3]/[#4] Capability gate, positive + hook executable: the satisfying
# target installs all three components, each non-empty; hook is executable.
# ---------------------------------------------------------------------------

group "capability-gate-positive"

for target in "${SATISFYING_TARGETS[@]}"; do
  home="$(new_home)"

  run_installer "$target" "$home" "" --with-optional

  skill_md="$(claude_skill_md "$home")"
  command_md="$(claude_command_md "$home")"
  hook_sh="$(claude_hook_sh "$home")"

  if [[ -s "$skill_md" ]]; then
    pass "[#3] $target: skill component installed and non-empty ($skill_md)"
  else
    fail "[#3] $target: skill component installed and non-empty (expected non-empty file at $skill_md, got $( [[ -e "$skill_md" ]] && echo 'empty file' || echo 'missing' ))"
  fi
  if [[ -f "$SRC_SKILL_MD" && -f "$skill_md" ]] && cmp -s "$SRC_SKILL_MD" "$skill_md"; then
    pass "[#3] $target: installed skill content is byte-identical to the repo's copy"
  else
    fail "[#3] $target: installed skill content is byte-identical to the repo's copy (expected cmp -s $SRC_SKILL_MD $skill_md to succeed)"
  fi

  if [[ -s "$command_md" ]]; then
    pass "[#3] $target: slash-command component installed and non-empty ($command_md)"
  else
    fail "[#3] $target: slash-command component installed and non-empty (expected non-empty file at $command_md, got $( [[ -e "$command_md" ]] && echo 'empty file' || echo 'missing' ))"
  fi
  if [[ -f "$SRC_COMMAND_MD" && -f "$command_md" ]] && cmp -s "$SRC_COMMAND_MD" "$command_md"; then
    pass "[#3] $target: installed slash-command content is byte-identical to the repo's copy"
  else
    fail "[#3] $target: installed slash-command content is byte-identical to the repo's copy (expected cmp -s $SRC_COMMAND_MD $command_md to succeed)"
  fi

  if [[ -s "$hook_sh" ]]; then
    pass "[#3] $target: hook component installed and non-empty ($hook_sh)"
  else
    fail "[#3] $target: hook component installed and non-empty (expected non-empty file at $hook_sh, got $( [[ -e "$hook_sh" ]] && echo 'empty file' || echo 'missing' ))"
  fi

  if [[ -e "$hook_sh" && -x "$hook_sh" ]]; then
    pass "[#4] $target: hook is executable after install ($hook_sh)"
  else
    fail "[#4] $target: hook is executable after install (expected -x on $hook_sh, got $( [[ -e "$hook_sh" ]] && echo 'not executable' || echo 'missing' ))"
  fi
done

# ---------------------------------------------------------------------------
# [#5] Symlink mode: the hook is always a real file, never a symlink, byte-
# identical to the repo's copy, and still executable.
# ---------------------------------------------------------------------------

group "symlink-mode"

for target in "${SATISFYING_TARGETS[@]}"; do
  home="$(new_home)"

  run_installer "$target" "$home" "" --with-optional --symlink

  hook_sh="$(claude_hook_sh "$home")"

  if [[ -e "$hook_sh" && ! -L "$hook_sh" && -f "$hook_sh" ]]; then
    pass "[#5] $target: hook is a regular file, not a symlink, under --symlink ($hook_sh)"
  else
    hook_state="missing"
    if [[ -L "$hook_sh" ]]; then
      hook_state="symlink"
    elif [[ -e "$hook_sh" ]]; then
      hook_state="exists but not a regular file"
    fi
    fail "[#5] $target: hook is a regular file, not a symlink, under --symlink (expected regular file at $hook_sh, got $hook_state)"
  fi

  if [[ -f "$SRC_HOOK_SH" && -e "$hook_sh" && ! -L "$hook_sh" ]] && cmp -s "$SRC_HOOK_SH" "$hook_sh"; then
    pass "[#5] $target: hook content is byte-identical to the repo's copy under --symlink"
  else
    fail "[#5] $target: hook content is byte-identical to the repo's copy under --symlink (expected cmp -s $SRC_HOOK_SH $hook_sh to succeed)"
  fi

  if [[ -e "$hook_sh" && -x "$hook_sh" ]]; then
    pass "[#5] $target: hook is still executable under --symlink"
  else
    fail "[#5] $target: hook is still executable under --symlink (expected -x on $hook_sh)"
  fi
done

# ---------------------------------------------------------------------------
# [#6] Dry run: --with-optional --dry-run writes nothing yet still reports
# every component it would install.
# ---------------------------------------------------------------------------

group "dry-run"

for target in "${SATISFYING_TARGETS[@]}"; do
  home="$(new_home)"
  before="$(snapshot_tree "$home")"

  run_installer "$target" "$home" "" --with-optional --dry-run
  out="$OUT"

  after="$(snapshot_tree "$home")"

  if [[ "$before" == "$after" ]]; then
    pass "[#6] $target: --with-optional --dry-run writes nothing (tree hash unchanged)"
  else
    fail "[#6] $target: --with-optional --dry-run writes nothing (expected hash $before, got $after)"
  fi

  skill_md="$(claude_skill_md "$home")"
  command_md="$(claude_command_md "$home")"
  hook_sh="$(claude_hook_sh "$home")"
  if [[ ! -e "$skill_md" && ! -e "$command_md" && ! -e "$hook_sh" ]]; then
    pass "[#6] $target: --with-optional --dry-run creates none of the three component files"
  else
    fail "[#6] $target: --with-optional --dry-run creates none of the three component files (found one or more of: $skill_md $command_md $hook_sh)"
  fi

  # "Reports every component" is asserted as: among the output LINES that
  # mention the package name, each of the three component-kind keywords
  # (skill, command/slash-command, hook) appears on at least one such line.
  # Restricting the keyword search to package-mentioning lines (rather than
  # the whole output) matters: the installer's own generic banner line
  # ("capabilities: subagents claude-transcripts mcp-browser hooks
  # slash-commands") and the unrelated "skill <name>" lines for the repo's
  # real skills already contain "hook"/"command"/"skill" substrings, so an
  # unanchored search would pass even with zero autoresearch-specific
  # reporting. This does not assume exact wording or exact paths, only that
  # a reader of the dry-run output can tell all three components -- not just
  # the package as a whole -- would have been installed.
  pkg_lines="$(printf '%s\n' "$out" | grep -iF -- "$PKG_NAME" || true)"
  mentions_pkg=0
  [[ -n "$pkg_lines" ]] && mentions_pkg=1

  mentions_skill=0
  printf '%s' "$pkg_lines" | grep -qiE 'skill' && mentions_skill=1
  mentions_command=0
  printf '%s' "$pkg_lines" | grep -qiE 'command|slash' && mentions_command=1
  mentions_hook=0
  printf '%s' "$pkg_lines" | grep -qiE 'hook' && mentions_hook=1

  if [[ "$mentions_pkg" -eq 1 && "$mentions_skill" -eq 1 && "$mentions_command" -eq 1 && "$mentions_hook" -eq 1 ]]; then
    pass "[#6] $target: dry-run output names the package and all three component kinds (skill, command, hook)"
  else
    fail "[#6] $target: dry-run output names the package and all three component kinds (skill, command, hook) (pkg=$mentions_pkg skill=$mentions_skill command=$mentions_command hook=$mentions_hook; output: $(printf '%s' "$out" | tr '\n' '|'))"
  fi
done

# ---------------------------------------------------------------------------
# [#9] Idempotence: two consecutive --with-optional installs into the same
# HOME both exit 0 (via run_installer's [#10] check) and leave the target's
# autoresearch files byte-identical. Content is hashed, not just the tree
# shape, and each file's existence/non-emptiness is re-checked after both
# runs so a still-missing feature fails here rather than passing by
# coincidence.
# ---------------------------------------------------------------------------

group "idempotence"

for target in "${SATISFYING_TARGETS[@]}"; do
  home="$(new_home)"

  run_installer "$target" "$home" "" --with-optional

  skill_md="$(claude_skill_md "$home")"
  command_md="$(claude_command_md "$home")"
  hook_sh="$(claude_hook_sh "$home")"

  sum_before=""
  if [[ -s "$skill_md" && -s "$command_md" && -s "$hook_sh" ]]; then
    sum_before="$( { shasum -a 256 "$skill_md" "$command_md" "$hook_sh" 2>/dev/null; } | shasum -a 256 | awk '{print $1}')"
  fi

  run_installer "$target" "$home" "" --with-optional

  sum_after=""
  if [[ -s "$skill_md" && -s "$command_md" && -s "$hook_sh" ]]; then
    sum_after="$( { shasum -a 256 "$skill_md" "$command_md" "$hook_sh" 2>/dev/null; } | shasum -a 256 | awk '{print $1}')"
  fi

  if [[ -n "$sum_before" && -n "$sum_after" && "$sum_before" == "$sum_after" ]]; then
    pass "[#9] $target: two consecutive --with-optional installs leave the three component files byte-identical"
  else
    fail "[#9] $target: two consecutive --with-optional installs leave the three component files byte-identical (before='$sum_before' after='$sum_after' -- empty means one or more files were missing/empty)"
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo
echo "== summary =="
echo "$PASS passed, $FAIL failed"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
