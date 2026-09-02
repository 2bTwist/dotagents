# Agent operations

Procedure for dispatching sub-agents and for running project development servers. `core.md`
names the role; the detail lives here.

## Sub-agent dispatch

For sub-agent work, parallelize independent tasks, assign disjoint ownership, and keep
high-blast-radius judgment in the main context. Give every dispatch an explicit model,
ground-truth paths, evidence requirements, and a stop condition. Verify returned claims
against the diff and source before relaying them.

A sub-agent that reports a defect has produced evidence, not a conclusion. Check its claim
against the source before acting on it, and check any fix it proposes against the known
solution for that problem class.

## Development servers

For development servers, check the canonical port before starting one and reuse the
project's existing server. Do not allow automatic port drift. Kill only duplicates from
the same project or processes you started. Report any intentional survivor with its PID,
port, and URL.
