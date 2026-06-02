# Groundwork — Reference

Detailed protocols for steps 1, 2a, 2c, and 3 of [SKILL.md](SKILL.md). These are rarely-needed-as-a-block — the SKILL.md summary covers most invocations. Reach here when an invocation actually needs the full procedure.

## Skill-crawl protocol

Step 1 inference vocabulary. The user is not required to know the canonical name for what they want. Map the fuzzy description to a canonical topic name before research starts.

List published skill names. Skill repo directory names are the cleanest source of canonical topic labels:

```
gh api repos/mattpocock/skills/contents             | jq -r '.[] | select(.type=="dir") | .name'
gh api repos/humanlayer/skills/contents/plugins     | jq -r '.[] | select(.type=="dir") | .name'
gh api repos/anthropics/skills/contents/skills      | jq -r '.[] | select(.type=="dir") | .name'
```

Then query the **skills.sh aggregator** (covers more publishers than the three GitHub orgs above):

```
npx --yes skills@latest find "<task class keyword>"
npx --yes skills@latest find "<alternate phrasing>"
```

Output lists `owner/repo@skill` matches with install counts. Treat install count as a quality signal, not absolute truth — 8K installs is stronger than 200, but neither is conclusive.

Aggregator READMEs to scan for additional pointers:
- https://github.com/hesreallyhim/awesome-claude-code
- https://github.com/karanb192/awesome-claude-skills
- https://github.com/VoltAgent/awesome-agent-skills
- https://github.com/travisvn/awesome-claude-skills

Match the user's description against listed skill names. If multiple plausibly match with no obvious winner, ask: *"This could be `<a>` or `<b>` — which fits?"* Otherwise restate the inferred topic in one sentence and proceed.

If no published skill matches: derive a label from the substantive nouns in the description (filler stripped, kebab-case). Examples: "I want to add background jobs that retry" → `background-job-retries`. "build a real-time multiplayer game" → `realtime-multiplayer-game`.

If the argument is genuinely ambiguous with no substantive nouns at all (e.g. "fix the thing"), ask one clarifying question.

## Skill vetting

skills.sh indexes long-tail publishers; not every match is reputable. Apply:
- **Install count** as a popularity proxy.
- **Recent maintenance** — commits in the last 6 months.
- **SKILL.md that holds up on read** — concrete, not vague.

Recommend installing only the 1-3 that genuinely fit the user's stage. Skip skills that duplicate what the repo already does well.

For each matched skill: fetch `<repo>/<skill-dir>/SKILL.md` raw (skills.sh hits resolve to `https://skills.sh/<owner>/<repo>/<skill>` or its GitHub-raw equivalent). Capture name, source URL, the load-bearing principles in the body (verbatim quotes). Note any supporting files (`tests.md`, `mocking.md`, etc.) and fetch them too if they look relevant.

A skill that exists on the topic is itself strong evidence — someone thought hard about the problem and wrote it down.

## Academic search

Fires only when the canonical topic from step 1 is research-adjacent: machine learning, algorithms, distributed systems theory, cryptography, statistical methods, formal verification, compilers, networking protocols, certain hardware. **Skip explicitly** for engineering-ergonomics topics (rate limiting, form architecture, CRUD scaffolding, build tooling, UI patterns) — note the skip in one line and move on.

If the topic qualifies:
- WebSearch `arxiv.org` and `scholar.google.com` with the canonical topic name. Add `survey` or `review` as a query term to surface consolidating papers.
- Identify 1-3 papers that introduce or canonicalize the technique. Signals: high citation count, "X is all you need" / seminal-paper framing, recent survey papers that point to a small set of foundational works.
- WebFetch the abstract and the relevant section. Capture verbatim: title, authors, year, URL, the load-bearing claim or result.
- **Recurring citation across multiple papers or surveys is the strongest signal.** A single paper with no follow-up is weaker — note it but don't anchor a phase on it.

If the topic clearly qualifies but no high-signal paper turns up: state the search queries used and treat the absence as a finding. Do not silently skip.

## Solution vetting

### Mode A — packaged solutions (libraries, SDKs, services, APIs)

Use when the task class is one another team likely productized.

- Search the **registry that fits the stack** — don't search them all. The right registry emerges from the topic (npm, PyPI, crates.io, Maven Central, CocoaPods, HuggingFace, vendor marketplaces).
- **Reputable means all of:** maintained in the last 6 months, install or download counts in the same order as competitors, GitHub stars and issue activity that suggest production use, no unresolved critical issues, license compatible with the project.
- **Convergence across multiple sources** (registry + GitHub + an independent vendor blog or tutorial naming the same library) is the strongest signal.
- **Don't reinvent.** If a maintained library solves this cleanly, the plan must surface that before proposing a from-scratch build. The plan can recommend building, but only with an explicit reason why off-the-shelf doesn't fit.

For each chosen library: capture name, URL, criteria checks, API surface (1-2 lines), license, integration cost.

### Mode B — reference open-source repos

Use when the task class is a pattern teams implement inline (auth flows, data pipelines, CI architecture, monorepo structure, deployment topology).

Search:

```
gh search repos "<task class>" --sort=updated --limit=10
gh search repos --topic=<relevant-topic>
```

Plus web search: `<task class> site:github.com <relevant context>`.

**Reputable means all of:** commits in the last 6 months, CI configured, tests present, releases or tags, substantive README, more than one contributor, similar scale to the user's project.

**Read the relevant SLICE of each repo, not the whole repo.** Identify the files where this task class is implemented and read them. The slice depends on the topic.

For each chosen repo: capture name, URL, criteria checks, the 2-3 conventions noticed in the relevant slice (file paths and 1-line descriptions), what diverges from the other solutions.

### Convergence

Recurring library choice OR recurring conventions across multiple sources is the strongest signal. If 2-3 reputable solutions cannot be found in either mode, state the search queries used and treat the absence as a finding. Do not silently skip.
