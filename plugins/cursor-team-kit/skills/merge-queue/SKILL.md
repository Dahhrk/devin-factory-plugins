---
name: merge-queue
description: Merge every mergeable open PR across the factory repos and clean up the branches. Use for "merge everything", "land the queue", "clean up PRs". Invocation is the merge authorization - never run unprompted.
---

# Merge queue

Sweep the factory's open PRs, land what is green, and report what is
blocked. Default repo set: `Dahhrk/plugins`, `Dahhrk/devin-factory-plugins`,
`Dahhrk/dark-factory`, `Dahhrk/haunt` - or the repos the human names.

## Workflow

1. Enumerate: `gh pr list --repo <slug> --json number,title,headRefName,isDraft,mergeable`
   for each repo. An empty set is a line in the report, not an error.
2. For each open PR, get check state with `gh pr checks <n> --repo <slug>`:
   - Draft PRs: `gh pr ready` first (drafts still run checks).
   - Green and mergeable: `gh pr merge <n> --merge --delete-branch`.
   - Red checks: do not merge. Pull `--log-failed` for the first actionable
     error; fix only if the fix is small and obvious, otherwise list it.
   - Conflicting (`mergeable: CONFLICTING`): attempt `gh pr update-branch`
     or a rebase only when the conflict is mechanical; otherwise list it.
3. Paired pack changes: merge either order - drift-check's peer-PR
   tolerance stops the second side failing. Re-run checks after the first
   lands before merging the twin.
4. Branch hygiene after merges: delete remote branches that are 0 commits
   ahead of `main` (`git rev-list --count origin/main..origin/<branch>`).
   Never delete a branch with commits ahead - list those instead.
5. Report a table: repo, PRs found, merged, blocked (with the reason).

## Guardrails

- Never merge a PR with failing checks or an unresolved conflict.
- A PR with no checks at all gets listed, not landed - never merge on the
  author agent's own verdict.
- Invocation is the merge authorization. Do not run this sweep because a
  PR "looks done".
- `--delete-branch` only on merge; never delete branches for unmerged PRs.
