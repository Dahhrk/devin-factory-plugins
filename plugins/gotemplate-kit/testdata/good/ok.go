package good

import (
	"html/template"
	"io"
	"strings"
)

// Documented intentional seam; keep allow on the smell line.
var legacy = template.HTML("<b>ok</b>") // gotemplate-rg-allow: fixture documents allow marker for intentional trusted-CMS HTML seam

func Render(w io.Writer, title string) error {
	funcs := template.FuncMap{
		"join": strings.Join,
	}
	t, err := template.New("ok").Funcs(funcs).Parse(`
		{{define "content"}}<h1>{{.}}</h1>{{end}}
		{{template "content" .}}
	`)
	if err != nil {
		return err
	}
	if err := t.ExecuteTemplate(w, "content", title); err != nil {
		return err
	}
	_ = legacy
	return nil
}
