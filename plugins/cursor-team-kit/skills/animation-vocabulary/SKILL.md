---
name: animation-vocabulary
description: Shared vocabulary for describing animation and motion in UI work. Use first when feedback about motion is vague ("make it feel better", "the animation is off"). Named contract.
---

# Animation vocabulary

Use this skill first when motion feedback is vague. "Make it feel better",
"the animation is off", "it feels janky", "more fluid", and similar phrases
need translation into concrete properties before anyone can act on them.
Do not wait for the human to type `/animation-vocabulary`. When vague UI
feedback involves motion, apply this skill to pin the language, then hand
off to `design-eng` or `review-animations`.

Provenance: adapted from emilkowalski/skills. Rewritten as operational agent
instructions in factory voice.

## The vocabulary

### Timing words

| Word | Means | Property |
|:-----|:------|:---------|
| snappy | under 200ms, ease-out | short duration, ease-out curve |
| smooth | 200ms to 400ms, gentle ease | medium duration, ease-in-out |
| sluggish | over 500ms or linear | too long or wrong easing |
| instant | under 80ms, often no easing | effectively no animation |
| bouncy | spring with overshoot | spring physics, high stiffness, low damping |
| gentle | spring with no overshoot | spring physics, low stiffness, high damping |

### Easing words

| Word | Means | Curve |
|:-----|:------|:------|
| ease-in | slow start, fast end | use for exits |
| ease-out | fast start, slow end | use for entrances |
| ease-in-out | slow both ends | use for symmetric transitions |
| linear | constant speed | almost never right for UI |
| spring | physics-based, responds to velocity | use for drag, gesture, natural motion |

### Motion words

| Word | Means | Implementation |
|:-----|:------|:---------------|
| slide | translate on one axis | transform: translateX/Y |
| fade | opacity change | opacity 0 to 1 or reverse |
| scale | size change from a point | transform: scale, set transform-origin |
| collapse | height to zero | height or max-height transition, or layout animation |
| stagger | sequential offset | delay each sibling by 30ms to 60ms |
| parallax | layers move at different speeds | scroll-linked transform at varying rates |

### Feel words (vague to concrete)

| Vague feedback | Likely means | Ask to confirm |
|:---------------|:------------|:---------------|
| "feels off" | wrong easing or duration | "Is it too fast, too slow, or does the curve feel wrong?" |
| "janky" | frame drops or layout thrash | "Is it stuttering, or is the motion path wrong?" |
| "too much" | too many animations or too long | "Should I cut animations or shorten them?" |
| "not enough" | missing feedback or too fast | "Should I add a transition or slow it down?" |
| "weird" | unexpected direction or origin | "Is the element moving the wrong way or from the wrong spot?" |
| "mechanical" | linear easing or no stagger | "Should I add easing curves or stagger the timing?" |

## How to use

1. When the human gives vague motion feedback, look up the closest match in
   the "feel words" table.
2. Translate to the concrete property column.
3. Confirm with the human: "You said it feels off. The entrance is 400ms
   with linear easing. Should I shorten to 200ms with ease-out?"
4. Once confirmed, hand off to `design-eng` for implementation or
   `review-animations` for review.

## When to apply

- Vague motion/animation feedback before implementation.
- Onboarding a new collaborator into UI motion work.
- Disambiguating animation descriptions in specs or issues.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Name the vague input, the concrete translation, and the confirmation
question. Then route to the implementation or review skill.
