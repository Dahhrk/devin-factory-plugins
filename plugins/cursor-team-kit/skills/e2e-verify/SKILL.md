---
name: e2e-verify
description: When the claim is end-to-end product behavior (esp. mobile or multi-screen UI), require a real e2e path, not unit-only. Pairs with verify-this and run-smoke-tests. Available skill; not Day-1 auto.
---

# E2E verify

Light companion when the claim is end-to-end product behavior. Typing
`/e2e-verify` (or a Done means that needs a real user journey) invokes
this skill. Available in the kit; not a Day-1 auto-apply default.

Provenance: factory companion for mobile / multi-screen e2e claims.
Pairs with `verify-this` (falsifiable claim + verdict) and
`run-smoke-tests` (Playwright smoke). Do not vendor a full tester.army
product.

## Hard rule

Unit green is not enough for an end-to-end product claim. Require a
real e2e path: harness, device, or browser journey that exercises the
user-visible flow.

## When to use

- Done means names a multi-screen or mobile journey
- Fix claims "users can complete X" across more than one surface
- UI / CLI / app claim where unit tests cannot see the wiring

## Steps

1. Restate the claim in falsifiable form (hand to `verify-this`).
2. Pick the smallest e2e surface that can disprove it:
   - Web: Playwright / `run-smoke-tests` / `control-ui`
   - CLI / TUI: `control-cli` or scripted transcript
   - Mobile / multi-screen: device or emulator run, or the repo's
     existing e2e harness (Detox, Maestro, XCUITest, Espresso, etc.)
3. Capture baseline and treatment the same way `verify-this` requires.
4. Return `VERIFIED` / `NOT VERIFIED` / `INCONCLUSIVE` with artifacts.
5. If the repo has no e2e harness and the claim needs one, say so and
   fail closed or add the minimum harness the Done means requires. Do
   not invent a large testing product.

## Guardrails

- Keep this skill short. Prefer existing repo scripts over new
  frameworks.
- Do not claim e2e from unit-only evidence.
- Screenshots / traces / device logs beat narrative recap.
- Autopilot stays off. Do not green TRUST-NEXT from a self-report.

## Overlap

`verify-this` owns falsifiable claim + baseline/treatment + verdict.
`run-smoke-tests` owns Playwright smoke triage. `control-ui` /
`control-cli` own local harness drives. This skill owns the gate that
e2e claims need an e2e path.

## Skip conditions

- Pure library / algorithm claims with no user journey skip this skill
  (`verify-this` alone is enough).
- When Done means is explicitly unit-scoped, respect that.

## Fail closed

Do not ship an end-to-end product claim without e2e evidence (or an
explicit `INCONCLUSIVE` with the gap named). Recap is not evidence.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Same shape as `verify-this`, plus the e2e surface used (harness,
device, browser journey) and artifact paths.
