package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
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
	log.Println("Starting server. Watch http://localhost:8080")
	r := mux.NewRouter()
	r.HandleFunc("/{key}", handler)
	http.ListenAndServe(":8080", r)
}
