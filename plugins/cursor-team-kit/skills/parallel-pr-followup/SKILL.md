---
name: parallel-pr-followup
description: Follow-up on an existing PR or branch in parallel (feedback, conflicts). Cloud agent or work on PR branch. No ga/tmux/Pi. Available skill; not Day-1 auto.
---

# Parallel PR follow-up

Kick off follow-up work on an existing PR or branch (review feedback,
merge conflicts, small continuations). Typing
`/parallel-pr-followup` (or "address this PR feedback in parallel")
invokes this skill. Available in the kit; not a Day-1 auto-apply
default.

Provenance: adapted from jnsahaj/skills `ga-pr`
(github.com/jnsahaj/skills). Same spirit. **Do not require** `ga-pr`,
tmux, or Pi.

## Hard rule

Never depend on `ga-pr`, tmux, or Pi. Work on the existing PR branch
via Cursor cloud agent, local checkout, or fleet workstream.

## Steps

1. Resolve the target: PR number, PR URL, or branch name. Task from the
   human (feedback, conflicts, continue).
2. Load context:

   ```bash
   gh pr view <n-or-url> --json number,title,body,url,state,headRefName,baseRefName,comments,reviews
   ```

   Optionally run `prepare-branch-context` on the head branch first.
3. Build a short task prompt for the child. For merge conflicts, say
   the child must ask before ambiguous choices.
4. Spawn on the **existing** PR branch (not a new feature branch):
   - Cursor cloud / background agent checked out to the PR head
   - Local work on the PR branch when that is simpler
   - Fleet workstream owned by one specialist when parent already
     orchestrates
5. Report: PR URL, branch, spawn path, task given. Do **not** tell the
   child to run `create-draft-pr` (PR already exists). Push updates to
   the same head.

## Guardrails

- Keep the task concise and direct.
- Conflict resolution: ask before ambiguous choices; prefer
  `fix-merge-conflicts` patterns when applicable.
- Author does not merge on own verdict. Autopilot stays off.
- Do not open a second PR for the same change set.

## Overlap

`parallel-task` owns new parallel kickoff + draft PR exit.
`get-pr-comments` owns fetching comments. `fix-merge-conflicts` owns
conflict resolution mechanics. `prepare-branch-context` owns read-only
catch-up. This skill owns parallel follow-up on an existing PR branch
without `ga`/tmux/Pi.

## Fail closed

Do not claim follow-up started without a PR/branch identity and a
child handle. Do not require tools the environment lacks.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

PR URL, branch, spawn path, task text. State that updates push to the
same head; no new draft PR.
