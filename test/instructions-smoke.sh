#!/usr/bin/env bash
#
# instructions-smoke.sh — shared-instructions installer contract smoke test.
#
# Verifies the "canonical instructions document, rendered into a managed
# region of each harness's instructions file" requirement, independent of how
# install.sh implements it:
#
#   - instructions/core.md is rendered once per harness into a delimited
#     managed region inside that harness's instructions file.
#   - Hand-written content outside the region survives every reinstall.
#   - The managed region is authoritative: hand-edits inside it are clobbered
#     back to the canonical content on the next install.
#   - Each harness's instructions/preamble/<target>.md is seeded once,
#     outside the managed region, and left alone thereafter.
#   - --dry-run writes nothing, including the reference documents below.
#   - Every install also places the repo's instructions/references/*.md
#     documents under the harness's own root, byte-identical.
#   - instructions/core.md and every instructions/preamble/*.md are
#     publishable: no maintainer-specific identifiers or machine paths.
#     instructions/references/*.local.md is git-ignored (that's where the
#     machine-specific detail is meant to live instead).
#   - Durable corrections follow one explicit storage hierarchy: architecture
#     and data structures; constraints and types; lint, tests, and CI; lean
#     AGENTS.md; curated local references or procedures; transcript only.
#     Task state is never treated as durable by default, the legacy broad
#     "Grow project memory" directive is gone, and memory-templates/ is no
#     longer an active source tree.
#   - Compacting durable task context is explicit-user-only. The compact skill
#     must not trigger itself at phase boundaries or from context-budget state.
#   - Every install run this script performs exits 0.
#
# Companion to install-smoke.sh (which covers skills/ and agents/); this file
# covers instructions/ only and does not repeat those assertions.
#
# Written for bash 3.2 (macOS's stock /bin/bash, which this script's
# `#!/usr/bin/env bash` shebang resolves to on a machine with no newer bash on
# PATH). That means: no associative arrays, no `mapfile`/`readarray`, and
# every `"${arr[@]}"` expansion is guarded with a `${#arr[@]} -gt 0` check,
# because bash <4.4 treats expanding an empty array under `set -u` as an
# unbound-variable error.
#
# Usage:
#   ./test/instructions-smoke.sh
#
set -uo pipefail

# ---------------------------------------------------------------------------
# Paths and prerequisites
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALLER="$REPO_ROOT/install.sh"
LIB_SH="$REPO_ROOT/install.d/_lib.sh"
CORE_MD="$REPO_ROOT/instructions/core.md"
COMPACT_MD="$REPO_ROOT/skills/compact/SKILL.md"
HIGH_RISK_MD="$REPO_ROOT/instructions/references/high-risk-engineering.md"

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

need_cmd awk
need_cmd grep
need_cmd sed
need_cmd cmp
need_cmd git
need_cmd shasum

[[ -f "$INSTALLER" ]] || die "installer not found at $INSTALLER"
[[ -f "$LIB_SH" ]] || die "shared lib not found at $LIB_SH"

# ---------------------------------------------------------------------------
# Managed-region markers, derived from install.d/_lib.sh (not copied), so a
# future change to the delimiter strings cannot silently desync this test
# from the installer.
# ---------------------------------------------------------------------------

MANAGED_BEGIN="$(grep -m1 '^MANAGED_BEGIN=' "$LIB_SH" | sed -E "s/^MANAGED_BEGIN='//; s/'\$//")"
MANAGED_END="$(grep -m1 '^MANAGED_END=' "$LIB_SH" | sed -E "s/^MANAGED_END='//; s/'\$//")"

[[ -n "$MANAGED_BEGIN" ]] || die "could not derive MANAGED_BEGIN from $LIB_SH"
[[ -n "$MANAGED_END" ]] || die "could not derive MANAGED_END from $LIB_SH"

# ---------------------------------------------------------------------------
# Safety: never touch the real HOME. Every HOME/dest we hand the installer
# lives under our own mktemp root, checked before every use.
# ---------------------------------------------------------------------------

REAL_HOME="${HOME:-}"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/instructions-smoke.XXXXXX")" || die "mktemp failed"
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

