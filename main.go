package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/rakyll/statik/fs"
	"github.com/spf13/viper"

	_ "github.com/ringvold/pi-dash/statik"
)

func ruterHandler(w http.ResponseWriter, r *http.Request) {
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

func viperSetup() {
	viper.SetConfigName("pi-dash")
	viper.AddConfigPath("$HOME")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()
	viper.SetEnvPrefix("pi_dash")

	viper.SetDefault("port", "8081")

	err := viper.ReadInConfig() // Find and read the config file
	if err != nil {             // Handle errors reading the config file
		log.Printf("Error reading config file: %s \n", err)
	}
}

func main() {

	viperSetup()

	port := viper.Get("port")
	log.Printf("Starting server. Watch http://localhost:%v", port)

	statikFS, _ := fs.New()
	router := mux.NewRouter()

	router.HandleFunc("/ruter/{key}", ruterHandler)
	router.Handle("/{name:.*}", http.FileServer(statikFS))

	http.ListenAndServe(fmt.Sprintf(":%v", port), router)
}
