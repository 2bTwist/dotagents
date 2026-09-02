#!/usr/bin/env bash
#
# repository-adapter-smoke.sh — repository instruction adapter contract.
#
# Default mode is a local, unauthenticated Codex prompt-construction check. It
# uses `codex debug prompt-input`, which renders model input without contacting
# a model. The qualified CLI baseline is intentionally exact: a version change
# fails until this adapter behavior is manually requalified.
#
# Claude runtime ingestion is a separate authenticated manual gate:
#   ./test/repository-adapter-smoke.sh --manual-claude
# It uses print mode with tools, session persistence, and MCP disabled. The
# qualified Claude Code baseline is also exact.
#
# Written for macOS bash 3.2: no associative arrays, mapfile, or namerefs.
#
set -uo pipefail

PASS=0
FAIL=0
GROUP="init"
MODE="default"

case "${1:-}" in
  "") : ;;
  --manual-claude) MODE="manual-claude" ;;
  *)
    echo "Usage: $0 [--manual-claude]" >&2
    exit 2
    ;;
esac

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

need_cmd git
need_cmd grep
need_cmd mktemp
need_cmd wc
need_cmd tr
need_cmd codex

QUALIFIED_CODEX_VERSION="codex-cli 0.144.1"
QUALIFIED_CLAUDE_VERSION="2.1.251 (Claude Code)"
SHARED_SENTINEL="DOTAGENTS_SHARED_REPOSITORY_SENTINEL_7F3A19"
CLAUDE_SENTINEL="DOTAGENTS_CLAUDE_ONLY_SENTINEL_8C4B27"

REAL_HOME="${HOME:-}"
TMP_PARENT="$(cd "${TMPDIR:-/tmp}" && pwd)" || die "cannot resolve temporary directory"
TMP_ROOT="$(mktemp -d "$TMP_PARENT/repository-adapter-smoke.XXXXXX")" || die "mktemp failed"

assert_tmp_root() {
  if [[ -z "$TMP_ROOT" || "$TMP_ROOT" == "/" || "$TMP_ROOT" == "$REAL_HOME" ]]; then
    die "refusing unsafe temporary root '$TMP_ROOT'"
  fi
  case "$TMP_ROOT" in
    "$TMP_PARENT"/repository-adapter-smoke.*) : ;;
    *) die "temporary root '$TMP_ROOT' is outside guarded prefix '$TMP_PARENT/repository-adapter-smoke.*'" ;;
  esac
}

