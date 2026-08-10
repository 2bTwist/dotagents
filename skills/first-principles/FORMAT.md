# First-principles doc format

Write to `specs/first-principles/YYYY-MM-DD-<slug>.md`.

## Standard structure (fixed)

```markdown
# First-principles: <topic> — <YYYY-MM-DD>

## 0. My reading of the topic
What I read the user as asking. Surface my interpretive choices so they can be corrected. 2-3 sentences.

## 1. The lazy bias
The conventional approach everyone defaults to. Name it precisely. Cite a vendor doc, library, or canonical source from sub-agent 1.

## 2. What has changed
Why the lazy bias's core assumptions may be stale. Be specific — name 1-2 concrete shifts (new audience, new physics, new affordances, new constraint) with source URLs from sub-agent 2. Skip if no material shift surfaced (proceed to negative-result mode).

## 3. Atomic primitives
Decompose the topic into atomic, separately-shippable primitives. Each primitive is a thing that could in principle be its own product. Cite repo file paths from sub-agent 3 where current instances exist.

## 4. The embarrassingly bad primitive
Which one primitive does the conventional approach get embarrassingly wrong at the simple version of the job? Be specific — performance, ergonomics, integration, defaults, observability, whatever. Cite the comparison with quantified evidence where possible.

## 5. The embarrassingly good rebuild
What would *just that primitive* look like rebuilt with restraint? One thing, done correctly. Reference an analog from CANON.md if it sharpens the proposal ("like Linear rejecting JIRA's configurability, here we reject <X> by <Y>"). Do not propose rebuilding more than one primitive.

## 6. How the thing markets itself
If we ship the rebuild, what is self-evidently true that needs no marketing? What does the page demonstrate by existing? (One paragraph.)

## 7. The re-bundle temptation
What features will we be tempted to add later that actually belong in a different product? Name them explicitly so future-us can resist them.

## Hand-off
- To operationalize the rebuild: `/plan <doc-path>`.
- To stress-test this framing first: grill the doc's tradeoffs (the `grill-me` skill if installed).
- If this analysis is rejected and the conventional approach holds: `/plan` directly without first-principles framing.
```

## Negative-result mode

If the sub-agents show no reframe is warranted (no material shift, no embarrassingly bad primitive, conventional approach holds), write this shortened doc instead:

```markdown
# First-principles: <topic> — <YYYY-MM-DD>

## Conclusion: no reframe
After analysis, the conventional approach to `<topic>` holds. Current incumbent solutions match the actual constraints.

## What was checked
- Conventional approach: <named, with source>
- Recent shifts considered: <named, or "none material">
- Atomic primitives: <listed>
- Embarrassingly bad primitive: <"none surfaced", with the specific check that ruled this out>

## Hand-off
Proceed with `/plan <topic>` using the conventional approach. No reframe needed.
```
