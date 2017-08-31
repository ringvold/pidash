module Api exposing (getDeparture, getStops)

import Http
import RemoteData exposing (WebData, RemoteData(..))
import Msg exposing (Msg(..))
import Data.VehicleArrivalTime exposing (..)
import Data.Stop exposing (..)


-- API/HTTP


baseUrl : String
baseUrl =
    "http://localhost:8081/ruter"


getStops : Cmd Msg
getStops =
    Http.get
        (baseUrl
            ++ "/selectedStops"
        )
        decodeStops
        |> RemoteData.sendRequest
        |> Cmd.map StopsReceived


getDeparture : LineStop -> Cmd Msg
getDeparture stop =
    let
        url =
            baseUrl ++ "/sanntid/" ++ toString stop.id
    in
        Http.get url decodeArrivals
            |> RemoteData.sendRequest
            |> Cmd.map (DeparturesReceived stop.id stop.direction)
