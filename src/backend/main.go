package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"

	"github.com/gorilla/mux"
)

type InfoResponse struct {
	OS       string `json:"os"`
	Hostname string `json:"hostname"`
	Time     string `json:"time"`
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/", getMain).Methods(http.MethodGet)

	log.Println("Server is running on http://localhost:80")
	log.Fatal(http.ListenAndServe("0.0.0.0:80", router))
}

func getMain(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	hostname, err := os.Hostname()
	if err != nil {
		http.Error(w, `{"error": "failed to get hostname"}`, http.StatusInternalServerError)
		return
	}

	resp := InfoResponse{
		OS:       runtime.GOOS,
		Hostname: hostname,
		Time:     time.Now().UTC().Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(resp); err != nil {
		http.Error(w, `{"error": "failed to encode JSON"}`, http.StatusInternalServerError)
	}
}
