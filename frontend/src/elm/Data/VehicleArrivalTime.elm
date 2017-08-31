module Data.VehicleArrivalTime exposing (..)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, string, int, field)
import Json.Decode.Extra exposing ((|:), date)
import Data.Direction exposing (Direction, decodeDirection)


type alias VehicleArrivalTime =
    { destinationName : String
    , publishedLineName : String
    , vehicleMode : Int
    , direction : Direction
    , expectedArrivalTime : Date
    , lineId : Int
    }


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
