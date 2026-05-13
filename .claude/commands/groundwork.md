---
description: |
  Lay the foundation before acting. For any task class or specialized project type, fetches external canonical guidance, finds 2-3 real-world reference implementations, compares them to the current repo, and produces a phased cleanup plan that hands off to /grill-me and /implement. Topic-agnostic by design — no hardcoded task classes, authors, or stacks.

  TRIGGER when:
  - User starts a brand new project or specialized project type and has not written code yet.
  - User asks to do a task class for the first time in a repo where no instance of it exists.
  - User asks to improve, clean up, or audit a task class in a repo where instances are accreted.
  - User asks "how should I set this up", "what is the right way to do X", or "how is this typically implemented".
  - User asks for an architecture or strategy decision before code exists.

  SKIP when:
  - Quick fix, rename, typo, color change, one-liner.
  - User says "just do it", "skip the research", or invokes /oneshot.
  - Pure debugging or root-cause investigation (use /research instead).
  - Work with no implementation component (use /research for pure mapping).
model: opus
---

# Groundwork

Produce a phased cleanup plan for any task class or specialized project type. The output is implementation-ready: deviations from good practice surfaced as cleanup phases with file paths, code snippets, and verification. The plan ends ready to be stress-tested by `/grill-me` and executed by `/implement`.

The skill is **topic-agnostic**. It does not hardcode any task class, author, framework, or stack. It runs a generic research-and-compare process and lets whatever topic the user invokes it on determine what gets fetched.

## Execution style

Execute steps immediately. Do not announce what you are about to do. Start with the first tool call. Only pause where a step explicitly says to.

## CRITICAL RULES

1. **No recommendation without a source.** Every load-bearing decision cites either (a) a published author, vendor doc, or paper found in step 2, or (b) a maintained library or reference-repo file path identified in step 3. **At least one decision per cleanup phase must cite a step-3 source.** Without citations, flag explicitly as "judgment call, no canonical source."
2. **Step 3 is mandatory.** Survey real-world solutions for every invocation unless the task class is purely abstract (e.g. naming, philosophy). 2-3 reputable solutions — libraries, services, or reference repos — must be identified and cited.
3. **Convergent practice beats single-author recommendation.** Conventions that recur across multiple production repos — or libraries adopted by multiple teams — are stronger evidence than any single author's principle. When sources conflict, prefer production-tested.
4. **Vendor official docs beat tutorials** for platform, SDK, or hardware work. **Peer-reviewed papers beat blog summaries** for research-adjacent topics (ML, algorithms, distributed systems theory, cryptography, formal methods).
5. **Good existing patterns in the repo beat external canonical.** Where the repo's pattern already matches good practice, document it briefly and leave it alone. Where it deviates without justification, surface as a cleanup phase with a concrete fix. **Do not ratify the status quo. Do not propose blanket migration to whatever you read.** Judge each deviation on its merits.
6. **Output is a phased cleanup plan, not a description.** Every output must contain at least one cleanup phase with file paths, ordered steps, and verification. Descriptive ratification of the status quo is a failed run.
7. **Output is implementation-ready.** Each phase pickup-ready by `/implement`: explicit file paths (not directories), ordered steps, code snippets where they reduce ambiguity, an automated verification checklist.
8. **Do not invoke `/grill-me` automatically.** End the output with the hand-off line, then stop.
9. **Scope to the task. Don't crawl every source.** Match search depth to the topic — narrow stack means a narrow registry slice, narrow domain means a narrow paper search. Stop when convergence is clear: 2-3 converging signals beat 8 weak ones. Quality of evidence > quantity of citations.

## Argument

Natural language. The user describes what they are trying to do, however they want to phrase it. All of the following are valid:

- `/groundwork rate-limiting-middleware`
- `/groundwork I'm trying to add rate limiting to our API`
- `/groundwork we need a background job system that retries on failure`
- `/groundwork how should I structure forms for a new mobile app`
- `/groundwork build a real-time multiplayer game from scratch`

