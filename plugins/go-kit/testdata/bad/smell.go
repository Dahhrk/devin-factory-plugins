package bad

import (
	"context"
	"io/ioutil"

	"golang.org/x/sync/errgroup"
)

var Hook = func() {}

func Smell() {
	go func() {}()
	_ = ioutil.ReadFile("x")
	panic("nope")
	g, _ := errgroup.WithContext(context.Background())
	_ = g
}
