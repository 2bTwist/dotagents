# Dispatching a phase's parts in parallel

Reached from `SKILL.md` step 1 when a phase holds parts that touch disjoint file sets and do not
depend on each other. If your harness has no sub-agents, build the phase serially and say so once;
everything else in `SKILL.md` is unaffected.

Your core instructions own the dispatch policy under **Agent loop efficiency**: blast radius,
disjoint file sets, briefing contents, an explicit model per dispatch, and a green report being a
claim rather than evidence. This file owns the procedure that applies it. Follow the policy, do not
restate it.

## 1. Split

Keep the parts where a mistake is expensive and invisible in a diff. Delegate the parts where a
mistake surfaces as a failing test or an obvious diff. Give every part a disjoint file set.

**Done when:** every file the phase will touch belongs to exactly one part, and you can say which
parts you kept and why.

## 2. Classify each part before dispatching

| | Runs alone | Needs the user |
|---|---|---|
| What it looks like | A self-contained change with a stated gate | A judgment call, a taste decision, an ambiguous requirement, anything needing a live exchange |
| Who does it | An agent | You, with the user |

An agent that answers the user's side of a question has broken this. If a part turns out to need the
user once it is already running, it stops and reports rather than deciding on their behalf.

**Done when:** no dispatched part contains a decision that was the user's to make.

## 3. Brief

Each brief carries the ground truth by path rather than your paraphrase of it, the part's own file
set, the files belonging to other parts, the evidence its report must carry, an instruction to stop
and report a blocker rather than route around it, and "say what you could not do".

Naming the neighbours' files is what stops a concurrent edit from being reported as a bug.

**Done when:** every brief names its own files, its neighbours' files, and its evidence bar.

## 4. Record the dispatch in the plan file

Before sending anything, append the dispatch to the phase in the plan file:

```markdown
- [ ] dispatched: <part name> | files: <paths> | model: <tier> | status: running
```

The plan is the durable artifact. A session that dies mid-phase leaves this behind, so the next one
can tell what was in flight from what was finished instead of reconstructing it from memory. Update
`status:` as parts return.

**Done when:** every part in flight has a line in the plan file.

## 5. Dispatch

Send every independent part in ONE message. Parts sent in separate messages queue instead of
overlapping, which makes the parallelism decorative. Pass an explicit model on each. Start any review
concurrently with the build rather than after it.

**Worktree isolation branches from the default branch, not from your working tree.** An agent given
its own worktree sees a clean checkout of the remote default branch, so uncommitted work in progress
is invisible to it. Before dispatching writers into worktrees, either commit the work they build on,
or configure the worktree base ref to branch from HEAD, or leave the parts in the shared tree and
rely on the disjoint file sets to keep them apart. Read-only parts are unaffected.

One case is deliberately serial: a test written to fail first. Its whole value is the ordering, so
wait for the author to report red before dispatching the implementation it covers.

**Done when:** all independent parts left in a single message.

## 6. Supervise

Wait for completion notifications and build the parts you kept while they run. A part that reports a
blocker gets a real answer, from you or from the user. Route blocked work back, never around.

Permission boundaries do not transfer. An action refused in this session stays refused: asking
another agent or another session to perform it launders a decision that belonged to the user.

**Done when:** every dispatched part is accounted for as returned, failed, or abandoned with a
stated reason, and the plan file agrees.

## 7. Integrate, and treat this as a gate

Read every diff. Merge the worktree branches yourself; conflicts here mean the file sets were not
actually disjoint, which is a splitting error to learn from rather than a merge to force. Re-run the
phase's automated criteria against the merged result, not against any agent's report of them. Check
each load-bearing claim against the source that supposedly backs it.

An agent reporting success is the author of that claim, and author bias is what this step exists to
catch.

**Done when:** the phase's criteria pass on the merged tree, and nothing reaches the user that you
have not verified yourself.
