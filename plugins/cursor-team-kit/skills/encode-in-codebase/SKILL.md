---
name: encode-in-codebase
description: Prefer encoding durable guidance in the repo itself (CODEOWNERS, AGENTS.md, repo skills, Bugbot rules, lint, CI) over chat memory or one-off prompts. Default when a correction or convention must survive the next agent. Named contract.
---

# Encode in the codebase

Default when a rule, ownership map, review ban, or working preference must
outlive this chat. Put it where the next agent will load it without being
told. Do not wait for `/encode-in-codebase`. This skill is the named
contract for that default.

Provenance: idea from Jacob Gold's public notes on encoding as much as
possible in the codebase (human CODEOWNERS, AGENTS.md, repo skills, Bugbot
rules) so agents reach real context
(https://x.com/jacobgold/status/2107196501781106819). Rewritten in factory
voice; no upstream text copied.

## Hard rule

When a correction or convention will matter again:

1. **Pick the strongest home.** Prefer structure over prose. Order of
   strength: unrepresentable state / type / banned API that fails CI, then
   lint or CODEOWNERS, then `BUGBOT.md` / review rules, then a repo skill,
   then `AGENTS.md` / CLAUDE.md. Chat memory is last and temporary.
2. **Write it in-tree.** Open a PR (or amend the current one) that adds or
   updates that home. Keep the text short and operational.
3. **Delete the chat-only copy.** Once the repo carries the rule, do not
   keep restating it mid-thread as if that were the source of truth.

Pairs with pstack `principle-encode-lessons-in-structure` when the fix is
a mechanism (lint, metadata, runtime check). This skill covers the broader
"where does the next agent read it" choice, including ownership and review.

## CODEOWNERS and review layers

- Use CODEOWNERS for paths that need a named human or team gate.
- Keep `BUGBOT.md` (and similar) as the soft review layer for agent PRs.
- Dogfood Bugbot on the product repo: enable it, treat real findings, dismiss
  noise with a short disproof. See also `bugbot-dogfood`.

## Anti-patterns

- Leaving durable guidance only in a Slack thread or chat summary
- Growing AGENTS.md with one-off tips that belong in a lint or skill
- Asking the human to "remember to tell the next agent"
