# ruby-kit

Ruby bar for the dark factory Cursor lane. Public research pilot: rails/rails (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/ruby`, `skills/poteto-ruby` |
| Rule | `rules/ruby.mdc` (`**/*.{rb,rake,gemspec}`, not alwaysApply) |
| Tier 0 | `scripts/ruby-rg-gate.sh` (eval; dynamic send smells; SQL string interpolate in where/order/select; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/ruby-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `RUBY_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/ruby-fmt-gate.sh` (RuboCop wiring / live rubocop) |
| Tier 1 | `scripts/ruby-rubocop-performance-gate.sh` (rubocop-performance plugin wiring) |
| Selfcheck | `scripts/ruby-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/ruby-gates.yml` + `templates/rubocop.yml` |
| Boundaries | `templates/parameterized_where.rb`, `templates/allowlisted_dispatch.rb` |

PSR Ruby encode (Programming Standards Reference): RuboCop or an agreed alternative; automated tests; handle dynamic behaviour carefully; validate inputs. Language-farm practical bar: **RuboCop**, **rubocop-performance**, **no-eval**, **dynamic send smells**, **no SQL string interpolate in where/order/select**. Primary authority: Ruby documentation and project/community style.

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live rubocop when on PATH unless `RUBY_FMT_CONFIG_ONLY=1`). Performance gate checks `rubocop-performance` in `.rubocop.yml` or Gemfile.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/ruby-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-ruby` (Ruby stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`ruby-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `ruby-hotpath-gate` fails if that wall exceeds `RUBY_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and rails/rails (activerecord+actionpack+activesupport lib) under default budget.

### Escape

Line marker `ruby-rg-allow` with a short rationale. Prefer named boundaries from `templates/parameterized_where.rb` / `templates/allowlisted_dispatch.rb` over scattered allows.

## Selfcheck

`bash scripts/ruby-kit-selfcheck.sh` proves rg/hotpath/fmt/rubocop-performance gates discriminate fixtures, single-walk encode, budget discrimination (`RUBY_RG_BUDGET_MS=1`), and template presence.