You normalize the argument internally:
- **Task-class label** for the search queries and the chat summary (e.g. "rate-limiting middleware", "background job retries", "form architecture", "real-time multiplayer game"). Strip filler words ("I'm trying to", "we need", "how should I"), keep the substantive nouns.
- **File slug** for the plan path: kebab-case, lowercase, max 6 words. e.g. `rate-limiting-middleware`, `background-job-retries`, `form-architecture-mobile`, `realtime-multiplayer-game`. Used as `specs/plans/YYYY-MM-DD-groundwork-<slug>.md`.

In Step 1, restate the normalized task-class label back to the user before proceeding so they can correct the parse if it drifted.

If no argument is provided, respond with:
```
What are you trying to do? Describe it however you want — "I'm trying to add X" or just "X" both work.
```
Then wait.

## Steps

### 1. Infer the canonical topic, then confirm scope

**The user is not required to know the canonical name for what they want.** They may describe the problem fuzzily — "I want to write code that doesn't break when I refactor", "the codebase feels messy", "I'm worried about my Supabase functions getting hammered", "how do I make sure this thing keeps running when the network drops". Your first job is to map that fuzzy description to a canonical topic name **before** research starts.

**Inference protocol:**

1. **List published skill names as canonical vocabulary.** Skill repo directory names are the cleanest source of canonical topic labels in the agent-skill ecosystem. Run:
   ```
   gh api repos/mattpocock/skills/contents             | jq -r '.[] | select(.type=="dir") | .name'
   gh api repos/humanlayer/skills/contents/plugins     | jq -r '.[] | select(.type=="dir") | .name'
   gh api repos/anthropics/skills/contents/skills      | jq -r '.[] | select(.type=="dir") | .name'
   ```
2. **Match the user's description against the listed skill names.** If one or more skills match well (e.g. fuzzy input "code that doesn't break when I refactor" → `tdd`), that is the canonical topic. If multiple plausibly match, list them.
3. **If no published skill matches**, fall back to deriving a label from the substantive nouns in the description (filler stripped, kebab-case). Examples: "I want to add background jobs that retry" → `background-job-retries`. "build a real-time multiplayer game" → `realtime-multiplayer-game`.

**Restate back in one sentence:** *"Based on your description, I read this as `<topic>` [or possibly `<topic2>`]. Continuing unless you correct me."* This is a soft confirmation — the user can interrupt if you guessed wrong, otherwise proceed without waiting. If multiple plausible matches and no obvious winner, do ask: *"This could be `<a>` or `<b>` — which fits?"* Then wait.

Then identify scenario:
- **(a) Existing repo, new task class within it.**
- **(b) Brand new project, no existing code yet.**
- **(c) Existing repo, accreted area being audited or re-established.**

If the argument is genuinely ambiguous with no substantive nouns at all (e.g. "fix the thing"), ask one clarifying question.

### 2. Find canonical guidance

Goal: identify what published authors or vendor docs say is good practice for this topic. Two sub-steps, both required.

**2a. Crawl published agent-skill collections.** Step 1 already listed the skills across `mattpocock/skills`, `humanlayer/skills/plugins`, and `anthropics/skills/skills` — reuse that list, don't re-query. For each skill that matches the task class, fetch its SKILL.md verbatim. The list is **WHERE to look**, not what topics are allowed — the topics that emerge come from whatever the repos contain.

For aggregator lists, read the README and look for relevant pointers:
- https://github.com/hesreallyhim/awesome-claude-code
- https://github.com/karanb192/awesome-claude-skills
- https://github.com/VoltAgent/awesome-agent-skills
- https://github.com/travisvn/awesome-claude-skills

For each skill that matches the topic:
- Fetch `<repo>/<skill-dir>/SKILL.md` raw.
- Capture: name, source URL, the load-bearing principles in the body (verbatim quotes).
- Note any supporting files (`tests.md`, `mocking.md`, etc.) and fetch them too if they look relevant.

**A skill that exists on the topic is itself strong evidence.** It is a recommendation that has been written down and shared by someone who thought hard about the problem.

**2b. Web search for broader canonical guidance.** Beyond skill repos:
- WebSearch the task class with terms like "best practices", "guide", "patterns" — and the current year.
- For platform/SDK/hardware work, search the vendor's official documentation explicitly.
- Fetch the top 2-4 high-signal results using WebFetch. Capture verbatim quotes — do not paraphrase from training data; the cutoff may be stale.

