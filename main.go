package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"reflect"
	"strconv"
	"strings"

	"github.com/gorilla/mux"
	"github.com/markbates/refresh/refresh/web"
	"github.com/rakyll/statik/fs"
	"github.com/spf13/viper"

	_ "github.com/ringvold/pi-dash/statik"
)

var stops []Line

func ruterHandler(rw http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)

	stopId, err := strconv.Atoi(vars["stopId"])
	if err != nil {
		rw.WriteHeader(http.StatusBadRequest)
		rw.Write([]byte("Bad Request"))
		return
	}

	data, err := GetArrivalData(stopId)
	dataJson, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		panic(err)
		return
	}
	rw.Header().Set("Access-Control-Allow-Origin", "*")
	rw.Write(dataJson)
}

func selectedStopsHandler(stops []Line) func(http.ResponseWriter, *http.Request) {
	return http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) {
		dataJson, err := json.MarshalIndent(stops, "", "  ")
		if err != nil {
			panic(err)
			return
		}
		rw.Header().Set("Access-Control-Allow-Origin", "*")
		rw.Write(dataJson)
	})
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

	// Actually make this work when passing stops to the HandleFunc

	// viper.WatchConfig()

	// viper.OnConfigChange(func(in fsnotify.Event) {
	// 	fmt.Println("Reloading config")
	// 	stops = getStopsFromConfig()
	// })
}

func main() {

	viperSetup()

	stops = getStopsFromConfig()

	port := viper.Get("port")
	log.Printf("Starting server. Watch http://localhost:%v", port)

	statikFS, _ := fs.New()
	router := mux.NewRouter()

	router.HandleFunc("/ruter/sanntid/{stopId}", ruterHandler)
	router.HandleFunc("/ruter/selectedStops", selectedStopsHandler(stops))

	router.Handle("/{name:.*}", http.FileServer(statikFS))

	http.ListenAndServe(fmt.Sprintf(":%v", port), web.ErrorChecker(router))
}

func getStopsFromConfig() []Line {
	config := viper.Get("lines")

	var lines []Line

	if config != nil {

		switch reflect.TypeOf(config).Kind() {
		case reflect.Slice:
			s := reflect.ValueOf(config)

			for i := 0; i < s.Len(); i++ {

				l := s.Index(i)
				m := l.Interface().(map[interface{}]interface{})

				var (
					id        int
					name      string
					direction string
					ok        bool
				)

				err := errors.New("Error parsing config: Line  id must be an int")
				id, ok = m["id"].(int)
				if !ok {
					panic(err)
				}
				err = errors.New("Error parsing config: Line name must be string")
				name, ok = m["name"].(string)
				if !ok {
					panic(err)
				}
				err = errors.New("Error parsing config: Line direction must be string")
				direction, ok = m["direction"].(string)
				if !ok {
					panic(err)
				}
				sd := directionStringToInt(direction)
				lines = append(lines, Line{Id: id, Name: name, Direction: sd})

			}
			log.Println("Loaded lines from config:", lines)
		}
	}
	return lines
}

func directionStringToInt(direction string) sanntidDirection {
	switch strings.ToLower(direction) {
	case "up":
		return DirUp
	case "down":
		return DirDown
	default:
		log.Fatalf("%v is not a valid direction", direction)
		os.Exit(1)
		return 0
	}
}
