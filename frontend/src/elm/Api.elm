module Api exposing (getDeparture, getStops)

import Http
import Json.Decode as Json exposing (Decoder, decodeValue, succeed, string, int, field)
import Json.Decode.Extra exposing ((|:), date)
import Json.Decode as Decode
import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (..)
import Msg exposing (Msg(..))


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


decodeStops : Json.Decoder (List LineStop)
decodeStops =
    Decode.list
        (Decode.map4 LineStop
            (Decode.field "name" Decode.string)
            (Decode.field "id" int)
            (Decode.field "direction" int |> Decode.andThen decodeDirection)
            (Decode.succeed RemoteData.NotAsked)
        )


getDeparture : LineStop -> Cmd Msg
getDeparture stop =
    let
        url =
            baseUrl ++ "/sanntid/" ++ toString stop.id
    in
        Http.get url decodeArrivals
            |> RemoteData.sendRequest
            |> Cmd.map (DeparturesReceived stop.id stop.direction)


decodeArrivals : Json.Decoder (List VehicleArrivalTime)
decodeArrivals =
    Json.list vehicleArrivalTime


vehicleArrivalTime : Json.Decoder VehicleArrivalTime
vehicleArrivalTime =
    succeed VehicleArrivalTime
        |: (field "destinationName" string)
        |: (field "publishedLineName" string)
        |: (field "vehicleMode" int)
        |: (field "directionRef" int |> Decode.andThen decodeDirection)
        |: (field "expectedArrivalTime" date)
        |: (field "lineId" int)


decodeDirection : Int -> Decoder Direction
decodeDirection direction =
    succeed (convertDirection direction)


convertDirection : Int -> Direction
convertDirection directionString =
    case directionString of
        1 ->
            A

        2 ->
            B

        _ ->
            Unknown
