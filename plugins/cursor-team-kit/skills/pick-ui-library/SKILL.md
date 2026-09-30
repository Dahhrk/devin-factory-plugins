---
name: pick-ui-library
description: Choose a UI component or animation library for a project. Structured comparison against project constraints. Use when the user asks which library to pick or when starting a new frontend.
---

# Pick UI library

Use when the user asks which UI component or animation library to use, or
when starting a new frontend and the stack is not yet decided. Do not wait
for the human to type `/pick-ui-library`. When the task needs a library
decision, apply this skill.

Provenance: adapted from emilkowalski/skills. Rewritten as operational agent
instructions in factory voice.

## Decision inputs

Before comparing libraries, collect these from the project context (read
package.json, framework config, or ask the human):

1. **Framework**: React, Vue, Svelte, Solid, vanilla, other.
2. **Rendering**: client-side, SSR, static, hybrid.
3. **Bundle budget**: hard limit in KB, or "no limit."
4. **Design system**: existing tokens/components, or starting fresh.
5. **Animation needs**: none, basic transitions, complex gesture-driven
   motion, physics-based, scroll-linked.
6. **Accessibility bar**: WCAG AA (default), WCAG AAA, or custom.
7. **Team familiarity**: libraries the team already knows.

## Comparison categories

For each candidate library, evaluate:

| Category | What to check |
|:---------|:-------------|
| Coverage | Does it cover the components and patterns the project needs? |
| Bundle size | Gzipped size of the runtime. Tree-shaking support. |
| Accessibility | Built-in ARIA, focus management, keyboard nav, screen reader testing. |
| Animation | Built-in motion primitives, or requires a separate animation library. |
| Theming | Token-based theming, dark mode support, CSS variable integration. |
| SSR | Hydration correctness, streaming support, no client-only globals. |
| Maintenance | Release cadence, open issue count, last release date, bus factor. |
| Escape hatches | Can you style or extend individual components without forking? |

## Common candidates (reference, not exhaustive)

**Component libraries**: Radix, Headless UI, Ark UI, Shadcn, Mantine,
Chakra, MUI, Ant Design.

**Animation libraries**: Framer Motion / Motion, React Spring, GSAP,
Lenis (scroll), Auto Animate, View Transitions API (native).

**CSS frameworks**: Tailwind, vanilla-extract, Panda CSS, CSS Modules.

## Decision format

Present a short comparison table (3 candidates max, 4 to 6 rows). Below the
table, name the recommendation and the one-sentence reason. If two
candidates are close, name the tiebreaker (usually bundle size or
accessibility).

## When to apply

- User asks "which library should I use" for UI, components, or animation.
- `factory-init` or `seat-kit` finds a frontend project with no component
  library chosen.
- `design-eng` needs a motion library and the project has none.

## Skip conditions

- Library already chosen and working. Do not re-litigate unprompted.
- Backend-only or CLI-only projects.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the prose.

## Reply shape

Decision inputs (what was collected), comparison table, recommendation with
reason, and any caveats. One paragraph max for caveats.
