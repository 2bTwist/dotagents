---
name: design-engineering
description: Design direction and taste for UI work, applied before the markup rather than after. Invoke at the START of interface or interaction work — a new surface, a redesign, a polish pass — to sense the direction, propose named alternatives, then shape the build. Where the direction is already fixed by the repo, it narrows to the principles. Where the markup already exists, it becomes a critique lens. The verifiable craft rules live in checklist.md, read at review time.
---

# Design engineering: how to think about the surface

A philosophy of interface work distilled from the published thinking of multiple design
engineers, not one voice. Where several of them arrive at the same principle
independently, treat it as law, not taste.

**This skill shapes what gets built. It does not grade what already exists.** If the
markup, layout, and component structure are already in place when this loads, say so in
one line and use the principles below as a critique lens. Do not pretend to be shaping a
decision that has already been made.

---

## How to use this: sense, propose, shape

### 1. Sense the direction

Three cases, and only the first runs the questions:

- **The direction is open** — a new surface, a redesign, no established look to inherit.
  Ask, through AskUserQuestion, at most three or four, recommendation first.
- **The direction is fixed** by the repo, the session, or an existing design. Skip to
  step 3 and build inside it.
- **The markup exists.** Skip to the principles and read as a critic.

When you ask:

- **Feel.** Where does this sit: quiet and utilitarian, warm and editorial, dense and
  professional, playful? Name a product it should feel like, not an adjective.
- **Density.** Is the user scanning many things or focused on one? This decides spacing,
  type scale, and whether chrome earns its space.
- **Frequency.** How often does someone touch this surface? Daily tools get less motion
  and less decoration than once-a-month ones. See principle 4.
- **Motion appetite.** Is movement part of the identity here, or is stillness the point?

Ask about the feel. Decide the implementation yourself.

### 2. Propose before you build

Never open with the obvious solution silently. Offer **two or three named directions**,
and make at least one non-obvious: a pattern borrowed from a different context, a native
OS behavior, a structure the incumbent products do not use. Look at how the tastemakers'
products and the native OS solve this first — a direction is stronger for having a
reference than for having been invented at the desk.

For each direction give:
- A **name** it can be referred to by.
- The **principle** below that it leans on.
- A **reference**: which practitioner or product does this well. The people table in
  [`references.md`](references.md) is here for exactly this moment.
- What it **costs**: what gets harder, what it rules out.

Recommend one. Then build that one.

### 3. Shape the construction

Once the direction is chosen, the principles below are the reasoning frame while
building, not a pass/fail at the end. When a decision is close, the principle that
resolves it should be nameable. Judge interactions by driving them, never by screenshot.

---

## Tells

A tell is a surface detail that gives away how little was decided. Readers recognise the
machine-built house style on sight and discount the product before trying it. The four
loudest, per Mitchell Hashimoto: hairline borders, glow, mixed fonts, monospace as
flavor. Gradient headings and an emoji standing in for an icon join the same family. Each
is correct somewhere, so treat them as defaults that need a reason, not as bans.

- **Hairline borders.** A 1px line around every card implies structure without deciding
  any: if everything carries a border, no border carries information. Grouping comes from
  spacing and alignment first. Spend a border where whitespace cannot separate two
  regions, or where a surface must read as raised or inset.
- **Glow.** Elevation is a light source with one direction; glow emits in every direction,
  so it reads as decoration rather than depth. Reserve it for something genuinely
  emitting: a live status, a selection, a focus ring.
- **Mixed fonts.** Two families needs a reason, usually a display face against a text
  face. Three is an accident. The tell is the absence of a rule anyone could state, so
  state it: which families, which weights, which sizes, what each is for.
- **Monospace.** Right for content that is actually monospaced: code, hashes, IPs, ports,
  log lines, aligned numerals. Wrong as flavor on headings, nav, buttons, and body, where
  it only signals "technical". The line is data, not chrome.

### The tell test

For each tell on the page, name what it does that spacing, weight, or color could not.
Anything unnamed comes out.

---

## Philosophy of the surface

**1. The interface is a physical space with unbreakable rules.**
Treat the app as a place with consistent spatial physics: things come from somewhere and
go somewhere, direction matches intent (left tab moves left), and elements keep their
identity across states. We fly instead of teleport; interactions mirror real-world
metaphors and retain momentum.
Direction carries information, so spend it: forward and back travel on opposite vectors,
and the surrounding chrome (title, breadcrumb) travels with the content rather than
sitting still. Which axis to use is decided by the layout's existing eye path, not by
preference. A stepper alone on a page can go either way; a stepper beside an illustration
already moves the eye horizontally, so vertical motion will fight it.

