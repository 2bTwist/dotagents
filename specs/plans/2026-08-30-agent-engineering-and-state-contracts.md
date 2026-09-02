# Agent Engineering and Repository State Contracts Implementation Plan

## Overview

Apply the engineering lessons from the Turso and Convex founder discussion without
turning a podcast transcript into technical authority. Keep cross-project agent
behavior in the canonical dotagents global policy. Put concrete persistence,
database, privacy, recovery, and verification guarantees in each owned repository
that owns or materially coordinates persistent state.

The user completed the `grill-me` decision interview and approved consecutive
execution without phase pauses. Architectural changes still require the explicit
architecture gate defined below; this plan does not silently authorize product or
data-model redesigns.

## Current State Analysis

- `instructions/core.md` is the canonical portable global policy rendered into all
  harnesses by `install.sh` (`install.sh:176-211`).
- Managed blocks preserve hand-written content outside their markers
  (`install.d/_lib.sh:131-157`).
- `test/global-instructions-pruning-smoke.sh` behaviorally pins the lean global core,
  but the README verification list does not yet include it (`README.md:232-250`).
- The current core partially covers technical judgment and suspicious measurements,
  but does not yet encode risk-scaled rigor, the high-risk system-model gate,
  touched-surface repair, hard-to-misuse abstractions, compact reasoning handoffs,
  repository state-contract routing, or the architecture pause.
- The protected 2026-08-29 migration ledger records 27 in-scope repositories, 25
  completed context migrations, one deleted repository, and active Anonymage as the
  sole blocked repository (`summary.tsv:1-18`). It does not classify persistent state
  or link database contracts.
- BeSeen already provides a strong local-first state contract in `AGENTS.md:1-71`.
  Billing separates its durable Registry from disposable derived state in
  `docs/adr/0001-registry-derived-database-split.md:1-5`. These are the patterns to
  reuse, not text to copy blindly.

## Desired End State

1. Claude and Codex receive one lean global policy that requires system understanding,
   risk-scaled rigor, independent verification, expert tool use, architecture pauses,
   and concise learning-oriented handoffs.
2. Every stable, owned repository in the existing migration scope is classified as
   stateful or stateless with evidence and risk level.
3. Every stateful repository has a narrow, evidence-backed state/database contract in
   its canonical `AGENTS.md`, or its existing canonical repository documentation when
   it intentionally has no repository adapter. Thin `CLAUDE.md` adapters remain
   unchanged.
4. Demonstrated contradictions and non-architectural safety gaps found during the
   audit are corrected. Architectural gaps are recorded with their missing decision
   and are not silently implemented.
5. No operational data, PHI, secrets, live services, external repositories, active
   Anonymage work, or Transafrik files are touched.

### Key Discoveries

- Passing tests can still validate the wrong oracle or omit component interactions.
- The deeper a component is in the stack, the more its guarantees affect callers.
- Existing high-quality contracts express ownership, atomicity, migration,
  recoverability, and realistic verification as observable behavior.
- For this audit, persistent system state survives a process and is later reopened,
  mutated, or used to coordinate behavior. One-shot exports that the producing program
  does not manage afterward are outputs, not repository state. They keep their normal
  overwrite/privacy contracts without triggering a database contract.

## What We're NOT Doing

- No changes to Transafrik, external clones, archived/dormant repositories, deleted
  TextureSense, or active Anonymage.
- No reading of billing operational data, PHI, databases, spreadsheets, exports,
  reports, raw inputs, `corrections.toml`, or `.schema`.
- No live database, provider, deployment, release, or authenticated hosted-model run.
- No speculative database redesign, provider migration, ORM adoption, consistency
  change, or broad refactor.
- No commits.

## Implementation Approach

Use layered policy. Keep only behavioral triggers in the always-loaded core and route
the detailed system-model procedure to an on-demand portable reference. Classify
repositories from current code and configuration, not filename inference or archived
memory. Update only canonical repository contracts. Treat missing verification as a
gap, not proof of broken behavior.

Risk tiers:

