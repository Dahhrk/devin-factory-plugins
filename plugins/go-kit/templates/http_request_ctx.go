package templates

// Named boundary: build HTTP requests with context (cancellation / deadline).
// Prefer NewRequestWithContext over NewRequest + later WithContext.
// Do not use http.Get / http.Post / http.Head / http.PostForm in product paths
// (they ignore context and use http.DefaultClient).

import (
	"context"
	"net/http"
)

func NewGet(ctx context.Context, url string) (*http.Request, error) {
	return http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
}
