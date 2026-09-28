---
name: figma-from-system
description: Default for ui:yes / Figma work. Start from the existing design system plus one approved keyframe, expand the full flow in Figma, prove visual parity, then encode. Agents start here automatically; slash optional.
---

# Figma from system

Default behavior for every `ui:yes` / Figma ask. Do not wait for the human
to type `/figma-from-system`. This skill is the named contract for that
default. Same shape as `one-shot-task` and `orwell-prose`: agents start
here automatically on UI paths. It does not replace those defaults.

## Route

1. Confirm an existing design system is available (tokens, components,
   patterns already in the product or shared library).
2. Confirm one approved keyframe exists for the ask (a reviewed screen or
   state the human has signed off).
3. Confirm Figma access works (Figma MCP or the lane's Figma tooling).
4. Inside Figma, expand the full end-to-end flow from that system and
   keyframe. Cover every state the Done means names (empty, loading,
   error, success, edge).
5. Prove visual parity against the approved keyframe and system. Capture
   evidence (frame links, screenshots, or MCP reads).
6. Get a look from the frontend workstream before any encode step.
7. Only then implement UI against the Figma source of truth.

## Fail closed

Stop and report. Do not invent a design system. Do not invent a keyframe.
Do not implement UI when any of these are missing:

- No design system
- No approved keyframe
- No Figma access

A fail-closed report names which gate failed and what evidence would
unblock it. Builds and self-reports are not evidence.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge. Author does not
merge on own verdict.

## Language

Plain workstream nouns only (frontend, backend, mobile, design, CI,
review, QA, registry). Prefer foundation / increment / PR / milestone /
backlog. No bot persona names, no role titles, no phase / slice / section /
wave labels, no em dashes.

## Reply shape

Name the gate status (system, keyframe, Figma access), the Figma flow
link or frame ids, the visual-parity proof, and the frontend look result.
Then encode only if every gate passed.
