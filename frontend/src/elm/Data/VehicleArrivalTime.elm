module Data.VehicleArrivalTime exposing (..)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, string, int, field)
import Json.Decode.Extra exposing ((|:), date)


type alias VehicleArrivalTime =
    { destinationName : String
    , publishedLineName : String
    , vehicleMode : Int
    , direction : Direction
    , expectedArrivalTime : Date
    , lineId : Int
    }


type Direction
    = A
    | B
    | Unknown


decodeArrivals : Decode.Decoder (List VehicleArrivalTime)
decodeArrivals =
    Decode.list vehicleArrivalTime


vehicleArrivalTime : Decode.Decoder VehicleArrivalTime
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


directionToComparable : Direction -> String
directionToComparable direction =
    case direction of
        A ->
            "A"

        B ->
            "B"

        _ ->
            "Unknown"


stringToDirection : String -> Direction
stringToDirection directionString =
    case directionString of
        "A" ->
            A

        "B" ->
            B

        _ ->
            Unknown
