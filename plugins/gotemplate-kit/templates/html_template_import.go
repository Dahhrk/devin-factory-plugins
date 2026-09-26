package templates

// Named boundary: prefer html/template over text/template for HTML output.
// Anti-pattern (banned without allow): import "text/template" for HTML.

import (
	"html/template"
	"io"
)

func RenderHello(w io.Writer, name string) error {
	t, err := template.New("hello").Parse(`<p>Hello, {{.}}!</p>`)
	if err != nil {
		return err
	}
	return t.Execute(w, name)
}
