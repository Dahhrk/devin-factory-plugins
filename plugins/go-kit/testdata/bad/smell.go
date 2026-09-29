package bad

import (
	"context"
	"io/ioutil"
	"net/http"

	"golang.org/x/sync/errgroup"
)

var Hook = func() {}

func Smell() {
	go func() {}()
	_ = ioutil.ReadFile("x")
	panic("nope")
	g, _ := errgroup.WithContext(context.Background())
	_ = g
	_, _ = http.NewRequest(http.MethodGet, "http://example.invalid", nil)
	_, _ = http.Get("http://example.invalid")
}
