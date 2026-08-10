# The craft checklist

Read this when **reviewing or finishing** a UI change, not while shaping direction. This
is the floor, not the goal. Passing it does not make an interface good; failing it makes
one feel cheap.

Condensed from interfaces.rauno.me and the Web Interface Guidelines. Full list at source.

## Geometry

- **Nested radii**: `inner = outer − padding`. If the gap exceeds the outer radius, the
  inner element needs no rounding at all. Equal radii read as too round to be nested.
  (Steve Ruiz has the edge-case formula.)
- **Optical over mathematical alignment.** Perfectly centered icons often look wrong: a
  play triangle wants to nudge right, a checkmark down. Trust the eye over the number.
- Focus ring shape matches the element shape; a square ring on a rounded button is a tell.

## Interactivity

- Clicking a label focuses its input; inputs live in a `<form>` so Enter submits; correct
  `type=` on every input.
- Buttons disable after submit (no duplicate requests); toggles apply immediately, no
  confirm step.
- Interactive elements: `user-select: none` on inner content; decorative layers get
  `pointer-events: none`.
- Dropdowns open on `mousedown`, not `click`; no dead zones between list items (grow
  padding, not gaps).

## Typography

- No font weight below 400; weight never changes on hover or selected (layout shift).
- `font-variant-numeric: tabular-nums` for tables, timers, tickers.
- Fluid sizes via `clamp()`; `-webkit-font-smoothing: antialiased`.
- `text-wrap: balance` on headings, `pretty` on body to kill orphans. When `balance`
  produces a narrow column, use `max-width` instead.
- **Truncate by content type.** End-truncate labels and descriptions where the start
  carries meaning. **Middle**-truncate filenames and URLs where the end does:
  `Screensho…at 14.32.08.png` identifies the file, `Screenshot 2026-…` identifies nothing
  because every screenshot shares that prefix.
- Icon beside multiline text: wrap it in a `height: 1lh` box and position inside, rather
  than `align-items: center`, which floats the icon to the middle of the block.

## Motion bounds

Vocabulary lives in `animation-vocabulary`. Decisions live in the frequency law
(principle 4 in SKILL.md).

- Keep UI animation under 300ms; interaction feedback under ~200ms.
- Animation values proportional to trigger size: dialogs scale from ~0.8 not 0, button
  press ~0.96 not 0.8.
- Duration scales with distance and size travelled. A flat 200ms everywhere is wrong at
  both ends: too slow for a small nudge, too fast for a full-screen transition. (Carbon)
- Animate `transform` and `opacity`. Anything else hits layout or paint and will jank.
  (Paul Lewis, FLIP)
- Icon motion stays tiny and fast: small translations and rotations, spring or ease-out,
  well under 300ms.
- Theme switches must not trigger transitions on every element.
- Looping animations pause when off-screen.
- Everything respects `prefers-reduced-motion`.

## Touch

- Hover states gated behind `@media (hover: hover)`; input font-size >= 16px (iOS zoom);
  no autofocus on touch; replace (never just remove) the iOS tap highlight.
- **Hit area exceeds visual area.** Grow it with a pseudo-element and negative `inset`, so
  a 20×20 dot catches presses across 26×36 without changing how it looks. Hard rule:
  neighbouring hit zones must never overlap. An ambiguous press that fires the wrong
  control is worse than a small target. Grow into dead space, stop at the gap.
- Correct keyboard per input: numeric fields must not summon the full keyboard.

## Accessibility

- Focus rings via `box-shadow` (respects radius) and visible on every focusable element.
- Icon-only controls need `aria-label`; disabled buttons never carry the explanation in a
  tooltip (unreachable by keyboard).
- Lists navigable with arrow keys; images use real `<img>`; gradient text unsets the
  gradient on `::selection`.
- **A control group is one Tab stop, not many.** Tab reaches the group, then arrows move
  within it, Home and End jump to the ends, and disabled items are skipped rather than
  landed on.
- State needs a role, not just a label: `aria-current="step"` or `aria-selected` tells the
  user *which one they are on*, where `aria-label` alone only says a control exists.
- **Focus movement is an announcement mechanism**, not just navigation. Moving focus into
  a dialog is what tells a screen reader the dialog opened. Where focus goes and how it is
  labelled are one decision. (Radix)
- A tooltip must never be the only carrier of information. It is mouse-only, so keyboard
  and screen-reader users get nothing.

## States and feedback

- Every element designs hover, focus, active, disabled, empty, loading, and error states;
  skeletons match final layout.
- Optimistic UI: update locally, roll back with feedback on error.
- Feedback appears at the trigger: inline checkmark on copy, highlight the failing input.
  Not a toast across the screen.
- Empty states prompt creation.

## Before calling it done

Keyboard and touch paths both work. Spatial continuity holds, nothing teleports. Motion
obeys the frequency law. You have **actually driven the interaction** (run the app or a
browser test) and judged the feel, not just looked at a screenshot.

Then degrade it on purpose, because ideal conditions hide the real failures: throttle the
network to expose missing loading states, paste instead of typing, navigate by keyboard
only, load empty and overlong content, and shrink the window to find what breaks first.
Run the hesitation test from SKILL.md over the result. Any half-second pause is a defect,
including the ones you want to blame on yourself.

## Existing components

Reference `pqoqubbw/icons` (animated lucide icons, MIT) before hand-rolling animated
icons.