assert_fixture_path() {
  local path="$1"
  case "$path" in
    "$TMP_ROOT"/*) : ;;
    *) die "fixture path '$path' is outside guarded temporary root '$TMP_ROOT'" ;;
  esac
}

# shellcheck disable=SC2329  # called by the EXIT trap
cleanup() {
  case "$TMP_ROOT" in
    "$TMP_PARENT"/repository-adapter-smoke.*) rm -rf -- "$TMP_ROOT" ;;
    *) echo "ABORT: refusing cleanup of unsafe path '$TMP_ROOT'" >&2 ;;
  esac
}

assert_tmp_root
trap cleanup EXIT

FIXTURE="$TMP_ROOT/repository"
FIXTURE_HOME="$TMP_ROOT/home"
assert_fixture_path "$FIXTURE"
assert_fixture_path "$FIXTURE_HOME"
mkdir -p "$FIXTURE" "$FIXTURE_HOME/.codex"
git -C "$FIXTURE" init -q || die "could not initialize disposable Git fixture"

# AGENTS.md is the fixture's canonical repository instruction source. The
# Claude adapter stays thin: it imports the canonical file, then adds only a
# Claude-specific sentinel. The probe prompt does not repeat either token.
cat >"$FIXTURE/AGENTS.md" <<EOF
# Canonical repository instructions

Shared repository adapter sentinel: $SHARED_SENTINEL
EOF

cat >"$FIXTURE/CLAUDE.md" <<EOF
@AGENTS.md
Claude-only adapter sentinel: $CLAUDE_SENTINEL
EOF

count_literal() {
  local needle="$1" file="$2" count
  count="$(grep -oF -- "$needle" "$file" 2>/dev/null | wc -l | tr -d ' ')"
  printf '%s' "${count:-0}"
}

group "fixture"

if [[ "$(git -C "$FIXTURE" rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then
  pass "disposable fixture is a Git repository"
else
  fail "disposable fixture is a Git repository"
fi

if [[ -s "$FIXTURE/AGENTS.md" ]] && [[ "$(count_literal "$SHARED_SENTINEL" "$FIXTURE/AGENTS.md")" -eq 1 ]]; then
  pass "canonical AGENTS.md contains the shared sentinel exactly once"
else
  fail "canonical AGENTS.md contains the shared sentinel exactly once"
fi

if [[ "$(sed -n '1p' "$FIXTURE/CLAUDE.md")" == "@AGENTS.md" ]] \
   && [[ "$(count_literal "$CLAUDE_SENTINEL" "$FIXTURE/CLAUDE.md")" -eq 1 ]] \
   && [[ "$(wc -l <"$FIXTURE/CLAUDE.md" | tr -d ' ')" -eq 2 ]]; then
  pass "thin CLAUDE.md imports @AGENTS.md and adds one Claude-only line"
else
  fail "thin CLAUDE.md imports @AGENTS.md and adds one Claude-only line"
fi

group "codex-local-prompt-input"

CODEX_VERSION="$(codex --version 2>/dev/null | tail -1)"
if [[ "$CODEX_VERSION" == "$QUALIFIED_CODEX_VERSION" ]]; then
  pass "Codex version matches qualified baseline $QUALIFIED_CODEX_VERSION"
else
  fail "Codex version requires repository-adapter requalification (expected '$QUALIFIED_CODEX_VERSION', got '$CODEX_VERSION')"
fi

CODEX_OUTPUT="$TMP_ROOT/codex-prompt-input.json"
CODEX_ERROR="$TMP_ROOT/codex-prompt-input.stderr"
CODEX_RC=0
(
  cd "$FIXTURE" || exit 2
  env \
    -u OPENAI_API_KEY \
    -u CODEX_API_KEY \
    HOME="$FIXTURE_HOME" \
    CODEX_HOME="$FIXTURE_HOME/.codex" \
    HTTP_PROXY="http://127.0.0.1:9" \
    HTTPS_PROXY="http://127.0.0.1:9" \
    ALL_PROXY="http://127.0.0.1:9" \
    codex debug prompt-input \
      "Report which repository instruction source is visible. Do not infer missing sources."
) >"$CODEX_OUTPUT" 2>"$CODEX_ERROR" || CODEX_RC=$?

if [[ "$CODEX_RC" -eq 0 ]] && [[ -s "$CODEX_OUTPUT" ]]; then
  pass "local unauthenticated codex debug prompt-input completed without a model call"
else
  fail "local unauthenticated codex debug prompt-input completed without a model call (exit=$CODEX_RC, stderr recorded at $CODEX_ERROR)"
fi

sharedCount="$(count_literal "$SHARED_SENTINEL" "$CODEX_OUTPUT")"
claudeCount="$(count_literal "$CLAUDE_SENTINEL" "$CODEX_OUTPUT")"

if [[ "$sharedCount" -eq 1 ]]; then
  pass "Codex model-visible prompt contains the shared AGENTS.md sentinel exactly once"
else
  fail "Codex model-visible prompt contains the shared AGENTS.md sentinel exactly once (found $sharedCount)"
fi

if [[ "$claudeCount" -eq 0 ]]; then
  pass "Codex model-visible prompt excludes the Claude-only sentinel"
else
  fail "Codex model-visible prompt excludes the Claude-only sentinel (found $claudeCount)"
fi

if [[ "$MODE" == "manual-claude" ]]; then
  group "claude-runtime-manual-gate"
  need_cmd claude

  CLAUDE_VERSION="$(claude --version 2>/dev/null | tail -1)"
  if [[ "$CLAUDE_VERSION" == "$QUALIFIED_CLAUDE_VERSION" ]]; then
    pass "Claude version matches qualified baseline $QUALIFIED_CLAUDE_VERSION"
  else
    fail "Claude version requires repository-adapter requalification (expected '$QUALIFIED_CLAUDE_VERSION', got '$CLAUDE_VERSION')"
  fi

  # This is the only model-contacting path and it requires explicit opt-in.
  # It uses the caller's existing authentication but disables tools, session
  # persistence, all MCP configuration, and non-project setting sources.
  CLAUDE_OUTPUT="$TMP_ROOT/claude-output.txt"
  CLAUDE_ERROR="$TMP_ROOT/claude.stderr"
  CLAUDE_RC=0
  claude_cmd=(
    claude
    --print
    --no-session-persistence
    --tools ""
    --strict-mcp-config
    --mcp-config '{"mcpServers":{}}'
    --setting-sources project
    --no-chrome
    --disable-slash-commands
    "Return one line containing every uppercase repository sentinel token visible in your instructions, each exactly once, separated by one space, and no other text."
  )
  (
    cd "$FIXTURE" || exit 2
    "${claude_cmd[@]}"
  ) >"$CLAUDE_OUTPUT" 2>"$CLAUDE_ERROR" || CLAUDE_RC=$?

  if [[ "$CLAUDE_RC" -eq 0 ]] && [[ -s "$CLAUDE_OUTPUT" ]]; then
    pass "authenticated Claude print probe completed with tools, persistence, and MCP disabled"
  else
    fail "authenticated Claude print probe completed with tools, persistence, and MCP disabled (exit=$CLAUDE_RC)"
    if [[ -s "$CLAUDE_ERROR" ]]; then
      echo "  Claude stderr (first 8 lines):"
      sed -n '1,8p' "$CLAUDE_ERROR" | sed 's/^/    /'
    else
      echo "  Claude stderr was empty."
    fi
  fi

  claudeSharedCount="$(count_literal "$SHARED_SENTINEL" "$CLAUDE_OUTPUT")"
  claudeOnlyCount="$(count_literal "$CLAUDE_SENTINEL" "$CLAUDE_OUTPUT")"
  if [[ "$claudeSharedCount" -eq 1 ]] && [[ "$claudeOnlyCount" -eq 1 ]]; then
    pass "Claude runtime sees the imported shared sentinel and Claude-only sentinel exactly once each"
  else
    fail "Claude runtime sees the imported shared sentinel and Claude-only sentinel exactly once each (shared=$claudeSharedCount claude-only=$claudeOnlyCount)"
  fi
else
  echo
  echo "MANUAL GATE NOT RUN: Claude runtime ingestion requires explicit --manual-claude opt-in and authenticated Claude access."
fi

echo
echo "== summary =="
echo "$PASS passed, $FAIL failed"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
