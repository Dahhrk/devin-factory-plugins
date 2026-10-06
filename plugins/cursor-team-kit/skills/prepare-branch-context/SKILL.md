---
name: prepare-branch-context
description: Read-only branch catch-up. Diff from main, commits, related PR. Use for "prepare context", "catch me up", "what is on this branch". Available skill; not Day-1 auto.
---

# Prepare branch context

Build a clear picture of the current branch so follow-up work has full
context. Typing `/prepare-branch-context` (or "catch me up on this
branch") invokes this skill. Available in the kit; not a Day-1
auto-apply default.

Provenance: adapted from jnsahaj/skills prepare-branch-context
(github.com/jnsahaj/skills). Rewritten in factory voice.

## Hard rule

Read only. Do not edit files, commit, push, or open a PR while running
this skill.

## Steps

1. Identify branch and base:

   ```bash
   git branch --show-current
   git merge-base HEAD main
   ```

2. Gather the diff from main (read the content, not only `--stat`):

   ```bash
   git diff main...HEAD --stat
   git diff main...HEAD
   ```

3. Review commit history on this branch:

   ```bash
   git log main..HEAD --oneline
   ```

4. Check for a related PR:

   ```bash
   gh pr list --head "$(git branch --show-current)" \
     --json number,title,body,url,state,comments --jq '.[0]'
   ```

   If a PR exists, read title, body, and comments for Done means and
   review feedback.

5. Summarize: purpose, key files, notable decisions, open review
   comments, working-tree state (clean / dirty).

6. Signal readiness for follow-up on this branch.

## Guardrails

- If the branch is `main` (or has no divergence), say so and stop.
- Large diffs: structure first, then key files in detail.
- No PR is fine; note it and continue.
- Prefer `origin/main` / `upstream/main` when local `main` is stale;
  say which base you used.

## Overlap

`get-pr-comments` owns fetching review comments alone.
`make-pr-easy-to-review` owns reviewability cleanup.
`review-and-ship` owns review-then-ship. This skill owns read-only
catch-up before further work on the branch.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Purpose, key files, decisions, open review threads, tree state, then
"ready for follow-up".
