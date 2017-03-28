module Api exposing (getDeparture)

import Http
import Json.Decode as Json exposing (Decoder, decodeValue, succeed, string, int, field)
import Json.Decode.Extra exposing ((|:), date)
import Json.Decode
import Types exposing (..)
import Msg exposing (Msg(..))


-- API/HTTP


getDeparture : LineStop -> String -> Cmd Msg
getDeparture stop baseUrl =
    let
        url =
            baseUrl ++ toString stop.id
    in
        Http.send
            DeparturesReceived
            (Http.get url decodeResponse)


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
    succeed (departureDirection status)


departureDirection : String -> Direction
departureDirection direction =
    case direction of
        "1" ->
            A

        "2" ->
            B

        _ ->
            All
