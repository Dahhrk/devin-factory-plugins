package templates

// Named boundary: always close HTTP response bodies (golangci bodyclose).
// Prefer defer close immediately after a successful Do/Get.

import (
	"io"
	"net/http"
)

func Fetch(client *http.Client, req *http.Request) ([]byte, error) {
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	return io.ReadAll(resp.Body)
}
