package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/bkohler93/npp-cloud/mod4-lab1/setup-a/data"
	"github.com/bkohler93/npp-cloud/mod4-lab1/setup-a/frontend/format"
	"github.com/bkohler93/npp-cloud/mod4-lab1/setup-a/helpers"
)

const (
	BackendAddr = "http://10.0.2.1:1234"
)

func main() {
	localIP := helpers.GetLocalIP()
	err := format.LoadTemplate()
	if err != nil {
		log.Fatalf("failed to parse template file with err - %v\n", err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		log.Println("HC")
		w.WriteHeader(http.StatusOK)
	})
	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		data := &data.TemplateData{}

		res, err := http.Get(BackendAddr)
		if err != nil {
			helpers.InternalServerError(w, fmt.Sprintf("error reaching backend server - %v\n", err))
			return
		}
		if res.StatusCode == http.StatusInternalServerError {
			bytes, _ := io.ReadAll(res.Body)
			helpers.InternalServerError(w, fmt.Sprintf("server error - %v\n", string(bytes)))
			return
		}

		err = json.NewDecoder(res.Body).Decode(data)
		if err != nil {
			helpers.InternalServerError(w, fmt.Sprintf("failed to decode response from backend server - %v\n", err))
			return
		}

		hostname, err := os.Hostname()
		if err != nil {
			helpers.InternalServerError(w, fmt.Sprintf("failed to get hostname - %v\n", err))
			return
		}
		data.FrontEnd.IP = localIP
		data.FrontEnd.Host = hostname

		// err = format.ExecuteTemplate(w, data)
		err = format.ReturnJson(w, data)
		if err != nil {
			helpers.InternalServerError(w, fmt.Sprintf("failed to encode data - %v", err))
		}
	})

	log.Printf("listening on %s:8080\n", localIP)
	log.Fatalln(http.ListenAndServe(":8080", mux))
}
