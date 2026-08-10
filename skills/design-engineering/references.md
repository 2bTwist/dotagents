# Reference catalog

Deeper sources behind SKILL.md. Reach for these during **Propose**, when a direction needs
grounding, or when a specific problem (motion performance, accessible combobox, layout
mechanics) needs a primary source rather than a principle.

All URLs verified live as of 2026-07-27.

## Foundational essays still actively cited

| Source | The claim worth knowing |
|---|---|
| **Magic Ink**, Bret Victor · worrydream.com/MagicInk | Information software is a *graphic design* problem, not an engineering one. Most "interaction" is a failure of the interface to infer context. It should show the right thing without being asked. |
| **First Principles of Interaction Design**, Tognazzini · asktog.com/atc/principles-of-interaction-design | Latency Reduction: attack *perceived* latency before actual latency. Any immediate response beats a genuinely faster operation. |
| **Response Times: The 3 Important Limits**, Nielsen · nngroup.com/articles/response-times-3-important-limits | 0.1s feels instantaneous. 1s keeps thought unbroken, no indicator needed. 10s loses attention. Past ~1s the user stops feeling they operate on the object and starts feeling they wait on a system. |
| **Refactoring UI**, Wathan & Schoger · refactoringui.com | Tactical, for developers doing design. Most-quoted tip: borders should not be the default separator. Reach for shadow or a background shift first, because box-heavy UI reads as unpolished. |

## Motion and performance

| Source | The claim worth knowing |
|---|---|
| **FLIP Your Animations**, Paul Lewis · aerotwist.com/blog/flip-your-animations | Why transform and opacity are cheap and everything else is not (layout vs paint vs composite). FLIP is what Motion's `layout` and every peer library actually implement. Primary source for *why*, not just how. |
| **Motion Magazine**, Matt Perry · motion.dev/magazine | "The Web Animation Performance Tier List." Also "Crashing cars and improving hover detection", which borrows game-dev collision techniques to fix fast-pointer hover misses. The most systems-engineering item here. |
| **Carbon motion guidelines**, IBM · carbondesignsystem.com/elements/motion/overview | Duration should scale with distance and size travelled, not a flat 200ms everywhere. Entrance easing signals "the system is responding to you"; exit easing accelerates to imply permanence. |
| **Building a Toast Component**, Emil Kowalski · emilkowal.ski/ui/building-a-toast-component | Sonner's origin. Honest tension with Paco's API-first framing: what drove adoption was the stacking animation, not the API. The feel sold it. |
| **Cassie Evans** · cassie.codes | SVG motion specifically: motion paths, stroke technique, SVG as the handoff surface between illustrator and animator. |

## Accessibility as craft, not compliance

| Source | The claim worth knowing |
|---|---|
| **Radix accessibility docs** · radix-ui.com/primitives/docs/overview/accessibility | Focus movement is a *screen-reader announcement mechanism*, not just keyboard convenience. Moving focus into a dialog is what announces the dialog. Where you move focus and how you label it are one concern, not two. |
| **React Aria blog**, Adobe · react-aria.adobe.com/blog | Where ARIA spec and real screen-reader support diverge. Portal-rendered menus break traversal order; touch needs a tray, not a popover. Naive spec compliance still fails real assistive tech. |
| **Base UI**, Radix + Floating UI + MUI team · base-ui.com/react/overview/about | Unstyled *and* fully open parts: no wrapper hides the DOM, so parts can be added, removed, reordered. Composition stays the consumer's decision. |
| **UX Patterns for Developers** · uxpatterns.dev | Per-pattern anatomy, a11y requirements, and testing strategy. Implementation reference rather than a why-essay. |

## Courses

| Source | Format |
|---|---|
| **Invisible Details**, Dmytro · invisibledetails.com | $145 one-time. Notes (principles) then Practice (one component dissected: stepper, tree, date picker, activity chart). Source of the hesitation test and most of the geometry rules in checklist.md. Free previews at /preview/. |
| **Devouring Details**, Rauno · devouringdetails.com | Interaction craft, learn-by-building. |
| **Animations on the Web**, Emil · animations.dev | Motion decisions and implementation. |
| **Whimsical Animations**, Josh Comeau · whimsy.joshwcomeau.com | $299+. Particle effects, SVG/spring, cursor tracking, View Transitions, canvas physics. Interactive rather than video-passive. |
| **Framer Motion Recipes**, Build UI · buildui.com/courses/framer-motion-recipes | $199. Rebuilds real patterns (wizard, resizable panel, carousel, calendar) rather than toy demos. |
| **Motion for React**, Frontend.fyi · frontend.fyi/course/motion | €249. Motion values, layout, scroll. Free lesson previews. |
| **The Layout Maestro**, Ahmad Shadeed · thelayoutmaestro.com | CSS layout mechanics. Free article archive at ishadeed.com/articles is substantial on its own. |

## Newsletters, communities, galleries

| Source | Notes |
|---|---|
| **Interfaces** · interfaces.dev | Jakub Krehel. $7.99/mo, 3 issues free. Monthly, interactive demos plus source. Typography, shadows, micro-interactions. |
| **Motion Magazine** · motion.dev/magazine | Free. See above. |
| **Piccalilli** · piccalil.li | Andy Bell. Free weekly "The Index", human-curated. |
| **Design Eng Club** · designeng.club | Community plus IRL events (SF/NYC), members from Linear, Vercel, Cursor, Netflix. Membership doubles as a live practitioner directory. |
| **Little Big Details** · littlebigdetails.com | Community catalog of single interface decisions, screenshot plus one line. Raw material for browsing, not a framework. |
| **Codrops** · tympanus.net/codrops | 500+ demos with MIT source. Code, not analysis. Pair with a teardown source for the why. |
| **Awwwards Developer Award** · awwwards.com/developer-award | The one gallery where code is the judging axis: a separate jury scores interoperability, accessibility, and standards after the visual score. |

## Adjacent: rethinking the primitives

Different axis from craft-polish. Useful when the right move is to question the pattern
rather than perfect it.

- **Amelia Wattenberger** · wattenberger.com, "Our interfaces have lost their senses"
- **Alexander Obenauer** · alexanderobenauer.com/think, on app/window/notification as arbitrary inventions rather than computing truths
- **Szymon Kaliski** · szymonkaliski.com, "The Incredible Power of the Right Interface", how a representation changes what thinking is possible
- **Flora Guo** · floguo.com, agentic interfaces, designing when the user is sometimes an agent

## Gaps

No strong second teardown site in the vein of Devouring Details or Invisible Details was
found. That genre currently lives in scattered X threads and video breakdowns rather than
dedicated sites. If a real one appears, it belongs here.
