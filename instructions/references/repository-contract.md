# Repository contract

Read when writing or reviewing a repository's `AGENTS.md` / `CLAUDE.md`, or before the first
test or first persistent state in a repository that lacks these sections.

## Test policy

Every repository's contract defines what earns a test, when it is written, and what is out of
scope.

## State contract

A stateful repository's contract also defines:

- authoritative and derived state
- write and transaction boundaries
- invariants
- failure and recovery behavior
- retention and deletion rules
- migration rules
- realistic verification

Keep these facts in the repository contract, not only in global instructions.