# run_installer TARGET HOME DEST [EXTRA_ARGS...] -> sets RC and OUT globals,
# and asserts [#12] that the run exited 0 (printing captured output on
# failure, since a crashing installer should be caught here directly rather
# than only inferred later from missing files).
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

  local mode="normal"
  [[ "$*" == *--dry-run* ]] && mode="dry-run"
  if [[ "$RC" -eq 0 ]]; then
    pass "[#12] $target: install run exits 0 ($mode, home=$home)"
  else
    fail "[#12] $target: install run exits 0 ($mode, home=$home) (expected 0, got $RC; output: $OUT)"
  fi
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

# ---------------------------------------------------------------------------
# Instructions-specific helpers
# ---------------------------------------------------------------------------

# instructions_dest_path TARGET HOME DEST -> path to the file receiving the
# managed block. Transcribed from each install.d/<target>.sh's
# harness_instructions_dest() definition (read once, not introspected at
# runtime) -- the same convention install-smoke.sh uses for its
# skill_dir_path()/agent_artifact_path() helpers: expected behavior is
# encoded from the requirement/adapter source, not learned by calling into
# the installer.
instructions_dest_path() {
  local target="$1" home="$2" dest="$3"
  case "$target" in
    claude) printf '%s/.claude/CLAUDE.md' "$home" ;;
    codex)  printf '%s/.codex/AGENTS.md' "$home" ;;
    pi)     printf '%s/.pi/agent/AGENTS.md' "$home" ;;
    agents) printf '%s/AGENTS.md' "$dest" ;;
  esac
}

# preamble_src_path TARGET -> canonical source of the harness's preamble.
preamble_src_path() { printf '%s/instructions/preamble/%s.md' "$REPO_ROOT" "$1"; }

# references_dir_path TARGET HOME DEST -> <harness-root>/references, per
# instructions/references/README.md ("the installer copies them to
# <harness-root>/references/"). Computed from each install.d/<target>.sh's
# harness_root() value directly (same transcribe-don't-introspect convention
# as instructions_dest_path), not derived from instructions_dest_path: the
# two happen to share a parent today for every target, but nothing enforces
# that, so this is kept as its own source of truth.
references_dir_path() {
  local target="$1" home="$2" dest="$3"
  case "$target" in
    claude) printf '%s/.claude/references' "$home" ;;
    codex)  printf '%s/.codex/references' "$home" ;;
    pi)     printf '%s/.pi/agent/references' "$home" ;;
    agents) printf '%s/references' "$dest" ;;
  esac
}

# marker_count FILE MARKER -> number of literal occurrences of MARKER in FILE.
marker_count() {
  local file="$1" marker="$2" n
  [[ -f "$file" ]] || { printf '0'; return; }
  n="$(grep -cF -- "$marker" "$file" 2>/dev/null)"
  printf '%s' "${n:-0}"
}

# extract_managed_block FILE -> lines strictly between the BEGIN/END marker
# lines (exclusive), or nothing if the markers are absent.
extract_managed_block() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  awk -v b="$MANAGED_BEGIN" -v e="$MANAGED_END" '
    $0 == b { inb=1; next }
    $0 == e { inb=0; next }
    inb { print }
  ' "$file"
}

# marker_line FILE MARKER -> 1-based line number of the (first) literal
# occurrence of MARKER in FILE, or 0 if absent.
marker_line() {
  local file="$1" marker="$2" n
  [[ -f "$file" ]] || { printf '0'; return; }
  n="$(awk -v m="$marker" '$0==m{print NR; exit}' "$file")"
  printf '%s' "${n:-0}"
}

# line_number_of FILE TEXT -> 1-based line number of the first line of FILE
# that equals TEXT exactly, or 0 if absent.
line_number_of() {
  local file="$1" text="$2" n
  [[ -f "$file" ]] || { printf '0'; return; }
  n="$(grep -nxF -- "$text" "$file" 2>/dev/null | head -1 | cut -d: -f1)"
  printf '%s' "${n:-0}"
}

