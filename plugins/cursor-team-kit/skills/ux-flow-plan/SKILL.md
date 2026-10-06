---
name: ux-flow-plan
description: Default for user-facing feature work. Build current vs desired UX flow trees first, then attach file and function anchors. Named contract; agents apply automatically.
---

# UX flow plan

Default rule when the work changes what a user does or sees. Do not
wait for the human to type `/ux-flow-plan`. This skill is the named
contract for that default. Agents start here automatically before
encoding a user-facing feature, flow, or navigation change.

Provenance: adapted from jnsahaj/skills ux-flow-plan
(github.com/jnsahaj/skills). Rewritten language-agnostic in factory
voice.

## Hard rule

Plan the experience as flow trees first. Attach file and function
anchors after the trees are clear. Do not start from line numbers.

## Steps

1. Restate the feature goal in product terms (the human's words).
2. Draw the **current** UX flow as a tree:

   ```text
   User action
   └─ System behavior
      └─ Existing layer
         └─ File / function anchor (after the tree, not as the story)
   ```

3. Draw the **desired** UX flow as a second tree in the same shape.
4. Name the boundary decisions:
   - Which layer detects the condition
   - Which layer owns side effects
   - Which layer updates UI or status
   - Which layer persists or mutates state
5. Attach implementation anchors only after the trees: files,
   functions, existing abstractions to reuse, tests that cover the
   flow.
6. End with a short decision list: recommended shape, alternatives
   rejected, open questions.

## Operational rules

- Start with UX and system flow, not edits.
- Keep trees short. Prefer product nouns over framework jargon unless
  the jargon names a real boundary.
- Separate current flow from desired flow. Mixing them hides the delta.
- Call out whether the feature couples to an existing concept or stands
  alone on purpose.

## Overlap

`figma-from-system` owns design-system + keyframe + Figma expand before
encode. `design-eng` owns UI and motion taste. `software-factory-gates`
owns Product / Architecture approval gates. This skill owns flow trees
before code. Use it with those skills; it does not replace them.

## Skip conditions

- Pure backend / infra / gate work with no user-visible flow skips this
  skill.
- Trivial copy or typography tweaks skip this skill.
- When the human explicitly says "skip ux-flow-plan", respect that.

## Fail closed

Do not encode a user-facing flow change without current and desired
trees (or an explicit skip). If the surface is large, scope trees to
the flow the change touches and say so in the commit.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge. Author does
not merge on own verdict.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Show current tree, desired tree, boundary decisions, then anchors.
Keep the narrative UX-first; put paths last.
