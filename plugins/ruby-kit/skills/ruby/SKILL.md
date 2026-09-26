---
name: ruby
description: Ruby PSR bar. RuboCop, rubocop-performance, no-eval, no dynamic send smells, no SQL string interpolate in where/order/select. Use when reading or editing any .rb / .rake / .gemspec in a factory product.
paths: ["**/*.rb", "**/*.rake", "**/*.gemspec", "**/.rubocop.yml", "**/Gemfile", "**/.github/workflows/**"]
---

# Ruby

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Ruby checks into product gates.

## PSR Ruby (encoded)

1. **Agreed formatter** — RuboCop (or documented alternative). Gate: `scripts/ruby-fmt-gate.sh`. Starter: `templates/rubocop.yml`.
2. **rubocop-performance** — plugin required in `.rubocop.yml` or Gemfile. Gate: `scripts/ruby-rubocop-performance-gate.sh` (wiring); run RuboCop in product CI when the host supports it.
3. **no-eval** — no `eval(` without allow. Gate: `scripts/ruby-rg-gate.sh` (single-walk).
4. **Dynamic send smells** — no `send` / `__send__` / `public_send` with interpolated method name or `params` without allow. Prefer explicit methods or allowlisted dispatcher. Gate: `scripts/ruby-rg-gate.sh`. Template: `templates/allowlisted_dispatch.rb`.
5. **SQL string interpolate** — no `.where("...#{...}")` / `.order` / `.select` / `.find_by_sql` without allow. Prefer binds / hash conditions / Arel. Gate: `scripts/ruby-rg-gate.sh`. Template: `templates/parameterized_where.rb`.
6. **Hot-path** — `scripts/ruby-hotpath-gate.sh` fails if rg-gate wall exceeds `RUBY_RG_BUDGET_MS` (default 250ms).

## Rules

- `ruby-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-ruby**.
