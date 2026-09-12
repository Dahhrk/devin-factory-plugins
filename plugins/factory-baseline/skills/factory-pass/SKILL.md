---
name: factory-pass
description: Bring an existing codebase up to factory spec. Surveys the repo against the baseline rules (smallest diff, no comments, perf, authorship, gates), reports findings ordered by risk, then fixes in reviewable units. Use for "full pass on this codebase", "convert/normalize this repo", "bring this up to spec".
---

# Factory pass

Available as `/factory-baseline:factory-pass`.

Convert an existing codebase to the factory contract. Audit first, fix
second — a report with no findings is a valid result, not a failure.

## Pass 0 — the floor

Before touching code, establish the gate the fixes will run against:

- Is there a test / lint / typecheck command? Find it in `package.json`,
  CI config, or Makefile — not by guessing.
- No gate at all → that is finding zero. A refactor sweep without a gate
  is unverifiable churn; offer to install the minimal gate first
  (`/pstack:create-verification-skill` for a product, or the repo's own
  test runner wired into CI).
- Vendored, generated, and third-party trees are out of scope — never
  rewrite them.

## The survey

Walk the repo and log findings as `path:line — rule — fix shape`. Order:

1. **Dead weight** — commented-out code, unused exports/helpers, dead
   branches, scratch files, stale TODOs whose moment passed.
2. **Comment slop** — narration, banners, docstrings that restate the
   signature, AI-flavored justification paragraphs. Keep-list is
   `smallest-correct-diff`: license headers, API contracts, forced
   non-obvious behavior, faulty-rule suppressions.
3. **Surface shrink** — single-use helpers that inline cleaner, wrappers
   around what the platform already does, speculative abstractions
   ("configurable" knobs nobody turns), N-copy-paste sites that are one
   shared function.
4. **Perf smells** — N+1 calls, awaits serialized in loops, allocation
   churn on hot paths, recomputed constants, unbounded collections.
   Each one gets a claimed-fix note, and the fix carries a number
   (benchmark/profile/timing before-after) per smallest-correct-diff.
5. **Contract surfaces** — `AGENTS.md` present? `verify-*` / control CLI
   for a product? CI gates wired? `.devin/` blueprint if the repo wants
   the cloud lane? Missing pieces are findings too.

## Report

Findings table ordered by risk x value — correctness and perf first,
cosmetics last. Each row is a unit the human can approve or skip. Do not
start fixing until the human says go, unless they asked for the full
sweep outright.

## Fixing

- One finding cluster per commit / PR — the survey is not a license for
  one giant cleanup diff. Group by area, not by rule.
- Run the repo's gate after every unit. Red gate means stop and fix or
  revert — never sweep on red.
- Minimal is not sloppy: validation, locks, concurrency guards, and
  error paths stay. If removing a guard looks right, that is a bug, not
  a cleanup.
- Draft PRs, `Done means` + `Keep`, professional commits — the whole
  contract applies to the sweep itself.
- Deeper AI-slop removal is `/cursor-team-kit:deslop`; verification of a
  specific claim is `/cursor-team-kit:verify-this`; a full audit review
  of a gnarly diff is `cursor-team-kit:thermo-nuclear-code-quality-review`.