- **High:** a failure can corrupt, lose, expose, or misattribute authoritative,
  security-sensitive, financial, identity, or shared coordination state. Require a
  system model, independent evidence, failure/recovery checks, and reversal analysis.
- **Medium:** CMS, cache, persistent configuration, model state, or external operational
  guidance where impact is material but localized or the repository does not directly
  own authoritative data mutation.
- **Low:** preferences or other replaceable managed state with bounded recovery cost.

## Phase 1: Global Policy and Independent Acceptance

### Overview

Encode the resolved cross-project principles while keeping the core below the existing
1,319-word acceptance ceiling.

### Changes Required

#### 1. Canonical global policy

**File**: `/Users/edmond/Projects/dotagents/instructions/core.md`

Add or consolidate concise rules for:

- “Do not trust generated code merely because tests pass. Understand the system,
  identify its invariants, and verify risky interactions.”
- Risk-scaled rigor and explicit high-risk triggers.
- User/product authority versus evidence-backed technical responsibility.
- Touched-surface repair without unrelated cleanup.
- Guarantees enforced at the lowest capable layer and hard-to-misuse interfaces.
- A compact reasoning handoff for non-trivial work.
- Surprisingly good or bad measurements as possible measurement failures.
- A mandatory architecture pause and confirmation for durable system decisions.
- Stateful repositories owning their concrete state/database contracts locally.

#### 2. On-demand high-risk procedure

**File**: `/Users/edmond/Projects/dotagents/instructions/references/high-risk-engineering.md`

Define the compact system model: promises, state ownership, invariants, interactions,
failure/recovery, verification oracle, alternatives, future constraints, migration,
and reversal. Make clear that the transcript supplies hypotheses while installed
versions, primary sources, current code, and production evidence determine facts.

#### 3. Independent behavior tests and documentation

**Files**:

- `/Users/edmond/Projects/dotagents/test/global-instructions-pruning-smoke.sh`
- `/Users/edmond/Projects/dotagents/test/instructions-smoke.sh`
- `/Users/edmond/Projects/dotagents/README.md`
- `/Users/edmond/Projects/dotagents/instructions/references/README.md`
- `/Users/edmond/Projects/dotagents/install.sh`

Have an independent agent author red-first assertions from the resolved requirements.
Add the pruning suite to the documented verification list and verify that the portable
reference is installed byte-identically. Add and test `--instructions-only` so global
policy installation cannot create or overwrite skills or agents. Document portable
references separately from gitignored `*.local.md` machine references.

The architecture pause triggers on changes to persistent-state ownership, durable data
formats, public interfaces, trust/security boundaries, concurrency/consistency
guarantees, dependency topology, or deployment shape. Its decision artifact records
the current system model, credible alternatives, tradeoffs, future constraints,
migration/recovery, verification evidence, and reversal cost. Implementation resumes
only after explicit user confirmation of the recommended option. A discovered active
safety issue may halt work immediately, but does not authorize an unconfirmed redesign.

### Success Criteria

#### Automated Verification

- [x] `./test/global-instructions-pruning-smoke.sh`
- [x] `./test/instructions-smoke.sh`
- [x] `./test/install-smoke.sh`
- [x] `./test/repository-adapter-smoke.sh`
- [x] `./test/optional-smoke.sh`
- [x] `shellcheck -S warning install.sh install.d/*.sh optional/*/install.sh test/*.sh`
- [x] `git diff --check`
- [x] `./install.sh --target=claude --target=codex --instructions-only`
- [x] Managed regions in `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` compare
      byte-identically with `instructions/core.md`.
- [x] Snapshot and compare all content outside both managed regions and all installed
      references before/after installation; only the named managed blocks,
      `references/README.md`, and `references/high-risk-engineering.md` may change.
- [x] Scan every portable reference for machine paths, maintainer identifiers, and
      secret-shaped material; continue to exempt gitignored `*.local.md` files.

#### Manual Verification

- [x] Read the final global policy once for contradictory rules and prompt bloat.
- [x] Confirm a fresh session is required; do not make a hosted model call.

