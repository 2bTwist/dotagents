# Instruction references

`../core.md` is shared and public. Portable procedures that are too detailed for the system prompt
live here as tracked Markdown files. Machine-specific detail also lives here, but only in files
named `*.local.md`.

Local files are gitignored and never committed. The installer copies both portable and local
references to `<harness-root>/references/` alongside the rendered instructions.

## The convention

- One file per topic. Portable references use descriptive names. Prefix local files with a number
  to control read order: `10-tools.local.md`,
  `20-machine.local.md`.
- Write them for on-demand reading, not for the system prompt. `core.md` names the role
  ("read your environment-fixes reference"); the agent opens the file when the topic comes up.
  Nothing here is loaded eagerly, so length is cheaper here than in `core.md`.
- Anything that identifies you, names a host or an internal service, or would rot on another
  machine belongs here rather than in `core.md`. Handles, emails, LAN addresses, tailnet names,
  MCP server names, local model names, absolute paths under your home directory.

## Writing your own

Copy the shape below into `instructions/references/<topic>.local.md`. There is no schema; these
are read by an agent, not parsed.

```markdown
# Tooling (local)

- Personal CLI tools live in `<dir on PATH>`, exported from `<your shell rc>`.
- Self-hosted metasearch runs at `http://localhost:<port>`; recovery steps in `<path>`.
- Use the `<handle>` GitHub account for external issues and PRs.
```

If a file here disagrees with `core.md`, `core.md` is describing the rule and this file is
describing the machine. Follow both: the rule decides what to do, this file decides where.
