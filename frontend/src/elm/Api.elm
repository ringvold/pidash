module Api exposing (getDeparture, getStops, getForecast)

import Http
import RemoteData exposing (WebData, RemoteData(..))
import Msg exposing (Msg(..))
import Data.VehicleArrivalTime exposing (..)
import Data.LineStop exposing (..)
import Data.Weather exposing (decodeForecast)


-- API/HTTP


baseUrl : String
baseUrl =
    "http://localhost:8081"


getStops : Cmd Msg
getStops =
    Http.get
        (baseUrl
            ++ "/ruter/selectedStops"
        )
        decodeStops
        |> RemoteData.sendRequest
        |> Cmd.map StopsReceived


getDeparture : LineStop -> Cmd Msg
getDeparture stop =
    let
        url =
            baseUrl ++ "/ruter/sanntid/" ++ stop.id
    in
        Http.get url decodeArrivals
            |> RemoteData.sendRequest
            |> Cmd.map (DeparturesReceived stop.id stop.direction)


getForecast : Cmd Msg
getForecast =
    Http.get (baseUrl ++ "/weather/forecast") decodeForecast
        |> RemoteData.sendRequest
        |> Cmd.map ForecastReceived