---

## Phase 2: Read-Only Repository Classification

### Overview

Extend the protected ledger without reopening the completed context migration.

### Changes Required

#### 1. New stateful-repository ledger

**File**:
`/Users/edmond/.local/state/agent-context-triage/2026-08-29/state-contracts.tsv`

Record path, ownership, activity, stateful classification, state kind, risk tier,
contract status, evidence paths, identified gaps, remediation status, and verification.

Classification rule: a repository is stateful when it owns or materially coordinates
information that survives a process and is later reopened, mutated, or relied on for
future behavior. Host-provided persistence ports and operational control repositories
count. One-shot exports and tracked source/goldens do not count merely because they are
files.

Initial evidence-backed stateful set:

| Risk | Repositories |
|---|---|
| High | BeSeen, Cogito, DeepDive Website, baasdk, billing, bitpass, interactive, parallel-agent-fs, text-rental |
| Medium | Beseen-Web/beseen-web, component-previewer, dotagents, homelab, pitch-value, yt2md-web |
| Low | portfolio |

Initial stateless set:

- batchhome, batchhome/building-3d, archscore, edit-validity, larping-speed-test,
  termdoc, texture-to-sound, vtt2md, and yt2md.

#### 2. Program decisions and summary

**Files**:

- `/Users/edmond/.local/state/agent-context-triage/2026-08-29/program-decisions.md`
- `/Users/edmond/.local/state/agent-context-triage/2026-08-29/summary.tsv`

Append the confirmed four-phase program, exclusions, risk definitions, and aggregate
state-contract counts. Preserve the earlier migration history rather than replacing it.

Before any write, create a fresh protected porcelain-status snapshot for every
eligible, excluded, and non-owned repository. For excluded, non-owned, billing-forbidden,
or otherwise sensitive paths, record only status plus non-content metadata such as
path, type, size, and modification time. Content-hash only explicitly safe in-scope
contract, source, and test files named by this plan. Hash the safe pre-change protected
ledger files. Do not use the stale 2026-08-29 dirty counts as preservation evidence.

#### 3. Schema-aware ledger validator

**File**:
`/Users/edmond/Projects/dotagents/test/repository-state-contract-ledger-smoke.sh`

Accept the migration inventory and new ledger as explicit arguments. Validate exact
eligible-path coverage, exclusions, unique rows, enum values, evidence for both
stateful and stateless decisions, contract dispositions, and summary counts. Keep the
test portable by avoiding hard-coded home paths. Encode dotagents' deliberate README
contract exception explicitly rather than treating a missing adapter as success.

### Success Criteria

#### Automated Verification

- [x] `./test/repository-state-contract-ledger-smoke.sh /Users/edmond/.local/state/agent-context-triage/2026-08-29/migration-results.tsv /Users/edmond/.local/state/agent-context-triage/2026-08-29/state-contracts.tsv`
- [x] Fresh before/after porcelain status and non-content path metadata are identical
      for every excluded and non-owned repository.
- [x] Every row, including stateless rows, names current-code evidence and a contract
      disposition.
- [x] Protected pre-existing ledger prefixes and hashes are preserved except for the
      explicitly append-only `program-decisions.md` and new summary metrics.

#### Manual Verification

- [x] Re-read every high-risk classification and its cited source.
- [x] Confirm no operational or live data was accessed.

---

## Phase 3: Repository-Local State and Database Contracts

### Overview

Keep strong existing contracts intact and add only missing, evidence-backed guarantees.

### Changes Required

#### 1. Strong existing contracts, verify without rewriting

**Files**:

- `/Users/edmond/Projects/BeSeen/AGENTS.md`
- `/Users/edmond/Projects/billing/AGENTS.md`
- `/Users/edmond/Projects/text-rental/AGENTS.md`

Record these as contract-complete unless new current-code evidence contradicts them.

#### 2. High-risk contract additions

**Files**:

