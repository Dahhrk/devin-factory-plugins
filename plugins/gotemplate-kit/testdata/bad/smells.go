package bad

import (
	"io"
	"net/http"
	"text/template"
)

// Intentional smells for gotemplate-rg-gate discrimination (not product code).

func handler(w http.ResponseWriter, r *http.Request) {
	name := r.FormValue("view")
	t := template.Must(template.New("x").Funcs(template.FuncMap{
		"raw": func(s string) string { return s },
	}).Parse(`<html><body>{{.}}</body></html>`))
	_ = t.Execute(w, r.FormValue("q"))
	_ = t.ExecuteTemplate(w, name, nil)
}

func render(w io.Writer, userHTML string) {
	t := template.Must(template.New("y").Parse(`Hello, {{.}}!`))
	_ = t.Execute(w, userHTML)
}
