package templates

// Named boundary: prefer contextual autoescape over template.HTML / raw FuncMap.
// Anti-pattern (banned without allow): template.HTML(user) or FuncMap{"raw": ...}

import (
	"html/template"
	"io"
	"strings"
)

func RenderJoined(w io.Writer, parts []string) error {
	funcs := template.FuncMap{
		"join": strings.Join,
	}
	t, err := template.New("join").Funcs(funcs).Parse(`<p>{{join . " "}}</p>`)
	if err != nil {
		return err
	}
	return t.Execute(w, parts)
}