- `/Users/edmond/Projects/Cogito/AGENTS.md`
- `/Users/edmond/Projects/DeepDive Website/AGENTS.md`
- `/Users/edmond/Projects/baasdk/AGENTS.md`
- `/Users/edmond/Projects/bitpass/AGENTS.md`
- `/Users/edmond/Projects/interactive/AGENTS.md`
- `/Users/edmond/Projects/parallel-agent-fs/AGENTS.md`

Add only verified ownership, durability, consistency, migration, failure/recovery,
privacy, and realistic-verification boundaries. Mark known gaps as gaps, not promises.

#### 3. Medium- and low-risk contract additions

**Files**:

- `/Users/edmond/Projects/Beseen-Web/beseen-web/AGENTS.md`
- `/Users/edmond/Projects/component-previewer/AGENTS.md`
- `/Users/edmond/Projects/dotagents/README.md`
- `/Users/edmond/Projects/homelab/AGENTS.md`
- `/Users/edmond/Projects/pitch-value/AGENTS.md`
- `/Users/edmond/Projects/portfolio/AGENTS.md`
- `/Users/edmond/Projects/yt2md-web/AGENTS.md`

Document CMS authority, cache retention, preferences, host-provided persistence,
configuration installation, operational topology, and model artifacts only to the
extent current code proves them.

#### 4. Thin adapters

**Files**: the corresponding existing `CLAUDE.md` files. Dotagents is exempt because
its own repository does not use a repository adapter; its state boundary belongs in
the canonical README and installer tests.

Do not edit their content. Verify each remains exactly `@AGENTS.md` plus a terminal
newline.

### Success Criteria

#### Automated Verification

- [x] For every edited repository: `git diff --check -- AGENTS.md CLAUDE.md`
- [x] For every edited repository that uses the adapter convention, excluding the
      documented dotagents exception:
      `cmp -s CLAUDE.md <(printf '@AGENTS.md\n')`
- [x] BeSeen: `pnpm run check && pnpm run test:run`
- [x] BeSeen Web: run `pnpm run check`; record production build as undriven because
      current routes contact Sanity.
- [x] component-previewer: `pnpm lint && pnpm typecheck && pnpm test && pnpm build`
- [x] dotagents: run every Phase 1 suite.
- [x] homelab: `git diff --check -- AGENTS.md CLAUDE.md`; do not contact hosts or
      network services.
- [x] Cogito: `swift test --package-path Packages/CogitoKit`; record app/device legs.
- [x] DeepDive: `pnpm lint && pnpm typecheck`; record build as undriven because current
      routes contact Sanity.
- [x] baasdk: `pnpm verify`
- [x] billing: `uv run pytest -q tests/test_repo_context.py && uv run python scripts/check_repo_context.py`
- [x] bitpass: `pnpm typecheck && pnpm test:mcp-handshake`
- [x] interactive: `node --check serve.js && node --check hook.js && node test-bridge.js`
- [x] parallel-agent-fs: `python3 test_concurrency.py`; do not run `test_broker.py`
      without a proven disposable Postgres database.
- [x] pitch-value: `uv run ruff check . && uv run pytest -m "not network"`
- [x] portfolio: `pnpm lint && pnpm test && pnpm build && pnpm size && pnpm e2e`;
      record the browser leg if the pinned browser is unavailable.
- [x] text-rental: `bun run check`; run `bun test` only after its isolated Postgres
      creation path is proven against a disposable local server. That proof is outside
      this no-database-contact program, so record `bun test` as undriven. Never run
      migrations against a shared or operational database.
- [x] yt2md-web: `pnpm test`

#### Manual Verification

- [x] Every added sentence cites current evidence in the audit ledger.
- [x] No contract converts an unimplemented design into a claimed guarantee.
- [x] Existing user work outside `AGENTS.md` remains byte-identical.

---

## Phase 4: Risk-Ordered Remediation and Closeout

### Overview

Correct demonstrated, reversible contradictions and safety-gate gaps. Record but do
not silently implement architectural changes such as provider-level idempotency,
credential-vault design, consistency changes, or database redesign.

### Changes Required

#### 1. Independent red-first tests

