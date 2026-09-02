---
name: animation-vocabulary
description: Glossary for NAMING a motion effect precisely — entrances, sequencing, transforms, transitions, scroll, easing, springs, performance. Use when putting an animation into words, either to spec it or to critique one. For deciding what the motion should be, use design-engineering.
---

# Animation vocabulary

A precise shared language for motion, so "make it smoother" becomes "ease-out, ~220ms, scale-in with a slight pop." This is a naming tool. What the motion *should* be is a design decision — `design-engineering` owns that.

Offline copy of [animations.dev/vocabulary](https://animations.dev/vocabulary) (Emil Kowalski), extended.

## Writing a motion spec

1. **Name the technique** from the vocabulary below instead of a vague phrase. "Shared element transition," not "the thing where it grows."
2. **Fill five slots:** **trigger** (what starts it), **duration or spring** (how long / what physics), **easing** (the curve), **what changes** (which transform/opacity/property), **purpose** (what it communicates). An animation that cannot fill all five is decoration.
3. **Check it against the [principles](#principles)** — a spec that names a technique but violates a default is still a bad spec.

## Vocabulary

### Entrances & exits
- **Fade in / out:** appear or disappear by changing opacity.
- **Slide in:** enter by sliding from off-screen (left/right/top/bottom).
- **Scale in:** grow from smaller to full size as it appears, often paired with a fade.
- **Pop in:** appear with a slight overshoot, bouncing into place.
- **Reveal:** uncover content gradually, often via clip-path or mask.
- **Enter / exit:** the animation an element plays when added to or removed from the screen.

### Sequencing & timing
- **Keyframes:** defined points (0%, 50%, 100%) the browser fills the gaps between.
- **Interpolation / tween:** generating the in-between frames so motion is continuous.
- **Stagger:** animate items one after another with a small delay each, creating a cascade.
- **Orchestration:** deliberately timing multiple animations so they feel like one coordinated motion.
- **Delay:** time before an animation starts.
- **Duration:** how long an animation takes.
- **Fill mode:** whether an element keeps its first/last frame's styles before/after the animation (e.g. forwards).
- **Stepped animation:** divided into discrete steps, like a countdown timer.

### Movement & transforms
- **Translate:** move along the X or Y axis.
- **Scale:** make bigger or smaller.
- **Rotate:** spin around a point.
- **Skew:** slant along an axis, shearing out of the rectangular shape.
- **3D tilt / flip:** rotate in 3D space (rotateX / rotateY) to add depth.
- **Perspective:** how strong the 3D effect looks; a lower value exaggerates depth, like the viewer is closer.
- **Transform origin:** the anchor point a scale or rotation grows or spins from.
- **Origin-aware animation:** animate from the trigger point rather than the center, like a popover expanding from the button that opened it.

### Transitions between states
- **Crossfade:** one element fades out as another fades in, in the same spot.
- **Continuity transition:** a change that keeps the user oriented by visually connecting before and after (e.g. the same rectangle growing/shrinking).
- **Morph:** one shape smoothly turns into another, e.g. the Dynamic Island.
- **Shared element transition:** an element travels and transforms from one position into another, like a thumbnail expanding into a card.
- **Layout animation:** when size/position changes, it animates to the new spot instead of snapping.
- **Accordion / collapse:** a section smoothly expands and collapses its height to show/hide content.
- **Direction-aware transition:** content slides one way going forward, the opposite going back, giving navigation a sense of direction.

### Scroll
- **Scroll reveal:** elements fade or slide into place as they enter the viewport.
- **Scroll-driven animation:** progress tied directly to scroll position.
- **Parallax:** background and foreground move at different speeds while scrolling, creating depth.
- **Page transition:** plays when navigating from one page/route to another.
- **View transition:** the browser morphs between two states/pages, connecting shared elements.

### Feedback & interaction
- **Hover effect:** visual change when the cursor moves over an element.
- **Press / tap feedback:** a subtle scale-down on click, so it feels physical.
- **Hold to confirm:** a progress effect that fills while the user holds a button.
- **Drag:** moving an element by grabbing it, often with momentum on release.
- **Drag to reorder:** dragging list items to rearrange, while others shift to make room.
- **Swipe to dismiss:** dragging an element off-screen to close it, like a drawer or toast.
- **Rubber-banding:** resistance and snap-back when dragging past a boundary (the iOS overscroll feel).
- **Shake / wiggle:** a quick side-to-side jitter signaling an error or rejected input.
- **Ripple:** a circle expanding from the tap point, confirming the press.

### Easing
- **Easing:** the rate at which an animation speeds up or slows down.
- **Ease-out:** starts fast, ends slow. The default for most UI and anything responding to the user.
- **Ease-in:** starts slow, ends fast. Usually avoided; can feel sluggish.
- **Ease-in-out:** slow, fast, slow. Good for elements already on screen moving from A to B.
- **Linear:** constant speed. Avoid for UI; reserve for spinners or marquees.
- **Cubic-bezier:** a custom easing curve you define for precise control.
- **Asymmetric easing:** a curve that accelerates and decelerates at different rates. Feels more alive than a symmetric one.

### Spring animations
- **Spring:** motion driven by physics (tension, mass, damping) rather than a set duration.
- **Stiffness / tension:** how strongly the spring pulls toward its target. Higher feels snappier.
- **Damping:** how quickly a spring settles. Lower means more bounce and oscillation.
- **Mass:** how heavy the element feels. More mass is slower and more sluggish.
- **Bounce:** a spring that overshoots and settles, adding playfulness.
- **Perceptual duration:** how long a spring feels finished, even though it keeps micro-settling underneath.
- **Momentum:** motion that carries velocity, especially after a drag or interruption.
- **Velocity:** how fast and in which direction an element is moving. A spring carries it into the next animation when interrupted, so a flicked element keeps its speed.
- **Interruptible animation:** can be smoothly redirected mid-flight instead of finishing first.

### Looping & ambient motion
- **Marquee:** text/content scrolling continuously in a loop.
- **Loop:** an animation that repeats, a set number of times or infinitely.
- **Alternate (yoyo):** plays forward then reverses each iteration, instead of jumping back to the start.
- **Orbit:** an element circling another in a continuous path.
- **Pulse:** a gentle repeating scale/opacity change to draw attention.
- **Float:** a gentle, continuous up-and-down drift that makes a static element feel alive and weightless.
- **Idle animation:** subtle motion while an element sits waiting to be interacted with.

### Polish & effects
- **Blur:** a blur filter to soften an element or mask tiny imperfections.
- **Clip-path:** clipping to a shape, used for reveals, masks, before/after sliders.
- **Mask:** hide/reveal parts of an element using a shape or gradient, like clip-path but with soft, fadeable edges.
- **Before / after slider:** a draggable divider that wipes between two overlaid images to compare them.
- **Line drawing:** an SVG path that draws itself in, like an invisible pen tracing it.
- **Text morph:** text that animates character by character when it changes, drawing attention to the new value.
- **Skeleton / shimmer:** a placeholder with a moving sheen shown while content loads.
- **Number ticker:** digits rolling or counting up to a value.
- **Tabular numbers:** fixed-width digits so numbers don't shift around as they change. Essential for tickers, timers, counters.
- **Typewriter:** text appearing one character at a time, as if typed.

### Performance
- **Frame rate (FPS):** frames drawn per second. 60fps is the baseline for smooth motion; 120fps on newer displays.
- **Jank:** visible stutter when frames are dropped because the system can't keep up.
- **Dropped frame:** a frame the system missed its deadline to draw, causing a tiny hitch.
- **Compositing:** letting the GPU move or fade an element on its own layer without redoing layout or paint.
- **will-change:** a CSS hint that an element is about to animate, so the browser can promote it to its own layer ahead of time.
- **Layout thrashing:** animating width/height/top/left forces layout recalculation every frame, causing jank.

## Principles

The defaults a spec has to argue its way out of, not merely satisfy:

- **Purposeful animation:** motion orients, gives feedback, or shows a relationship. Nothing else earns a frame.
- **Ease-out by default** for UI and anything responding to the user. Ease-in-out for on-screen A-to-B moves. Ease-in and linear are for spinners and marquees.
- **Transform and opacity only.** `width/height/top/left` recalculate layout every frame; transform and opacity ride the GPU compositing path.
- **Springs for interruptible or gesture-driven motion** — they carry velocity across the interruption. Timed easing for discrete enter/exit.
- **Frequency of use:** the more often a user sees it, the shorter and subtler it gets.
- **Reduced motion:** `prefers-reduced-motion` tones the motion down or removes it, and the state change still happens.
- **Spatial consistency:** an element keeps its identity and position across states, so the user never loses track of where it went.
- **Perceived performance:** the right animation makes an interface feel faster than it is.
- **Anticipation:** a small wind-up opposite the move, hinting at what is about to happen.
- **Follow-through:** parts keep moving and settle slightly after the main motion stops, adding weight.
- **Squash & stretch:** deforming as it moves conveys weight, speed, and flexibility.

## Stack note

The terms are platform-agnostic. Map them to the stack at hand: web is CSS transitions/keyframes plus WAAPI or Motion; React Native is Reanimated (`withTiming`/`withSpring`, `useAnimatedStyle`, gesture-handler).
