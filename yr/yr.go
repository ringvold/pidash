package yr

import (
	"encoding/xml"
	"io/ioutil"
	"net/http"
)

// Resouces:
// https://golang.org/src/encoding/xml/example_test.go
// https://www.yr.no/sted/Norge/Oslo/Oslo/Storo/forecast.xml
// https://beta.api.met.no/weatherapi/weathericon/1.1/documentation
// http://erikflowers.github.io/weather-icons/

type Symbol struct {
	Number string `xml:"numberEx,attr"`
	Name   string `xml:"name,attr"`
	Var    string `xml:"var,attr"`
}

type Temperature struct {
	Unit  string `xml:"unit,attr"`
	Value int    `xml:"value,attr"`
}

type Time struct {
	Symbol      Symbol      `xml:"symbol"`
	Temperature Temperature `xml:"temperature"`
	FromTime    string      `xml:"from,attr"`
	ToTime      string      `xml:"to,attr"`
	Period      int         `xml:"period,attr"`
}

type WeatherData struct {
	Name      string `xml:"location>name"`
	Forecasts []Time `xml:"forecast>tabular>time"`
	Sun       Sun    `xml:"sun"`
}

type Sun struct {
	Rise string `xml:"rise,attr"`
	Set  string `xml:"set,attr"`
}

func GetForecast(url string) (WeatherData, error) {
	data, err := requestForecast(url)
	if err != nil {
		return WeatherData{}, err
	}
	transformed, err := parseForecast(data)
	return transformed, err
}

func parseForecast(content []byte) (WeatherData, error) {
	var data WeatherData
	err := xml.Unmarshal(content, &data)
	if err != nil {
		return WeatherData{}, err
	}
	return data, nil
}

func requestForecast(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}

	defer resp.Body.Close()
	return ioutil.ReadAll(resp.Body)
}