**2. Morph, don't replace.**
Avoid static swaps. Text, icons, and components already on screen should transform or
persist across transitions, never duplicate or blink out. Continuity is what keeps the
user oriented.

**3. Reveal gradually; one focus per surface.**
Present features as they become relevant, not all at once. Each tray, dialog, or step
carries one primary action or idea. Break intimidating flows into compact steps: distil
overwhelming actions into manageable interactions. Overlay context rather than displacing
it, so users never lose where they were.

**4. The frequency law.** (Emil Kowalski; Benji Taylor; Rauno Freiberg; Josh Comeau)
Four practitioners converge on this independently, so treat it as the strongest law
here: the more often an interaction happens, the less it should animate or embellish.
High-frequency and keyboard-initiated actions get instant response, zero animation. Rare
moments (onboarding, success, easter eggs) are where bold delight belongs. Components
used daily turn "pleasant surprise" into "daily annoyance." Comeau names the mechanism:
the active ingredient in whimsy is **novelty**, and novelty is destroyed by repetition.
So the question is never "is this delightful" but "is this still delightful the four
hundredth time."

**5. Restraint: the best animation is often none.**
Never animate responses to keyboard input. Some interactions feel better with a touch of
delay, and some feel best with no motion at all. Deciding *when not to* is the taste
being tested.

**6. Respond before the threshold.**
Interfaces respond to input delta in real time: drags show movement from the first pixel,
destructive actions confirm only on gesture completion so they can be cancelled. Every
user-triggered animation is interruptible.

**7. Details compound.**
No single detail matters much alone; interfaces feel expensive because dozens hold
simultaneously. That arithmetic is why the rarely-visited corner gets the same polish as
the landing screen, and why polish is not vanity: it is the part of the product that
signals the user's time was valued.

**8. Perceived speed is the real speed.** (Tognazzini; Nielsen; Dmytro)
Three independent sources, so treat it as law. **Attack perceived latency before actual
latency**: an immediate acknowledgement beats a genuinely faster operation with no
response. The thresholds everything else traces back to are 0.1s (feels instantaneous,
direct manipulation), 1s (thought stays unbroken, no indicator needed), and 10s
(attention is gone). Past roughly one second the user stops feeling they are operating on
the object and starts feeling they are waiting on a system. Good software is deliberately
slow in the right place and instant in another; uniform timing is a smell.

**9. Predictable beats clever.**
A surprising interface is an expensive one, because every surprise spends attention.
Three consequences worth designing for directly: **forgive input** (accept the paste with
spaces, the wrong date format, the extra zero, rather than rejecting it), **remember
state** (filters, scroll position, sort order, half-finished text, so returning is
cheap), and keep behavior consistent across surfaces so a learned gesture keeps working.

**10. Words are interface.**
Copy is not decoration applied after layout; it is the part of the interface that sets
expectations about what a control will do. A label that must be read twice is a design
defect, not a writing nitpick. Name the actual outcome ("Delete 3 invoices") rather than
the mechanism ("Confirm"). Wording is the cheapest place to remove hesitation and the
most commonly skipped.

### Two that shape structure, not surface

**Icons are interaction surfaces, not static glyphs.**
They communicate state change by moving: menu to X, play to pause, copy to check. One
coherent motion personality per interface, the same easing family and the same scale of
movement everywhere.

**The public API is a design surface.**
Build compound components with sensible defaults and full keyboard support out of the
box, so consumers only compose. Handle the ugly edge cases inside the component so
consumers cannot get them wrong. Optimize for the reader of the usage site, not the
implementation.

---

## Reviewing, not shaping

The verifiable craft rules (geometry, interactivity, typography, motion bounds, touch,
accessibility, states) and the two review procedures — driving the interface under
deliberate stress, and the hesitation test — live in [`checklist.md`](checklist.md).
Read it when reviewing or finishing a UI change. Do not read it while shaping the
direction; it is the floor, not the goal, and pulling it in early turns design work into
compliance work.

The deeper source catalog, including the people table for **Propose**, is in
[`references.md`](references.md).
