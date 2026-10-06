---
name: bugbot-dogfood
description: Enable and dogfood Bugbot (or equivalent AI review) on the product repo. Treat real findings, dismiss noise with a short disproof, and keep BUGBOT.md bans in sync. Use when setting up soft review or when Bugbot comments need a consistent response pattern.
---

# Bugbot dogfood

Soft review layer for agent-heavy repos. Available skill; not a Day-1
default. Run when enabling Bugbot, wiring `BUGBOT.md`, or answering a
pile of Bugbot comments with a consistent bar.

Provenance: idea from Jacob Gold's public notes on CODEOWNERS, automated
review, self-certification, CI, and CUA verification as the merge bar
(https://x.com/jacobgold/status/2106879810719089079), plus kitchen
practice of dogfooding Bugbot on product PRs. Rewritten in factory voice.

## Setup

1. Enable Bugbot (or the team's AI review) on the product remote.
2. Keep a `BUGBOT.md` (or equivalent) with the same footgun bans you want
   agents and bots to enforce.
3. Prefer branch protection that needs green checks. Soft review does not
   replace hard CI.

## Response pattern

- **Real finding:** fix in the owning PR, or open a follow-up if out of
  scope. Do not merge past a confirmed security, auth, billing, or data
  issue.
- **Noise:** dismiss with a short disproof that cites code. From later
  passes, lean dismiss documented false-positive patterns; still escalate
  security-class items.
- **Prompt vs PR mismatch:** if a reviewer skill checks that the PR matches
  what was asked, treat that paranoia as a feature. Prefer encoding the
  check as a skill or Bugbot rule over reminding the human mid-thread.

## Anti-patterns

- Enabling Bugbot and ignoring every comment
- Treating soft review as a substitute for tests and CI
- Endless debate on style nits that belong in lint
