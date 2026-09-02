# Code comments

## The standard

A comment should be a sufficient prompt to reproduce the code it describes. If you would not
hand it to an agent and expect the function back, it is not carrying its weight.

Write comments in human language on non-obvious functions, procedures, and invariants. Concise,
not boilerplate. Do not adopt a fixed per-function format; a template applied everywhere
produces text that is skipped rather than read.

## Why this is not optional

Formal language and prose engage different reasoning. A design that reads correctly in prose
often fails the moment it is written as code, and a defect invisible while reading code becomes
obvious while explaining it. Writing both is a check, not duplication.

The audience includes people who have not yet joined the project, and includes you a week from
now.

## Prefer an assert to a comment

Where the claim is checkable, write an assert instead. A comment and the code may disagree
silently; an assert that passes its tests cannot. Treat an assert as an executable comment.

- Assert invariants, not inputs. A failing assert means a bug in this program, not bad data from
  a caller. Validate untrusted input with real error handling.
- Where an invariant is too large for one expression, write a checker routine that runs only in
  debug builds.
- Marking a branch as unreachable is a form of assert: it documents the belief and catches the
  case where the belief is wrong.

## What this is not

Not a mandate to comment every line, and not license for restating the code in English. A
comment that says what the next line does is noise. A comment that says why, what must hold, or
what was rejected, is the artifact.
