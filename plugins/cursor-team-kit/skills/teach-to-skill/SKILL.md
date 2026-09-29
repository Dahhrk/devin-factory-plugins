---
name: teach-to-skill
description: Post-pass after recurring manual work. If the same manual flow recurred twice, offer skill-authoring / learn-from-demonstration once; drop if declined. Agents start here automatically; slash optional.
---

# Teach to skill

Post-pass after a task lands. Do not wait for the human to type
`/teach-to-skill`. When the same manual flow has recurred twice, offer
to encode it once. This skill is the named contract for that default.
Same shape as `one-shot-task`: agents apply the post-pass automatically.
It does not replace that default.

## Route

1. After a successful pass, check whether this session (or the recent
   trail) repeated the same manual flow at least twice: same steps,
   same gates, same "we keep doing this by hand" smell.
2. If yes, offer skill-authoring once. Point at Cursor's built-in
   `/create-skill` or the lane's learn-from-demonstration path. Name
   the flow in plain words and the skill file you would write.
3. If the human declines or ignores the offer, drop it. Do not nag.
   Do not open a skill PR unasked.
4. If the flow is already a skill, skip the offer. Point at the existing
   skill only when that helps the next run.

## Fail closed

Do not invent a skill from one occurrence. Do not encode product secrets
or one-off credentials into a skill. Do not block the main artifact on
this post-pass.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes.

## Reply shape

After the main artifact: one short offer line when the twice-bar is
met, or silence when it is not. If declined, say nothing further about
it.
