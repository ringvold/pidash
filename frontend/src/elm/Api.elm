module Api exposing (getDeparture, getForecast, getStopPlace, getStopPlaces, getStops)

import Data.LineStop exposing (..)
import Data.StopPlace as StopPlace
import Data.VehicleArrivalTime exposing (..)
import Data.Weather exposing (decodeForecast)
import Graphql.Http
import Http
import Msg exposing (Msg(..))
import RemoteData exposing (RemoteData(..), WebData)



-- API/HTTP


getStopPlace : String -> Cmd Msg
getStopPlace id =
    StopPlace.query id
        |> Graphql.Http.queryRequest "https://api.entur.org/journeyplanner/2.0/index/graphql"
        |> Graphql.Http.withHeader "ET-Client-Name" "github.com/ringvold/pidash-default_client_name"
        |> Graphql.Http.send (RemoteData.fromResult >> StopReceived id)


getStopPlaces : List String -> Cmd Msg
getStopPlaces ids =
    List.map getStopPlace ids
        |> Cmd.batch


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
