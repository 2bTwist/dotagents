#!/usr/bin/env bash
#
# global-instructions-pruning-smoke.sh — acceptance test for a lean global
# instruction set. It checks behavioral boundaries which must remain global,
# while requiring task-specific procedures to move behind skills or references.
#
# Bash 3.2 compatible: no associative arrays, mapfile, or readarray.
#
# Usage: ./test/global-instructions-pruning-smoke.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CORE="$REPO_ROOT/instructions/core.md"
PREAMBLES="$REPO_ROOT/instructions/preamble"

# This is the observed pre-pruning size. Requiring removal of at least half of
# the always-loaded words is a material, historically anchored reduction, not
# a preference for an arbitrarily tiny prompt.
BASELINE_WORDS=2639
MAX_WORDS=$(((BASELINE_WORDS + 1) / 2 - 1))

PASS=0
FAIL=0
GROUP="init"

group() {
  GROUP="$1"
  echo
  echo "== $GROUP =="
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

require_file() {
  local file="$1"
  [[ -f "$file" ]] || die "required file is missing: $file"
}

# require_all FILE DESCRIPTION PATTERN...
# The assertions intentionally use behavior-level vocabulary, allowing the
# canonical prose to become shorter without coupling this test to one rewrite.
require_all() {
  local file="$1" description="$2"
  shift 2
  local pattern
  local missing=""
  for pattern in "$@"; do
    if ! grep -Eqi -- "$pattern" "$file"; then
      missing="${missing}${missing:+; }/$pattern/"
    fi
  done
  if [[ -z "$missing" ]]; then
    pass "$description"
  else
    fail "$description (missing $missing)"
  fi
}

require_literal() {
  local file="$1" description="$2" literal="$3"
  if grep -qF -- "$literal" "$file"; then
    pass "$description"
  else
    fail "$description (missing exact text: $literal)"
  fi
}

reject_pattern() {
  local file="$1" description="$2" pattern="$3"
  if grep -Enqi -- "$pattern" "$file"; then
    local first
    first="$(grep -Eni -- "$pattern" "$file" | head -1)"
    fail "$description (found: $first)"
  else
    pass "$description"
  fi
}

require_file "$CORE"
[[ -d "$PREAMBLES" ]] || die "preamble directory is missing: $PREAMBLES"

group "always-on behavior"

require_all "$CORE" \
  "forbids AI attribution in authored work" \
  "no ai attribution|never.{0,80}(ai attribution|co-?author|generated[- ]by)" \
  "commit|pr|issue|doc|comment"

require_all "$CORE" \
  "defaults to pnpm, respects a lockfile, and does not switch package managers unprompted" \
  "pnpm" \
  "(existing|current).{0,40}lockfile|lockfile.{0,40}(existing|current)" \
  "(never|do not).{0,80}switch.{0,40}package manager|package manager.{0,80}(never|do not).{0,40}switch"

require_all "$CORE" \
  "never exposes or requests secrets" \
  "(never|do not).{0,100}(log|print|commit|request|ask).{0,100}(secret|credential|token)" \
  "(paste|share).{0,80}(secret|credential|token)|(secret|credential|token).{0,80}(paste|share)"

require_all "$CORE" \
  "does not transfer refused permissions between agents or sessions" \
  "permission" \
  "refus|refuse|denied|deny" \
  "(do not|never|cannot).{0,100}(transfer|launder)|(transfer|launder).{0,100}(do not|never|cannot)" \
  "agent|session"

require_all "$CORE" \
  "preserves dirty user work and requires explicit authority for destructive actions" \
  "dirty.{0,40}(worktree|work|change)|uncommitted.{0,40}(change|work)" \
  "destructive|delete|overwrite|reset" \
  "explicit.{0,40}(authori[sz]|request|permission)|(authori[sz]|request|permission).{0,40}explicit"

require_all "$CORE" \
  "requires verification before assertions" \
  "verif|read.{0,40}(file|data)|run.{0,40}(command|check)" \
  "assert|claim|state"

require_all "$CORE" \
  "treats the installed library version as the specification" \
  "installed.{0,80}(version|library|package)|version.{0,80}spec" \
  "spec"

group "technical judgment and learning"

require_literal "$CORE" \
  "does not trust generated code merely because tests pass, and requires system, invariant, and risky-interaction understanding" \
  "Do not trust generated code merely because tests pass. Understand the system, identify its invariants, and verify risky interactions."

require_all "$CORE" \
  "scales rigor to risk and names high-risk corruption, loss, exposure, or misattribution triggers" \
  "risk[- ]scaled|scale.{0,30}rigor|rigor.{0,30}risk" \
  "high[- ]risk" \
  "corrupt|loss|expos|misattribut" \
  "authoritative|security|financial|identity|shared.{0,30}coordination"

require_all "$CORE" \
  "separates user or product authority from evidence-backed technical responsibility" \
  "user|product" \
  "intent|authority" \
  "technical" \
  "evidence" \
  "responsib|judgment"

require_all "$CORE" \
  "repairs the touched surface while keeping unrelated cleanup out of scope" \
  "touch(ed)?.{0,40}(surface|area)|affected.{0,40}(surface|area)" \
  "repair|correct|fix" \
  "unrelated.{0,40}cleanup|cleanup.{0,40}unrelated"

require_all "$CORE" \
  "places guarantees at the lowest capable layer and requires hard-to-misuse interfaces" \
  "lowest.{0,40}(capable|layer)|layer.{0,40}lowest" \
  "guarantee|enforce|invariant" \
  "hard[- ]to[- ]misuse|misuse.{0,40}(hard|difficult)"

require_all "$CORE" \
  "requires a compact reasoning handoff for non-trivial work" \
  "compact" \
  "reasoning|rationale" \
  "handoff" \
  "non[- ]trivial"

require_all "$CORE" \
  "treats surprisingly good or bad measurements as possible measurement failures" \
  "(surprising|suspicious).{0,50}(good|strong|bad)|good.{0,50}(surprising|suspicious)|bad.{0,50}(surprising|suspicious)" \
  "measurement|metric" \
  "failure|bug|error"

require_all "$CORE" \
  "pauses architecture decisions and resumes only after explicit confirmation" \
  "architect" \
  "pause|stop" \
  "explicit.{0,50}(confirm|approval)|confirm|approval" \
  "resume|implementation"

require_all "$CORE" \
  "routes concrete state or database contracts to the owning stateful repository" \
  "stateful|persistent.{0,40}(state|repository)|repository.{0,40}(state|database)" \
  "(state|database).{0,40}contract|contract.{0,40}(state|database)" \
  "local|owning|repository"

require_all "$CORE" \
  "treats user direction as input, not unquestionable technical authority" \
  "user.{0,40}(direction|request|instruction)|(direction|request|instruction).{0,40}user" \
  "(input|question|challenge|evaluate|assess)" \
  "(not|never|rather than).{0,80}(unquestion|automatic|authority)|(unquestion|automatic).{0,80}(not|never)"

require_all "$CORE" \
  "explains contradictions, risky assumptions, and weaker architecture before acting" \
  "contradict|conflict" \
  "risk.{0,40}assumption|assumption.{0,40}risk" \
  "architect|design choice|maintainab" \
  "explain|reason" \
  "before.{0,40}(act|implement|proceed|change)"

require_all "$CORE" \
  "surfaces concise learning opportunities without derailing or condescending" \
  "learn|teach|understand" \
  "concise|brief|short" \
  "deliver|derail|scope|progress" \
  "condescend|patroniz"

require_all "$CORE" \
  "uses expert-maintainer standards without vague praise or performative perfection" \
  "expert|maintainer|practitioner" \
  "standard|credible|quality" \
  "vague.{0,40}praise|performative.{0,40}perfection"

group "durable decisions and independent verification"

require_all "$CORE" \
  "keeps the six-step durable-corrections hierarchy" \
  "architecture.{0,50}(data structure|data-structure)" \
  "constraint.{0,50}type" \
  "lint.{0,50}(test|ci)|test.{0,50}(lint|ci)" \
  "lean.{0,50}agents\\.md|agents\\.md.{0,50}lean" \
  "(local )?reference.{0,50}(procedure|process)|procedure.{0,50}(local )?reference" \
  "transcript( only)?"

require_all "$CORE" \
  "does not automatically preserve task state" \
  "task state" \
  "(not|never|do not).{0,80}(automatic|preserv)|(automatic|preserv).{0,80}(not|never|do not)"

require_all "$CORE" \
  "requires verification independent from the implementation author" \
  "author.{0,80}(independ|separate)|independ.{0,80}author|separate.{0,80}(agent|verifier)" \
  "verif|assert|test|acceptance"

require_all "$CORE" \
  "does not automatically commit, release, or deploy" \
  "commit" \
  "release" \
  "deploy" \
  "(explicit|unless asked|unless requested|do not automatically|never automatically)"

group "lean task routing"

CORE_WORDS="$(wc -w < "$CORE" | tr -d ' ')"
if [[ "$CORE_WORDS" -le "$MAX_WORDS" ]]; then
  pass "core is materially reduced from the $BASELINE_WORDS-word baseline ($CORE_WORDS words; maximum $MAX_WORDS)"
else
  fail "core is materially reduced from the $BASELINE_WORDS-word baseline ($CORE_WORDS words; must be at most $MAX_WORDS, removing at least half)"
fi

require_all "$CORE" \
  "routes task-specific guidance to skills or references on demand" \
  "skill|reference" \
  "(on demand|when relevant|for task-specific|for the relevant task|read.*before)"

# These headings identify former procedural branches. They belong behind the
# on-demand routing pointer, not in an always-loaded core document.
reject_pattern "$CORE" \
  "does not retain the inlined dev-server procedure branch" \
  "^##[[:space:]]+Dev servers and ports"
reject_pattern "$CORE" \
  "does not retain the inlined search-and-fetch procedure branch" \
  "^##[[:space:]]+Search and fetch tool selection"
reject_pattern "$CORE" \
  "does not retain the inlined workflow-entry-points branch" \
  "^##[[:space:]]+Workflow entry points"
reject_pattern "$CORE" \
  "does not retain the inlined agent-loop procedure branch" \
  "^##[[:space:]]+Agent loop efficiency"
reject_pattern "$CORE" \
  "does not retain the inlined UI-craft procedure branch" \
  "^##[[:space:]]+UI and interaction craft"

group "stale prompt artifacts"

SOURCE_FILES=("$CORE")
for source in "$PREAMBLES"/*.md; do
  [[ -f "$source" ]] && SOURCE_FILES+=("$source")
done

for source in "${SOURCE_FILES[@]}"; do
  reject_pattern "$source" \
    "rejects stale automatic-memory language in $(basename "$source")" \
    "(automatically|automatic)[[:space:]]+(write|create|save|record|grow).{0,80}(memory|memories)"
  reject_pattern "$source" \
    "rejects stale automatic-handoff language in $(basename "$source")" \
    "(automatically|automatic)[[:space:]]+(write|create|save|record|compact).{0,80}handoff"
  reject_pattern "$source" \
    "rejects the known malformed Claude output token in $(basename "$source")" \
    "bu[[:space:]][[:space:]][[:space:]][[:space:]][[:space:]]ilding"
done

echo
echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
