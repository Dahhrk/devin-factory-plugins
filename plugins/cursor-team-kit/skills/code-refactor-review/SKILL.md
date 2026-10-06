---
name: code-refactor-review
description: Review diffs and PRs for reuse, composition, codebase consistency, and slop. Invoke when asked to review a PR or diff for fit with the codebase. Available skill; not Day-1 auto.
---

# Code refactor review

Deep review lens for reuse, composition, consistency, and slop on a
diff or PR. Typing `/code-refactor-review` (or an explicit review ask)
invokes this skill. It is available in the kit; it is not a Day-1
auto-apply default.

Provenance: adapted from jnsahaj/skills code-refactor-review
(github.com/jnsahaj/skills). Rewritten language-agnostic in factory
voice. Framework-specific reaction examples from upstream were dropped;
prefer the host repo's patterns.

## When to use

- Review a PR, branch diff, or staged changes for fit with the codebase
- Check reuse, composition, consistency, or "is this slop?"
- Before ship when a large feature landed and needs a second pass

## First pass

1. Inspect the full diff (`git diff`, `git diff HEAD`, or `gh pr diff`).
2. Build call stack / data flow when useful. Do not judge isolated
   lines without knowing how the feature is wired.
3. Search the codebase before judging new helpers, modules, or
   patterns. Prefer nearby and sibling patterns over invented ones.

## Review lenses

1. **Reuse.** Existing utilities, components, routes, copy, and style
   primitives beat newly written twins. Flag duplicated logic. A new
   shared helper needs real reuse, not a vague name on private logic.
2. **Consistency.** Placement matches domain neighbors. Naming matches
   what the code does. Result / error / loading patterns match the
   repo's standard. User-facing copy matches tone.
3. **Composition and boundaries.** One job per function at the right
   level. No grab-bag modules. Prefer simple composition over wrapper
   chains and prop plumbing. Domain logic stays near its domain unless
   cross-domain reuse is proven.
4. **Slop.** Obvious comments defending awkward code; tiny wrappers
   that add no meaning; one-off types that paper over bad shape;
   memo / callback / effect noise without a measured reason;
   compatibility cruft; unrelated diff churn.
5. **Minimality.** Prefer deleting over adding structure. Keep the fix
   proportional. Do not invent architecture the repo does not use.

## Output

Start with a verdict:

- `clean` - no meaningful concerns
- `mostly clean` - minor cleanup only
- `needs cleanup` - important reuse / composition / consistency issues

Then list findings by priority. For each: path + symbol, what is wrong,
existing pattern to reuse (if found), minimal fix.

Review-only asks: do not edit. Fix asks: edit and summarize.

## Overlap

`deslop` owns AI slop cleanup as a pass. `thermo-nuclear-code-quality-review`
owns the unusually strict maintainability rubric. `refactor-first` owns
work order (refactor then change). This skill owns reuse + composition
+ consistency review lenses on a diff. Do not duplicate the thermo
rubric here.

## Skip conditions

- Trivial one-liner diffs with no new abstractions skip this skill
  unless the human asked for review.
- When the human asks only for ship / CI / verify, stay on those skills.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge. Author does
not merge on own verdict.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Verdict first, then prioritized findings with path, problem, reuse
target, and minimal fix.
