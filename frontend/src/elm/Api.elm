module Api exposing (getDeparture, getStops, getForecast)

import Http
import RemoteData exposing (WebData, RemoteData(..))
import Msg exposing (Msg(..))
import Data.VehicleArrivalTime exposing (..)
import Data.LineStop exposing (..)
import Data.Weather exposing (decodeForecast)


-- API/HTTP


getStops : Cmd Msg
getStops =
    Http.get
        "/ruter/selectedStops"
        decodeStops
        |> RemoteData.sendRequest
        |> Cmd.map StopsReceived


getDeparture : LineStop -> Cmd Msg
getDeparture stop =
    let
        url =
            "/ruter/sanntid/" ++ stop.id
    in
        Http.get url decodeArrivals
            |> RemoteData.sendRequest
            |> Cmd.map (DeparturesReceived stop.id stop.direction)


getForecast : Cmd Msg
getForecast =
    Http.get "/weather/forecast" decodeForecast
        |> RemoteData.sendRequest
        |> Cmd.map ForecastReceived
