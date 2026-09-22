---
name: factory-status
description: One-table health sweep across the factory repos and runners. Use for "is everything merged", "status check", "what's outstanding", "are we clean". Reports fresh evidence only - never answers from memory.
---

# Factory status

Answer "where do we stand" with a fresh sweep instead of a remembered
state. Default repo set: `Dahhrk/plugins`, `Dahhrk/devin-factory-plugins`,
`Dahhrk/dark-factory`, `Dahhrk/open-bot`. Local clones live under
`~/Projects/` (plug-factory maps to `plugins`).

## Workflow

1. Per repo: `gh pr list --repo <slug> --json number -q length` for open
   PRs, and `gh api repos/<slug>/branches` for remote branches that are
   not `main`.
2. Per remote branch: `git rev-list --count origin/main..origin/<branch>`
   in the local clone after `git fetch` - 0 ahead means merged residue,
   >0 means real unmerged work to flag.
3. Per local clone: `git status -sb` for branch, ahead/behind, and dirty
   file count.
4. Runners (when `kubectl` is configured):
   `kubectl -n gha-runners get pods -o wide` - expect `1/1 Running` and
   the intended node; `gh api repos/<slug>/actions/runners` for the
   GitHub-side `status`.
5. Kitchen ledger: `git status --porcelain audit/smells.tsv` in the
   dark-factory clone - dirty rows are orphaned lessons that never
   shipped with their unit.
6. Emit one table: repo, open PRs, non-main branches (with ahead counts),
   local tree state. Then a short anomaly list - dirty trees, stale
   branches, offline runners, drift warnings, uncommitted ledger rows.

## Guardrails

- Fresh evidence only. Never quote PR counts or merge state from earlier
  in the session - re-run the queries.
- Report anomalies; fix them only if asked (or use `/merge-queue` for the
  mergeable set, `/fix-ci` for red checks).
- A repo with no clone locally gets a remote-only row - say so rather than
  skipping it silently.
