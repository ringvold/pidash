module Api exposing (getForecast, getStopPlace, getStopPlaces, getStops)

import Data.Entur as Entur
import Data.LineStop exposing (..)
import Data.Weather exposing (decodeForecast)
import Graphql.Http
import Http
import Msg exposing (Msg(..))
import RemoteData exposing (RemoteData(..), WebData)



-- API/HTTP


getStopPlace : LineStop -> Cmd Msg
getStopPlace lineStop =
    Entur.query lineStop.id
        |> Graphql.Http.queryRequest "https://api.entur.org/journeyplanner/2.0/index/graphql"
        |> Graphql.Http.withHeader "ET-Client-Name" "github.com/ringvold/pidash-default_client_name"
        |> Graphql.Http.send RemoteData.fromResult
        |> Cmd.map (StopPlaceReceived lineStop.id lineStop.quay)


getStopPlaces : List LineStop -> Cmd Msg
getStopPlaces stops =
    List.map getStopPlace stops
        |> Cmd.batch


getStops : Cmd Msg
getStops =
    Http.get
        "/ruter/selectedStops"
        decodeStops
        |> RemoteData.sendRequest
        |> Cmd.map StopsReceived


getForecast : Cmd Msg
getForecast =
    Http.get "/weather/forecast" decodeForecast
        |> RemoteData.sendRequest
        |> Cmd.map ForecastReceived
