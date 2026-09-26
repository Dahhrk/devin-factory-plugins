package templates

// Named boundary: prefer checked Execute / ExecuteTemplate errors.
// Anti-pattern (banned without allow): _ = tmpl.Execute(w, data)

import (
	"html/template"
	"io"
)

func ExecuteChecked(w io.Writer, tmpl *template.Template, data any) error {
	if err := tmpl.Execute(w, data); err != nil {
		return err
	}
	return nil
}
