package templates

// Named boundary: derive errgroup from a parent/request context, never Background.
// Copy into product packages; keep go-rg-allow only on intentional Background seams.

import (
	"context"

	"golang.org/x/sync/errgroup"
)

func WithParent(ctx context.Context) (*errgroup.Group, context.Context) {
	return errgroup.WithContext(ctx)
}
