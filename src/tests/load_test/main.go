package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"runtime"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
)

func main() {
	println("Starting...")

	url := os.Getenv("ENDPOINT")
	if url == "" {
		log.Fatal("URL IS EMPTY")
		return
	}
	workersX, _ := strconv.Atoi(os.Getenv("WORKERS"))
	if workersX <= 0 {
		workersX = 100
	}

	transport := &http.Transport{
		MaxIdleConns:        100000,
		MaxIdleConnsPerHost: 100000,
		MaxConnsPerHost:     100000,
		IdleConnTimeout:     90 * time.Second,
		ForceAttemptHTTP2:   false,
		DisableKeepAlives:   false,
	}
	client := &http.Client{
		Transport: transport,
		Timeout:   10 * time.Second,
	}

	runtime.GOMAXPROCS(runtime.NumCPU())
	var ops atomic.Uint64
	var wg sync.WaitGroup
	current := time.Now()
	workers := runtime.NumCPU() * workersX
	wg.Add(workers)
	for i := 0; i < workers; i++ {
		go par(&ops, &wg, client, url)
	}

	go func() {
		for {
			fmt.Printf("Time: %s\nOperations: %d\n", time.Since(current), ops.Load())
			time.Sleep(time.Second)
		}

	}()
	wg.Wait()
	fmt.Printf("END\nTime: %s\nOperations: %d\n", time.Since(current), ops.Load())
}

func par(ops *atomic.Uint64, wg *sync.WaitGroup, client *http.Client, url string) {
	counter := uint64(0)
	for {
		if makeRequest(client, url) {
			counter++
		}

		if counter >= 5 {
			ops.Add(counter)
			counter = 0
		}
	}
	wg.Done()
}

func makeRequest(client *http.Client, url string) bool {
	res, err := client.Get(url)

	if err != nil {
		println(err.Error())
		return false
	}
	io.Copy(io.Discard, res.Body)
	res.Body.Close()
	return true
}
