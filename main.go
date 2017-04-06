package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/rakyll/statik/fs"

	_ "./statik" // TODO: Replace with the absolute import path
)

func handler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	key, err := strconv.Atoi(vars["key"])
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Bad Request"))
		return
	}

	data, err := GetArrivalData(key)
	dataJson, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		panic(err)
		return
	}
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Write(dataJson)
}

func main() {
	log.Println("Starting server. Watch http://localhost:8081")

	statikFS, _ := fs.New()
	router := mux.NewRouter()

	router.HandleFunc("/ruter/{key}", handler)
	router.Handle("/{name:.*}", http.FileServer(statikFS))

	http.ListenAndServe(":8081", router)
}
