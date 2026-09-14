---
description: Record corrections and repeated workarounds into the kitchen ledger, then encode repeats into structure. Only fires in repos that carry scripts/close-loop.mjs.
trigger: always_on
---

# Close-loop

Applies only where the ledger exists — this rule no-ops in repos without
`scripts/close-loop.mjs` (today that is the dark-factory kitchen). Do not
hunt for it; if it is absent, skip.

- If the human corrected you, a check failed, or you used the same
  workaround again:
  `node scripts/close-loop.mjs record --source devin --workspace <slug> --smell <slug> --evidence <text>`
- If `node scripts/close-loop.mjs status` shows a REPEAT: encode it into
  lint / CI / hook / Feature Map this turn, then
  `node scripts/close-loop.mjs encode --workspace <slug> --smell <slug> --evidence <text>`.
  Do not write another reminder.
- The ledger row ships with the unit that caused it — commit
  `audit/smells.tsv` alongside the fix/PR so the lesson survives (in cloud
  sessions this is the only way it persists). Kitchen-side,
  `node scripts/close-loop.mjs harvest` aggregates every repo's ledger.
- If nothing happened: do not invent a smell.
- Do not encode taste, spend, merge rights, or Slack secrets.
