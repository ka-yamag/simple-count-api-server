package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync/atomic"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "80"
	}
	portWithColon := fmt.Sprintf(":%s", port)

	var zero uint64
	c := countHandler{
		index: &zero,
	}

	http.HandleFunc("/", c.countHandler)
	http.HandleFunc("/health", healthHandler)

	fmt.Printf("Serving at http://localhost:%s\n(Pass as PORT environment variable)\n", port)
	log.Fatal(http.ListenAndServe(portWithColon, nil))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "ok\n")
}

type count struct {
	Count    uint64 `json:"count"`
	Hostname string `json:"hostname"`
}

type countHandler struct {
	index *uint64
}

func (c *countHandler) countHandler(w http.ResponseWriter, r *http.Request) {
	atomic.AddUint64(c.index, 1)
	hostname, _ := os.Hostname()
	index := atomic.LoadUint64(c.index)

	count := count{Count: index, Hostname: hostname}

	responseJSON, _ := json.Marshal(count)
	fmt.Fprintf(w, string(responseJSON))
}
