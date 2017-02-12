// Source: https://github.com/michaelenger/sanntid/blob/master/ruter.go

package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

// sanntidDirection defines the direction of the vehicle. It is either,
// 0 (undefined (?)), 1 or 2.
type sanntidDirection int

type sanntidMonitoredCall struct {
	ExpectedArrivalTime   string `json:"expectedArrivalTime"`
	DeparturePlatformName string `json:"departurePlatformName"`
	DestinationDisplay    string `json:"destinationDisplay"`
}

type sanntidArrivalData struct {
	DestinationName   string               `json:"destinationName"`
	MonitoredCall     sanntidMonitoredCall `json:"monitoredCall"`
	PublishedLineName string               `json:"publishedLineName"`
	VehicleMode       int                  `json:"vehicleMode"`
	DirectionRef      sanntidDirection     `json:"directionRef,string"`
}

type customArrivalData struct {
	DestinationName     string           `json:"destinationName"`
	PublishedLineName   string           `json:"publishedLineName"`
	VehicleMode         int              `json:"vehicleMode"`
	DirectionRef        sanntidDirection `json:"directionRef,string"`
	ExpectedArrivalTime string           `json:"expectedArrivalTime"`
}

// ArrivalData cointains the parsed data returned from a request to
// Ruter's API.
type departures struct {
	MonitoredVehicleJourney sanntidArrivalData
}

// Get the arrival data for a specific location ID
func GetArrivalData(locationID int) ([]customArrivalData, error) {
	data, err := requestArrivalData(arrivalDataUrl(locationID))
	if err != nil {
		return nil, err
	}

	transformed := transformArrivalData(parseArrivalData(data))

	return transformed, nil
}

// Transform ruter response to smaller respons
func transformArrivalData(departures []departures) []customArrivalData {
	arrivals := make([]customArrivalData, 0)

	for _, d := range departures {
		mvj := d.MonitoredVehicleJourney

		s := customArrivalData{
			DestinationName:     mvj.DestinationName,
			PublishedLineName:   mvj.PublishedLineName,
			VehicleMode:         mvj.VehicleMode,
			DirectionRef:        mvj.DirectionRef,
			ExpectedArrivalTime: mvj.MonitoredCall.ExpectedArrivalTime,
		}

		arrivals = append(arrivals, s)
	}

	if len(arrivals) > 3 {
		return arrivals[:3]
	}

	return arrivals
}

// Construct the arrival data URL
func arrivalDataUrl(locationID int) string {
	return fmt.Sprintf("http://reisapi.ruter.no/stopvisit/getdepartures/%d?", locationID)
}

// RequestArrivalData retrieves information about the upcoming arrivals for
// a given location based on its locationId.
func requestArrivalData(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}

	defer resp.Body.Close()
	return ioutil.ReadAll(resp.Body)
}

func parseArrivalData(content []byte) []departures {
	var data []departures

	json.Unmarshal(content, &data)

	return data
}