If multiple results converge on the same author or doc, that is signal. Read it. **Do not pre-bias toward any specific author, framework, or stack.** Let the search lead.

**2c. Academic literature (research-adjacent topics only).** Fires only when the canonical topic from Step 1 is research-adjacent: machine learning, algorithms, distributed systems theory, cryptography, statistical methods, formal verification, compilers, networking protocols, certain hardware. **Skip explicitly** for engineering-ergonomics topics (rate limiting, form architecture, CRUD scaffolding, build tooling, UI patterns) — note the skip in one line and move on.

If the topic qualifies:
- WebSearch `arxiv.org` and `scholar.google.com` with the canonical topic name. Add `survey` or `review` as a query term to surface the consolidating papers.
- Identify 1-3 papers that introduce or canonicalize the technique. Signals: high citation count, "X is all you need" / seminal-paper framing, recent survey papers that point to a small set of foundational works.
- WebFetch the abstract and the relevant section. Capture verbatim: title, authors, year, URL, the load-bearing claim or result.
- **Recurring citation across multiple papers or surveys is the strongest signal.** A single paper with no follow-up is weaker — note it but don't anchor a phase on it.

If the topic clearly qualifies but no high-signal paper turns up, state the search queries used and treat the absence as a finding. Do not silently skip.

### 3. Survey real-world solutions

Identify 2-3 reputable solutions to this task class. Two complementary modes — use whichever fit the topic, often both:

**Mode A — packaged solutions (libraries, SDKs, hosted services, APIs).** Use when the task class is one another team likely productized.

- Search the registry that fits the stack — don't search them all. The right registry emerges from the topic (npm, PyPI, crates.io, Maven Central, CocoaPods, HuggingFace, vendor marketplaces).
- **Reputable means all of:** maintained in the last 6 months, install or download counts in the same order as competitors, GitHub stars and issue activity that suggest production use, no unresolved critical issues, license compatible with the project.
- Convergence across multiple sources (registry + GitHub + an independent vendor blog or tutorial naming the same library) is the strongest signal.
- **If a maintained library solves this cleanly, the plan must surface that before proposing a from-scratch build.** "Don't reinvent" is a load-bearing default. The plan can still recommend building, but only with an explicit reason why off-the-shelf doesn't fit.

**Mode B — reference open-source repos.** Use when the task class is a pattern teams implement inline (auth flows, data pipelines, CI architecture, monorepo structure, deployment topology).

- `gh search repos "<task class>" --sort=updated --limit=10`
- `gh search repos --topic=<relevant-topic>` (the topic emerges from the task class)
- Web search: `<task class> site:github.com <relevant context>`
- **Reputable means all of:** commits in the last 6 months, CI configured, tests present, releases or tags, substantive README, more than one contributor, similar scale to the user's project.
- **Read the relevant SLICE of each repo, not the whole repo.** Identify the files where this task class is implemented and read them. The slice depends on the topic — let the topic decide.

**For each chosen solution, capture:**
- Name, URL, why it qualifies (the criteria checks).
- For Mode A (libraries/services): the API surface that addresses this task class (1-2 lines), license, integration cost.
- For Mode B (repos): the 2-3 conventions noticed in the relevant slice — file paths and 1-line descriptions.
- What diverges from the other solutions (divergence signals no consensus).

Recurring library choice OR recurring conventions across multiple sources is the strongest signal.

**If 2-3 reputable solutions cannot be found in either mode, state the search queries used and treat the absence as a finding.** Do not silently skip.

### 4. Map the current repo (scenarios a and c)

Spawn an Explore subagent (or do it yourself if the surface is small) to produce a concrete map:
- Stack identified at the relevant level (package manager, language, framework, runtime).
- File paths and counts of existing instances of this task class.
- The canonical local pattern (the file most worth copying).
- Anti-patterns: where the repo deviates from good practice — file paths, line numbers, why.
- Coverage gaps: parts of the system with zero instances.

This map IS the input to step 5. Without concrete file paths, step 5 produces vague output. Do not skip.

