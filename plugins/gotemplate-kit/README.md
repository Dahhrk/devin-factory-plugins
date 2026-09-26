# gotemplate-kit

Go Template bar for the dark factory Cursor lane. Public research pilot: golang/go `src/text/template` + `src/html/template` (BSD-3-Clause).

| Surface | Path |
|---------|------|
| Skills | `skills/gotemplate`, `skills/poteto-gotemplate` |
| Rule | `rules/gotemplate.mdc` (`**/*.{go,tmpl,gotmpl,html}`, not alwaysApply) |
| Tier 0 | `scripts/gotemplate-rg-gate.sh` (text/template for HTML XSS; Execute without context / discarded err; missing FuncMap escaping; nested template include of untrusted names; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/gotemplate-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `GOTEMPLATE_RG_BUDGET_MS`) |
| Tier 1 | `scripts/gotemplate-html-gate.sh` (html/template import / go.mod / CI wiring / live) |
| Selfcheck | `scripts/gotemplate-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/gotemplate-gates.yml` |
| Boundaries | `templates/html_template_import.go`, `templates/execute_with_err.go`, `templates/funcmap_escaped.go`, `templates/static_template_name.go` |

PSR Go Template encode (Programming Standards Reference): prefer `html/template` over `text/template` whenever output is HTML (XSS); check `Execute` / `ExecuteTemplate` errors (no discarded-err / context-blind execute); do not bypass escaping via `template.HTML(...)` casts or raw/safe FuncMap helpers without allow; do not `{{template .Name}}` or `ExecuteTemplate` with untrusted names. Primary authority: golang/go `html/template` + `text/template` docs (BSD-3-Clause).

Compose with `/poteto-mode`. Tier 1 checks html/template wiring (live `go list html/template` when resolvable unless `GOTEMPLATE_HTML_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/gotemplate-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-gotemplate` (Go Template stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`gotemplate-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `gotemplate-hotpath-gate` fails if that wall exceeds `GOTEMPLATE_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `gotemplate-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer `"html/template"` for HTML. Prefer `if err := tmpl.Execute(...)`. Prefer contextual autoescape over `template.HTML` / raw FuncMap. Prefer static template names (`{{template "x" .}}` / `ExecuteTemplate(w, "x", data)`).

## Selfcheck

`bash scripts/gotemplate-kit-selfcheck.sh` proves rg/hotpath/html gates discriminate fixtures, single-walk encode, budget discrimination (`GOTEMPLATE_RG_BUDGET_MS=1`), html/template wiring bar, and template presence.