# block_start_line FILE BLOCKFILE -> 1-based line number in FILE where the
# full contents of BLOCKFILE first appear as a contiguous run, or 0 if the
# block is not found (including when BLOCKFILE is empty/missing).
block_start_line() {
  local file="$1" blockfile="$2"
  [[ -f "$file" && -s "$blockfile" ]] || { printf '0'; return; }
  awk -v cf="$blockfile" '
    BEGIN {
      n = 0
      while ((getline line < cf) > 0) { n++; blk[n] = line }
      close(cf)
    }
    { buf[NR] = $0 }
    END {
      if (n == 0) { print 0; exit }
      for (i = 1; i + n - 1 <= NR; i++) {
        ok = 1
        for (j = 1; j <= n; j++) {
          if (buf[i + j - 1] != blk[j]) { ok = 0; break }
        }
        if (ok) { print i; exit }
      }
      print 0
    }
  ' "$file"
}

# is_outside_region LINE BEGIN_LINE END_LINE -> true (0) if LINE is not
# within [BEGIN_LINE, END_LINE]. Vacuously true when BEGIN_LINE is 0 (no
# managed region exists yet) -- there is nothing to be "inside" of, and the
# marker-count assertions already flag that condition on their own.
is_outside_region() {
  local line="$1" begin="$2" end="$3"
  [[ "$line" -eq 0 ]] && return 1
  [[ "$begin" -eq 0 ]] && return 0
  [[ "$line" -lt "$begin" || "$line" -gt "$end" ]]
}

TARGETS=(claude codex pi agents)

