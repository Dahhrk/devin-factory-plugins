---
name: progressive-disclosure
description: Default for designing or reviewing public APIs, libraries, component props, CLI flags, or SDK surfaces. Four layers of progressive disclosure. Zero-config default, complexity opt-in, call-site-first. Named contract; agents apply automatically.
---

# Progressive disclosure

Default rule for every public seam: API, library, component props, CLI
flags, SDK surface, configuration schema, or plugin interface. Do not
wait for the human to type `/progressive-disclosure`. This skill is the
named contract for that default. Agents start here automatically when
designing, reviewing, or refactoring a public surface.

Provenance: adapted from Peter Friese's Stratos project
(github.com/peterfriese/Stratos) and Petros Karatzas's API craft
principles. Rewritten language-agnostic in factory voice.

## Hard rule

Design every public surface so the simplest correct call has the fewest
arguments and imports possible. Complexity is opt-in, never forced on
the first caller.

## Four layers

Organize the surface into four concentric rings. A caller who never
leaves layer 1 should never see layers 2 through 4.

1. **Surface.** The zero-config entry point. One function, one
   constructor, one command. No required options beyond the obvious
   input. Sensible defaults for everything else. Most callers stop here.
2. **Customization.** Named options that override defaults. Passed as
   optional parameters, builder methods, flags, or config keys. Caller
   picks what to customize; everything else keeps its default.
3. **Environment.** Integration with external systems (auth providers,
   storage backends, network layers, platform APIs). Separate from
   customization so a caller who only tweaks a color never sees a
   database handle.
4. **Advanced.** Escape hatches, raw access, lifecycle hooks, low-level
   overrides. Documented but not discoverable from the surface layer.
   Used by library authors and power users, not by adopters on day one.

These layers are a design lens, not a folder structure. A small API
might collapse layers 3 and 4. The test is: can a caller who only needs
layer N ignore layers N+1 and above?

## Operational rules

Treat these as constraints, not a checklist.

- **Call-site-first.** Read the call site before the declaration. A
  clean call site beats a clean declaration every time. If the call site
  looks noisy, the API is wrong.
- **Minimize public symbols.** Every exported name is a promise. Fewer
  names, fewer promises. Internal helpers stay internal.
- **Cut adopter-facing deps.** If the caller must import a type or
  package only to satisfy your signature, that dependency is a tax.
  Accept primitives or provide the type from your own surface.
- **Layers stay opaque.** Layer 1 does not leak types from layer 3.
  A caller who never configures a storage backend should never see
  `StorageConfig` in autocomplete.
- **No stringly types.** An argument that accepts an arbitrary string
  where an enum, union, or newtype would prevent misuse is a bug.
- **No boolean traps.** A function with two boolean positional
  parameters is unreadable at the call site. Use named options, enums,
  or separate functions.
- **Errors are API.** Error types, codes, and messages are part of the
  public surface. Design them like return types, not afterthoughts.
- **Make expensive ops obvious.** If a call triggers network, disk, or
  heavy compute, the name or signature should say so. Hiding latency
  behind a property getter is a trap.
- **Design the client API first.** Write the call site you want before
  writing the implementation. The implementation serves the call site,
  not the reverse.

## Rejection criteria

Reject (or require rework of) a public surface that:

- Forces a required import the caller does not conceptually need.
- Exposes more than one layer of complexity at the default call site.
- Uses boolean positional parameters without named context.
- Accepts raw strings where a constrained type would prevent misuse.
- Leaks an internal abstraction (database row, wire format, cache key)
  into the public signature.
- Makes an expensive operation look cheap at the call site.

## Overlap

`software-factory-gates` owns architecture and design approval gates.
`refactor-first` owns work order when changing existing modules.
`pit-of-success` owns the footgun test for misuse resistance. This
skill owns progressive disclosure structure and call-site-first
design of public seams.

## Skip conditions

- Pure internal code with no public surface skips this skill.
- Trivial one-liner fixes skip this skill.
- When the human explicitly says "skip progressive-disclosure", respect
  that.

## Fail closed

Do not ship a new public API, component prop set, CLI flag group, or
SDK surface without checking it against the four layers and the
rejection criteria. If the surface is too large to review in one pass,
scope to the area the change touches and say so in the commit.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge. Author does
not merge on own verdict.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Name the layer each public symbol lives in, call out any rejection
criteria violations, and state whether the surface passes or needs
rework.
