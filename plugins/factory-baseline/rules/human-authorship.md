# Human authorship

Everything this lane ships appears under the human's GitHub account, not an
AI identity.

- **Author every commit as the human.** Use their git `user.name` /
  `user.email` (local sessions inherit it from `~/.gitconfig`). In a fresh
  sandbox where identity is unset or defaults to an agent identity, set
  repo-local config before the first commit —
  `git config user.name "<their name>"` and
  `git config user.email "<their GitHub noreply>"` (the noreply is the safe
  email; it attributes to the account without leaking a real address).
- **No AI attribution anywhere.** No `Co-Authored-By` bot trailers, no
  "Generated with" footers, no AI/tool references in commit messages, PR
  bodies, code comments, or file headers. Commit messages read as if a human
  wrote them: professional, imperative, first-person ownership.
- **No tool names either.** `devin`, `cursor`, `claude`, `gpt`, `swe` in a
  commit subject, PR title, or posted body is attribution by another name —
  scope by the feature, not the tool (`feat(cloud):`, `docs(factory):`,
  never `feat(devin):`). The only survivors are literal artifact names a
  reader needs: `.devin/` paths, repo slugs like `devin-factory-plugins`,
  `@Devin` mentions, and CLI invocations (`devin plugins update`).
- **No em dash in commit messages** — use a regular hyphen.
- **PRs under the human's account where possible.** In sessions with the
  human's `gh` auth, `gh pr create` opens as them. In cloud sessions the
  platform's GitHub App opens the PR — that actor is fixed and will show the
  integration bot; the commits inside it still carry the human's author.
- **Do not rewrite history to hide provenance.** This rule shapes new
  commits. It does not cover upstream attribution in vendored files
  (NOTICE, licenses) — that provenance stays.
