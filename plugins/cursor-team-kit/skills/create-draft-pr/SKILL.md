---
name: create-draft-pr
description: Commit, push, and open a draft PR with Summary / Problem / (UX Flow) / Solution. Factory conventions. Prefer gh pr create --draft. Available skill; not Day-1 auto.
---

# Create draft PR

Commit focused work, push, and open a **draft** pull request. Typing
`/create-draft-pr` (or an explicit "open a draft PR") invokes this
skill. Available in the kit; not a Day-1 auto-apply default.

Provenance: adapted from jnsahaj/skills create-draft-pr
(github.com/jnsahaj/skills). Rewritten for factory conventions
(orwell-prose, no achievement language, Autopilot off, author does not
merge).

## Steps

1. `git status` and `git diff` (staged + unstaged). Understand the
   change set.
2. Match commit message style from recent `git log`.
3. If on `main`, create a focused branch (kebab-case, short) and switch
   to it.
4. Stage and commit focused changes. Plain what/why. No achievement
   language.
5. Push with `-u`.
6. Build the PR body (Summary / Problem / optional UX Flow / Solution).
7. Create draft PR:

   ```bash
   gh pr create --draft --title "..." --body "$(cat <<'EOF'
   ...
   EOF
   )"
   ```

   Fork-style clones: pass explicit `--repo` and `--head` as in
   `new-branch-and-pr`.
8. Report the draft PR URL. Do not merge. Do not mark ready unless Dark
   asks.

## PR body shape

```markdown
## Summary

<One sentence describing the overall change>

## Problem

What was broken, missing, or suboptimal. Root cause when known.

## Solution

Approach taken. Snippets only when they clarify the core approach.
```

When the change is user-facing or architectural, insert between
Problem and Solution (tree style from `ux-flow-plan`):

````markdown
## UX Flow

```text
Current flow
└─ ...

Desired flow
└─ ...
```
````

Omit UX Flow for mechanical, dependency, or tiny internal changes.

## Guardrails

- Prefer `--draft`. Ready-for-review is a separate human decision.
- Title: succinct. `fix:` ok for bug fixes. No achievement fluff.
- No file-by-file dump. No checkbox test plan theater. No "Generated
  with ..." footers.
- Orwell on the prose. No em dashes.
- Author does not merge on own verdict.

## Overlap

`new-branch-and-pr` owns the general branch+PR path.
`make-pr-easy-to-review` owns reviewability polish after the PR exists.
`review-and-ship` owns review-then-ship. This skill owns the draft-PR
exit with Summary / Problem / (UX Flow) / Solution.

## Autopilot stays off

Leave Autopilot and TRUST-NEXT off unless Dark has already greened them
with evidence. Do not invent Autopilot. Do not self-merge.

## Language

Plain workstream nouns only. No bot persona names, no role titles, no
phase / slice / section / wave labels, no em dashes. Orwell on the
prose.

## Reply shape

Branch name, commit summary, draft PR URL. State that it stays draft
until Dark marks ready / merges.