For each implementation fix, have a separate agent derive the failing test from the
contract before implementation. Freeze the test between red and green.

#### 2. Confirmed non-architectural corrections

Candidate files, only if current evidence still reproduces the mismatch:

- `/Users/edmond/Projects/text-rental/README.md`
- `/Users/edmond/Projects/text-rental/docs/design/security-and-privacy.md`
- `/Users/edmond/Projects/yt2md/AGENTS.md`
- `/Users/edmond/Projects/parallel-agent-fs/test_broker.py`
- `/Users/edmond/Projects/parallel-agent-fs/test_broker_guard.py`
- `/Users/edmond/Projects/parallel-agent-fs/AGENTS.md`

Correct stale schema counts/claims and the `yt2md` dependency-contract contradiction.
For the broker test, require no default DSN, an explicit destructive-test opt-in, and
a dedicated database identity. Refusal must occur before any connection. An independent
test must prove zero connection/mutation when the guard is absent. A green broker run
still requires a freshly provisioned disposable database and remains undriven otherwise.
The independent guard check is `python3 test_broker_guard.py`.

#### 3. Architectural gap register

**File**:
`/Users/edmond/.local/state/agent-context-triage/2026-08-29/state-contracts.tsv`

Record DeepDive webhook idempotency, bitpass credential boundaries, interactive user
settings recovery, Cogito cross-boundary failure injection, and provider-backed baasdk
integrity as explicit gaps with required evidence. These remain unimplemented until a
repository-specific architecture decision is confirmed.

#### 4. Closeout

Update the protected summary and program decisions with verified outcomes, undriven
legs, and exact changed files. Do not mark Anonymage complete or start the archive
retention clock.

### Success Criteria

#### Automated Verification

- [x] Run each affected repository's exact gate from Phase 3.
- [x] Re-run all dotagents Phase 1 suites.
- [x] `git diff --check` in every changed repository.
- [x] Compare final dirty-path inventories with the pre-change snapshots and confirm
      all new paths are explicitly listed in this plan.
- [x] The final ledger has no high-risk row with an empty gap, disposition,
      verification, or remediation field.

#### Manual Verification

- [x] Review the final high-risk ledger against its source citations.
- [x] Confirm all architectural gaps remain explicit rather than disguised as done.
- [x] Confirm no release, deployment, live migration, external message, or commit occurred.

## Testing Strategy

- Independent acceptance tests pin global behavior before implementation.
- Repository contracts are checked against source/schema/configuration evidence.
- Documentation-only edits run repository context and syntax gates.
- Code safety fixes use frozen red-first tests plus the repository gate.
- Real database or provider checks run only against already-proven disposable
  environments; otherwise the undriven leg is named.

## Performance Considerations

No performance claim is accepted from a synthetic number alone. Surprisingly good or
bad results require reproduction, oracle inspection, and a user-relevant workload.
This program does not run new benchmarks unless a concrete remediation requires one.

## Migration Notes

This is an instruction and verification migration, not a user or production data
migration. No production schema, provider, shared database, or operational state is
changed. A repository test may create disposable local state only when its isolation is
proven first. Existing dirty work is preserved and each edit remains uncommitted.

## References

- User-provided transcript: `Turso x Convex: Database Founder Friend Time`
- Existing migration decisions:
  `/Users/edmond/.local/state/agent-context-triage/2026-08-29/program-decisions.md`
- Existing migration ledger:
  `/Users/edmond/.local/state/agent-context-triage/2026-08-29/migration-results.tsv`
- BeSeen state contract: `/Users/edmond/Projects/BeSeen/AGENTS.md`
- Billing state split:
  `/Users/edmond/Projects/billing/docs/adr/0001-registry-derived-database-split.md`
- `plan` and `implement`: execute this approved phased workflow.
- `rigor`: use for consequential measurements and claims.
- `domain-modeling`: use when a repository's state ownership terminology is unclear.
- `sqlalchemy-alembic-expert`: use only for an actual SQLAlchemy/Alembic change.
- `supabase-postgres-best-practices`: use only for a concrete Supabase/Postgres change.
