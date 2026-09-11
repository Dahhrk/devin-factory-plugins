---
name: no-secrets-in-kitchen
description: Screen a change destined for the public kitchen repo for secrets and product internals. Use before committing or pushing to Dahhrk/dark-factory or any other public recipe repo.
---

# No secrets in the kitchen

Available as `/factory-baseline:no-secrets-in-kitchen`.

`Dahhrk/dark-factory` is public and holds **recipes only**: how the factory
works, reproducible from outside, nothing that leaks product internals.

## Screen every diff for

- Credentials: API keys, tokens, cookies, connection strings, private keys,
  `.env` / `credentials.json` files. Masked or "example" values must be
  obviously fake.
- Product Feature Maps, internal routing tables, registry rows, or anything
  owned by another lane (the registry is Dr Strange's source of truth — link,
  do not copy).
- Private URLs and hosts: internal dashboards, tailnet names, webhook
  endpoints, Discord/Slack webhook URLs.
- Customer, user, or personal data in logs, transcripts, and screenshots —
  including text visible inside images.

## Procedure

1. `git diff --merge-base <base>` and read every added line, not just the
   filenames.
2. Grep the diff for `key|token|secret|password|webhook|https?://` and clear
   each hit deliberately.
3. Check attachments and screenshots for readable secrets before committing.
4. If something sensitive is needed to make the recipe useful, describe the
   shape ("set `FOO_API_KEY` in Devin secrets") instead of the value.

## If a secret already landed

Stop. Say so immediately and treat the credential as compromised — it needs
rotation by a human. Do not silently force-push history away as the only fix.
