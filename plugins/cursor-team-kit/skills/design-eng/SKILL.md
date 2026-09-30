---
name: design-eng
description: Main design-engineering taste skill for UI and motion work. Covers layout, spacing, typography, color, animation, and interaction polish. Default for UI and animation tasks. Named contract.
---

# Design engineering

Default for UI work, animation, and interaction polish. Do not wait for the
human to type `/design-eng`. When the task touches user-facing visuals or
motion, apply this skill. Named contract; same shape as `figma-from-system`
for UI paths.

Provenance: adapted from emilkowalski/skills (Emil Kowalski's design
engineering practice). Rewritten as operational agent instructions in factory
voice.

## Core stance

Good UI feels inevitable. Every pixel, timing curve, and interaction should
look like the only possible answer, not a choice among equals. Strip
decoration that does not serve comprehension or delight. Animation is not
ornament; it communicates state, hierarchy, and causality.

## Layout and spacing

- Use a consistent spatial scale (4px or 8px base). Do not invent spacing
  values per component.
- Align elements to a visible or implied grid. Misalignment by 1px is a bug.
- Group related elements with proximity; separate unrelated groups with
  whitespace, not dividers. Dividers are a last resort.
- Responsive layouts degrade gracefully. Define breakpoints from content
  needs, not device names.

## Typography

- Limit to two typefaces maximum. One is better.
- Establish a type scale and use only its steps. Ad hoc font sizes are bugs.
- Line height for body text: 1.4 to 1.6. For headings: 1.1 to 1.3.
- Contrast ratio: 4.5:1 minimum for body text, 3:1 for large text (WCAG AA).

## Color

- Derive every color from the product's design tokens or system palette.
  Do not invent colors.
- Limit the active palette to 3 to 5 colors plus neutrals. Accent colors
  highlight one thing; if everything is accent, nothing is.
- Dark mode is not inverted light mode. Reduce surface contrast (dark grey,
  not pure black), shift accent colors for legibility, and drop shadows in
  favor of subtle borders or elevation cues.

## Animation principles

- Every animation answers "what changed and why." If you cannot name what
  it communicates, cut it.
- Duration: 150ms to 300ms for micro-interactions, 300ms to 500ms for layout
  transitions. Under 100ms feels instant and wastes motion. Over 500ms feels
  sluggish.
- Easing: ease-out for entrances (fast start, gentle land), ease-in for
  exits (gentle start, fast disappear). Linear easing is almost never right
  for UI.
- Spring physics over bezier curves when the framework supports them. Springs
  feel more natural because they respond to velocity.
- Stagger: offset sibling animations by 30ms to 60ms to suggest spatial
  order. Identical timing on a list feels robotic.
- Reduce motion: honor `prefers-reduced-motion`. Fade instead of slide.
  Shorten or skip stagger. Never disable feedback entirely.

## Interaction feedback

- Every interactive element has a visible pressed/active state.
- Hover states are additive, not transformative. A button that moves on
  hover is disorienting; a button that gains a subtle highlight is legible.
- Loading states communicate progress or activity. Skeleton screens beat
  spinners for layout stability. Spinners beat nothing.
- Error states appear inline next to the cause, not in a distant toast.
  Toasts are for success confirmations the user can safely ignore.

## Polish pass

Before shipping any UI change, run a polish pass:

1. Tab through every interactive element. Focus ring visible and correct?
2. Resize the viewport at 320px, 768px, 1024px, 1440px. Layout intact?
3. Toggle dark mode. Contrast, shadows, and accents correct?
4. Enable `prefers-reduced-motion`. Animations replaced or shortened?
5. Check alignment on a pixel grid (browser DevTools overlay or screenshot
   comparison). Off-by-one is a bug.

## When to apply

- Any task that creates or modifies user-facing UI.
- Any task that adds or changes animation or transitions.
- Review pass before shipping front-end work (pairs with `review-animations`).

## Skip conditions

- Backend-only, CLI-only, or headless work skips this skill entirely.

## Fail closed

Do not ship UI that fails the polish pass. Report which check failed and fix
it, or flag the item for the human.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them with
evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Name the UI elements changed, the polish pass results, and any animation
decisions with their reasoning. Show before/after when feasible.
