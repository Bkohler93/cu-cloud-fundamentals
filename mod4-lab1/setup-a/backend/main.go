package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/bkohler93/npp-cloud/mod4-lab1/setup-a/data"
	"github.com/bkohler93/npp-cloud/mod4-lab1/setup-a/helpers"
	"github.com/jackc/pgx/v5/pgxpool"
)

const (
	DBURL = "10.0.3.1"
)

func main() {
	mux := http.NewServeMux()
	localIP := helpers.GetLocalIP()
	ctx := context.Background()

	//  ipv4_address: 10.0.3.1
	//   POSTGRES_DB: mydb
	//   POSTGRES_USER: user
	//   POSTGRES_PASSWORD: password
	dbURL := fmt.Sprintf("postgres://user:password@%s:5432/mydb", DBURL)

	pool, err := pgxpool.New(ctx, dbURL)
	// conn, err := pgx.Connect(ctx, dbURL)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer pool.Close()
	_, err = pool.Exec(ctx, "DROP TABLE IF EXISTS Hits;")
	if err != nil {
		log.Fatalf("failed to create table Hits - %v\n", err)
	}

	_, err = pool.Exec(ctx, "CREATE TABLE Hits(id BOOLEAN PRIMARY KEY DEFAULT TRUE,hitCount INTEGER);")
	if err != nil {
		log.Fatalf("failed to create table Hits - %v\n", err)
	}
	_, err = pool.Exec(ctx, "INSERT INTO Hits(hitCount) Values(0);")
	if err != nil {
		log.Fatalf("failed to set hitCount in table Hits - %v\n", err)
	}

	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		log.Println("HC")
		w.WriteHeader(http.StatusOK)
	})
	mux.HandleFunc("GET /", func(w http.ResponseWriter, r *http.Request) {
		handlerCtx, cancel := context.WithTimeout(ctx, time.Second*3)
		defer cancel()

		hostName, err := os.Hostname()
		if err != nil {
			helpers.InternalServerError(w, fmt.Sprintf("failed to get hostname - %v", err))
			return
		}
		var hitCount int
		err = pool.QueryRow(handlerCtx, "UPDATE Hits SET hitCount = hitCount + 1 RETURNING hitCount;").Scan(&hitCount)
		if err != nil {
			helpers.InternalServerError(w, fmt.Sprintf("error querying database: %v\n", err))
			return
		}
		data := data.TemplateData{
			NumHits:  hitCount,
			FrontEnd: data.ServerInfo{},
			BackEnd: data.ServerInfo{
				IP:   localIP,
				Host: hostName,
			},
		}
		err = json.NewEncoder(w).Encode(data)
		if err != nil {
			helpers.InternalServerError(w, fmt.Sprintf("error querying database - %v\n", err))
			return
		}
	})

	log.Printf("listening on %s:1234\n", localIP)
	log.Fatalln(http.ListenAndServe(":1234", mux))
}
