package templates

// Named boundary: prefer static template names over {{template .Name}} / variable names.
// Anti-pattern (banned without allow): ExecuteTemplate(w, userInput, data) or {{template .Name}}

import (
	"html/template"
	"io"
)

func ExecuteStatic(w io.Writer, set *template.Template, data any) error {
	return set.ExecuteTemplate(w, "content", data)
}
