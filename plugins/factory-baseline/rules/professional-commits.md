# Professional commits

Every commit and PR reads like a senior dev wrote it. Identity and the
no-AI-references ban live in `human-authorship` — this rule is the craft.

## Subject line

- Conventional Commits: `type(scope): subject` —
  feat / fix / chore / docs / refactor / perf / test.
- Imperative mood, lowercase, no trailing period: `fix(scope): drop stale
  market cache on reconnect`, not "Fixed stuff" or "Updates".
- 72 chars max. If it needs more, the commit is probably two commits.
- Banned subjects: "wip", "updates", "changes", "fix stuff", "more", "final",
  "asdf", "checkpoint", empty or pasted-error subjects.

## Body

- Only when the diff doesn't speak for itself — small diffs ship subject-only.
- Body answers **why**, never narrates **what** (the diff shows that).
  Wrap ~72 chars. Reference the trigger: failing check, review comment,
  observed behavior — not "the user asked".

## Shape of the work

- One logical change per commit. A commit that needs "and also" in the
  subject is two commits.
- Ordered story before the PR: rebase fixups, WIPs, and checkpoints into the
  commits they belong to. Nobody reviews your scratchpad.
- Never commit commented-out code, debug prints, scratch files, or dead
  files "just in case" — that's what branches and stashes are for.

## PR title and body

- Title follows the same convention as a commit subject.
- Body carries Why / Scope / Verification plus the factory contract
  (Done means + Keep). No filler sections, no restating the diff.
- No emojis unless the human asked. No em dash anywhere in the message —
  use a regular hyphen.
