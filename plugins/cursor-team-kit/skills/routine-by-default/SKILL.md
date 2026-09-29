---
name: routine-by-default
description: When an ask is recurring, scheduled, time-based, "let me know when", "check daily", "keep an eye on", or the same manual flow is about to be re-asked, create or update a routine/automation instead of doing it once and waiting for another ping. Agents apply automatically; slash `/routine-by-default` names the contract. Named contract; same shape as leave-machine-clean.
---

# Routine by default

Recurring work becomes a routine. Do not wait for the human to type
`/routine-by-default`. When the ask is scheduled, time-based, "let me
know when", "check daily", "keep an eye on", "remind me", or the same
manual flow is about to be re-asked, save a routine (or this lane's
equivalent automation) with a clear trigger and prompt, then confirm
once. This skill is the named contract for that default. Same shape as
`leave-machine-clean`: agents apply automatically when the need is
recurring.

## Route

1. Recurring / scheduled / monitor / remind / keep-an-eye: create or
   update the routine now. Confirm once with the trigger in plain words.
2. One-shot stays one-shot. Do not invent cron for a single ask.
3. Unsure whether it should recur: offer one sentence and wait for yes.
   Do not create silently when unsure.
4. Fail closed if you end with "remind me later", "ask me again", or
   "I'll check next time" for a clearly recurring need.

## Fail closed

Ending a clearly recurring ask without a routine (or a pending offer the
human can accept) is not done.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose: say what changed and why.

## Reply shape

Name the routine created or updated (or the offer you made). State the
trigger in plain words and when it fires.
