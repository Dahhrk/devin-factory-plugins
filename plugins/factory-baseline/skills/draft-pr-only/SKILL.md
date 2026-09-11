---
name: draft-pr-only
description: Run the dark factory pre-stop checklist before finishing a coding unit. Use when opening, updating, or wrapping up a pull request, or when tempted to merge or enable Autopilot.
---

# Draft PR only

Available as `/factory-baseline:draft-pr-only`.

The author never plates their own work. Code lands as a draft PR; proof goes
Riddler → Gordon → human plate.

## Checklist before you stop

1. **One verifiable unit** — the PR does one thing a reviewer can check in a
   sitting. Split it if it does not.
2. **Draft state** — the PR is a draft (or explicitly ready-for-review when
   asked). You did not merge, squash to main, or push to `main`/`master`.
3. **Proof path named** — the PR body names the exact command, doctor, test,
   or screenshot path a reviewer runs to falsify the change.
4. **Done means + Keep** — both written in the PR body and the session report.
5. **Secrets clean** — no keys, tokens, or product Feature Maps in the diff;
   nothing sensitive in the public kitchen repo.
6. **Autopilot off** — no overnight fleet, no scheduled self-merge, no
   auto-approve wiring added by this change.

## When CI is red

Fix it or report it. Never merge "to land it", never disable the failing check
or weaken a security/branch-protection setting to get past it.

## When blocked

Spend caps, missing keys, and human-only steps are stop conditions, not
puzzles. Say what is blocked, what you tried, and what unblocks it.
