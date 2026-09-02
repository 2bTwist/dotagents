# High-risk engineering

Load this procedure before work whose failure can corrupt, lose, expose, misattribute, or
irreversibly change authoritative data, identity, money, credentials, security boundaries,
external systems, concurrent coordination, migrations, or shared durable state.

## Establish the system model

Write down the smallest model that makes the change reviewable before implementation:

1. Product promise and accepted risk.
2. Authoritative state, derived state, and state ownership.
3. Write, transaction, concurrency, and external-effect boundaries.
4. Invariants that must hold before, during, and after failure.
5. Interactions across components, including retries, partial completion, cancellation, and
   duplicate delivery.
6. Recovery, rollback, migration, retention, deletion, and audit behavior.
7. Independent verification oracle, verification evidence, and the real user path to drive.

Use current code and its system model, schemas, installed-version documentation, primary sources,
and production evidence as authority. Treat transcript claims and expert opinions as hypotheses,
not facts, until those sources support them.

## Stop for architecture

An architecture decision changes persistent state ownership, a durable format, a public interface,
a trust or security boundary, consistency or concurrency semantics, dependency topology, or
deployment shape. Before making one:

- state the decision and why the current design is insufficient;
- compare credible alternatives, their tradeoffs, and the strongest case against the recommendation;
- describe future constraints, maintenance and migration cost, failure modes, and reversal cost;
- identify what evidence would change the recommendation; and
- obtain explicit user confirmation before implementation.

Pause for confirmation before implementation can resume. An active safety halt remains in force
until its stated condition is resolved.

Do not disguise an architecture decision as cleanup or let prior implementation effort decide it.

## Build guarantees into the system

Put each guarantee at the lowest layer that can enforce it for every writer. Prefer constraints and
transactions for stored-state invariants, types for exhaustiveness, and narrow interfaces that make
unsafe use difficult. Tests demonstrate behavior but do not replace these controls.

Repair defects discovered on the touched path when they affect the requested behavior or its
guarantees. Record unrelated defects without broadening the change.

For a stateful repository, keep an evidence-backed local contract naming authoritative and derived
state, write boundaries, invariants, failure and recovery behavior, retention and deletion,
migrations, and realistic verification. Update it when the implemented model changes.

## Verify independently

- Derive acceptance checks from the requirement before implementation and keep their oracle
  independent from the author where practical.
- Exercise risky interactions with realistic integration checks, failure injection, or a real user
  path. State every leg that remains undriven.
- Treat unexpectedly good and unexpectedly bad measurements as possible harness or oracle defects.
  Reproduce them cleanly against a representative workload before drawing a conclusion.
- Prefer injectable seams over mocks. Substitute the clock, allocator, filesystem, transport, or
  syscall layer so real failure paths execute rather than an assertion about how a mock was
  called. Loop the injection: fail the first allocation, then the second, and continue until the
  operation completes without failing.
- Test the deliverable, not only the source. A build that requires special flags to be testable
  is not testing what ships. Do not assume the compiler, bundler, or minifier is correct.
- Layer the oracles; each is blind to what the next finds. Coverage finds untaken branches.
  Fuzzing finds inputs coverage never suggested, and high-coverage code is not thereby immune.
  Differential and semantic checks find wrong answers that neither crash nor fail an assertion.
  Adversarial review finds pathological inputs the others do not construct.
- Do not treat test volume as waste. Test code larger than the source it covers is normal, and
  code that exists only to make the system testable is a legitimate part of the deliverable.
- Treat an agent-found defect as high-value evidence and an agent-proposed fix as an unreviewed
  hypothesis. Before accepting a fix that adds a limit, a fallback, or a retry, look for the
  known solution to that problem class; the standard answer is often simpler and faster than the
  workaround.
- Never weaken a gate, narrow a workload, or redefine a metric merely to make a result pass.

## Close the work

Provide a compact reasoning handoff that states what changed and why, the guarantees preserved,
the evidence used, undriven checks and uncertainty, and any decision whose reversal cost matters.
