---
name: design-engineering
description: Design philosophy and taste for UI work. Establishes design direction BEFORE code, proposes non-obvious alternatives, then shapes how the interface is constructed. Invoke at the START of any UI or interaction work (new component, screen, form, menu, landing page, icon, micro-interaction, redesign, polish pass), before writing markup. This is a way of thinking, not a checklist; the verifiable craft rules live in checklist.md, read at review time. Complements animation-vocabulary (motion language) and frontend-design (aesthetic direction). Distilled from Rauno Freiberg, Benji Taylor, Emil Kowalski, Dmytro (pqoqubbw), Paco Coursey, Kathryn Gonzalez, Vercel design engineering.
---

# Design engineering: how to think about the surface

A philosophy of interface work distilled from the published thinking of multiple design
engineers, not one voice. Where several of them arrive at the same principle
independently, treat it as law, not taste.

**This skill exists to shape what gets built, not to grade what already exists.** If the
markup, layout, and component structure are already in place when this loads, say so in
one line and use the principles below as a critique lens instead. Do not pretend to be
shaping a decision that has already been made.

---

## How to use this: sense, propose, shape

### 1. Sense the direction

Before proposing anything, establish what this interface should feel like. Ask when the
direction is genuinely open. Skip the questions when the repo, the session, or an
existing design already fixes the aesthetic, and go straight to proposing within it.

When you ask, ask through AskUserQuestion, at most three or four, recommendation first:

- **Feel.** Where does this sit: quiet and utilitarian, warm and editorial, dense and
  professional, playful? Name a product it should feel like, not an adjective.
- **Density.** Is the user scanning many things or focused on one? This decides spacing,
  type scale, and whether chrome earns its space.
- **Frequency.** How often does someone touch this surface? Daily tools get less motion
  and less decoration than once-a-month ones. See principle 4.
- **Motion appetite.** Is movement part of the identity here, or is stillness the point?

Do not ask about implementation. Ask about the feel, then decide the implementation
yourself.

### 2. Propose before you build

Never open with the obvious solution silently. Offer **two or three named directions**,
and make at least one of them non-obvious: a pattern borrowed from a different context, a
native OS behavior, a structure the incumbent products do not use.

For each direction give:
- A **name** it can be referred to by.
- The **principle** below that it leans on.
- A **reference**: which practitioner or product does this well, from the table at the
  bottom. Reach for the table here; this is the moment it earns its place.
- What it **costs**: what gets harder, what it rules out.

Recommend one. Then build that one.

### 3. Shape the construction

Once the direction is chosen, the principles below are the reasoning frame while
building, not a pass/fail at the end. When a decision is close, the principle that
resolves it should be nameable.

---

## Philosophy of the surface

**1. The interface is a physical space with unbreakable rules.** (Benji Taylor; Rauno Freiberg)
Treat the app as a place with consistent spatial physics: things come from somewhere and
go somewhere, direction matches intent (left tab moves left), and elements keep their
identity across states. Benji: "we fly instead of teleport." Rauno: interactions should
mirror real-world metaphors and retain momentum.
Direction carries information, so spend it: forward and back should travel on opposite
vectors, and the surrounding chrome (title, breadcrumb) should travel with the content,
not sit still. Which axis to use is decided by the layout's existing eye path, not by
preference. A stepper alone on a page can go either way; a stepper beside an illustration
already moves the eye horizontally, so vertical motion will fight it. (Dmytro)

**2. Morph, don't replace.** (Benji; Rauno)
Avoid static swaps. Text, icons, and components already on screen should transform or
persist across transitions, never duplicate or blink out. Continuity is what keeps the
user oriented.

**3. Reveal gradually; one focus per surface.** (Benji, "Simplicity")
Present features as they become relevant, not all at once. Each tray, dialog, or step
carries one primary action or idea. Break intimidating flows into compact steps: "distil
overwhelming actions into manageable interactions." Overlay context rather than
displacing it, so users never lose where they were.

