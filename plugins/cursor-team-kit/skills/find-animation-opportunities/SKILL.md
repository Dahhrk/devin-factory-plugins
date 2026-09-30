---
name: find-animation-opportunities
description: Scan a UI for places where animation would improve clarity, feedback, or delight. Use during polish passes or when the user asks where to add motion.
---

# Find animation opportunities

Scan existing UI for places where adding animation would improve clarity,
feedback, or delight. Use during polish passes, design reviews, or when the
user asks "where should I add animation?" Do not wait for the human to type
`/find-animation-opportunities`.

Provenance: adapted from emilkowalski/skills. Rewritten as operational agent
instructions in factory voice.

## Where to look

Check each category. For every opportunity found, name the element, the
animation type, and what it communicates.

### State transitions

- **Appear/disappear**: elements that pop in or vanish without transition
  (modals, tooltips, dropdowns, toasts, drawers). Add fade, slide, or
  scale entrance/exit.
- **Content swap**: text, images, or cards that replace each other without
  crossfade. Add crossfade or slide.
- **Loading to loaded**: skeleton or spinner to real content without
  transition. Add a gentle fade.
- **Expand/collapse**: accordions, disclosure panels, or detail sections
  that snap open. Add height animation.

### Feedback

- **Click/tap**: buttons or interactive elements with no pressed state.
  Add scale-down (0.97 to 0.98) on active.
- **Success/error**: form submissions that show a result without emphasis.
  Add a subtle shake (error) or checkmark animation (success).
- **Drag**: draggable elements that teleport instead of following the
  pointer. Add position tracking with spring physics.

### Spatial hierarchy

- **Page transitions**: full page swaps with no transition. Add slide,
  fade, or shared-element transition.
- **Tab/panel switches**: tab content that swaps instantly. Add directional
  slide to reinforce spatial model.
- **List reorder**: items that teleport to new positions. Add layout
  animation (FLIP or framework equivalent).
- **List add/remove**: items that appear or vanish without transition. Add
  enter/exit animations with stagger.

### Delight (budget: at most two per view)

- **Empty state illustration**: a static illustration that could use a
  subtle loop or entrance animation.
- **Hover detail**: a card or link that could reveal extra information with
  a smooth expansion on hover.

## Prioritization

Rank opportunities:

1. **Clarity** (state transitions that confuse users without animation).
2. **Feedback** (interactions that feel broken without response).
3. **Spatial hierarchy** (navigation that disorients without transition).
4. **Delight** (lowest priority; cut first under time pressure).

## Output format

| Priority | Element | Animation type | What it communicates |
|:---------|:--------|:---------------|:--------------------|
| 1 | ... | ... | ... |

## When to apply

- Polish pass on any UI before shipping.
- User asks "where should I add animation" or "this feels static."
- `design-eng` identifies a UI that lacks motion feedback.

## Skip conditions

- Backend-only, CLI-only, or headless work.
- User explicitly says "no animation."

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Present the opportunity table. Name the top 3 highest-priority items and
suggest concrete implementation (duration, easing, library if relevant).
Hand off to `design-eng` for execution.
