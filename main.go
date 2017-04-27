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

	viper.SetConfigName("pi-dash")
	viper.AddConfigPath("$HOME")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()
	viper.SetEnvPrefix("pi_dash")
	err := viper.ReadInConfig() // Find and read the config file
	if err != nil {             // Handle errors reading the config file
		panic(fmt.Errorf("Fatal error config file: %s \n", err))
	}

	port := viper.Get("port")
	log.Printf("Starting server. Watch http://localhost:%v", port)

	statikFS, _ := fs.New()
	router := mux.NewRouter()

	router.HandleFunc("/ruter/{key}", handler)
	router.Handle("/{name:.*}", http.FileServer(statikFS))

	http.ListenAndServe(fmt.Sprintf(":%v", port), router)
}
