# CANON.md

Anchor examples for `/first-principles`. Each entry names what the company or thinker rejected, what they built instead, and what it teaches. Reach for these only when the user's topic benefits from a concrete analogy. **Do not name-drop on every invocation.**

The originating reference for this skill is the **Pierre Computer Company** — see the parent skill's intro. The examples below extend the same lineage.

## Linear

**Rejected:** JIRA's configurability dogma. "Issue tracking should be infinitely customizable so power users can model anything."

**Built:** A keyboard-first tracker with opinionated defaults and zero per-team configuration drift. Speed and restraint as the brand.

**Teaches:** When the field is racing to add more configuration, the move can be to delete it. Ergonomics and speed compound; configurability decays into chaos.

## Stripe

**Rejected:** "Payments is for banks. Developers integrate by reading 800-page PDFs and waiting six months for an approval call."

**Built:** A payments API where the developer is the user. A two-line code snippet is the demo. The docs are the marketing.

**Teaches:** When the assumed audience is wrong, the whole interface is wrong. Re-pick the user and rebuild around them.

## Figma

**Rejected:** "Design tools must be native desktop apps. The web is too slow for real creative work."

**Built:** A web-native design tool with real-time multiplayer. Files are URLs. The platform shift was the entire product.

**Teaches:** When the world has changed (browsers got fast, collaboration became table-stakes), the assumption that "real tools must be native" can be the lazy bias. Question what's "obviously impossible."

## Tarsnap (Colin Percival)

**Rejected:** "Backups need pretty UI, marketing, and growth." Also: "Cryptography is for libraries to add as an afterthought."

**Built:** A backup service where correctness is the entire pitch. Single-author, terminal-only, deliberately underwhelming surface. Bills by the byte.

**Teaches:** Restraint *is* the brand. When the simple version of the job is hard to get right, getting it right IS the differentiator. No feature checklist required.

## suckless / Plan 9

**Rejected:** Configuration creep. "Power users want options." Bloated Unix.

**Built:** dwm, st, surf, dmenu — programs where the configuration *is* the source code. Recompile to change behavior. Each does one thing.

**Teaches:** The Unix purist lineage. When tempted to add a flag, ask if it belongs in a different program. Composability beats configurability.

## Bret Victor / Christopher Alexander (the intellectual lineage)

**Bret Victor — "Inventing on Principle" (2012).** Talk that frames principled design as identifying the single thing that's wrong with how the world currently does X, then refusing to accept it as inevitable. Reach for this when the user is stuck on what "lazy bias" even means in their domain.

**Christopher Alexander — *A Pattern Language* (1977).** The OG first-principles decomposition. Architecture as a set of atomic primitives that compose. Reach for this when the user's "decompose into primitives" step feels too abstract — Alexander shows what disciplined decomposition looks like at scale.

**Teaches:** This is not a SaaS-era trick. Before software, before product, the move was already named.
