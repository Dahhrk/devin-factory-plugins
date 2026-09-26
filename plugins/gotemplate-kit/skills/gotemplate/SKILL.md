---
name: gotemplate
description: PSR Go Template encode for product text/html templates. Use when editing .go / .tmpl / .gotmpl HTML templates or html/template wiring.
disable-model-invocation: false
---

# Go Template

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Go Template checks into product gates.

## PSR Go Template (encoded)

1. **Agreed toolchain** — `html/template` for HTML output / go.mod + templates / CI. Gate: `scripts/gotemplate-html-gate.sh`. Product CI: `templates/github-workflows/gotemplate-gates.yml`.
2. **text/template for HTML (XSS)** — no `"text/template"` for HTML without allow. Prefer `"html/template"` (contextual autoescape). Gate: `scripts/gotemplate-rg-gate.sh` (single-walk). Template: `templates/html_template_import.go`.
3. **Execute without context** — no discarded-err `_ = tmpl.Execute` / `_ = tmpl.ExecuteTemplate` without allow. Prefer `if err := tmpl.Execute(...)`. Gate: `scripts/gotemplate-rg-gate.sh`. Template: `templates/execute_with_err.go`.
4. **Missing FuncMap escaping** — no `template.HTML(...)` cast / raw|safe|unescaped FuncMap helpers without allow. Prefer contextual autoescape. Gate: `scripts/gotemplate-rg-gate.sh`. Template: `templates/funcmap_escaped.go`.
5. **Untrusted template names** — no `{{template .Name}}` / `ExecuteTemplate` with non-literal names without allow. Prefer static `"name"`. Gate: `scripts/gotemplate-rg-gate.sh`. Template: `templates/static_template_name.go`.
6. **Hot-path** — `scripts/gotemplate-hotpath-gate.sh` fails if rg-gate wall exceeds `GOTEMPLATE_RG_BUDGET_MS` (default 250ms).

## Rules

- `gotemplate-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-gotemplate**.
