---
name: review-animations
description: Review all animations and transitions in a change before shipping. Check timing, easing, purpose, reduced-motion, and performance. Default pre-ship gate for UI work. Named contract.
---

# Review animations

Pre-ship review gate for animations and transitions. Apply before merging any
change that adds or modifies motion. Do not wait for the human to type
`/review-animations`. When UI work includes animation, this fires as a final
gate alongside the normal review pass. Named contract.

Provenance: adapted from emilkowalski/skills. Rewritten as operational agent
instructions in factory voice.

## Review checklist

For every animation or transition in the diff, answer each question. A "no"
on any item is a finding that blocks ship until fixed or explicitly accepted
by the human.

### Purpose

1. Can you name in one sentence what this animation communicates?
   If not, cut it.
2. Would the UI be confusing without it? If not, it is decorative. Cut it
   or justify it as delight (delight budget: at most two decorative
   animations per view).

### Timing

3. Duration within 150ms to 300ms for micro-interactions?
4. Duration within 300ms to 500ms for layout transitions?
5. No animation under 100ms (wasted motion) or over 500ms (sluggish)?

### Easing

6. Entrances use ease-out (or spring)?
7. Exits use ease-in (or spring with low bounce)?
8. No linear easing on UI elements?

### Stagger

9. Sibling list animations offset by 30ms to 60ms?
10. Stagger order matches reading direction or spatial position?

### Reduced motion

11. `prefers-reduced-motion` honored?
12. Reduced alternative is fade or instant, not just slower?
13. Feedback (focus rings, pressed states) preserved under reduced motion?

### Performance

14. Animation runs on compositor-friendly properties (transform, opacity)
    where possible? Avoid animating width, height, top, left, margin, or
    padding directly.
15. No layout thrashing (forced reflow inside animation frame)?
16. GPU layer count reasonable (no accidental will-change on every element)?

### Consistency

17. Same interaction pattern uses the same timing and easing across the app?
18. Animation tokens (duration, easing) come from shared constants, not
    inline magic numbers?

## Findings format

For each finding, report:

- File and line.
- Which checklist item failed.
- Suggested fix (one sentence).

## When to apply

- Before merging any PR that adds or changes CSS transitions, keyframe
  animations, Framer Motion / React Spring / GSAP / Web Animations API
  usage, or any other motion code.
- Pairs with `design-eng` during the polish pass.
- `poteto-mode` routes here on the review step of any UI playbook.

## Skip conditions

- Changes with zero animation or transition modifications skip this gate.

## Fail closed

Do not ship animations that fail the checklist without explicit human
acceptance for each finding. Decorative animations over the delight budget
are cut, not negotiated.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them with
evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Present findings as a numbered list (file, checklist item, fix). End with
pass/fail verdict. If all items pass, say so in one line.
