// Liberally borrowed code form here: https://github.com/michaelenger/sanntid/blob/master/ruter.go

package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

type sanntidDirection int

// sanntidDirection defines the direction of the vehicle. It is either,
// 0 (undefined (?)), 1 or 2.
const (
	// DirAny will give you Line in any direction.
	DirAny = iota

	// DirUp will give you Line in only one direction.
	DirUp

	// DirDown will give you Line in only one direction, reverse of DirUp.
	DirDown
)

type Line struct {
	Name      string           `json:"name"`
	Id        string           `json:"id"`
	Direction sanntidDirection `json:"direction"`
}

// ArrivalData cointains the parsed data returned from a request to
// Ruter's API.
type ArrivalData struct {
	MonitoringRef           string `json:"monitoringRef"`
	MonitoredVehicleJourney MonitoredVehicleJourney
}

type MonitoredVehicleJourney struct {
	DestinationName   string               `json:"destinationName"`
	MonitoredCall     sanntidMonitoredCall `json:"monitoredCall"`
	PublishedLineName string               `json:"publishedLineName"`
	VehicleMode       int                  `json:"vehicleMode"`
	DirectionRef      sanntidDirection     `json:"directionRef,string"`
}

type sanntidMonitoredCall struct {
	ExpectedArrivalTime string `json:"expectedArrivalTime"`
}

type smallerSanntidData struct {
	LineId              string           `json:"lineId"`
	DestinationName     string           `json:"destinationName"`
	PublishedLineName   string           `json:"publishedLineName"`
	VehicleMode         int              `json:"vehicleMode"`
	DirectionRef        sanntidDirection `json:"directionRef"`
	ExpectedArrivalTime string           `json:"expectedArrivalTime"`
}

// Get the arrival data for a specific location ID
func GetArrivalData(locationID int) ([]smallerSanntidData, error) {
	data, err := requestArrivalData(arrivalDataUrl(locationID))
	if err != nil {
		return nil, err
	}

	transformed := transformArrivalData(parseArrivalData(data))

	return transformed, nil
}

// Transform Ruter response to smaller respons
func transformArrivalData(departures []ArrivalData) []smallerSanntidData {
	arrivals := make([]smallerSanntidData, 0)

	for _, d := range departures {
		mvj := d.MonitoredVehicleJourney

		s := smallerSanntidData{
			DestinationName:     mvj.DestinationName,
			PublishedLineName:   mvj.PublishedLineName,
			VehicleMode:         mvj.VehicleMode,
			DirectionRef:        mvj.DirectionRef,
			ExpectedArrivalTime: mvj.MonitoredCall.ExpectedArrivalTime,
			LineId:              d.MonitoringRef,
		}

		arrivals = append(arrivals, s)
	}

	if len(arrivals) > 6 {
		return arrivals[:6]
	}

	return arrivals
}

// Construct the arrival data URL
func arrivalDataUrl(locationID int) string {
	// TODO: Support spesifying direction
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

func parseArrivalData(content []byte) []ArrivalData {
	var data []ArrivalData

	json.Unmarshal(content, &data)

	return data
}
