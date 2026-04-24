---
description: Execute an approved plan one phase at a time. Ticks checkboxes, pauses for manual verification.
argument-hint: "<plan path>"
---

# Implement Plan

> $@

Your task: execute the approved plan at the path above, one phase at a time. The plan is the authority. Do not go beyond its scope.

## Your tools
You have `read`, `write`, `edit`, `bash`, `grep`, `find`, `ls`. That is all.

## Hard rules

- Read the plan FULLY before starting (no partial reads).
- Check for existing `- [x]` marks to resume mid-execution.
- One phase at a time. Pause between phases for the user's manual verification.
- If the plan doesn't match reality, STOP. Report the mismatch. Do not guess.
- Tick automated boxes after running them. Never tick manual boxes yourself.

## Steps

### 1. Load the plan
Read the plan file completely. Note existing checkmarks — resume from the first unchecked item.

### 2. Read referenced files
For the current phase, read every file the plan mentions, fully, before editing.

### 3. Implement phase N
Make the code changes described in the phase. Use `edit` for existing files, `write` for new ones.

### 4. Run automated verification
Run each automated command listed in the phase. If any fail, debug and fix before proceeding. Tick each box with `edit` on the plan file as checks pass.

### 5. Pause for manual verification
When automated checks are all green, stop and report:

```
Phase N complete — ready for manual verification.

Automated checks passed:
- [x] <check 1>
- [x] <check 2>

Please verify manually:
- [ ] <manual item 1>
- [ ] <manual item 2>

Tell me when manual verification is done and I'll proceed to Phase N+1.
```

Do NOT tick the manual boxes. The user ticks those.

### 6. On user confirmation, proceed
If the user confirms, tick the manual boxes yourself (only after their confirmation) and start Phase N+1.

## If you hit a mismatch

Stop immediately. Report:

```
Issue in Phase N:
  Expected: <what the plan says>
  Found: <actual situation>
  Why this matters: <brief explanation>

How should I proceed?
```

Do not silently adapt. Do not guess. The user decides.

## Resuming work

If the plan has existing `- [x]` marks:
- Trust that completed work is done
- Pick up from the first unchecked item
- Verify prior work only if something seems off

## If the model is small (qwen2.5-coder:7b)

Do one file at a time within a phase. Verify after each file before moving to the next. If a phase has more than 3 file changes, pause halfway and re-orient on the plan.

## Anti-patterns

- Racing through multiple phases without pausing
- Ticking manual verification boxes without user confirmation
- Silently "fixing" plan mismatches instead of reporting them
- Refactoring or adding scope beyond what the phase says
- Amending commits from previous phases
