---
name: pit-of-success
description: Default for public seams. Make the obvious call correct; make misuse hard. Footgun test on every public surface. Named contract; agents apply automatically.
---

# Pit of success

Default rule for public seams: APIs, library exports, component props,
CLI commands, SDK surfaces, configuration schemas. Do not wait for the
human to type `/pit-of-success`. This skill is the named contract for
that default. Agents start here automatically when building, reviewing,
or extending a public surface.

Provenance: adapted from jnsahaj/skills pit-of-success
(github.com/jnsahaj/skills). Rewritten language-agnostic in factory
voice.

## Hard rule

The obvious way to call the code must be the correct way. Misuse must
require deliberate effort, not a missing argument or a wrong default.

## Footgun test

Run this test on every public seam before shipping. Each question is
pass/fail.

1. **Default call.** Does the zero-argument (or minimal-argument) call
   do the right thing? If the caller must remember a flag to avoid
   broken behavior, the default is wrong.
2. **Wrong-type guard.** Can the caller pass a wrong type and get a
   runtime surprise? If yes, tighten the signature (union, enum,
   newtype, branded primitive).
3. **Forgettable step.** Is there a step the caller must remember
   (close a handle, call init, set a header) that the API cannot
   enforce? If yes, restructure so the step is automatic or the
   compiler catches the omission.
4. **Silent failure.** Can the caller misuse the API and get silence
   instead of an error? If yes, fail loudly.
5. **Pit escape.** Does correct usage require reading docs that the
   type system or defaults could have enforced? If yes, encode the
   constraint.

One failure means the seam needs rework. Fix the seam itself, not
individual call sites.

## Operational rules

- **Fix the seam, not the callers.** A footgun found at one call site
  means every caller is exposed. Change the API, not a single usage.
- **Defaults encode the common case.** If 90% of callers pass the
  same value, that value is the default.
- **Impossible states stay impossible.** Use types, enums, sealed
  classes, or similar constructs so the caller cannot represent an
  invalid configuration.
- **Errors surface early.** Validate at the boundary, not deep inside.
  The caller sees the failure where they can act on it.
- **Names prevent mistakes.** A parameter named `timeout_ms` prevents
  the seconds-vs-milliseconds bug. A boolean named `force` prevents
  the "what does true mean here" bug.

## Overlap

`progressive-disclosure` owns the four-layer structure and
call-site-first design. `refactor-first` owns work order for existing
modules. This skill owns the footgun test: make obvious calls correct,
make misuse hard.

## Skip conditions

- Pure internal code with no public surface skips this skill.
- Trivial one-liner fixes skip this skill.
- When the human explicitly says "skip pit-of-success", respect that.

## Fail closed

Do not ship a new or changed public seam without running the footgun
test. If the surface is large, scope to the area the change touches
and say so in the commit.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge. Author does
not merge on own verdict.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

List each footgun test result (pass/fail) for the seam under review.
Name any failing items and the fix applied or required.