For scenario b (brand new project), skip this step but capture user-stated constraints (deployment target, performance bounds, certification requirements, hardware specifics, budget, team size).

### 5. Write the phased cleanup plan

Write the plan to `specs/plans/YYYY-MM-DD-groundwork-<task-class>.md`. Create `specs/plans/` if it does not exist. Plan structure (fixed):

```markdown
# Groundwork: <task class> — <YYYY-MM-DD>

## Current state (5 bullets max)
Concrete facts about the current repo. No analysis.

## Solutions surveyed
For each of 2-3 reputable solutions (libraries, services, or reference repos):
- **<Name>** (URL) — why it qualifies.
  - For libraries / services: API surface (1-2 lines), license, integration cost.
  - For reference repos:
    - Convention 1 — <repo>/<file>:<line range> — 1-line description.
    - Convention 2 — <repo>/<file>:<line range> — 1-line description.

**Convergence note:** which library OR conventions recur across multiple sources. If fewer than 2 reputable solutions were found, state the search queries used and call out the absence.

**Build vs adopt.** If a maintained library covers this cleanly and the repo's constraints don't preclude it, the plan adopts it and the cleanup phases integrate it. If the plan recommends building from scratch, this section names the off-the-shelf candidates considered and the explicit reason none fit (license, scale, dependency surface, performance, control over data, team capacity, etc.).

## Skills available to install
Existing agent skills that match this topic, found in step 2a. Skip this section if no skills matched.

- **<skill name>** (`<repo>/<path>`) — SKILL.md description, 1-2 lines. Install via `npx skills@latest add <repo>/<path>` or copy SKILL.md (and any supporting files) to `~/.claude/skills/<skill-name>/`.

## Canonical guidance consulted
For each of 2-4 sources (combine 2a skills + 2b search results + 2c papers if applicable):
- **<Author / vendor / paper>** (URL) — the load-bearing principle or claim, 1-2 lines. For papers, include `(<authors>, <year>)` and the citation count or survey-confirmation status if known.

## What's good (do not change)
3-7 file paths in this repo that already match good practice (cross-checked against reference repos and canonical guidance). One sentence per file.

## Cleanup phases

### Phase 1: <action verb leading title>

**Why.** Deviation from good practice. Cite both: (a) an author principle, vendor doc, or paper, and (b) a step-3 source — either a reference-repo file path showing the production pattern, OR a maintained library/service that addresses this task.

**Reference pattern.** Either:
- `<repo>/<file>:<line>` — quote the relevant snippet (5-15 lines), OR
- `<package@version>` (URL) — the API surface that addresses this task (1-3 lines), license, and why this library over alternatives.

**Files affected.**
- /full/path/to/file1.ext
- /full/path/to/file2.ext

**Steps.**
1. Concrete action with code snippet or diff if it reduces ambiguity. Where applicable, the snippet matches the reference-repo pattern shape, adapted to this repo's conventions.
2. Next concrete action.
3. ...

**Verification.**
- [ ] Automated check (test runs, typecheck, grep returns 0, etc.).
- [ ] Manual check if needed.

**Effort.** Low / Medium / High, with one-line reason.

**Trigger.** Now / After X / Before Y / When Z.

### Phase 2: ...
```

## Out of scope
Things a reader might expect but that are not in this plan, with one-line reasons.

## Hand-off
Run `/grill-me` against this plan to stress-test the tradeoffs.
Then `/implement specs/plans/YYYY-MM-DD-groundwork-<task-class>.md` to execute Phase 1.
```

After writing the plan file, output a brief summary in chat:
- The path to the plan file.
- The number of phases and their titles.
- The first phase's effort and verification.

### 6. Hand off

Do not invoke `/grill-me` or `/implement` automatically. End the chat summary with the same hand-off line as the plan file:

> Run `/grill-me` against this plan to stress-test the tradeoffs. Then `/implement specs/plans/<file>` to execute Phase 1.

Stop here.

## When invoked on the wrong task

If invoked on a task that the frontmatter SKIP block matches, push back in one sentence and suggest `/oneshot` (trivial work) or `/research` (pure mapping, debugging) instead.
