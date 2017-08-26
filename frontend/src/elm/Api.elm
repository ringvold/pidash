module Api exposing (getDeparture)

import Http
import Json.Decode as Json exposing (Decoder, decodeValue, succeed, string, int, field)
import Json.Decode.Extra exposing ((|:), date)
import Json.Decode
import RemoteData exposing (WebData, RemoteData(..))
import Types exposing (..)
import Msg exposing (Msg(..))


-- API/HTTP


baseUrl : String
baseUrl =
    "http://localhost:8081/ruter/sanntid/"


getDeparture : LineStop -> Cmd Msg
getDeparture stop =
    let
        url =
            baseUrl ++ toString stop.id
    in
        Http.get url decodeResponse
            |> RemoteData.sendRequest
            |> Cmd.map (DeparturesReceived stop.id stop.direction)


decodeResponse : Json.Decoder (List VehicleArrivalTime)
decodeResponse =
    Json.list vehicleArrivalTime


vehicleArrivalTime : Json.Decoder VehicleArrivalTime
vehicleArrivalTime =
    succeed VehicleArrivalTime
        |: (field "destinationName" string)
        |: (field "publishedLineName" string)
        |: (field "vehicleMode" int)
        |: (field "directionRef" string |> Json.Decode.andThen decodeDirection)
        |: (field "expectedArrivalTime" date)
        |: (field "lineId" int)


decodeDirection : String -> Decoder Direction
decodeDirection status =
    succeed (convertDirection status)


convertDirection : String -> Direction
convertDirection directionString =
    case directionString of
        "1" ->
            A

        "2" ->
            B

        _ ->
            Unknown
