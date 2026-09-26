package good

import (
	"context"
	"errors"
	"os"
)

var ErrSentinel = errors.New("sentinel")

func Ok(ctx context.Context) error {
	b, err := os.ReadFile("x") // go-rg-allow: named file boundary for fixture
	if err != nil {
		return err
	}
	_ = b
	select {
	case <-ctx.Done():
		return ctx.Err()
	default:
		return nil
	}
}
