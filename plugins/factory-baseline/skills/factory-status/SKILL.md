---
name: factory-status
description: Answer "merged?", "what's on my plate", "all sorted?" across the whole factory. Enumerates open PRs, draft/mergeable/CI state, and pending plates for every registered repo. Use for status checks spanning more than one repo.
---

# Factory status

Available as `/factory-baseline:factory-status`.

Answers the recurring question — what is open, what is plated, what is
waiting — with live evidence, never from memory.

## Repo list

- If `~/Projects/registry.md` exists, take the `github:` lines — that is
  the registered fleet. Skip entries marked `none` or `pending`.
- Otherwise fall back to `gh repo list <owner> --limit 50` on the account
  being worked.
- The current repo always counts even if it is not in the registry.

## The check

Per repo:

```
gh pr list --repo <slug> --state open --json number,title,isDraft,mergeable,headRefName,statusCheckRollup
```

Report one table row per open PR: repo, number, title, draft?,
mergeable?, checks state, and the action needed — `needs ready`,
`needs rebase`, `checks red`, or `ready to plate`.

Then the close: `Nothing open` is a complete answer. A list of drafts
with their next action is a complete answer. A paragraph about what was
done earlier is not.

## Extras when asked

- `devin plugins list` for live plugin cache versions when the question
  is about whether a marketplace change is live.
- `gh pr list --state merged --limit 5` per repo when the question is
  "did X land".
- Conflicts on an open PR are a finding, not a status — say which branch
  it is behind, not just `CONFLICTING`.
