---
name: product-debate
description: Default for every new product idea before implementation. Open a temporary product/design/engineering debate room, capture requirements and the decision, then close. Agents start here automatically; slash optional.
---

# Product debate

Default behavior for every new product idea before implementation. Do not
wait for the human to type `/product-debate`. This skill is the named
contract for that default. Same shape as `one-shot-task` and
`orwell-prose`: agents start here automatically when the ask is a new
product idea. It does not replace those defaults.

## Route

1. Open a temporary debate room whose name is plain product words (the
   product or feature under discussion). Not a bot name, not a role
   title, not Phase / Slice / Wave, not a standing channel.
2. Invite product, design, and engineering into that room (or the
   lane-native equivalent below).
3. Capture requirements and the decision in writing inside the room
   (or a linked note the room points at).
4. Close the room after the decision is captured. Do not leave it as a
   standing channel.
5. Only then start implementation under `one-shot-task` / poteto-mode.

## Lane-native room

- Where group channels exist: open a temporary named group channel, capture
  the decision, then close or archive the channel.
- Other lanes: run a time-boxed discussion and write the decision down
  (issue comment, doc, or session note). No fake `/loop`.

## Fail closed

Do not encode until the decision is captured in writing. A missing room,
missing requirements, or missing decision is a stop. Report what is missing
and what would unblock encode.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only (frontend, backend, mobile, design, CI,
review, QA, registry). Prefer foundation / increment / PR / milestone /
backlog. Room names use product words. No bot persona names, no role
titles, no phase / slice / section / wave labels, no em dashes.

## Reply shape

Name the room, the requirements captured, the decision, and that the room
is closed. Then hand off to the one-shot route for encode.
