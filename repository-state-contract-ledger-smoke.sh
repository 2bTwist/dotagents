#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 MIGRATION_RESULTS_TSV STATE_CONTRACTS_TSV" >&2
  exit 2
fi

migration_results=$1
state_contracts=$2
ledger_dir=$(dirname "$state_contracts")
program_decisions="$ledger_dir/program-decisions.md"
summary="$ledger_dir/summary.tsv"

for required in "$migration_results" "$state_contracts" "$program_decisions" "$summary"; do
  if [[ ! -f "$required" ]]; then
    echo "missing required ledger file: $required" >&2
    exit 1
  fi
done

awk -F '\t' '
function fail(message) { print "FAIL [repository-state-contract-ledger] " message > "/dev/stderr"; failed = 1 }
function supported(value, values,   pattern) {
  pattern = "^(" values ")$"
  return value ~ pattern
}
function expected(path) {
  if (path ~ /\/Projects\/BeSeen$/) return "stateful\034high"
  if (path ~ /\/Projects\/Cogito$/) return "stateful\034high"
  if (path ~ /\/Projects\/DeepDive Website$/) return "stateful\034high"
  if (path ~ /\/Projects\/baasdk$/) return "stateful\034high"
  if (path ~ /\/Projects\/billing$/) return "stateful\034high"
  if (path ~ /\/Projects\/bitpass$/) return "stateful\034high"
  if (path ~ /\/Projects\/interactive$/) return "stateful\034high"
  if (path ~ /\/Projects\/parallel-agent-fs$/) return "stateful\034high"
  if (path ~ /\/Projects\/text-rental$/) return "stateful\034high"
  if (path ~ /\/Projects\/Beseen-Web\/beseen-web$/) return "stateful\034medium"
  if (path ~ /\/Projects\/component-previewer$/) return "stateful\034medium"
  if (path ~ /\/Projects\/dotagents$/) return "stateful\034medium"
  if (path ~ /\/Projects\/homelab$/) return "stateful\034medium"
  if (path ~ /\/Projects\/pitch-value$/) return "stateful\034medium"
  if (path ~ /\/Projects\/yt2md-web$/) return "stateful\034medium"
  if (path ~ /\/Projects\/portfolio$/) return "stateful\034low"
  return "stateless\034none"
}

FILENAME == ARGV[1] {
  if (FNR == 1) {
    if ($1 != "repository_path") fail("migration inventory must start with repository_path")
    next
  }
  if ($1 == "") fail("migration inventory has an empty repository_path at line " FNR)
  if ($6 == "removed" || $6 == "blocked") {
    excluded[$1] = 1
    next
  }
  if ($1 in eligible) fail("migration inventory repeats eligible path " $1)
  eligible[$1] = 1
  eligible_count++
  expected_pair = expected($1)
  split(expected_pair, pair, "\034")
  required_classification[$1] = pair[1]
  required_risk[$1] = pair[2]
  next
}

FILENAME == ARGV[2] {
  if (FNR == 1) {
    expected_header = "repository_path\townership\tactivity\tstateful_classification\tstate_kind\trisk_tier\tcontract_disposition\tevidence_paths\tidentified_gaps\tremediation_status\tverification"
    if ($0 != expected_header) fail("state-contracts.tsv header does not match the protected schema")
    next
  }
  if (NF != 11) { fail("state-contracts.tsv line " FNR " has " NF " columns, expected 11"); next }
  path = $1
  if (path == "") { fail("state-contracts.tsv line " FNR " has an empty repository_path"); next }
  if (path in rows) { fail("state-contracts.tsv repeats path " path); next }
  rows[path] = 1
  if (!(path in eligible)) { fail("state-contracts.tsv contains non-eligible path " path); next }
  if (!supported($2, "owned|user-controlled")) fail(path " has invalid ownership " $2)
  if (!supported($3, "active|stable")) fail(path " has invalid activity " $3)
  if (!supported($4, "stateful|stateless")) fail(path " has invalid stateful_classification " $4)
  if (!supported($5, "authoritative-data|identity-or-credential|financial|shared-coordination|cms|host-persistence|configuration|operational-topology|model-artifact|cache|preference|none")) fail(path " has invalid state_kind " $5)
  if (!supported($6, "high|medium|low|none")) fail(path " has invalid risk_tier " $6)
  if (!supported($7, "complete|add-contract|existing-contract|readme-contract-exception|not-applicable")) fail(path " has invalid contract_disposition " $7)
  if (!supported($10, "complete|planned|verify-only|not-applicable")) fail(path " has invalid remediation_status " $10)
  for (field = 2; field <= 11; field++) {
    if ($field == "") fail(path " has an empty required field at column " field)
  }
  if ($8 ~ /(^|;)(none|n\/a|not-applicable)(;|$)/) fail(path " must cite current-code evidence, not a placeholder")
  evidence_count = split($8, evidence, ";")
  for (item = 1; item <= evidence_count; item++) {
    if (evidence[item] == "" || evidence[item] !~ /[.\/]/) fail(path " has invalid evidence path " evidence[item])
  }
  if ($4 != required_classification[path]) fail(path " classification must be " required_classification[path])
  if ($6 != required_risk[path]) fail(path " risk_tier must be " required_risk[path])
  if ($4 == "stateless" && ($5 != "none" || $6 != "none" || $7 != "not-applicable" || $10 != "not-applicable")) fail(path " stateless disposition must use none risk and not-applicable contract/remediation")
  if ($4 == "stateful" && ($5 == "none" || $6 == "none" || $7 == "not-applicable" || $10 == "not-applicable")) fail(path " stateful row has a stateless disposition")
  if (path ~ /\/Projects\/dotagents$/ && $7 != "readme-contract-exception") fail("dotagents must record its intentional README contract exception")
  next
}

END {
  for (path in eligible) if (!(path in rows)) fail("state-contracts.tsv is missing eligible path " path)
  for (path in excluded) if (path in rows) fail("state-contracts.tsv must not include excluded path " path)
  if (eligible_count != 25) fail("migration inventory did not yield the expected 25 eligible repositories")
  if (failed) exit 1
}
' "$migration_results" "$state_contracts"

if ! grep -Fq 'Agent Engineering and State Contracts' "$program_decisions" || ! grep -Fqi 'four-phase' "$program_decisions" || ! grep -Fq 'Transafrik' "$program_decisions" || ! grep -Fq 'Anonymage' "$program_decisions"; then
  echo "FAIL [repository-state-contract-ledger] program decisions must append the four-phase program and exclusions" >&2
  exit 1
fi

for expected_summary in \
  $'state-contracts\tstateful\t16' \
  $'state-contracts\tstateless\t9' \
  $'state-contracts\thigh\t9' \
  $'state-contracts\tmedium\t6' \
  $'state-contracts\tlow\t1'; do
  if ! grep -Fxq "$expected_summary" "$summary"; then
    echo "FAIL [repository-state-contract-ledger] summary is missing aggregate: $expected_summary" >&2
    exit 1
  fi
done

echo "PASS [repository-state-contract-ledger] protected repository coverage, classifications, evidence, and aggregate state-contract counts are valid"