# The repo's reference *.md files (README.md plus whatever *.local.md exist
# on this machine right now). Bash-3.2-safe: no nullglob, so an unmatched
# glob is filtered out explicitly rather than relied on to vanish.
REPO_REFERENCES_DIR="$REPO_ROOT/instructions/references"
REPO_REFERENCE_FILES=()
for f in "$REPO_REFERENCES_DIR"/*.md; do
  [[ -e "$f" ]] && REPO_REFERENCE_FILES+=("$(basename "$f")")
done

# ---------------------------------------------------------------------------
# Per-target checks
# ---------------------------------------------------------------------------

for target in "${TARGETS[@]}"; do
  group "target=$target"

  # --- Sub-test A: fresh install -- #1 markers, #2 content, #3 preamble ----

  homeA="$(new_home)"
  destA=""
  [[ "$target" == "agents" ]] && destA="$(new_dest)"

  run_installer "$target" "$homeA" "$destA"
  fileA="$(instructions_dest_path "$target" "$homeA" "$destA")"

  if [[ -f "$fileA" ]]; then
    pass "[#1] $target: instructions file exists after install ($fileA)"
  else
    fail "[#1] $target: instructions file exists after install (expected $fileA, got missing)"
  fi

  beginCount="$(marker_count "$fileA" "$MANAGED_BEGIN")"
  if [[ "$beginCount" -eq 1 ]]; then
    pass "[#1] $target: exactly one BEGIN marker (got 1)"
  else
    fail "[#1] $target: exactly one BEGIN marker (expected 1, got $beginCount)"
  fi

  endCount="$(marker_count "$fileA" "$MANAGED_END")"
  if [[ "$endCount" -eq 1 ]]; then
    pass "[#1] $target: exactly one END marker (got 1)"
  else
    fail "[#1] $target: exactly one END marker (expected 1, got $endCount)"
  fi

  blockA="$TMP_ROOT/blockA.$target"
  extract_managed_block "$fileA" >"$blockA"

  if [[ -s "$blockA" ]]; then
    pass "[#2] $target: managed-region content is non-empty"
  else
    fail "[#2] $target: managed-region content is non-empty (expected non-empty, got empty/absent)"
  fi

  if [[ -f "$CORE_MD" ]]; then
    if cmp -s "$blockA" "$CORE_MD"; then
      pass "[#2] $target: managed-region content matches instructions/core.md"
    else
      fail "[#2] $target: managed-region content matches instructions/core.md (content differs or region absent)"
    fi
  else
    fail "[#2] $target: managed-region content matches instructions/core.md (expected $CORE_MD to exist, it does not)"
  fi

  preambleSrc="$(preamble_src_path "$target")"
  if [[ -s "$preambleSrc" ]]; then
    startLine="$(block_start_line "$fileA" "$preambleSrc")"
    preLines="$(wc -l <"$preambleSrc" | tr -d ' ')"
    endLine=$((startLine + preLines - 1))
    beginLine="$(marker_line "$fileA" "$MANAGED_BEGIN")"
    endMarkerLine="$(marker_line "$fileA" "$MANAGED_END")"

    if [[ "$startLine" -ne 0 ]]; then
      pass "[#3] $target: harness preamble content is present in $fileA"
    else
      fail "[#3] $target: harness preamble content is present in $fileA (block from $preambleSrc not found)"
    fi

    if [[ "$startLine" -ne 0 ]] && is_outside_region "$startLine" "$beginLine" "$endMarkerLine" \
       && is_outside_region "$endLine" "$beginLine" "$endMarkerLine"; then
      pass "[#3] $target: harness preamble sits outside the managed region"
    else
      fail "[#3] $target: harness preamble sits outside the managed region (preamble lines $startLine-$endLine, managed region $beginLine-$endMarkerLine)"
    fi
  else
    fail "[#3] $target: harness preamble content is present in $fileA (expected canonical source $preambleSrc to exist and be non-empty, it does not)"
    fail "[#3] $target: harness preamble sits outside the managed region (cannot evaluate: canonical source $preambleSrc missing)"
  fi

  # --- Sub-test A (continued): reference documents -- #11 -----------------

  refDirA="$(references_dir_path "$target" "$homeA" "$destA")"

  if [[ -d "$refDirA" ]]; then
    pass "[#11] $target: reference directory exists after install ($refDirA)"
  else
    fail "[#11] $target: reference directory exists after install (expected $refDirA, got missing)"
  fi

  if [[ ${#REPO_REFERENCE_FILES[@]} -gt 0 ]]; then
    badRefs=()
    for relname in "${REPO_REFERENCE_FILES[@]}"; do
      srcRef="$REPO_REFERENCES_DIR/$relname"
      dstRef="$refDirA/$relname"
      if [[ ! -f "$dstRef" ]]; then
        badRefs+=("$relname:missing")
      elif ! cmp -s "$srcRef" "$dstRef"; then
        badRefs+=("$relname:content-differs")
      fi
    done
  if [[ ${#badRefs[@]} -eq 0 ]]; then
      pass "[#11] $target: all repo reference *.md files installed byte-identical (${#REPO_REFERENCE_FILES[@]} file(s))"
    else
      fail "[#11] $target: all repo reference *.md files installed byte-identical (expected ${#REPO_REFERENCE_FILES[@]} ok, got ${#badRefs[@]} problem(s): ${badRefs[*]})"
    fi
  else
    fail "[#11] $target: all repo reference *.md files installed byte-identical (expected at least one *.md under $REPO_REFERENCES_DIR, found none)"
  fi

  highRiskDest="$refDirA/high-risk-engineering.md"
  if [[ -f "$HIGH_RISK_MD" ]] && cmp -s "$HIGH_RISK_MD" "$highRiskDest"; then
    pass "[#19] $target: portable high-risk reference installs byte-identically"
  elif [[ -f "$HIGH_RISK_MD" ]]; then
    fail "[#19] $target: portable high-risk reference installs byte-identically (expected $highRiskDest to match $HIGH_RISK_MD)"
  else
    fail "[#19] $target: portable high-risk reference installs byte-identically (canonical source $HIGH_RISK_MD is missing)"
  fi

  # --- Sub-test B: idempotence -- #5 ---------------------------------------

  cp -p "$fileA" "$TMP_ROOT/idempotence-snapshot.$target" 2>/dev/null || : >"$TMP_ROOT/idempotence-snapshot.$target"

  run_installer "$target" "$homeA" "$destA"

  if [[ -f "$fileA" ]] && cmp -s "$TMP_ROOT/idempotence-snapshot.$target" "$fileA"; then
    pass "[#5] $target: two consecutive installs leave the instructions file byte-identical"
  else
    fail "[#5] $target: two consecutive installs leave the instructions file byte-identical (differs, or file now missing)"
  fi

  # --- Sub-test C: preservation + managed-region authority -- #4, #6, #10 -

  homeC="$(new_home)"
  destC=""
  [[ "$target" == "agents" ]] && destC="$(new_dest)"
  fileC="$(instructions_dest_path "$target" "$homeC" "$destC")"

  sentinel="SENTINEL-$target-$$-preserve-me-verbatim"
  mkdir -p "$(dirname "$fileC")"
  printf '%s\n%s\n' "# hand-written notes, installer must not touch this" "$sentinel" >"$fileC"

  run_installer "$target" "$homeC" "$destC"

  sentinelLine="$(line_number_of "$fileC" "$sentinel")"
  beginLineC="$(marker_line "$fileC" "$MANAGED_BEGIN")"
  endLineC="$(marker_line "$fileC" "$MANAGED_END")"

  if [[ "$sentinelLine" -ne 0 ]]; then
    pass "[#4] $target: hand-written sentinel line survives the first install, byte-for-byte"
  else
    fail "[#4] $target: hand-written sentinel line survives the first install, byte-for-byte (not found verbatim in $fileC)"
  fi

  if is_outside_region "$sentinelLine" "$beginLineC" "$endLineC"; then
    pass "[#4] $target: hand-written sentinel line stays outside the managed region"
  else
    fail "[#4] $target: hand-written sentinel line stays outside the managed region (sentinel at line $sentinelLine, managed region $beginLineC-$endLineC)"
  fi

  # Corrupt one line inside the region (no-op if the region doesn't exist),
  # and append a hand-written line outside it, then reinstall.
  outsideAppend="OUTSIDE-APPEND-$target-$$-must-survive"
  awk -v b="$MANAGED_BEGIN" -v e="$MANAGED_END" -v corrupt="CORRUPTED-BY-TEST-$target" '
    $0 == b { print; inb=1; next }
    $0 == e { inb=0; print; next }
    inb && !done { print corrupt; done=1; next }
    { print }
  ' "$fileC" >"$TMP_ROOT/corrupted.$target"
  mv "$TMP_ROOT/corrupted.$target" "$fileC"
  printf '%s\n' "$outsideAppend" >>"$fileC"

  run_installer "$target" "$homeC" "$destC"

  blockC="$TMP_ROOT/blockC.$target"
  extract_managed_block "$fileC" >"$blockC"

  if [[ -f "$CORE_MD" ]]; then
    if cmp -s "$blockC" "$CORE_MD"; then
      pass "[#6] $target: corrupted managed-region content is restored to instructions/core.md on reinstall"
    else
      fail "[#6] $target: corrupted managed-region content is restored to instructions/core.md on reinstall (still differs)"
    fi
  else
    fail "[#6] $target: corrupted managed-region content is restored to instructions/core.md on reinstall (expected $CORE_MD to exist, it does not)"
  fi

  appendLine="$(line_number_of "$fileC" "$outsideAppend")"
  beginLineC2="$(marker_line "$fileC" "$MANAGED_BEGIN")"
  endLineC2="$(marker_line "$fileC" "$MANAGED_END")"
  if [[ "$appendLine" -ne 0 ]] && is_outside_region "$appendLine" "$beginLineC2" "$endLineC2"; then
    pass "[#6] $target: hand-written line added outside the region survives reinstall"
  else
    fail "[#6] $target: hand-written line added outside the region survives reinstall (not found outside the region after reinstall)"
  fi

  beginCountC="$(marker_count "$fileC" "$MANAGED_BEGIN")"
  if [[ "$beginCountC" -eq 1 ]]; then
    pass "[#10] $target: BEGIN marker not duplicated after corrupt+reinstall cycle"
  else
    fail "[#10] $target: BEGIN marker not duplicated after corrupt+reinstall cycle (expected 1, got $beginCountC)"
  fi

  endCountC="$(marker_count "$fileC" "$MANAGED_END")"
  if [[ "$endCountC" -eq 1 ]]; then
    pass "[#10] $target: END marker not duplicated after corrupt+reinstall cycle"
  else
    fail "[#10] $target: END marker not duplicated after corrupt+reinstall cycle (expected 1, got $endCountC)"
  fi

  # --- Sub-test D: --dry-run writes nothing -- #7 --------------------------

  homeD="$(new_home)"
  destD=""
  [[ "$target" == "agents" ]] && destD="$(new_dest)"
  fileD="$(instructions_dest_path "$target" "$homeD" "$destD")"

  beforeHomeD="$(snapshot_tree "$homeD")"
  beforeDestD=""
  [[ "$target" == "agents" ]] && beforeDestD="$(snapshot_tree "$destD")"

  run_installer "$target" "$homeD" "$destD" --dry-run

  afterHomeD="$(snapshot_tree "$homeD")"
  afterDestD=""
  [[ "$target" == "agents" ]] && afterDestD="$(snapshot_tree "$destD")"

  if [[ ! -e "$fileD" ]]; then
    pass "[#7] $target: --dry-run does not create the instructions file"
  else
    fail "[#7] $target: --dry-run does not create the instructions file (found $fileD)"
  fi

  if [[ "$beforeHomeD" == "$afterHomeD" ]]; then
    pass "[#7] $target: --dry-run writes nothing under HOME (tree hash unchanged)"
  else
    fail "[#7] $target: --dry-run writes nothing under HOME (expected hash $beforeHomeD, got $afterHomeD)"
  fi

  if [[ "$target" == "agents" ]]; then
    if [[ "$beforeDestD" == "$afterDestD" ]]; then
      pass "[#7] $target: --dry-run writes nothing under --dest (tree hash unchanged)"
    else
      fail "[#7] $target: --dry-run writes nothing under --dest (expected hash $beforeDestD, got $afterDestD)"
    fi
  fi

  # --- Sub-test D (continued): reference documents -- #11 ------------------

  refDirD="$(references_dir_path "$target" "$homeD" "$destD")"

  if [[ ! -e "$refDirD" ]]; then
    pass "[#11] $target: --dry-run does not create the reference directory"
  else
    fail "[#11] $target: --dry-run does not create the reference directory (found $refDirD)"
  fi

  refFileCountD=0
  if [[ -d "$refDirD" ]]; then
    refFileCountD="$(find "$refDirD" -type f 2>/dev/null | wc -l | tr -d ' ')"
  fi
  if [[ "$refFileCountD" -eq 0 ]]; then
    pass "[#11] $target: --dry-run creates no file under the reference directory"
  else
    fail "[#11] $target: --dry-run creates no file under the reference directory (found $refFileCountD file(s) under $refDirD)"
  fi
done

# ---------------------------------------------------------------------------
# Repo-level checks -- #8, #9
# ---------------------------------------------------------------------------

group "repo-level"

if [[ -f "$CORE_MD" ]]; then
  pass "[#8] instructions/core.md exists"
else
  fail "[#8] instructions/core.md exists (expected $CORE_MD, not found)"
fi

FORBIDDEN_TOKENS=(
  "ndanjiedmond"
  "2bTwist"
  "localhost:8888"
  $'~/bin'
  "local-ai-stack"
  "machine-fixes"
  "MCP_DOCKER"
  "claude-in-chrome"
  "cloudflare-browser"
  "security-defaults"
  "/Users/edmond"
)

# scan_forbidden_tokens FILE LABEL -- one [#8] pass/fail per token in
# FORBIDDEN_TOKENS, tagged with LABEL for the message. Used for
# instructions/core.md and, per new requirement 2, every published
# instructions/preamble/*.md (NOT instructions/references/*.local.md: those
# are gitignored specifically so they can hold this content).
scan_forbidden_tokens() {
  local file="$1" label="$2" token
  for token in "${FORBIDDEN_TOKENS[@]}"; do
    if [[ -f "$file" ]] && grep -qiF -- "$token" "$file"; then
      fail "[#8] $label does not contain '$token' (expected absent, found it, case-insensitive)"
    elif [[ -f "$file" ]]; then
      pass "[#8] $label does not contain '$token'"
    else
      fail "[#8] $label does not contain '$token' (cannot check: $file missing)"
    fi
  done
}

scan_forbidden_tokens "$CORE_MD" "instructions/core.md"

for target in "${TARGETS[@]}"; do
  scan_forbidden_tokens "$(preamble_src_path "$target")" "instructions/preamble/$target.md"
done

# Portable references are clone-safe sources. Unlike *.local.md files, they
# cannot contain a maintainer identifier, machine path, or secret-shaped value.
portableReferenceCount=0
portableReferenceProblems=()
for portableRef in "$REPO_REFERENCES_DIR"/*.md; do
  [[ -f "$portableRef" ]] || continue
  case "$(basename "$portableRef")" in
    *.local.md) continue ;;
  esac
  portableReferenceCount=$((portableReferenceCount + 1))
  for forbiddenToken in "${FORBIDDEN_TOKENS[@]}"; do
    if grep -qiF -- "$forbiddenToken" "$portableRef"; then
      portableReferenceProblems+=("$(basename "$portableRef"):contains-$forbiddenToken")
    fi
  done
  if grep -Eqi -- '(api[_-]?key|access[_-]?token|secret|password)[[:space:]]*[:=][[:space:]]*[[:alnum:]_.-]{8,}' "$portableRef"; then
    portableReferenceProblems+=("$(basename "$portableRef"):contains-secret-shaped-value")
  fi
done

if [[ "$portableReferenceCount" -eq 0 ]]; then
  fail "[#20] portable references are publishable (expected at least one non-local instructions/references/*.md file)"
elif [[ ${#portableReferenceProblems[@]} -eq 0 ]]; then
  pass "[#20] portable references are publishable (no machine identifiers, machine paths, or secret-shaped values in $portableReferenceCount file(s))"
else
  fail "[#20] portable references are publishable (found: ${portableReferenceProblems[*]})"
fi

if [[ -s "$HIGH_RISK_MD" ]]; then
  pass "[#21] instructions/references/high-risk-engineering.md exists as a non-empty portable reference"
else
  fail "[#21] instructions/references/high-risk-engineering.md exists as a non-empty portable reference (expected non-empty $HIGH_RISK_MD)"
fi

if git -C "$REPO_ROOT" check-ignore -q -- "instructions/references/high-risk-engineering.md"; then
  fail "[#21] instructions/references/high-risk-engineering.md is publishable rather than git-ignored"
else
  pass "[#21] instructions/references/high-risk-engineering.md is publishable rather than git-ignored"
fi

require_high_risk_terms() {
  local missing="" pattern
  for pattern in "$@"; do
    if ! grep -Eqi -- "$pattern" "$HIGH_RISK_MD" 2>/dev/null; then
      missing="${missing}${missing:+; }/$pattern/"
    fi
  done
  if [[ -z "$missing" ]]; then
    pass "[#22] high-risk reference defines the required system model, evidence hierarchy, and architecture gate"
  else
    fail "[#22] high-risk reference defines the required system model, evidence hierarchy, and architecture gate (missing $missing)"
  fi
}

require_high_risk_terms \
  "promise" \
  "state.{0,40}(own|owner)|own.{0,40}state" \
  "invariant" \
  "interaction" \
  "failure.{0,40}recovery|recovery.{0,40}failure" \
  "verification.{0,40}oracle|oracle" \
  "alternative" \
  "future.{0,40}constraint|constraint" \
  "migration" \
  "reversal|reverse" \
  "transcript.{0,80}(hypoth|not.{0,40}fact)|hypoth.{0,80}transcript" \
  "installed.{0,80}version|primary.{0,80}source|current.{0,80}code|production.{0,80}evidence" \
  "persistent.{0,40}(ownership|state)|durable.{0,40}(format|data)" \
  "public.{0,40}interface|trust.{0,40}boundar|security.{0,40}boundar" \
  "concurren|consistency" \
  "dependency.{0,40}topology|deployment.{0,40}shape" \
  "pause" \
  "explicit.{0,60}(confirm|approval)|confirm.{0,60}(resume|implement)|approval.{0,60}(resume|implement)" \
  "current.{0,50}system.{0,50}model|system.{0,50}model" \
  "tradeoff" \
  "verification.{0,50}evidence|evidence.{0,50}verification" \
  "reversal.{0,50}cost|cost.{0,50}reversal" \
  "active.{0,50}safety.{0,50}(halt|stop)|safety.{0,50}(halt|stop)"

if git -C "$REPO_ROOT" check-ignore -q -- "instructions/references/machine.local.md"; then
  pass "[#9] instructions/references/*.local.md is git-ignored"
else
  fail "[#9] instructions/references/*.local.md is git-ignored (git check-ignore did not match instructions/references/machine.local.md)"
fi

# ---------------------------------------------------------------------------
# Durable-correction policy. These assertions encode the required precedence
# directly instead of learning it from an installer or template. The six
# labels must appear as one contiguous ordered hierarchy in the canonical
# core. Their exact spelling keeps a prose rewrite from silently changing the
# storage decision rule.
# ---------------------------------------------------------------------------

group "durable-corrections"

DURABLE_HIERARCHY="$TMP_ROOT/durable-corrections.expected"
cat >"$DURABLE_HIERARCHY" <<'EOF'
1. Architecture/data structures
2. Constraints/types
3. Lint/tests/CI
4. Lean AGENTS.md
5. Curated local reference/procedure
6. Transcript only
EOF

hierarchyLine="$(block_start_line "$CORE_MD" "$DURABLE_HIERARCHY")"
if [[ "$hierarchyLine" -gt 0 ]]; then
  pass "[#13] instructions/core.md contains the required durable-corrections hierarchy in exact precedence"
else
  fail "[#13] instructions/core.md contains the required durable-corrections hierarchy in exact precedence (expected the six canonical lines from architecture/data structures through transcript only as one contiguous block)"
fi

if [[ -f "$CORE_MD" ]] && grep -qiF -- "Grow project memory" "$CORE_MD"; then
  fail "[#14] instructions/core.md rejects the legacy 'Grow project memory' directive (expected absent, found it)"
elif [[ -f "$CORE_MD" ]]; then
  pass "[#14] instructions/core.md rejects the legacy 'Grow project memory' directive"
else
  fail "[#14] instructions/core.md rejects the legacy 'Grow project memory' directive (cannot check: $CORE_MD missing)"
fi

if [[ -f "$CORE_MD" ]] && grep -qF -- "Task state is not automatically preserved." "$CORE_MD"; then
  pass "[#15] instructions/core.md explicitly states that task state is not automatically preserved"
elif [[ -f "$CORE_MD" ]]; then
  fail "[#15] instructions/core.md explicitly states that task state is not automatically preserved (expected exact rule: 'Task state is not automatically preserved.')"
else
  fail "[#15] instructions/core.md explicitly states that task state is not automatically preserved (cannot check: $CORE_MD missing)"
fi

MEMORY_TEMPLATES_DIR="$REPO_ROOT/memory-templates"
activeMemorySources=0
if [[ -d "$MEMORY_TEMPLATES_DIR" ]]; then
  activeMemorySources="$(find "$MEMORY_TEMPLATES_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')"
fi
if [[ "$activeMemorySources" -eq 0 ]]; then
  pass "[#16] memory-templates/ is not an active source directory"
else
  fail "[#16] memory-templates/ is not an active source directory (found $activeMemorySources active source file(s) under $MEMORY_TEMPLATES_DIR)"
fi

# ---------------------------------------------------------------------------
# Durable-context trigger policy. Compaction writes session state to a durable
# handoff, so it must be a deliberate user request rather than an automatic
# response to phase or context-budget state. Inspect the public skill
# description because that is the harness-visible trigger surface.
# ---------------------------------------------------------------------------

group "durable-context-trigger"

COMPACT_EXPLICIT_TRIGGER="Use only when the user explicitly asks to compact, hand off, or wrap up for a clean restart."
compactDescription=""
if [[ -f "$COMPACT_MD" ]]; then
  compactDescription="$(awk '
    NR==1 && $0=="---" { infm=1; next }
    infm && $0=="---" { exit }
    infm && /^description:/ {
      sub(/^description:[ \t]*/, "")
      print
      exit
    }
  ' "$COMPACT_MD")"
fi

case "$compactDescription" in
  *"$COMPACT_EXPLICIT_TRIGGER"*)
    pass "[#17] compact skill declares the exact explicit-user-only trigger"
    ;;
  *)
    fail "[#17] compact skill declares the exact explicit-user-only trigger (expected exact statement: '$COMPACT_EXPLICIT_TRIGGER')"
    ;;
esac

COMPACT_AUTOMATIC_TRIGGERS=(
  "phase boundary"
  "context budget is warned"
  "nearly spent"
)
for automaticTrigger in "${COMPACT_AUTOMATIC_TRIGGERS[@]}"; do
  if printf '%s\n' "$compactDescription" | grep -qiF -- "$automaticTrigger"; then
    fail "[#18] compact skill rejects automatic trigger '$automaticTrigger' (expected absent from description, found it)"
  else
    pass "[#18] compact skill rejects automatic trigger '$automaticTrigger'"
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
