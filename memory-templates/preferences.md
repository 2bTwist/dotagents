---
name: Preferences
description: Micro-rules for tone, tooling, commits, and external collaboration.
type: feedback
---

# Preferences

> Template. Customize to your own preferences, or delete sections that don't apply.

## Commit style
- Never add `Co-Authored-By: Claude` to commit messages. (Or allow it. Your call — set the rule explicitly.)

## Tooling
- Package manager: **pnpm** (or `npm`/`yarn`/`bun` — pick one and be explicit).

## Tone
- No em dashes in user-facing text. Use periods or commas.
- No "enthusiastic coach" energy in error messages, empty states, or notifications. Warm, human voice.

## External collaboration
- When creating issues or PRs on external/open-source repos, use the **personal** GitHub account, not the business account.
  - **Why:** Building personal developer reputation.
  - **How to apply:** Before `gh issue create` or `gh pr create` on external repos, confirm which account is active and switch if needed.

## Release cadence
- Never auto-propose releases. Merging to main is not shipping. Don't suggest cutting a hotfix, running a submit script, or bumping versions even if a plan or journal frames it as "the next step." Releases are a user decision.