**4. The frequency law.** (Emil Kowalski; Benji's delight-impact curve; Rauno; Josh Comeau)
Four practitioners converge on this independently, so treat it as the strongest law
here: the more often an interaction happens, the less it should animate or embellish.
High-frequency and keyboard-initiated actions get instant response, zero animation. Rare
moments (onboarding, success, easter eggs) are where bold delight belongs. Emil:
components used daily turn "pleasant surprise" into "daily annoyance." Comeau names the
mechanism: the active ingredient in whimsy is **novelty**, and novelty is destroyed by
repetition. So the question is never "is this delightful" but "is this still delightful
the four hundredth time."

**5. Restraint: the best animation is often none.** (Emil; Rauno's Devouring Details)
Never animate responses to keyboard input. Some interactions feel better with a touch of
delay, and some feel best with no motion at all. Deciding *when not to* is the taste
being tested.

**6. Respond before the threshold.** (Rauno)
Interfaces respond to input delta in real time: drags show movement from the first pixel,
destructive actions confirm only on gesture completion so they can be cancelled. Every
user-triggered animation is interruptible.

**7. Details compound, and every one is intentional.** (Dmytro; Rauno)
"Every pixel and interaction feels intentional, from smooth motion to accessibility"
(Dmytro). No single detail matters much alone; interfaces feel expensive because dozens
hold simultaneously. Equal polish everywhere, even rarely-visited corners.

**8. Perceived speed is the real speed.** (Tognazzini; Nielsen; Dmytro, "Speed is a feeling")
Three independent sources, so treat it as law. **Attack perceived latency before actual
latency**: an immediate acknowledgement beats a genuinely faster operation with no
response. The thresholds that everything else traces back to are 0.1s (feels
instantaneous, direct manipulation), 1s (thought stays unbroken, no indicator needed),
and 10s (attention is gone). Past roughly one second the user stops feeling they are
operating on the object and starts feeling they are waiting on a system. Good software is
deliberately slow in the right place and instant in another; uniform timing is a smell.

**9. Predictable beats clever.** (Dmytro, "Predictability is a feature")
A surprising interface is an expensive one, because every surprise spends attention. Three
consequences worth designing for directly: **forgive input** (accept the paste with
spaces, the wrong date format, the extra zero, rather than rejecting it), **remember
state** (filters, scroll position, sort order, half-finished text, so returning is
cheap), and keep behavior consistent across surfaces so a learned gesture keeps working.

**10. Words are interface.** (Dmytro, "Words shape expectations")
Copy is not decoration applied after layout; it is the part of the interface that sets
expectations about what a control will do. A label that must be read twice is a design
defect, not a writing nitpick. Name the actual outcome ("Delete 3 invoices") rather than
the mechanism ("Confirm"). Wording is the cheapest place to remove hesitation and the
most commonly skipped.

**11. Craft is respect.** (Benji)
"Thoughtfully crafted software showcases a deep respect for the user." Polish is not
vanity; it signals that the user's time is valued. This is the *why* under everything
above.

### Two that shape structure, not surface

**Icons are interaction surfaces, not static glyphs.** (Dmytro, pqoqubbw.dev)
They communicate state change by moving: menu to X, play to pause, copy to check. One
coherent motion personality per interface, the same easing family and the same scale of
movement everywhere.

**The public API is a design surface.** (Paco Coursey: cmdk, next-themes)
Build compound components with sensible defaults and full keyboard support out of the
box, so consumers only compose. Handle the ugly edge cases inside the component so
consumers cannot get them wrong. Optimize for the reader of the usage site, not the
implementation.

---

## Developing the judgment (Emil, "Developing Taste"; Rauno, Devouring Details)

Taste is a trained instinct, not a preference. The loop:

1. **Study excellent work first.** Before building a pattern, look at how the tastemakers'
   products do it, and at native OS behavior.
2. **Analyze, then rebuild.** Articulate *why* a reference feels right (spacing? timing?
   continuity?) before borrowing it. Dmytro goes one step further and **rebuilds** the
   thing that felt good, because reconstructing it is what exposes the reasoning behind
   the choice. Reading a detail teaches you less than reproducing it.
3. **Build and feel it.** Prototype, use it, notice it sucks, iterate. Rauno's course
   exists because learning happens by "trying to build an idea and realising it sucks in
   practice." Judge interactions by driving them, never by screenshot.

### The hesitation test (Dmytro)

Drive the interface yourself. **Any half-second pause marks a real defect**, and your
instinct to dismiss it as your own distraction is wrong. If you hesitated there, users
hesitate there, and they will never tell you. Four signals worth naming:

- **The second click.** You clicked and clicked again. The first click was not confirmed
  fast enough, or the hit target sits a few pixels off the visible control and the first
  click hit nothing at all.
- **Cursor drift.** The pointer hovers around but never lands. Either the hit target is
  too small or unclear, or it is a recognition failure: the option is there and the eye
  cannot find it.
- **Reflexive undo.** The user undoes an action that was correct, because nothing
  confirmed what happened and they went to check.
- **Re-reading.** A label read twice is almost always a wording problem, not a reader
  problem. See principle 10.

### Recreate friction on purpose (Dmytro)

Interfaces are built under ideal conditions (fast network, three rows of test data, a
mouse, a 27-inch screen) and then used in hostile ones. **The components that break under
stress are the load-bearing ones.** Before calling UI work good, deliberately degrade it:
throttle the network or add artificial delay to reveal the missing loading states, paste
instead of typing, drive it with the keyboard only, load long and empty content, and
shrink the window to see which element fails first.

**Prototype in code where code wins** (Vercel): animations, keyboard behavior, touch,
physics get judged in the real medium. **Own the outcome, not the process stage**
(Gonzalez, Vercel): take the problem from conception to shipped, and measure by the
result.

---

## People and sources

Reach for this table during **Propose**, to ground a direction in someone who does it well.

| Person | For | Source |
|---|---|---|
| Rauno Freiberg, Vercel | Interface guidelines, invisible interaction details | interfaces.rauno.me, rauno.me/craft, devouringdetails.com |
| Benji Taylor, Family | Simplicity, fluidity, delight; spatial physics of product surfaces | benji.org/family-values |
| Emil Kowalski, ex-Vercel | Taste as trained instinct, animation restraint | emilkowal.ski, animations.dev |
| Dmytro (pqoqubbw), Mintlify | Animated icons, micro-interaction craft | pqoqubbw.dev, github.com/pqoqubbw/icons |
| Paco Coursey, Linear | Component API craft, keyboard-first components | paco.me, cmdk, next-themes |
| Kathryn Gonzalez, ex-DoorDash | What the role is: autonomy, craft, final fidelity | ryngonzalez.com/blog/the-attributes-of-a-design-engineer |
| Vercel DE team | Outcomes over process, prototype in code | vercel.com/blog/design-engineering-at-vercel |
| Steve Ruiz, tldraw | Direct-manipulation physics: dragging, rotation, z-order | steveruiz.me ("Perfect Dragging") |
| Jakub Krehel | Component-level craft details, typography, color | jakub.kr, interfaces.dev |
| Matt Perry, Motion | Why animation is fast or janky; hover/pointer mechanics | motion.dev/magazine |
| Andy Allen, Not Boring | Game-feel and sound applied to product UI | notbor.ing |
| Josh Comeau | Whimsy, novelty budget, CSS mechanics | joshwcomeau.com |
| Ahmad Shadeed | CSS layout mechanics, deeply diagrammed | ishadeed.com |
| Amelia Wattenberger | Rethinking interaction primitives, data viz | wattenberger.com |
| Jhey Tompkins | Creative CSS techniques | craftofui.com |
| Bret Victor | The ancestor this whole circle cites | worrydream.com ("Magic Ink") |
| Directories | Finding more practitioners, stay current on their own | ui.land (by Emil), desengs.com, designengineering.arun.is |

Deeper catalog (courses, newsletters, communities, foundational essays, per-topic
sources) lives in `references.md` next to this file. Reach for it when the direction
needs grounding this table cannot give.

---

## Reviewing, not shaping

The verifiable craft rules (interactivity, typography, touch, accessibility, states) live
in `checklist.md` next to this file. Read it when reviewing or finishing a UI change.
Do not read it while shaping the direction; it is the floor, not the goal, and pulling it
in early turns design work into compliance work.
