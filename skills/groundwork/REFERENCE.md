# Groundwork — Reference

Detailed protocols for steps 1, 2a, 2c, and 3 of [SKILL.md](SKILL.md). These are rarely needed as a block. The SKILL.md summary covers most invocations. Reach here when an invocation actually needs the full procedure.

## Problem-framing protocol

The purpose of framing is to choose useful research lanes, not to prove that the request belongs to a known category. Begin with the observed world and desired outcome. Treat every label as provisional.

### Ask only questions that change the research

Inspect the user's prompt and available repository evidence before asking. Use one compact batch of 1-3 questions when the missing answers could change the problem classes, success criteria, or sources to consult. Do not ask the user to supply jargon.

High-information question targets:

- **Outcome:** What observable behavior should improve, and how would we know it worked?
- **Evidence:** What is happening now? Which examples, traces, measurements, or user reports distinguish the real failure from a guessed cause?
- **Boundary:** Where is the relevant state or decision made, and what other systems or people interact with it?
- **Constraints:** Which tradeoffs are unacceptable: correctness, latency, memory, cost, privacy, safety, reversibility, explainability, compatibility, or operational burden?
- **Interpretation:** When the description plausibly means different things, which interpretation matches the user's intent?

Ask only the missing subset. A concrete request such as "add retries to these background jobs while preserving at-most-once billing" usually needs no intake questions. An underspecified request such as "help support understand customer themes" needs clarification because search, summarization, routing, and longitudinal analysis imply different evidence and verification.

### Classify on more than one axis

Use two or more dimensions instead of forcing one noun:

1. **System domain:** algorithms and data structures; persistent state and lifecycle; concurrency and distributed coordination; performance and resource use; reliability and operations; security, privacy, and trust; integration and protocols; statistical or ML inference; search and retrieval; interaction and human factors; organizational process.
2. **Problem shape:** diagnosis, prediction or decision, search or planning, optimization, transformation, synchronization or coordination, control and feedback, migration or evolution.
3. **Dominant constraints:** correctness, consistency, latency, throughput, memory, cost, privacy, safety, reversibility, explainability, compatibility, or team operations.

This vocabulary is intentionally non-exhaustive. Record a primary class only when evidence supports it. Keep secondary classes when they materially affect the solution. Mark the frame **hybrid** when domains interact, **uncertain** when evidence is insufficient, and **potentially novel** when established categories explain only part of the behavior.

Disambiguate overloaded words. "Memory" might mean process memory, durable application state, agent context, human recall, or retrieval. "AI problem" might actually be search, ranking, workflow automation, interface design, or statistical inference. An LLM is a technique worth investigating only when the framed task needs capabilities it plausibly supplies and there is an evaluation that can distinguish success from fluent-looking failure.

### Route research without prejudging the solution

Turn the working frame into multiple search lanes when needed:

- algorithmic or optimization work: foundational algorithms, complexity bounds, benchmarks, and reference implementations;
- state, concurrency, or distributed work: invariants, failure models, database or protocol documentation, and production recovery patterns;
- ML or statistical inference: non-ML baselines, data and label quality, evaluation design, error costs, papers, and maintained implementations;
- security, privacy, or trust: threat models, standards, abuse cases, and independently maintained guidance;
- performance or reliability: measurements, budgets, capacity models, failure injection, and operational evidence;
- interaction or organizational work: user evidence, accessibility or human-factors guidance, workflow constraints, and comparable deployed systems.

These are routing examples, not a closed mapping. Research adjacent mechanisms when no exact label fits. State what is known, what is inferred, and what remains unresolved.

## Skill-crawl protocol

Step 2a evidence discovery. The user is not required to know the canonical name for what they want. Skill names are possible search terms after the problem frame exists; they are not the vocabulary authority for step 1.

**Check locally installed skills FIRST** (before any network call). They are already vetted for this stack, and a locally present match is a strong signal that a technique is supported here. It is not proof that the technique fits the framed problem. Enumerate every skill source, then read the `description:` frontmatter of each candidate to match against the task class:

```
# every install location on this machine, across harnesses, plus the repo's own
ls ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills .claude/skills .agents/skills 2>/dev/null
# read frontmatter descriptions to match by topic
for d in ~/.claude/skills ~/.codex/skills ~/.pi/agent/skills .claude/skills .agents/skills; do
  for f in "$d"/*/SKILL.md; do [ -f "$f" ] && { echo "== $f"; sed -n '1,8p' "$f"; }; done
done 2>/dev/null
```

Enumerate every location, not just the one the current harness loads from. A skill installed for another harness, or sitting in the repo without being loaded into context, is still readable and citable. It is evidence that relevant guidance or a related technique exists here, not that the framed problem is solved. Match one, read its `SKILL.md` with the Read tool, cite it by path. Only AFTER exhausting local matches, crawl published skills.

List published skill names as additional evidence and technique leads:

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

Match the working problem frame and its research lanes against listed skill names. Multiple matches can be useful when the problem is hybrid. Do not ask the user to choose between skill names unless that choice represents a real unresolved difference in desired outcome or constraints.

If no published skill matches, treat the absence as a finding and continue with vendor guidance, literature where applicable, and real-world solutions. Derive the file slug from the working problem frame. Examples: "I want to add background jobs that retry" → `background-job-failure-recovery`. "build a real-time multiplayer game" → `realtime-multiplayer-coordination`.

If the argument is genuinely ambiguous with no substantive nouns at all (e.g. "fix the thing"), ask one clarifying question.

## Skill vetting

skills.sh indexes long-tail publishers; not every match is reputable. Apply:
- **Install count** as a popularity proxy.
- **Recent maintenance** — commits in the last 6 months.
- **SKILL.md that holds up on read** — concrete, not vague.

Recommend installing only the 1-3 that genuinely fit the user's stage. Skip skills that duplicate what the repo already does well.

For each matched skill: fetch `<repo>/<skill-dir>/SKILL.md` raw (skills.sh hits resolve to `https://skills.sh/<owner>/<repo>/<skill>` or its GitHub-raw equivalent). Capture name, source URL, the load-bearing principles in the body (verbatim quotes). Note any supporting files (`tests.md`, `mocking.md`, etc.) and fetch them too if they look relevant.

A skill that exists on the topic is evidence that someone documented a procedure. Judge the procedure against the framed outcome, constraints, and stronger sources before relying on it.

## Academic search

Fires only when the working problem frame includes a research-adjacent lane: machine learning, algorithms, distributed systems theory, cryptography, statistical methods, formal verification, compilers, networking protocols, certain hardware. **Skip explicitly** for engineering-ergonomics topics (rate limiting, form architecture, CRUD scaffolding, build tooling, UI patterns) — note the skip in one line and move on.

If the topic qualifies:
- WebSearch `arxiv.org` and `scholar.google.com` using the working problem frame and applicable research lanes. Add `survey` or `review` as a query term to surface consolidating papers.
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
